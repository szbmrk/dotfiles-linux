import QtQuick
import Quickshell.Io
import "../"

Text {
    id: root

    property string statusText: "..."
    property color statusColor: Theme.yellow
    property string ethernetIp: ""
    property bool isEthernet: false
    property bool showEthernetIp: false
    property bool isWifi: false

    text: statusText
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: statusColor

    function updateEthernetText() {
        if (!isEthernet)
            return;
        root.statusText = showEthernetIp ? (" " + ethernetIp) : " eth";
    }

    function onClicked() {
        if (isWifi) {
            PanelManager.toggleById("wifiPanel");
            return;
        }

        if (isEthernet && ethernetIp !== "") {
            showEthernetIp = !showEthernetIp;
            updateEthernetText();
        }
    }

    Process {
        id: networkProc
        command: ["bash", "-c", "sig=$(nmcli -t -f active,signal dev wifi 2>/dev/null | grep ^yes | cut -d: -f2);" + " if [ -n \"$sig\" ]; then echo wifi:$sig;" + " else dev=$(nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep ':ethernet:connected$' | cut -d: -f1 | head -n1);" + " if [ -n \"$dev\" ]; then ip=$(nmcli -g IP4.ADDRESS dev show \"$dev\" 2>/dev/null | cut -d/ -f1 | head -n1);" + " if [ -n \"$ip\" ]; then echo eth:$ip; else echo eth:0; fi;" + " else echo off:0; fi; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim().split(":");
                if (p[0] === "wifi") {
                    root.statusText = "󰤨 " + p[1] + "%";
                    root.isWifi = true;
                    root.isEthernet = false;
                    root.ethernetIp = "";
                    root.statusColor = Theme.yellow;
                } else if (p[0] === "eth") {
                    root.isWifi = false;
                    root.isEthernet = true;
                    root.ethernetIp = p[1] === "0" ? "eth" : p[1];
                    root.updateEthernetText();
                    root.statusColor = Theme.yellow;
                } else {
                    root.statusText = " disconnected";
                    root.isWifi = false;
                    root.isEthernet = false;
                    root.ethernetIp = "";
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
        onClicked: root.onClicked()
    }
}
