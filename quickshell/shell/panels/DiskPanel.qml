import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

// Disk usage panel — shows / and /home usage with visual bars
PopupPanel {
    id: root

    property string rootPercent: "0"
    property string rootUsed: "\u2014"
    property string rootTotal: "\u2014"
    property string rootFree: "\u2014"
    property string homePercent: "0"
    property string homeUsed: "\u2014"
    property string homeTotal: "\u2014"
    property string homeFree: "\u2014"

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
                        text: "\uf0a0"
                        pointSize: Style.fontXXL
                        color: Theme.teal
                    }

                    PanelText {
                        text: "Disk Usage"
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

            // ── Root (/) ──
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

                        IconText {
                            text: "\uf292"
                            pointSize: Style.fontL
                            color: {
                                var p = parseInt(root.rootPercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                            }
                        }

                        PanelText {
                            text: "Root  /"
                            font.weight: Style.weightSemiBold
                            pointSize: Style.fontL
                        }

                        Item { Layout.fillWidth: true }

                        PanelText {
                            text: root.rootPercent + "%"
                            pointSize: Style.fontL
                            font.weight: Style.weightBold
                            color: {
                                var p = parseInt(root.rootPercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
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
                            width: parent.width * Math.max(0, Math.min(1, (parseInt(root.rootPercent) || 0) / 100))
                            height: parent.height
                            radius: 5
                            color: {
                                var p = parseInt(root.rootPercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                            }

                            Behavior on width {
                                NumberAnimation { duration: Style.animNormal; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        PanelText {
                            text: "Used: " + root.rootUsed
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        PanelText {
                            text: "Free: " + root.rootFree
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        PanelText {
                            text: "Total: " + root.rootTotal
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }
                }
            }

            // ── Home (/home) ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: homeCol.implicitHeight + Style.marginXL

                ColumnLayout {
                    id: homeCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        IconText {
                            text: "\uf015"
                            pointSize: Style.fontL
                            color: {
                                var p = parseInt(root.homePercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.blue;
                            }
                        }

                        PanelText {
                            text: "Home  /home"
                            font.weight: Style.weightSemiBold
                            pointSize: Style.fontL
                        }

                        Item { Layout.fillWidth: true }

                        PanelText {
                            text: root.homePercent + "%"
                            pointSize: Style.fontL
                            font.weight: Style.weightBold
                            color: {
                                var p = parseInt(root.homePercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.blue;
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
                            width: parent.width * Math.max(0, Math.min(1, (parseInt(root.homePercent) || 0) / 100))
                            height: parent.height
                            radius: 5
                            color: {
                                var p = parseInt(root.homePercent) || 0;
                                return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.blue;
                            }

                            Behavior on width {
                                NumberAnimation { duration: Style.animNormal; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        PanelText {
                            text: "Used: " + root.homeUsed
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        PanelText {
                            text: "Free: " + root.homeFree
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                        Item { Layout.fillWidth: true }
                        PanelText {
                            text: "Total: " + root.homeTotal
                            pointSize: Style.fontS
                            color: Theme.subtext0
                        }
                    }
                }
            }
        }
    }

    // ── Data fetching ──
    Process {
        id: diskProc
        command: ["bash", "-c", "df -h / | awk 'NR==2{gsub(/%/,\"\",$5); print \"root\",$5,$3,$2,$4}'; df -h /home | awk 'NR==2{gsub(/%/,\"\",$5); print \"home\",$5,$3,$2,$4}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim().split(/\s+/);
                    if (p.length >= 5) {
                        if (p[0] === "root") {
                            root.rootPercent = p[1];
                            root.rootUsed = p[2];
                            root.rootTotal = p[3];
                            root.rootFree = p[4];
                        } else if (p[0] === "home") {
                            root.homePercent = p[1];
                            root.homeUsed = p[2];
                            root.homeTotal = p[3];
                            root.homeFree = p[4];
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: diskProc.running = true
    }

    onIsOpenChanged: {
        if (isOpen)
            diskProc.running = true;
    }
}
