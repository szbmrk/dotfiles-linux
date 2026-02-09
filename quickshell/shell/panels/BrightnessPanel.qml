import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"
import "../components"

// Brightness panel — display brightness control
PopupPanel {
    id: root

    property string brightnessPercent: "0"

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
                        text: "\uf185"  // sun
                        pointSize: Style.fontXXL
                        color: Theme.peach
                    }

                    PanelText {
                        text: "Brightness"
                        pointSize: Style.fontXL
                        font.weight: Style.weightBold
                        Layout.fillWidth: true
                    }

                    IconButton {
                        icon: "\uf00d"
                        iconColor: Theme.subtext0
                        bgColor: "transparent"
                        onClicked: root.close()
                    }
                }
            }

            // ── Brightness Control ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: brightCol.implicitHeight + Style.marginXL

                ColumnLayout {
                    id: brightCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginM

                        IconText {
                            text: {
                                var val = parseInt(brightnessPercent) || 0;
                                if (val <= 30) return "\uf186";  // moon
                                return "\uf185";  // sun
                            }
                            pointSize: Style.fontL
                            color: Theme.peach
                        }

                        PanelText {
                            text: "Display"
                            Layout.fillWidth: true
                        }

                        PanelText {
                            text: brightnessPercent + "%"
                            color: Theme.subtext0
                            pointSize: Style.fontS
                        }
                    }

                    PanelSlider {
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: parseInt(brightnessPercent) || 0
                        stepSize: 1
                        fillColor: Theme.peach
                        tooltipText: Math.round(value) + "%"
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

    Process {
        id: brightnessProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.brightnessPercent = this.text.trim() || "0"
        }
    }

    Process { id: brightnessSetProc; command: ["brightnessctl", "set", "50%"] }

    Timer {
        interval: 2000
        running: root.isOpen
        repeat: true
        onTriggered: brightnessProc.running = true
    }

    onIsOpenChanged: {
        if (isOpen) brightnessProc.running = true;
    }
}
