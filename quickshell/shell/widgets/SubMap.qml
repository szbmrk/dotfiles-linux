import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../"

Text {
    id: root

    property string submapName: ""

    visible: submapName !== ""
    text: " " + submapName
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: submapName === "resize" ? Theme.yellow : submapName === "pause" ? Theme.red : Theme.text

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                root.submapName = event.data.trim();
        }
    }
}
