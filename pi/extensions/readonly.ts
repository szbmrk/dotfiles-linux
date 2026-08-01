const STATUS_KEY = "readonly";
const ENTRY_TYPE = "readonly-mode";
const DEFAULT_SESSION_KEY = "__readonly_default_session__";

const READONLY_ALLOWLIST = [
  "read",
  "ls",
  "glob",
  "grep",
  "find",
  "fffind",
  "fffgrep",
  "context7_resolve-library-id",
  "context7_query-docs",
  "web_search",
  "bash",
];

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function normalizeToolList(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const tools = value.filter((tool): tool is string => typeof tool === "string" && tool.trim().length > 0);
  return tools.length > 0 ? [...new Set(tools)] : [];
}

function getSessionKey(ctx: {
  sessionManager?: { getSessionId?: () => string | undefined };
}): string {
  const sessionId = ctx.sessionManager?.getSessionId?.();
  return typeof sessionId === "string" && sessionId.trim().length > 0
    ? sessionId
    : DEFAULT_SESSION_KEY;
}

function readPersistedState(ctx: {
  sessionManager?: { getEntries?: () => unknown[] };
}): { enabled: boolean; savedActiveTools: string[] | null } {
  const entries = ctx.sessionManager?.getEntries?.();
  if (!Array.isArray(entries)) {
    return { enabled: false, savedActiveTools: null };
  }

  for (let index = entries.length - 1; index >= 0; index -= 1) {
    const entry = entries[index];
    if (!isRecord(entry) || entry.type !== "custom" || entry.customType !== ENTRY_TYPE) {
      continue;
    }

    const data = isRecord(entry.data) ? entry.data : null;
    if (!data) break;

    return {
      enabled: data.enabled === true,
      savedActiveTools: normalizeToolList(data.savedActiveTools),
    };
  }

  return { enabled: false, savedActiveTools: null };
}

function persistState(
  pi: { appendEntry: (customType: string, data?: Record<string, unknown>) => void },
  state: { enabled: boolean; savedActiveTools: string[] | null },
): void {
  pi.appendEntry(ENTRY_TYPE, {
    enabled: state.enabled,
    savedActiveTools: state.savedActiveTools,
  });
}

function installedToolNames(pi: { getAllTools: () => Array<{ name?: string }> }): Set<string> {
  return new Set(
    pi
      .getAllTools()
      .map((tool) => (typeof tool?.name === "string" ? tool.name : ""))
      .filter((tool) => tool.length > 0),
  );
}

function filterInstalledTools(
  pi: { getAllTools: () => Array<{ name?: string }> },
  tools: readonly string[],
): string[] {
  const installed = installedToolNames(pi);
  return [...new Set(tools)].filter((tool) => installed.has(tool));
}

function readonlyTools(pi: { getAllTools: () => Array<{ name?: string }> }): string[] {
  return filterInstalledTools(pi, READONLY_ALLOWLIST);
}

function statusText(ctx: {
  ui: {
    theme?: { fg?: (color: string, text: string) => string };
    setStatus: (key: string, value: string | undefined) => void;
  };
}, enabled: boolean): void {
  if (!enabled) {
    ctx.ui.setStatus(STATUS_KEY, undefined);
    return;
  }

  const label = "🔒 readonly";
  const colored = typeof ctx.ui.theme?.fg === "function"
    ? ctx.ui.theme.fg("warning", label)
    : label;
  ctx.ui.setStatus(STATUS_KEY, colored);
}

function usage(): string {
  return "Usage: /readonly [toggle|on|off|status]";
}

