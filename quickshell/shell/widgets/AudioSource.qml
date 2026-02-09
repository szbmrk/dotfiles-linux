import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../"

Text {
    id: root

    property var node: Pipewire.defaultAudioSource
    property var audio: node?.audio ?? null
    property bool muted: audio?.muted ?? false
    property real vol: audio?.volume ?? 0

    text: muted ? " muted" : (" " + Math.round(vol * 100) + "%")
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: muted ? Theme.red : Theme.lavender

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
        command: ["pactl", "set-source-mute", "@DEFAULT_SOURCE@", "toggle"]
    }

    Process {
        id: increaseVol
        command: ["pactl", "set-source-volume", "@DEFAULT_SOURCE@", "+1%"]
    }

    Process {
        id: decraseVol
        command: ["pactl", "set-source-volume", "@DEFAULT_SOURCE@", "-1%"]
    }
}
