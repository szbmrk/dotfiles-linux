import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property string percent: "0"
    property bool available: false

    visible: available
    text: "󰃠 " + percent + "%"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: Theme.peach

    Process {
        id: backlightProc
        command: ["bash", "-c", `
            if ! ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
                echo "unavailable"
                exit 0
            fi

            brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'
            `]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let value = this.text.trim();

                if (value === "unavailable" || value === "") {
                    root.available = false;
                    return;
                }

                let number = Number(value);

                if (!isNaN(number) && number > 0) {
                    root.percent = value;
                    root.available = true;
                } else {
                    root.available = false;
                }
            }
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
        onClicked: PanelManager.toggleById("brightnessPanel")
    }
}