export default function readonlyExtension(pi: {
  on: (event: string, handler: (...args: unknown[]) => Promise<unknown> | unknown) => void;
  registerCommand: (
    name: string,
    options: { description: string; handler: (...args: unknown[]) => Promise<void> | void },
  ) => void;
  getActiveTools: () => string[];
  setActiveTools: (names: string[]) => void;
  getAllTools: () => Array<{ name?: string }>;
  appendEntry: (customType: string, data?: Record<string, unknown>) => void;
}) {
  const sessionState = new Map<string, { enabled: boolean; savedActiveTools: string[] | null }>();

  function currentState(ctx: { sessionManager?: { getSessionId?: () => string | undefined; getEntries?: () => unknown[] } }) {
    const key = getSessionKey(ctx);
    const cached = sessionState.get(key);
    if (cached) return { key, state: cached };
    const restored = readPersistedState(ctx);
    sessionState.set(key, restored);
    return { key, state: restored };
  }

  function updateState(
    key: string,
    state: { enabled: boolean; savedActiveTools: string[] | null },
  ): void {
    sessionState.set(key, state);
    persistState(pi, state);
  }

  function enableReadonly(
    ctx: {
      ui: {
        notify: (message: string, level?: string) => void;
        setStatus: (key: string, value: string | undefined) => void;
        theme?: { fg?: (color: string, text: string) => string };
      };
      sessionManager?: { getSessionId?: () => string | undefined; getEntries?: () => unknown[] };
    },
    options: { notify?: boolean; preserveCurrentTools?: boolean } = {},
  ): void {
    const { key, state } = currentState(ctx);
    const nextSavedTools = state.enabled
      ? state.savedActiveTools
      : options.preserveCurrentTools === false
        ? state.savedActiveTools
        : [...pi.getActiveTools()];
    const nextState = {
      enabled: true,
      savedActiveTools: nextSavedTools,
    };

    pi.setActiveTools(readonlyTools(pi));
    updateState(key, nextState);
    statusText(ctx, true);

    if (options.notify !== false) {
      ctx.ui.notify("Readonly mode enabled. Mutating tools removed; bash now asks for approval every run.", "info");
    }
  }

  function disableReadonly(
    ctx: {
      ui: {
        notify: (message: string, level?: string) => void;
        setStatus: (key: string, value: string | undefined) => void;
        theme?: { fg?: (color: string, text: string) => string };
      };
      sessionManager?: { getSessionId?: () => string | undefined; getEntries?: () => unknown[] };
    },
    options: { notify?: boolean } = {},
  ): void {
    const { key, state } = currentState(ctx);
    const restoreTools = state.savedActiveTools
      ? filterInstalledTools(pi, state.savedActiveTools)
      : null;

    if (restoreTools) {
      pi.setActiveTools(restoreTools);
    }

    updateState(key, {
      enabled: false,
      savedActiveTools: null,
    });
    statusText(ctx, false);

    if (options.notify !== false) {
      ctx.ui.notify("Readonly mode disabled. Previous tool set restored.", "info");
    }
  }

  function showStatus(ctx: {
    ui: { notify: (message: string, level?: string) => void };
    sessionManager?: { getSessionId?: () => string | undefined; getEntries?: () => unknown[] };
  }): void {
    const { state } = currentState(ctx);
    const activeReadonlyTools = readonlyTools(pi);
    const suffix = activeReadonlyTools.length > 0
      ? ` Allowed tools: ${activeReadonlyTools.join(", ")}`
      : " Allowed tools: none matched installed tools.";
    ctx.ui.notify(
      state.enabled
        ? `Readonly mode is ON.${suffix}`
        : "Readonly mode is OFF.",
      "info",
    );
  }

  pi.on("session_start", async (_event, ctx) => {
    const { key } = currentState(ctx);
    const restored = readPersistedState(ctx);
    sessionState.set(key, restored);

    if (restored.enabled) {
      enableReadonly(ctx, { notify: false, preserveCurrentTools: false });
      ctx.ui.notify("Readonly mode restored for this session.", "info");
      return;
    }

    statusText(ctx, false);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    statusText(ctx, false);
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!isRecord(event) || event.toolName !== "bash") {
      return;
    }

    const { state } = currentState(ctx);
    if (!state.enabled) {
      return;
    }

    const input = isRecord(event.input) ? event.input : null;
    const command = typeof input?.command === "string" && input.command.trim().length > 0
      ? input.command
      : "(unknown bash command)";

    if (!ctx.hasUI) {
      return {
        block: true,
        reason: "Readonly mode requires interactive approval for bash, but no UI is available.",
      };
    }

    const ok = await ctx.ui.confirm(
      "Readonly bash approval",
      `Readonly mode requires approval for each bash command.\n\n${command}`,
    );

    if (!ok) {
      return {
        block: true,
        reason: "Blocked by readonly mode.",
      };
    }
  });

  pi.registerCommand("readonly", {
    description: "Toggle read-only tool mode for this session",
    handler: async (args, ctx) => {
      const action = (args || "toggle").trim().toLowerCase();
      const normalized = action.length > 0 ? action.split(/\s+/)[0] : "toggle";

      if (normalized === "status") {
        showStatus(ctx);
        return;
      }

      const { state } = currentState(ctx);

      if (normalized === "off") {
        if (!state.enabled) {
          ctx.ui.notify("Readonly mode is already off.", "info");
          return;
        }
        disableReadonly(ctx);
        return;
      }

      if (normalized === "on") {
        if (state.enabled) {
          ctx.ui.notify("Readonly mode is already on.", "info");
          return;
        }
        enableReadonly(ctx);
        return;
      }

      if (normalized !== "toggle") {
        ctx.ui.notify(usage(), "warning");
        return;
      }

      if (state.enabled) {
        disableReadonly(ctx);
        return;
      }

      enableReadonly(ctx);
    },
  });
}
