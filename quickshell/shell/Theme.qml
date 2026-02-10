pragma Singleton

import Quickshell
import QtQuick

// Catppuccin Mocha — static theme
Singleton {
    // ── Base colors ──
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay2: "#9399b2"

    // ── Text ──
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color subtext1: "#bac2de"

    // ── Accent colors ──
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo: "#f2cdcd"
    readonly property color pink: "#f5c2e7"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color maroon: "#eba0ac"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color sky: "#89dceb"
    readonly property color sapphire: "#74c7ec"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"

    // ── Semantic aliases (panel system) ──
    readonly property color primary: blue
    readonly property color onPrimary: base
    readonly property color secondary: mauve
    readonly property color onSecondary: base
    readonly property color error: red
    readonly property color onError: base

    readonly property color panelBg: Qt.rgba(24 / 255, 24 / 255, 37 / 255, 0.95)       // mantle with alpha
    readonly property color cardBg: surface0
    readonly property color cardBorder: Qt.rgba(69 / 255, 71 / 255, 90 / 255, 0.6)      // surface1 with alpha
    readonly property color hoverBg: surface1
    readonly property color onHover: text

    // ── Bar ──
    readonly property color barBg: Qt.rgba(30 / 255, 30 / 255, 46 / 255, 0.95)
    readonly property color pillBg: Qt.rgba(17 / 255, 17 / 255, 27 / 255, 0.9)

    // ── Font ──
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property string fontFamilyUI: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: Quickshell.env("QS_FONT_SIZE")
    readonly property int fontWeight: 700
}
