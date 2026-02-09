import QtQuick
import "../"

Rectangle {
    id: root

    property string icon: ""
    property real iconSize: Style.fontL
    property color iconColor: Theme.text
    property color bgColor: Theme.cardBg
    property color hoverColor: Theme.hoverBg
    property string tooltip: ""

    signal clicked

    implicitWidth: Style.widgetSize
    implicitHeight: Style.widgetSize
    radius: Style.radiusS
    color: mouseArea.containsMouse ? hoverColor : bgColor
    border.color: Theme.cardBorder
    border.width: Style.borderS

    opacity: enabled ? 1.0 : Style.opacityDim

    Behavior on color {
        ColorAnimation {
            duration: Style.animFast
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.fontFamily
        font.pointSize: root.iconSize
        color: mouseArea.containsMouse ? Theme.onHover : root.iconColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
