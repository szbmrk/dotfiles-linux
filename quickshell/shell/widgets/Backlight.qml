import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property string percent: "0"

    text: "󰃠 " + percent + "%"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: Theme.peach

    Process {
        id: backlightProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.percent = this.text.trim() || "0"
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: backlightProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggleById("controlCenter")
    }
}
