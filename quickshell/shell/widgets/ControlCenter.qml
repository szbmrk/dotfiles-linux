import QtQuick
import "../"

// Control center bar widget — opens the control center panel on click
Text {
    id: root

    text: "\uf0c9"  // bars/hamburger menu icon
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: mouseArea.containsMouse ? Theme.primary : Theme.text

    Behavior on color { ColorAnimation { duration: 100 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggleById("controlCenter")
    }
}
