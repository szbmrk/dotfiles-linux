import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property real sessionPercent: 0
    property int sessionResetAt: 0
    property real weeklyPercent: 0
    property int weeklyResetAt: 0
    property bool loaded: false
    property real now: Date.now()

    function usageColor(percent) {
        return percent > 90 ? Theme.red : percent > 70 ? Theme.yellow : Theme.teal;
    }

    function formatResetIn(timestamp) {
        if (!timestamp)
            return "unknown";

        var minutes = Math.max(0, Math.floor((timestamp * 1000 - root.now) / 60000));
        var days = Math.floor(minutes / 1440);
        var hours = Math.floor(minutes % 1440 / 60);
        var mins = minutes % 60;

        if (days > 0)
            return days + "d " + hours + "h";
        if (hours > 0)
            return hours + "h " + mins + "m";
        return mins + "m";
    }

    component LimitCard: Card {
        id: card

        property string title
        property string icon
        property real percent
        property int resetAt

        Layout.fillWidth: true
        Layout.preferredHeight: limitCol.implicitHeight + Style.marginXL

        ColumnLayout {
            id: limitCol
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                IconText {
                    text: card.icon
                    pointSize: Style.fontL
                    color: root.usageColor(card.percent)
                }

                PanelText {
                    text: card.title
                    font.weight: Style.weightSemiBold
                    pointSize: Style.fontL
                }

                Item {
                    Layout.fillWidth: true
                }

                PanelText {
                    text: root.loaded ? Math.round(card.percent) + "%" : "—"
                    pointSize: Style.fontL
                    font.weight: Style.weightBold
                    color: root.usageColor(card.percent)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 10
                radius: 5
                color: Theme.surface1

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, card.percent / 100))
                    height: parent.height
                    radius: 5
                    color: root.usageColor(card.percent)

                    Behavior on width {
                        NumberAnimation {
                            duration: Style.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            PanelText {
                text: "Resets in " + root.formatResetIn(card.resetAt)
                pointSize: Style.fontS
                color: Theme.subtext0
            }
        }
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
                        text: ""
                        pointSize: Style.fontXXL
                        color: Theme.peach
                    }

                    PanelText {
                        text: "Claude Usage"
                        pointSize: Style.fontXL
                        font.weight: Style.weightBold
                        Layout.fillWidth: true
                    }

                    IconButton {
                        icon: ""
                        iconColor: Theme.subtext0
                        bgColor: "transparent"
                        onClicked: root.close()
                    }
                }
            }

            LimitCard {
                title: "5-hour limit"
                icon: ""
                percent: root.sessionPercent
                resetAt: root.sessionResetAt
            }

            LimitCard {
                title: "Weekly limit"
                icon: ""
                percent: root.weeklyPercent
                resetAt: root.weeklyResetAt
            }
        }
    }

    Process {
        id: claudeProc
        command: ["bash", "/home/szobo/.config/quickshell/shell/scripts/claude_usage.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(/\s+/);
                if (parts.length >= 4) {
                    root.sessionPercent = parseFloat(parts[0]) || 0;
                    root.sessionResetAt = parseInt(parts[1]) || 0;
                    root.weeklyPercent = parseFloat(parts[2]) || 0;
                    root.weeklyResetAt = parseInt(parts[3]) || 0;
                    root.loaded = true;
                }
            }
        }
    }

    Timer {
        interval: 120000
        running: true
        repeat: true
        onTriggered: claudeProc.running = true
    }

    Timer {
        interval: 30000
        running: root.isOpen
        repeat: true
        onTriggered: root.now = Date.now()
    }

    onIsOpenChanged: {
        if (isOpen) {
            root.now = Date.now();
            claudeProc.running = true;
        }
    }
}
