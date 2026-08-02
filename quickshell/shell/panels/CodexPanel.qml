import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property string weeklyPercent: "0"
    property int resetAt: 0

    function formatResetAt(timestamp) {
        if (!timestamp)
            return "unknown";

        var date = new Date(timestamp * 1000);
        return Qt.formatDateTime(date, "MMM d, HH:mm");
    }

    panelContent: Component {
        ColumnLayout {
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: headerRow.implicitHeight + Style.marginXL

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    IconText {
                        text: "\uf080"
                        pointSize: Style.fontXXL
                        color: Theme.lavender
                    }

                    PanelText {
                        text: "Codex Usage"
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

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: rootCol.implicitHeight + Style.marginXL

                ColumnLayout {
                    id: rootCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        PanelText {
                            text: "Weekly limit"
                            font.weight: Style.weightSemiBold
                            pointSize: Style.fontL
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        PanelText {
                            text: root.weeklyPercent + "%"
                            pointSize: Style.fontL
                            font.weight: Style.weightBold
                            color: {
                                var p = parseInt(root.weeklyPercent) || 0;
                                return p > 60 ? Theme.teal : p > 30 ? Theme.yellow : Theme.red;
                            }
                        }
                    }

                    // Usage bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        radius: 5
                        color: Theme.surface1

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, (parseInt(root.weeklyPercent) || 0) / 100))
                            height: parent.height
                            radius: 5
                            color: {
                                var p = parseInt(root.weeklyPercent) || 0;
                                return p > 60 ? Theme.teal : p > 30 ? Theme.yellow : Theme.red;
                            }

                            Behavior on width {
                                NumberAnimation {
                                    duration: Style.animNormal
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    PanelText {
                        text: "Resets: " + root.formatResetAt(root.resetAt)
                        pointSize: Style.fontS
                        color: Theme.subtext0
                    }
                }
            }
        }
    }

    // ── Data fetching ──
    Process {
        id: codexProc
        command: ["bash", "/home/szobo/.config/quickshell/shell/scripts/codex_usage.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    root.weeklyPercent = 100 - parts[0];
                    root.resetAt = parseInt(parts[1]) || 0;
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: codexProc.running = true
    }

    onIsOpenChanged: {
        if (isOpen)
            codexProc.running = true;
    }
}
