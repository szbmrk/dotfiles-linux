import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "claude-usage";
const PROVIDER = "claude-code";
const USAGE_URL = "https://api.anthropic.com/api/oauth/usage";
const FETCH_INTERVAL_MS = 5 * 60_000;
const MIN_FETCH_GAP_MS = 60_000;
const REPAINT_INTERVAL_MS = 60_000;
const REQUEST_TIMEOUT_MS = 10_000;

interface UsageWindow {
  usedPercent: number;
  resetsAt: number | undefined;
}

interface Usage {
  fiveHour: UsageWindow | undefined;
  sevenDay: UsageWindow | undefined;
}

type Theme = ExtensionContext["ui"]["theme"];
type Paint = (text: string) => string;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function credentialsPath(): string {
  const configDir =
    process.env.PI_CLAUDE_CODE_CONFIG_DIR ?? process.env.CLAUDE_CONFIG_DIR ?? join(homedir(), ".claude");
  return join(configDir, ".credentials.json");
}

async function readAccessToken(): Promise<string | undefined> {
  const parsed: unknown = JSON.parse(await readFile(credentialsPath(), "utf8"));
  if (!isRecord(parsed) || !isRecord(parsed.claudeAiOauth)) return undefined;
  const { accessToken, expiresAt } = parsed.claudeAiOauth;
  if (typeof accessToken !== "string") return undefined;
  if (typeof expiresAt === "number" && expiresAt <= Date.now()) return undefined;
  return accessToken;
}

function parseWindow(value: unknown): UsageWindow | undefined {
  if (!isRecord(value) || typeof value.utilization !== "number") return undefined;
  const resetsAt = typeof value.resets_at === "string" ? Date.parse(value.resets_at) : Number.NaN;
  return {
    usedPercent: value.utilization,
    resetsAt: Number.isNaN(resetsAt) ? undefined : resetsAt,
  };
}

async function fetchUsage(signal: AbortSignal): Promise<Usage | undefined> {
  const token = await readAccessToken();
  if (token === undefined) return undefined;
  const response = await fetch(USAGE_URL, {
    headers: {
      Authorization: `Bearer ${token}`,
      "anthropic-beta": "oauth-2025-04-20",
    },
    redirect: "error",
    signal,
  });
  if (!response.ok) return undefined;
  const body: unknown = await response.json();
  if (!isRecord(body)) return undefined;
  return { fiveHour: parseWindow(body.five_hour), sevenDay: parseWindow(body.seven_day) };
}

function countdown(resetsAt: number): string {
  const mins = Math.floor((resetsAt - Date.now()) / 60_000);
  if (mins <= 0) return "";
  if (mins < 60) return `${mins}m`;
  if (mins < 1440) return `${Math.floor(mins / 60)}h${mins % 60}m`;
  return `${Math.floor(mins / 1440)}d${Math.floor((mins % 1440) / 60)}h`;
}

function levelColor(theme: Theme, percentLeft: number): Paint {
  if (percentLeft < 15) return (text) => theme.fg("error", text);
  if (percentLeft < 40) return (text) => theme.fg("warning", text);
  return (text) => theme.fg("mdCode", text);
}

function formatWindow(theme: Theme, label: string, window: UsageWindow | undefined): string | undefined {
  if (window === undefined) return undefined;
  const left = Math.round(100 - window.usedPercent);
  const reset = window.resetsAt === undefined ? "" : countdown(window.resetsAt);
  return (
    theme.fg("muted", `${label} `) +
    levelColor(theme, left)(`${left}%`) +
    (reset === "" ? "" : theme.fg("accent", ` ${reset}`))
  );
}

function formatUsage(theme: Theme, usage: Usage): string | undefined {
  const parts = [
    formatWindow(theme, "5h", usage.fiveHour),
    formatWindow(theme, "7d", usage.sevenDay),
  ].filter((part): part is string => part !== undefined);
  return parts.length === 0 ? undefined : parts.join(theme.fg("borderMuted", " │ "));
}

export default function claudeUsageStatusExtension(pi: ExtensionAPI) {
  let usage: Usage | undefined;
  let lastFetchAt = 0;
  let inFlight: AbortController | undefined;
  let fetchTimer: ReturnType<typeof setInterval> | undefined;
  let repaintTimer: ReturnType<typeof setInterval> | undefined;
  let activeCtx: ExtensionContext | undefined;

  const isActive = (ctx: ExtensionContext) => ctx.hasUI && ctx.model?.provider === PROVIDER;

  const render = () => {
    if (activeCtx === undefined) return;
    const text = isActive(activeCtx) && usage !== undefined ? formatUsage(activeCtx.ui.theme, usage) : undefined;
    activeCtx.ui.setStatus(STATUS_KEY, text);
  };

  const refresh = async (force: boolean) => {
    if (activeCtx === undefined || !isActive(activeCtx) || inFlight !== undefined) return;
    if (!force && Date.now() - lastFetchAt < MIN_FETCH_GAP_MS) return;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    inFlight = controller;
    try {
      const next = await fetchUsage(controller.signal);
      lastFetchAt = Date.now();
      if (next !== undefined) usage = next;
    } catch {
      // Keep the last known values; the endpoint is undocumented and may fail transiently.
    } finally {
      clearTimeout(timeout);
      inFlight = undefined;
    }
    render();
  };

  const stopTimers = () => {
    clearInterval(fetchTimer);
    clearInterval(repaintTimer);
    fetchTimer = undefined;
    repaintTimer = undefined;
  };

  pi.on("session_start", async (_event, ctx) => {
    activeCtx = ctx;
    stopTimers();
    fetchTimer = setInterval(() => void refresh(true), FETCH_INTERVAL_MS);
    repaintTimer = setInterval(render, REPAINT_INTERVAL_MS);
    render();
    void refresh(true);
  });

  pi.on("model_select", async (_event, ctx) => {
    activeCtx = ctx;
    render();
    void refresh(false);
  });

  pi.on("agent_settled", async (_event, ctx) => {
    activeCtx = ctx;
    void refresh(false);
  });

  pi.on("session_shutdown", async () => {
    stopTimers();
    inFlight?.abort();
    activeCtx?.ui.setStatus(STATUS_KEY, undefined);
    activeCtx = undefined;
  });
}
