import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property bool btOn: false
    property bool btAvailable: false

    visible: btAvailable

    text: btOn ? "󰂯" : "󰂲"
    font.family: Theme.fontFamily
    font.pixelSize: 20
    font.weight: Theme.fontWeight
    color: Theme.blue

    Process {
        id: btCheckProc
        command: ["bash", "-c", "bluetoothctl list | wc -l"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.btAvailable = parseInt(this.text.trim()) > 0;
                if (root.btAvailable)
                    btStatusProc.running = true;
            }
        }
    }

    Process {
        id: btStatusProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: root.btOn = this.text.trim() === "yes"
        }
    }

    // Toggle power
    Process {
        id: btToggleProc
        command: ["bluetoothctl", "power", "on"]
        onRunningChanged: {
            if (!running)
                btStatusProc.running = true;
        }
    }

    Timer {
        interval: 5000
        running: btAvailable
        repeat: true
        onTriggered: btStatusProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        enabled: btAvailable

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                btToggleProc.command = ["bluetoothctl", "power", btOn ? "off" : "on"];
                btToggleProc.running = true;
            } else {
                PanelManager.toggleById("bluetoothPanel");
            }
        }
    }
}
