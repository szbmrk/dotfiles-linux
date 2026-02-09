import QtQuick
import "../"

// Icon text element using Nerd Font glyphs
Text {
    id: root

    property real pointSize: Style.fontL

    font.family: Theme.fontFamily
    font.pointSize: Math.max(1, pointSize)
    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
