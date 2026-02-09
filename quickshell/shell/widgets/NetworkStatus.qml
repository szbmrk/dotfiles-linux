import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property string statusText: "..."
    property color statusColor: Theme.yellow

    text: statusText
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: statusColor

    Process {
        id: networkProc
        command: ["bash", "-c", "sig=$(nmcli -t -f active,signal dev wifi 2>/dev/null | grep ^yes | cut -d: -f2);" + " if [ -n \"$sig\" ]; then echo wifi:$sig;" + " elif nmcli -t -f type,state dev 2>/dev/null | grep -q ethernet:connected; then echo eth:0;" + " else echo off:0; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim().split(":");
                if (p[0] === "wifi") {
                    root.statusText = "󰤨 " + p[1] + "%";
                    root.statusColor = Theme.yellow;
                } else if (p[0] === "eth") {
                    root.statusText = " eth";
                    root.statusColor = Theme.yellow;
                } else {
                    root.statusText = " disconnected";
                    root.statusColor = Theme.red;
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: networkProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggleById("networkPanel")
    }
}
