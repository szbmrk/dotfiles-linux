import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property bool btOn: false

    text: btOn ? "󰂯" : "󰂲"
    font.family: Theme.fontFamily
    font.pixelSize: 20
    font.weight: Theme.fontWeight
    color: Theme.blue

    Process {
        id: btStatusProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.btOn = this.text.trim() === "yes"
        }
    }

    Process {
        id: btToggleProc
        command: ["bluetoothctl", "power", "on"]
        onRunningChanged: {
            if (!running) btStatusProc.running = true;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: btStatusProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                btToggleProc.command = ["bluetoothctl", "power", btOn ? "off" : "on"];
                btToggleProc.running = true;
            } else {
                PanelManager.toggleById("bluetoothPanel");
            }
        }
    }
}
