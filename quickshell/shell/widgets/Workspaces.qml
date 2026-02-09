import QtQuick
import Quickshell.Hyprland
import "../"

Rectangle {
    id: root

    implicitHeight: 26
    implicitWidth: workspacesRow.implicitWidth + 16
    radius: 12
    color: Theme.pillBg

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            const focusedWorkspace = Hyprland.focusedWorkspace;
            if (!focusedWorkspace)
                return;

            const delta = wheel.angleDelta.y;
            if (delta > 0)
                Hyprland.dispatch("workspace e+1");
            else if (delta < 0)
                Hyprland.dispatch("workspace e-1");
        }
    }

    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                required property var modelData
                implicitWidth: wsLabel.implicitWidth + 6
                implicitHeight: 26
                visible: modelData.id > 0

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text: modelData.id
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: modelData.focused ? Font.Black : Theme.fontWeight
                    color: modelData.urgent ? Theme.yellow : modelData.focused ? Theme.red : Theme.subtext0
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: modelData.activate()
                }
            }
        }
    }
}
