pragma Singleton

import Quickshell
import QtQuick

// Design tokens — sizes, spacing, radii, animation durations
Singleton {
    // ── Font sizes (pt) ──
    readonly property int fontXS: 8
    readonly property int fontS: 9
    readonly property int fontM: 10
    readonly property int fontL: 12
    readonly property int fontXL: 14
    readonly property int fontXXL: 18
    readonly property int fontXXXL: 24

    // ── Font weights ──
    readonly property int weightRegular: 400
    readonly property int weightMedium: 500
    readonly property int weightSemiBold: 600
    readonly property int weightBold: 700

    // ── Spacing / Margins ──
    readonly property int marginXXS: 2
    readonly property int marginXS: 4
    readonly property int marginS: 6
    readonly property int marginM: 8
    readonly property int marginL: 12
    readonly property int marginXL: 18

    // ── Radii ──
    readonly property int radiusXS: 4
    readonly property int radiusS: 6
    readonly property int radiusM: 10
    readonly property int radiusL: 14
    readonly property int radiusXL: 20

    // ── Borders ──
    readonly property int borderS: 1
    readonly property int borderM: 2

    // ── Sizes ──
    readonly property int barHeight: 34
    readonly property int panelWidth: 420
    readonly property int iconSize: 18
    readonly property int widgetSize: 32

    // ── Animation durations (ms) ──
    readonly property int animFast: 100
    readonly property int animNormal: 200
    readonly property int animSlow: 350

    // ── Opacity ──
    readonly property real opacityDim: 0.6
    readonly property real opacitySubtle: 0.8
}
