import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property string weeklyPercent: "80"

    property string initialization: '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"clientInfo":{"name":"shell","title":"Shell","version":"0.1.0"}}}'
    property string usageRequest: '{"jsonrpc":"2.0","id":1,"method":"account/rateLimits/read"}'

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
                        text: "Resets: "
                        pointSize: Style.fontS
                        color: Theme.subtext0
                    }
                }
            }
        }
    }

    // ── Data fetching ──
    Process {
        id: diskProc
        command: ["bash", "-c", "codex app-server"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.weeklyPercent = this.text.trim() || "0";
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
