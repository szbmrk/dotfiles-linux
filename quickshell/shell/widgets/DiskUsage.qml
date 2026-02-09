import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../components"

Text {
    id: root

    property string rootPercent: ""
    property string rootUsed: ""
    property string rootTotal: ""
    property string rootFree: ""
    property string homePercent: ""
    property string homeUsed: ""
    property string homeTotal: ""
    property string homeFree: ""

    text: ""
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: Theme.teal

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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggleById("diskPanel")
    }

    // ── Styled tooltip ──
    Rectangle {
        id: tooltip
        visible: mouseArea.containsMouse
        z: 999

        anchors.bottom: root.top
        anchors.horizontalCenter: root.horizontalCenter
        anchors.bottomMargin: Style.marginM

        width: tooltipLayout.implicitWidth + Style.marginXL * 2
        height: tooltipLayout.implicitHeight + Style.marginL * 2
        radius: Style.radiusM
        color: Theme.panelBg
        border.color: Theme.cardBorder
        border.width: Style.borderS

        // Entry animation
        opacity: mouseArea.containsMouse ? 1.0 : 0.0
        scale: mouseArea.containsMouse ? 1.0 : 0.9
        transformOrigin: Item.Bottom

        Behavior on opacity {
            NumberAnimation {
                duration: Style.animFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Style.animFast
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: tooltipLayout
            anchors.centerIn: parent
            spacing: Style.marginS

            // Header
            RowLayout {
                spacing: Style.marginS
                IconText {
                    text: ""
                    pointSize: Style.fontL
                    color: Theme.teal
                }
                PanelText {
                    text: "Disk Usage"
                    pointSize: Style.fontM
                    font.weight: Style.weightSemiBold
                    color: Theme.text
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.cardBorder
            }

            // Root row
            RowLayout {
                spacing: Style.marginM

                // Mini usage bar
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Theme.surface0

                    Rectangle {
                        width: parent.width * (parseInt(root.rootPercent) || 0) / 100
                        height: parent.height
                        radius: 3
                        color: {
                            var p = parseInt(root.rootPercent) || 0;
                            return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                        }
                    }
                }

                PanelText {
                    text: "/"
                    pointSize: Style.fontS
                    font.weight: Style.weightSemiBold
                    color: Theme.subtext1
                    Layout.preferredWidth: 40
                }

                PanelText {
                    text: root.rootPercent + "%"
                    pointSize: Style.fontS
                    font.weight: Style.weightBold
                    color: {
                        var p = parseInt(root.rootPercent) || 0;
                        return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                    }
                    Layout.preferredWidth: 30
                    horizontalAlignment: Text.AlignRight
                }

                PanelText {
                    text: root.rootUsed + " / " + root.rootTotal
                    pointSize: Style.fontS
                    color: Theme.subtext0
                }
            }

            // Home row
            RowLayout {
                spacing: Style.marginM

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Theme.surface0

                    Rectangle {
                        width: parent.width * (parseInt(root.homePercent) || 0) / 100
                        height: parent.height
                        radius: 3
                        color: {
                            var p = parseInt(root.homePercent) || 0;
                            return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                        }
                    }
                }

                PanelText {
                    text: "/home"
                    pointSize: Style.fontS
                    font.weight: Style.weightSemiBold
                    color: Theme.subtext1
                    Layout.preferredWidth: 40
                }

                PanelText {
                    text: root.homePercent + "%"
                    pointSize: Style.fontS
                    font.weight: Style.weightBold
                    color: {
                        var p = parseInt(root.homePercent) || 0;
                        return p > 90 ? Theme.red : p > 70 ? Theme.yellow : Theme.teal;
                    }
                    Layout.preferredWidth: 30
                    horizontalAlignment: Text.AlignRight
                }

                PanelText {
                    text: root.homeUsed + " / " + root.homeTotal
                    pointSize: Style.fontS
                    color: Theme.subtext0
                }
            }

            // Free space summary
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.cardBorder
            }

            RowLayout {
                spacing: Style.marginM

                PanelText {
                    text: "Free"
                    pointSize: Style.fontXS
                    color: Theme.overlay1
                }

                PanelText {
                    text: "/  " + root.rootFree + "   /home  " + root.homeFree
                    pointSize: Style.fontXS
                    color: Theme.overlay1
                }
            }
        }
    }
}
