import QtQuick
import "../"

Text {
    id: root

    property real pointSize: Style.fontM

    font.family: Theme.fontFamilyUI
    font.pointSize: Math.max(1, pointSize)
    font.weight: Style.weightMedium
    color: Theme.text
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
