import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../"
import "../components"

// Control Center — profile, quick shortcuts, audio, brightness overview
PopupPanel {
    id: root

    panelContent: Component {
        ColumnLayout {
            spacing: Style.marginL

            // ── Profile Card ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: Theme.surface1

                        IconText {
                            anchors.centerIn: parent
                            text: "\uf007"  // user
                            pointSize: 16
                            color: Theme.primary
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        PanelText {
                            text: hostName
                            font.weight: Style.weightBold
                        }
                        PanelText {
                            text: "Uptime: " + uptimeText
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }

                    IconButton {
                        icon: "\uf00d"
                        iconColor: Theme.subtext0
                        bgColor: "transparent"
                        onClicked: root.close()
                    }
                }
            }

            // ── Quick Shortcuts ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: Style.marginS

                    Item { Layout.fillWidth: true }

                    IconButton {
                        icon: "\u{f1eb}"  // wifi
                        iconColor: Theme.yellow
                        tooltip: "Network"
                        onClicked: {
                            root.close();
                            PanelManager.toggleById("networkPanel");
                        }
                    }

                    IconButton {
                        icon: "\u{f294}"  // bluetooth
                        iconColor: Theme.blue
                        tooltip: "Bluetooth"
                        onClicked: {
                            root.close();
                            PanelManager.toggleById("bluetoothPanel");
                        }
                    }

                    IconButton {
                        icon: "\uf185"  // sun (brightness)
                        iconColor: Theme.peach
                        tooltip: "Brightness"
                        onClicked: {
                            root.close();
                            PanelManager.toggleById("brightnessPanel");
                        }
                    }

                    IconButton {
                        icon: "\uf011"  // power
                        iconColor: Theme.red
                        tooltip: "Power"
                        onClicked: powerProc.running = true
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            // ── Audio Output ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginXS

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        IconButton {
                            icon: sinkMuted ? "\uf026" : "\uf028"
                            iconColor: sinkMuted ? Theme.red : Theme.text
                            bgColor: "transparent"
                            implicitWidth: 28; implicitHeight: 28
                            onClicked: {
                                if (sink?.audio) sink.audio.muted = !sink.audio.muted;
                            }
                        }

                        PanelText {
                            text: sink ? (sink.description || "Output") : "No output"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        PanelText {
                            text: Math.round(sinkVol * 100) + "%"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }

                    PanelSlider {
                        Layout.fillWidth: true
                        from: 0; to: 1.0; value: sinkVol; stepSize: 0.01
                        fillColor: Theme.blue
                        onMoved: { if (sink?.audio) sink.audio.volume = value; }
                    }
                }
            }

            // ── Audio Input ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                visible: sourceNode !== null

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginXS

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        IconButton {
                            icon: sourceMuted ? "\uf131" : "\uf130"
                            iconColor: sourceMuted ? Theme.red : Theme.text
                            bgColor: "transparent"
                            implicitWidth: 28; implicitHeight: 28
                            onClicked: {
                                if (sourceNode?.audio) sourceNode.audio.muted = !sourceNode.audio.muted;
                            }
                        }

                        PanelText {
                            text: sourceNode ? (sourceNode.description || "Input") : "No input"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        PanelText {
                            text: Math.round(sourceVol * 100) + "%"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }

                    PanelSlider {
                        Layout.fillWidth: true
                        from: 0; to: 1.0; value: sourceVol; stepSize: 0.01
                        fillColor: Theme.lavender
                        onMoved: { if (sourceNode?.audio) sourceNode.audio.volume = value; }
                    }
                }
            }

            // ── Brightness ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginXS

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        IconButton {
                            icon: "\uf185"
                            iconColor: Theme.peach
                            bgColor: "transparent"
                            implicitWidth: 28; implicitHeight: 28
                        }

                        PanelText {
                            text: "Brightness"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                            Layout.fillWidth: true
                        }

                        PanelText {
                            text: brightnessPercent + "%"
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }

                    PanelSlider {
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: parseInt(brightnessPercent) || 0
                        stepSize: 1
                        fillColor: Theme.peach
                        onMoved: {
                            brightnessSetProc.command = ["brightnessctl", "set", Math.round(value) + "%"];
                            brightnessSetProc.running = true;
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ── Audio state ──
    property var sink: Pipewire.defaultAudioSink
    property var sourceNode: Pipewire.defaultAudioSource
    property real sinkVol: sink?.audio?.volume ?? 0
    property bool sinkMuted: sink?.audio?.muted ?? false
    property real sourceVol: sourceNode?.audio?.volume ?? 0
    property bool sourceMuted: sourceNode?.audio?.muted ?? false

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
    PwObjectTracker { objects: root.sourceNode ? [root.sourceNode] : [] }

    // ── System info ──
    property string hostName: ""
    property string uptimeText: "--"
    property string brightnessPercent: "0"

    Process {
        id: hostnameProc
        command: ["hostname"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.hostName = this.text.trim() }
    }

    Process {
        id: uptimeProc
        command: ["bash", "-c", "cat /proc/uptime | awk '{h=int($1/3600);m=int(($1%3600)/60);printf \"%dh %dm\",h,m}'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.uptimeText = this.text.trim() }
    }

    Timer { interval: 60000; running: true; repeat: true; onTriggered: uptimeProc.running = true }

    Process {
        id: brightnessProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.brightnessPercent = this.text.trim() || "0" }
    }

    Timer { interval: 3000; running: true; repeat: true; onTriggered: brightnessProc.running = true }

    Process { id: brightnessSetProc; command: ["brightnessctl", "set", "50%"] }
    Process { id: powerProc; command: ["wlogout"] }

    onIsOpenChanged: {
        if (isOpen) {
            uptimeProc.running = true;
            brightnessProc.running = true;
        }
    }
}
