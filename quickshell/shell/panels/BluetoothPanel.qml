import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property bool btEnabled: false
    property bool btScanning: false
    property var devices: []
    property string connectingTo: ""

    function toggleBluetooth() {
        btToggleProc.command = ["bluetoothctl", "power", btEnabled ? "off" : "on"];
        btToggleProc.running = true;
    }

    function toggleDiscovery() {
        if (btScanning) {
            btScanOffProc.running = true;
        } else {
            btScanOnProc.running = true;
        }
        btScanning = !btScanning;
    }

    function connectDevice(mac) {
        connectingTo = mac;
        btConnectProc.command = ["bluetoothctl", "connect", mac];
        btConnectProc.running = true;
    }

    function disconnectDevice(mac) {
        btDisconnectProc.command = ["bluetoothctl", "disconnect", mac];
        btDisconnectProc.running = true;
    }

    function refreshDevices() {
        btDevicesProc.running = true;
        btStatusProc.running = true;
    }

    // Split devices
    readonly property var connectedDevices: {
        return devices.filter(function (d) {
            return d.connected;
        });
    }
    readonly property var pairedDevices: {
        return devices.filter(function (d) {
            return !d.connected && d.paired;
        });
    }
    readonly property var availableDevices: {
        return devices.filter(function (d) {
            return !d.connected && !d.paired;
        });
    }

    panelContent: Component {
        ColumnLayout {
            spacing: Style.marginL

            // ── Header ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: headerRow.implicitHeight + Style.marginXL

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    IconText {
                        text: btEnabled ? "\u{f294}" : "\u{f294}"
                        pointSize: Style.fontXXL
                        color: btEnabled ? Theme.primary : Theme.overlay0
                    }

                    PanelText {
                        text: "Bluetooth"
                        pointSize: Style.fontXL
                        font.weight: Style.weightBold
                        Layout.fillWidth: true
                    }

                    PanelToggle {
                        checked: btEnabled
                        onToggled: function (checked) {
                            toggleBluetooth();
                        }
                    }

                    IconButton {
                        enabled: btEnabled
                        icon: btScanning ? "\uf04d" : "\uf021"
                        iconColor: Theme.subtext0
                        bgColor: "transparent"
                        onClicked: toggleDiscovery()
                    }

                    IconButton {
                        icon: "\uf00d"
                        iconColor: Theme.subtext0
                        bgColor: "transparent"
                        onClicked: root.close()
                    }
                }
            }

            // ── Bluetooth disabled state ──
            Card {
                visible: !btEnabled
                Layout.fillWidth: true
                Layout.preferredHeight: disabledCol.implicitHeight + Style.marginXL * 2

                ColumnLayout {
                    id: disabledCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginL

                    Item {
                        Layout.fillHeight: true
                    }

                    IconText {
                        text: "\u{f294}"
                        pointSize: 48
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0.5
                    }

                    PanelText {
                        text: "Bluetooth is disabled"
                        pointSize: Style.fontL
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    PanelText {
                        text: "Enable Bluetooth to discover and connect devices"
                        pointSize: Style.fontS
                        color: Theme.overlay0
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            // ── Scanning indicator ──
            Card {
                visible: btEnabled && btScanning && devices.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: scanCol.implicitHeight + Style.marginXL * 2

                ColumnLayout {
                    id: scanCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginL

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Style.marginS

                        IconText {
                            text: "\uf021"
                            pointSize: Style.fontXXL
                            color: Theme.primary
                            RotationAnimation on rotation {
                                running: true
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                                duration: 2000
                            }
                        }

                        PanelText {
                            text: "Scanning for devices..."
                            pointSize: Style.fontL
                        }
                    }

                    PanelText {
                        text: "Make sure your device is in pairing mode"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            // ── Empty state (not scanning, no devices) ──
            Card {
                visible: btEnabled && !btScanning && devices.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: emptyCol.implicitHeight + Style.marginXL * 2

                ColumnLayout {
                    id: emptyCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginL

                    Item {
                        Layout.fillHeight: true
                    }

                    IconText {
                        text: "\u{f294}"
                        pointSize: 48
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    PanelText {
                        text: "No devices found"
                        pointSize: Style.fontL
                        color: Theme.overlay0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: scanBtn.implicitWidth + Style.marginXL
                        height: scanBtn.implicitHeight + Style.marginM
                        radius: Style.radiusS
                        color: Theme.primary

                        PanelText {
                            id: scanBtn
                            anchors.centerIn: parent
                            text: "Scan for devices"
                            color: Theme.onPrimary
                            font.weight: Style.weightSemiBold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toggleDiscovery()
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            // ── Device lists ──
            Flickable {
                visible: btEnabled && devices.length > 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: deviceCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: deviceCol
                    width: parent.width
                    spacing: Style.marginM

                    // Connected devices
                    PanelText {
                        visible: connectedDevices.length > 0
                        text: "Connected Devices"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                    }

                    Repeater {
                        model: connectedDevices
                        delegate: deviceDelegate
                    }

                    // Paired devices
                    PanelText {
                        visible: pairedDevices.length > 0
                        text: "Paired Devices"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                        Layout.topMargin: Style.marginS
                    }

                    Repeater {
                        model: pairedDevices
                        delegate: deviceDelegate
                    }

                    // Available devices
                    PanelText {
                        visible: availableDevices.length > 0
                        text: "Available Devices"
                        pointSize: Style.fontS
                        color: Theme.subtext0
                        Layout.topMargin: Style.marginS
                    }

                    Repeater {
                        model: availableDevices
                        delegate: deviceDelegate
                    }
                }
            }
        }
    }

    // ── Device delegate ──
    Component {
        id: deviceDelegate

        Card {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: devRow.implicitHeight + Style.marginL
            border.color: modelData.connected ? Theme.primary : Theme.cardBorder
            color: modelData.connected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.05) : Theme.cardBg

            RowLayout {
                id: devRow
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginM

                IconText {
                    text: modelData.connected ? "\u{f294}" : "\u{f294}"
                    pointSize: Style.fontL
                    color: modelData.connected ? Theme.blue : Theme.overlay1
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PanelText {
                        text: modelData.name || modelData.mac
                        font.weight: modelData.connected ? Style.weightBold : Style.weightMedium
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: Style.marginXS

                        Rectangle {
                            visible: modelData.connected
                            color: Theme.primary
                            radius: height * 0.5
                            width: btConnText.implicitWidth + Style.marginS * 2
                            height: btConnText.implicitHeight + 2

                            PanelText {
                                id: btConnText
                                anchors.centerIn: parent
                                text: "Connected"
                                pointSize: 7
                                color: Theme.onPrimary
                            }
                        }

                        PanelText {
                            visible: connectingTo === modelData.mac
                            text: "Connecting..."
                            pointSize: 7
                            color: Theme.yellow
                        }

                        PanelText {
                            visible: modelData.type && modelData.type !== ""
                            text: modelData.type || ""
                            pointSize: 7
                            color: Theme.subtext0
                        }
                    }
                }

                IconButton {
                    icon: modelData.connected ? "\uf127" : "\uf0c1"
                    iconColor: modelData.connected ? Theme.red : Theme.green
                    bgColor: "transparent"
                    implicitWidth: 28
                    implicitHeight: 28
                    onClicked: {
                        if (modelData.connected)
                            disconnectDevice(modelData.mac);
                        else
                            connectDevice(modelData.mac);
                    }
                }
            }
        }
    }

    // ── Processes ──
    Process {
        id: btStatusProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.btEnabled = this.text.trim() === "yes"
        }
    }

    Process {
        id: btDevicesProc
        command: ["bash", "-c", "bluetoothctl devices 2>/dev/null | while read _ mac name; do connected=$(bluetoothctl info \"$mac\" 2>/dev/null | grep 'Connected:' | awk '{print $2}'); paired=$(bluetoothctl info \"$mac\" 2>/dev/null | grep 'Paired:' | awk '{print $2}'); icon=$(bluetoothctl info \"$mac\" 2>/dev/null | grep 'Icon:' | awk '{print $2}'); echo \"$mac|$name|$connected|$paired|$icon\"; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var result = [];
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("|");
                    if (parts.length >= 3 && parts[0]) {
                        result.push({
                            mac: parts[0],
                            name: parts[1] || parts[0],
                            connected: parts[2] === "yes",
                            paired: parts.length >= 4 ? parts[3] === "yes" : false,
                            type: parts.length >= 5 ? parts[4] || "" : ""
                        });
                    }
                }
                result.sort(function (a, b) {
                    if (a.connected && !b.connected)
                        return -1;
                    if (!a.connected && b.connected)
                        return 1;
                    if (a.paired && !b.paired)
                        return -1;
                    if (!a.paired && b.paired)
                        return 1;
                    return 0;
                });
                root.devices = result;
            }
        }
    }

    Process {
        id: btToggleProc
        command: ["bluetoothctl", "power", "on"]
        onRunningChanged: {
            if (!running) {
                Qt.callLater(function () {
                    btStatusProc.running = true;
                    btDevicesProc.running = true;
                });
            }
        }
    }

    Process {
        id: btScanOnProc
        command: ["bluetoothctl", "scan", "on"]
    }
    Process {
        id: btScanOffProc
        command: ["bluetoothctl", "scan", "off"]
    }

    Process {
        id: btConnectProc
        command: ["bluetoothctl", "connect", ""]
        onRunningChanged: {
            if (!running) {
                connectingTo = "";
                refreshDevices();
            }
        }
    }

    Process {
        id: btDisconnectProc
        command: ["bluetoothctl", "disconnect", ""]
        onRunningChanged: {
            if (!running)
                refreshDevices();
        }
    }

    // Auto-refresh while scanning
    Timer {
        interval: 5000
        running: btEnabled && btScanning && root.isOpen
        repeat: true
        onTriggered: btDevicesProc.running = true
    }

    onIsOpenChanged: {
        if (isOpen) {
            refreshDevices();
        } else {
            if (btScanning) {
                btScanOffProc.running = true;
                btScanning = false;
            }
        }
    }
}
