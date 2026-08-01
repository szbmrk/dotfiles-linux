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

const PURPLE = "\u001b[38;2;203;166;247m";
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
  constructor(
    tui: TUI,
    theme: EditorTheme,
    keybindings: KeybindingsManager,
  ) {
    super(tui, theme, keybindings);
    this.borderColor = borderColor(getReadonlyEnabled());
  }
}

export default function promptBorderColorExtension(pi: ExtensionAPI) {
  let activeTui: TUI | undefined;
  const activeEditors = new Set<unknown>();
  let unsubscribeReadonly: (() => void) | undefined;

  const repaint = (enabled: boolean) => {
    for (const editor of activeEditors) {
      applyBorderColor(editor, enabled);
    }
    activeTui?.requestRender();
  };

  let initialRepaintTimer: ReturnType<typeof setTimeout> | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (initialRepaintTimer) clearTimeout(initialRepaintTimer);
    unsubscribeReadonly?.();
    activeEditors.clear();

    const previous = ctx.ui.getEditorComponent() as EditorFactory | undefined;
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      activeTui = tui;
      const editor = previous?.(tui, theme, keybindings) ?? new PromptBorderEditor(tui, theme, keybindings);
      activeEditors.add(editor);
      applyBorderColor(editor, getReadonlyEnabled());
      return editor as never;
    });

    unsubscribeReadonly = subscribeReadonlyState((enabled) => {
      repaint(enabled);
    });

    repaint(getReadonlyEnabled());

    // Pi applies the initial thinking-level border after session_start completes.
    // A timer runs after that startup continuation and restores our border.
    initialRepaintTimer = setTimeout(() => {
      initialRepaintTimer = undefined;
      repaint(getReadonlyEnabled());
    }, 0);
  });

  // Pi applies its thinking-level border after emitting these events. Defer our
  // repaint so the readonly color remains authoritative.
  const restoreReadonlyBorder = () => {
    queueMicrotask(() => repaint(getReadonlyEnabled()));
  };

  pi.on("model_select", restoreReadonlyBorder);
  pi.on("thinking_level_select", restoreReadonlyBorder);

  pi.on("session_shutdown", () => {
    if (initialRepaintTimer) clearTimeout(initialRepaintTimer);
    initialRepaintTimer = undefined;
    unsubscribeReadonly?.();
    unsubscribeReadonly = undefined;
    activeEditors.clear();
    activeTui = undefined;
  });
}
