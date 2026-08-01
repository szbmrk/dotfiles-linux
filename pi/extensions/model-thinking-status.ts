const WIDGET_KEY = "model-thinking-status";
const CATPPUCCIN_MOCHA_BLUE = "\u001b[38;2;137;180;250m";
const ANSI_RESET_FG = "\u001b[39m";

function modelIdOf(model: unknown): string {
  if (typeof model !== "object" || model === null) return "no-model";
  const value = (model as { id?: unknown }).id;
  return typeof value === "string" && value.trim().length > 0
    ? value
    : "no-model";
}

function thinkingLevelOf(ctx: { thinkingLevel?: unknown }): string {
  return typeof ctx.thinkingLevel === "string" &&
    ctx.thinkingLevel.trim().length > 0
    ? ctx.thinkingLevel
    : "off";
}

function thinkingColor(level: string): string {
  switch (level) {
    case "low":
      return "success";
    case "medium":
      return "warning";
    case "high":
      return "accent";
    case "xhigh":
    case "max":
      return "error";
    case "minimal":
    case "off":
    default:
      return "muted";
  }
}

function colorModel(text: string): string {
  return CATPPUCCIN_MOCHA_BLUE + text + ANSI_RESET_FG;
}

function formatLine(ctx: {
  ui: { theme?: { fg?: (color: string, text: string) => string } };
  model?: unknown;
  thinkingLevel?: unknown;
}): string {
  const fg =
    typeof ctx.ui.theme?.fg === "function"
      ? ctx.ui.theme.fg.bind(ctx.ui.theme)
      : (_color: string, text: string) => text;

  const model = modelIdOf(ctx.model);
  const level = thinkingLevelOf(ctx);

  return colorModel(model) + fg("muted", " • ") + fg(thinkingColor(level), level);
}

function refreshWidget(ctx: {
  hasUI?: boolean;
  ui: {
    setWidget: (
      key: string,
      value: string[] | undefined,
      options?: { placement?: "aboveEditor" | "belowEditor" },
    ) => void;
    theme?: { fg?: (color: string, text: string) => string };
  };
  model?: unknown;
  thinkingLevel?: unknown;
}): void {
  if (!ctx.hasUI) return;
  ctx.ui.setWidget(WIDGET_KEY, [formatLine(ctx)], { placement: "belowEditor" });
}

function clearWidget(ctx: {
  hasUI?: boolean;
  ui: {
    setWidget: (
      key: string,
      value: string[] | undefined,
      options?: { placement?: "aboveEditor" | "belowEditor" },
    ) => void;
  };
}): void {
  if (!ctx.hasUI) return;
  ctx.ui.setWidget(WIDGET_KEY, undefined, { placement: "belowEditor" });
}

export default function modelThinkingStatusExtension(pi: {
  on: (
    event: string,
    handler: (...args: unknown[]) => Promise<unknown> | unknown,
  ) => void;
}) {
  pi.on("session_start", async (_event, ctx) => {
    refreshWidget(
      ctx as {
        hasUI?: boolean;
        ui: {
          setWidget: (
            key: string,
            value: string[] | undefined,
            options?: { placement?: "aboveEditor" | "belowEditor" },
          ) => void;
          theme?: { fg?: (color: string, text: string) => string };
        };
        model?: unknown;
        thinkingLevel?: unknown;
      },
    );
  });

  pi.on("model_select", async (_event, ctx) => {
    refreshWidget(
      ctx as {
        hasUI?: boolean;
        ui: {
          setWidget: (
            key: string,
            value: string[] | undefined,
            options?: { placement?: "aboveEditor" | "belowEditor" },
          ) => void;
          theme?: { fg?: (color: string, text: string) => string };
        };
        model?: unknown;
        thinkingLevel?: unknown;
      },
    );
  });

  pi.on("thinking_level_select", async (_event, ctx) => {
    refreshWidget(
      ctx as {
        hasUI?: boolean;
        ui: {
          setWidget: (
            key: string,
            value: string[] | undefined,
            options?: { placement?: "aboveEditor" | "belowEditor" },
          ) => void;
          theme?: { fg?: (color: string, text: string) => string };
        };
        model?: unknown;
        thinkingLevel?: unknown;
      },
    );
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    clearWidget(
      ctx as {
        hasUI?: boolean;
        ui: {
          setWidget: (
            key: string,
            value: string[] | undefined,
            options?: { placement?: "aboveEditor" | "belowEditor" },
          ) => void;
        };
      },
    );
  });
}
