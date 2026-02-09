import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../"

Text {
    id: root

    property var node: Pipewire.defaultAudioSink
    property var audio: node?.audio ?? null
    property bool muted: audio?.muted ?? false
    property real vol: audio?.volume ?? 0

    text: muted ? " muted" : ((vol > 0.3 ? " " : " ") + Math.round(vol * 100) + "%")
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: muted ? Theme.red : Theme.blue

    PwObjectTracker {
        objects: [root.node]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton)
                muteProc.running = true;
            else
                PanelManager.toggleById("audioPanel");
        }
        onWheel: wheel => {
            const delta = wheel.angleDelta.y;

            if (delta > 0)
                increaseVol.running = true;
            else if (delta < 0)
                decraseVol.running = true;
        }
    }

    Process {
        id: muteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    }

    Process {
        id: increaseVol
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+1%"]
    }

    Process {
        id: decraseVol
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-1%"]
    }
}
