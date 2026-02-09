import QtQuick
import "../"

Item {
    id: root

    property bool checked: false
    property string label: ""

    signal toggled(bool checked)

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(labelText.implicitHeight, switchBg.implicitHeight)

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginM

        Text {
            id: labelText
            visible: root.label !== ""
            text: root.label
            font.family: Theme.fontFamilyUI
            font.pointSize: Style.fontM
            font.weight: Style.weightMedium
            color: Theme.text
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: switchBg
            implicitWidth: 40
            implicitHeight: 22
            radius: 11
            color: root.checked ? Theme.primary : Theme.surface1
            border.color: root.checked ? Theme.primary : Theme.overlay0
            border.width: Style.borderS
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                ColorAnimation {
                    duration: Style.animFast
                }
            }

            Rectangle {
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: root.checked ? Theme.onPrimary : Theme.text
                anchors.verticalCenter: parent.verticalCenter
                x: root.checked ? parent.width - width - 3 : 3

                Behavior on x {
                    NumberAnimation {
                        duration: Style.animFast
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.checked = !root.checked;
                    root.toggled(root.checked);
                }
            }
        }
    }
}
