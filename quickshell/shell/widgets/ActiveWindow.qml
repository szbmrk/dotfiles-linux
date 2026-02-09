import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../"

Row {
    id: root

    property string title: ""
    property string windowClass: ""
    property int maxLength: 40

    spacing: 8

    Image {
        id: windowIcon
        source: root.getAppIcon()
        anchors.verticalCenter: parent.verticalCenter
        sourceSize: Qt.size(18, 18)
        fillMode: Image.PreserveAspectFit
        visible: root.windowClass !== ""
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
        color: Theme.subtext0
        elide: Text.ElideRight
    }

    function getAppIcon() {
        if (!windowClass)
            return "";

        var entry = DesktopEntries.heuristicLookup(windowClass);
        if (entry && entry.icon) {
            if (entry.icon.startsWith("/"))
                return "file://" + entry.icon;
            var resolved = Quickshell.iconPath(entry.icon, true);
            if (resolved !== "")
                return resolved;
        }

        return Quickshell.iconPath(windowClass, "image-missing");
    }

    Process {
        id: windowProc
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var obj = JSON.parse(this.text);
                    root.title = (obj.title || "").substring(0, root.maxLength);

                    if (obj.title.length > root.maxLength) {
                        root.title += "...";
                    }

                    root.windowClass = obj.class || "";
                } catch (e) {
                    root.title = "";
                    root.windowClass = "";
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activewindow" || event.name === "activewindowv2")
                windowProc.running = true;
        }
    }
}
