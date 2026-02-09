import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

Text {
    id: root

    property string rootPercent: ""
    property string rootUsed: ""
    property string rootTotal: ""
    property string rootFree: ""
    property string homePercent: ""
    property string homeUsed: ""
    property string homeTotal: ""
    property string homeFree: ""

    text: ""
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: Theme.teal

    Process {
        id: diskProc
        command: ["bash", "-c", "df -h / | awk 'NR==2{gsub(/%/,\"\",$5); print \"root\",$5,$3,$2,$4}'; df -h /home | awk 'NR==2{gsub(/%/,\"\",$5); print \"home\",$5,$3,$2,$4}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim().split(/\s+/);
                    if (p.length >= 5) {
                        if (p[0] === "root") {
                            root.rootPercent = p[1];
                            root.rootUsed = p[2];
                            root.rootTotal = p[3];
                            root.rootFree = p[4];
                        } else if (p[0] === "home") {
                            root.homePercent = p[1];
                            root.homeUsed = p[2];
                            root.homeTotal = p[3];
                            root.homeFree = p[4];
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: diskProc.running = true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggleById("diskPanel")
    }
}
