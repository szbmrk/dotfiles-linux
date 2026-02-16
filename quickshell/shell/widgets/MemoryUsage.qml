import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property bool alt: false
    property string percent: ""
    property string usedTotal: ""

    text: alt ? (" " + usedTotal) : (" " + percent + "%")
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: Theme.mauve

    Process {
        id: memProc
        command: ["bash", "-c", "free -m | awk '/Mem:/{printf \"%.0f %.1f %.1f\",$3/$2*100,$3/1024,$2/1024}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim().split(" ");
                if (p.length >= 3) {
                    root.percent = p[0];
                    root.usedTotal = p[1] + "G/" + p[2] + "G";
                }
            }
        }
    }

    Process {
        id: btop
        command: ["hyprctl", "dispatch", "exec", "wezterm start -- btop"]
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.alt = !root.alt;
            } else if (mouse.button === Qt.RightButton)
                btop.running = true;
        }
    }
}
