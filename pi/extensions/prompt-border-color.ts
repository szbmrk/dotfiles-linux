import {
  CustomEditor,
  type ExtensionAPI,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import {
  getReadonlyEnabled,
  subscribeReadonlyState,
} from "./readonly/state.ts";

const PLANNOTATOR_STATUS_KEY = "plannotator";

const PURPLE = "\u001b[38;2;180;190;254m";
const YELLOW = "\u001b[38;2;249;226;175m";
const RESET = "\u001b[39m";

type BorderAwareEditor = {
  borderColor: (text: string) => string;
};

type EditorFactory = (
  tui: TUI,
  theme: EditorTheme,
  keybindings: KeybindingsManager,
) => unknown;

function borderColor(enabled: boolean): (text: string) => string {
  const prefix = enabled ? YELLOW : PURPLE;
  return (text: string) => prefix + text + RESET;
}

function hasPlannotatorEnabled(ctx: {
  sessionManager?: { getEntries?: () => unknown[] };
}): boolean {
  const entries = ctx.sessionManager?.getEntries?.();
  if (!Array.isArray(entries)) return false;

  for (let index = entries.length - 1; index >= 0; index -= 1) {
    const entry = entries[index];
    if (typeof entry !== "object" || entry === null) continue;

    const typedEntry = entry as {
      type?: unknown;
      customType?: unknown;
      data?: { phase?: unknown };
    };

    if (
      typedEntry.type !== "custom" ||
      typedEntry.customType !== PLANNOTATOR_STATUS_KEY
    ) {
      continue;
    }

    return (
      typedEntry.data?.phase === "planning" ||
      typedEntry.data?.phase === "executing"
    );
  }

  return false;
}

function applyBorderColor(editor: unknown, enabled: boolean): void {
  if (typeof editor !== "object" || editor === null) return;
  if (!("borderColor" in editor)) return;

  const color = borderColor(enabled);
  const current = Object.getOwnPropertyDescriptor(editor, "borderColor");

  // InteractiveMode writes a thinking-level color after extensions start and
  // whenever a session is rebound. Keep this extension's color authoritative.
  try {
    Object.defineProperty(editor, "borderColor", {
      configurable: true,
      enumerable: current?.enumerable ?? true,
      get: () => color,
      set: () => {},
    });
  } catch {
    // Custom editors that do not allow redefining the property still retain the
    // best-effort behavior used before this guard was added.
    (editor as BorderAwareEditor).borderColor = color;
  }
}

class PromptBorderEditor extends CustomEditor {
  declare borderColor: (text: string) => string;

  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings);
    this.borderColor = borderColor(getReadonlyEnabled());
  }
}

export default function promptBorderColorExtension(pi: ExtensionAPI) {
  let activeTui: TUI | undefined;
  const activeEditors = new Set<unknown>();
  let unsubscribeReadonly: (() => void) | undefined;
  let restoreEditorComponent: (() => void) | undefined;
  let plannotatorEnabled = false;

  const isHighlighted = () => getReadonlyEnabled() || plannotatorEnabled;

  const repaint = () => {
    const enabled = isHighlighted();
    for (const editor of activeEditors) {
      applyBorderColor(editor, enabled);
    }
    activeTui?.requestRender();
  };

  let initialRepaintTimer: ReturnType<typeof setTimeout> | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (initialRepaintTimer) clearTimeout(initialRepaintTimer);
    restoreEditorComponent?.();
    restoreEditorComponent = undefined;
    unsubscribeReadonly?.();
    activeEditors.clear();
    plannotatorEnabled = hasPlannotatorEnabled(ctx);

    const originalSetStatus = ctx.ui.setStatus.bind(ctx.ui);
    ctx.ui.setStatus = (key, value) => {
      originalSetStatus(key, value);
      if (key !== PLANNOTATOR_STATUS_KEY) return;
      plannotatorEnabled = typeof value === "string" && value.length > 0;
      repaint();
    };

    const previous = ctx.ui.getEditorComponent() as EditorFactory | undefined;
    const originalSetEditorComponent = ctx.ui.setEditorComponent;
    const setEditorComponent = originalSetEditorComponent.bind(ctx.ui);

    // Image Paste installs its own CustomEditor in its session_start handler.
    // Extension load order is not a stable composition mechanism, so wrap both
    // an editor already registered before us and every editor registered later.
    const withBorder = (factory: EditorFactory): EditorFactory =>
      (tui, theme, keybindings) => {
        activeTui = tui;
        const editor = factory(tui, theme, keybindings);
        activeEditors.add(editor);
        applyBorderColor(editor, isHighlighted());
        return editor;
      };

    const defaultEditorFactory: EditorFactory = (tui, theme, keybindings) =>
      new PromptBorderEditor(tui, theme, keybindings);
    setEditorComponent(
      withBorder(previous ?? defaultEditorFactory) as never,
    );

    // Keep the border wrapper when an extension that starts later replaces the
    // editor (currently pi-image-paste). Preserve `undefined`, which restores
    // Pi's default editor during extension shutdown.
    const borderSetter = ((factory: EditorFactory | undefined) => {
      setEditorComponent(factory ? (withBorder(factory) as never) : undefined);
    }) as typeof ctx.ui.setEditorComponent;
    ctx.ui.setEditorComponent = borderSetter;
    restoreEditorComponent = () => {
      if (ctx.ui.setEditorComponent === borderSetter) {
        ctx.ui.setEditorComponent = originalSetEditorComponent;
      }
    };

    unsubscribeReadonly = subscribeReadonlyState(() => {
      repaint();
    });

    repaint();

    // Pi applies the initial thinking-level border after session_start completes.
    // A timer runs after that startup continuation and restores our border.
    initialRepaintTimer = setTimeout(() => {
      initialRepaintTimer = undefined;
      repaint();
    }, 0);
  });

  // Pi applies its thinking-level border after emitting these events. Defer our
  // repaint so the readonly color remains authoritative.
  const restoreReadonlyBorder = () => {
    queueMicrotask(() => repaint());
  };

  pi.on("model_select", restoreReadonlyBorder);
  pi.on("thinking_level_select", restoreReadonlyBorder);

  pi.on("session_shutdown", () => {
    if (initialRepaintTimer) clearTimeout(initialRepaintTimer);
    initialRepaintTimer = undefined;
    restoreEditorComponent?.();
    restoreEditorComponent = undefined;
    unsubscribeReadonly?.();
    unsubscribeReadonly = undefined;
    activeEditors.clear();
    activeTui = undefined;
    plannotatorEnabled = false;
  });
}
