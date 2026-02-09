import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property var networks: []
    property bool scanning: false
    property string connectedSsid: ""
    property string connectingTo: ""
    property bool wifiEnabled: true
    property string passwordSsid: ""
    property string passwordText: ""
    property string lastError: ""

    readonly property var knownNetworks: {
        var known = [];
        for (var i = 0; i < networks.length; i++) {
            if (networks[i].inUse || networks[i].saved)
                known.push(networks[i]);
        }
        return known;
    }

    readonly property var availableNetworks: {
        var avail = [];
        for (var i = 0; i < networks.length; i++) {
            if (!networks[i].inUse && !networks[i].saved)
                avail.push(networks[i]);
        }
        return avail;
    }

    function scan() {
        scanning = true;
        scanProc.running = true;
    }

    function connectNetwork(ssid, password) {
        connectingTo = ssid;
        lastError = "";
        if (password) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        }
        connectProc.running = true;
    }

    function disconnectNetwork() {
        if (connectedSsid)
            disconnectProc.command = ["nmcli", "connection", "down", connectedSsid];
        disconnectProc.running = true;
    }

    function forgetNetwork(ssid) {
        forgetProc.command = ["nmcli", "connection", "delete", ssid];
        forgetProc.running = true;
    }

    function getSignalIcon(sig) {
        var s = parseInt(sig) || 0;
        if (s >= 75) return "\u{f1eb}";  // wifi full
        if (s >= 50) return "\u{f1eb}";
        if (s >= 25) return "\u{f1eb}";
        return "\u{f1eb}";
    }

    panelContent: Component {
        ColumnLayout {
            spacing: Style.marginL

            // ── Header ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: headerCol.implicitHeight + Style.marginXL

                ColumnLayout {
                    id: headerCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        spacing: Style.marginM

                        IconText {
                            text: wifiEnabled ? "\u{f1eb}" : "\u{f1eb}"
                            pointSize: Style.fontXXL
                            color: wifiEnabled ? Theme.primary : Theme.overlay0
                        }

                        PanelText {
                            text: "Wi-Fi"
                            pointSize: Style.fontXL
                            font.weight: Style.weightBold
                            Layout.fillWidth: true
                        }

                        PanelToggle {
                            checked: wifiEnabled
                            onToggled: function(checked) {
                                wifiEnabled = checked;
                                wifiToggleProc.command = ["nmcli", "radio", "wifi", checked ? "on" : "off"];
                                wifiToggleProc.running = true;
                            }
                        }

                        IconButton {
                            icon: "\uf021"  // refresh
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            opacity: scanning ? 0.5 : 1.0
                            enabled: wifiEnabled && !scanning
                            onClicked: scan()
                        }

                        IconButton {
                            icon: "\uf00d"  // close
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            onClicked: root.close()
                        }
                    }

                    PanelText {
                        visible: connectedSsid !== ""
                        text: "Connected to " + connectedSsid
                        pointSize: Style.fontS
                        color: Theme.green
                    }
                }
            }

            // ── Error message ──
            Rectangle {
                visible: lastError.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: errorRow.implicitHeight + Style.marginXL
                color: Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.1)
                radius: Style.radiusS
                border.width: Style.borderS
                border.color: Theme.red

                RowLayout {
                    id: errorRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    IconText {
                        text: "\uf071"  // warning
                        pointSize: Style.fontL
                        color: Theme.red
                    }

                    PanelText {
                        text: lastError
                        color: Theme.red
                        pointSize: Style.fontS
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    IconButton {
                        icon: "\uf00d"
                        bgColor: "transparent"
                        iconColor: Theme.red
                        implicitWidth: 20; implicitHeight: 20
                        onClicked: lastError = ""
                    }
                }
            }

            // ── WiFi disabled state ──
            Card {
                visible: !wifiEnabled
                Layout.fillWidth: true
                Layout.preferredHeight: disabledCol.implicitHeight + Style.marginXL * 2

                ColumnLayout {
                    id: disabledCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginL

                    Item { Layout.fillHeight: true }

                    IconText {
                        text: "\u{f1eb}"
                        pointSize: 48
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0.5
                    }

                    PanelText {
                        text: "Wi-Fi is disabled"
                        pointSize: Style.fontL
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    PanelText {
                        text: "Enable Wi-Fi to scan for networks"
                        pointSize: Style.fontS
                        color: Theme.overlay0
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ── Scanning state ──
            Card {
                visible: wifiEnabled && scanning && networks.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.marginM

                    PanelText {
                        text: "Scanning for networks..."
                        color: Theme.subtext0
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // ── Network lists ──
            Flickable {
                visible: wifiEnabled && networks.length > 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: netCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: netCol
                    width: parent.width
                    spacing: Style.marginM

                    // ── Connected / Known ──
                    PanelText {
                        visible: knownNetworks.length > 0
                        text: "Known Networks"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                    }

                    Repeater {
                        model: knownNetworks
                        delegate: networkDelegate
                    }

                    // ── Available ──
                    PanelText {
                        visible: availableNetworks.length > 0
                        text: "Available Networks"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                        Layout.topMargin: Style.marginM
                    }

                    Repeater {
                        model: availableNetworks
                        delegate: networkDelegate
                    }
                }
            }

            // ── No networks ──
            PanelText {
                visible: wifiEnabled && !scanning && networks.length === 0
                text: "No networks found"
                color: Theme.overlay0
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // ── Network delegate ──
    Component {
        id: networkDelegate

        Card {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: netItemCol.implicitHeight + Style.marginM
            border.color: modelData.inUse ? Theme.primary : Theme.cardBorder
            color: modelData.inUse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.05) : Theme.cardBg

            property bool showPassword: passwordSsid === modelData.ssid
            property bool isConnecting: connectingTo === modelData.ssid

            ColumnLayout {
                id: netItemCol
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginS

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    IconText {
                        text: "\u{f1eb}"
                        pointSize: Style.fontL
                        color: modelData.inUse ? Theme.green : Theme.text
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        PanelText {
                            text: modelData.ssid || "(Hidden)"
                            font.weight: modelData.inUse ? Style.weightBold : Style.weightMedium
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: Style.marginXS

                            // Connected badge
                            Rectangle {
                                visible: modelData.inUse
                                color: Theme.primary
                                radius: height * 0.5
                                width: connText.implicitWidth + Style.marginS * 2
                                height: connText.implicitHeight + 2

                                PanelText {
                                    id: connText
                                    anchors.centerIn: parent
                                    text: "Connected"
                                    pointSize: 7
                                    color: Theme.onPrimary
                                }
                            }

                            PanelText {
                                visible: isConnecting
                                text: "Connecting..."
                                pointSize: 7
                                color: Theme.yellow
                            }

                            PanelText {
                                text: modelData.signal + "% · " + (modelData.security || "Open")
                                pointSize: 7
                                color: Theme.subtext0
                            }
                        }
                    }

                    // Disconnect button for connected network
                    IconButton {
                        visible: modelData.inUse
                        icon: "\uf127"  // unlink
                        iconColor: Theme.red
                        bgColor: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        onClicked: disconnectNetwork()
                    }

                    // Connect button for non-connected
                    IconButton {
                        visible: !modelData.inUse && !showPassword
                        icon: "\uf0c1"  // link
                        iconColor: Theme.green
                        bgColor: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        onClicked: {
                            if (modelData.security && modelData.security !== "" && modelData.security !== "--" && !modelData.saved)
                                passwordSsid = modelData.ssid;
                            else
                                connectNetwork(modelData.ssid);
                        }
                    }

                    // Forget button for saved networks
                    IconButton {
                        visible: modelData.saved && !modelData.inUse && !showPassword
                        icon: "\uf1f8"  // trash
                        iconColor: Theme.overlay1
                        bgColor: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        onClicked: forgetNetwork(modelData.ssid)
                    }
                }

                // Password input row
                RowLayout {
                    visible: showPassword
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: Style.radiusS
                        color: Theme.surface0
                        border.color: Theme.primary
                        border.width: Style.borderS

                        TextInput {
                            id: passInput
                            anchors.fill: parent
                            anchors.margins: Style.marginXS
                            font.family: Theme.fontFamilyUI
                            font.pointSize: Style.fontS
                            color: Theme.text
                            echoMode: TextInput.Password
                            clip: true
                            verticalAlignment: TextInput.AlignVCenter
                            onAccepted: {
                                connectNetwork(modelData.ssid, text);
                                passwordSsid = "";
                                text = "";
                            }
                            Component.onCompleted: if (showPassword) forceActiveFocus()
                        }
                    }

                    IconButton {
                        icon: "\uf00c"  // check
                        iconColor: Theme.green
                        bgColor: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        onClicked: {
                            connectNetwork(modelData.ssid, passInput.text);
                            passwordSsid = "";
                            passInput.text = "";
                        }
                    }

                    IconButton {
                        icon: "\uf00d"  // close
                        iconColor: Theme.red
                        bgColor: "transparent"
                        implicitWidth: 28; implicitHeight: 28
                        onClicked: { passwordSsid = ""; passInput.text = ""; }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.inUse) return;
                    if (modelData.security && modelData.security !== "" && modelData.security !== "--" && !modelData.saved)
                        passwordSsid = modelData.ssid;
                    else
                        connectNetwork(modelData.ssid);
                }
            }
        }
    }

    // ── Processes ──
    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes 2>/dev/null | head -50"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var result = [];
                var connected = "";
                for (var i = 0; i < lines.length; i++) {
                    if (!lines[i].trim()) continue;
                    // Handle nmcli terse escaped colons (\:)
                    var raw = lines[i].replace(/\\:/g, "##COL##");
                    var parts = raw.split(":");
                    if (parts.length >= 4) {
                        var inUse = parts[0].trim() === "*";
                        var ssid = parts[1].replace(/##COL##/g, ":");
                        if (!ssid) continue;
                        var signal = parts[2];
                        var security = parts.slice(3).join(":").replace(/##COL##/g, ":");

                        var dup = false;
                        for (var j = 0; j < result.length; j++) {
                            if (result[j].ssid === ssid) { dup = true; break; }
                        }
                        if (dup) continue;

                        if (inUse) connected = ssid;

                        result.push({
                            ssid: ssid,
                            signal: signal,
                            security: security,
                            inUse: inUse,
                            saved: false
                        });
                    }
                }
                result.sort(function(a, b) {
                    if (a.inUse && !b.inUse) return -1;
                    if (!a.inUse && b.inUse) return 1;
                    return parseInt(b.signal) - parseInt(a.signal);
                });
                root.networks = result;
                root.connectedSsid = connected;
                root.scanning = false;
                savedProc.running = true;
            }
        }
    }

    Process {
        id: savedProc
        command: ["bash", "-c", "nmcli -t -f NAME connection show 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var saved = this.text.trim().split("\n").map(function(s) { return s.trim(); });
                var nets = root.networks.slice();
                for (var i = 0; i < nets.length; i++) {
                    if (saved.indexOf(nets[i].ssid) >= 0)
                        nets[i].saved = true;
                }
                root.networks = nets;
            }
        }
    }

    Process {
        id: connectProc
        command: ["nmcli", "device", "wifi", "connect", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim();
                if (out.toLowerCase().indexOf("error") >= 0) {
                    root.lastError = out;
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                connectingTo = "";
                scan();
            }
        }
    }

    Process {
        id: disconnectProc
        command: ["nmcli", "connection", "down", ""]
        onRunningChanged: { if (!running) scan(); }
    }

    Process {
        id: forgetProc
        command: ["nmcli", "connection", "delete", ""]
        onRunningChanged: { if (!running) scan(); }
    }

    Process {
        id: wifiToggleProc
        command: ["nmcli", "radio", "wifi", "on"]
        onRunningChanged: {
            if (!running && wifiEnabled) {
                Qt.callLater(scan);
            }
        }
    }

    Process {
        id: wifiStatusProc
        command: ["bash", "-c", "nmcli radio wifi 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = this.text.trim() === "enabled"
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            wifiStatusProc.running = true;
            passwordSsid = "";
            lastError = "";
            scan();
        }
    }
}
