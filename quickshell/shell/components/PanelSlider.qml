import QtQuick
import QtQuick.Controls
import "../"

Slider {
    id: root

    property color fillColor: Theme.primary
    property string tooltipText: ""

    implicitHeight: 28
    padding: 0

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 8
        radius: 4
        color: Theme.surface1

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: root.enabled ? root.fillColor : Theme.overlay0
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8
        color: root.pressed ? Qt.lighter(root.fillColor, 1.2) : root.fillColor
        border.color: Theme.surface0
        border.width: 2

        Behavior on color {
            ColorAnimation {
                duration: Style.animFast
            }
        }
    }

    ToolTip {
        parent: root.handle
        visible: root.pressed && root.tooltipText !== ""
        text: root.tooltipText
        delay: 0
    }
}
