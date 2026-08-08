import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "widgets"
import "panels"
import "components"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Style.barHeight
            color: Theme.barBg

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ═══════ LEFT ═══════
                Clock {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                }

                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 4
                }

                SubMap {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 4
                }

                ActiveWindow {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.maximumWidth: 300
                }

                Item {
                    Layout.fillWidth: true
                }

                // ═══════ RIGHT ═══════

                SysTray {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 8
                }

                /*
                CodexUsage {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 12
				}
				*/

                DiskUsage {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 8
                }

                NetworkStatus {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                BluetoothStatus {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                MemoryUsage {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Brightness {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                AudioSource {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                AudioOutput {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Battery {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Notifications {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                PowerMenu {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 4
                    Layout.rightMargin: 8
                }
            }

            // ═══════ CENTER ═══════
            Date {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelOverlayWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: PanelManager.openPanel !== null ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "shell-panels"

            exclusionMode: ExclusionMode.Ignore

            visible: PanelManager.openPanel !== null

            // ── Panels ──

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: PanelManager.closeAll()

                AudioPanel {
                    id: audioPanel
                    anchors.fill: parent
                    panelId: "audioPanel"
                    anchor: "top-right"
                    preferredWidth: 420
                    preferredHeight: 540
                }

                CalendarPanel {
                    id: calendarPanel
                    anchors.fill: parent
                    panelId: "calendarPanel"
                    anchor: "top-center"
                    preferredWidth: 380
                    preferredHeight: 420
                }

                NetworkPanel {
                    id: networkPanel
                    anchors.fill: parent
                    panelId: "networkPanel"
                    anchor: "top-right"
                    preferredWidth: 400
                    preferredHeight: 480
                }

                BluetoothPanel {
                    id: bluetoothPanel
                    anchors.fill: parent
                    panelId: "bluetoothPanel"
                    anchor: "top-right"
                    preferredWidth: 400
                    preferredHeight: 460
                }

                BrightnessPanel {
                    id: brightnessPanel
                    anchors.fill: parent
                    panelId: "brightnessPanel"
                    anchor: "top-right"
                    preferredWidth: 380
                    preferredHeight: 200
                }

                /*
                CodexPanel {
                    id: codexPanel
                    anchors.fill: parent
                    panelId: "codexPanel"
                    anchor: "top-right"
                    preferredWidth: 400
                    preferredHeight: 200
                }
				*/

                DiskPanel {
                    id: diskPanel
                    anchors.fill: parent
                    panelId: "diskPanel"
                    anchor: "top-right"
                    preferredWidth: 400
                    preferredHeight: 310
                }

                NotificationsPanel {
                    id: notificationsPanel
                    anchors.fill: parent
                    panelId: "notificationsPanel"
                    anchor: "top-right"
                    preferredWidth: 420
                    preferredHeight: 540
                }

                PowerMenuPanel {
                    id: powerMenuPanel
                    anchors.fill: parent
                    panelId: "powerMenuPanel"
                    anchor: "top-right"
                    preferredWidth: 380
                    preferredHeight: 380
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: trayMenuOverlay
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: PanelManager.trayMenuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "shell-tray-menu"

            exclusionMode: ExclusionMode.Ignore
            visible: PanelManager.trayMenuOpen

            // Click anywhere outside the menu to close
            MouseArea {
                anchors.fill: parent
                onClicked: PanelManager.closeTrayMenu()
            }

            // Escape to close
            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: PanelManager.closeTrayMenu()
            }

            // QsMenuOpener lives here in the overlay
            QsMenuOpener {
                id: trayMenuOpener
                menu: PanelManager.trayMenuHandle
            }

            // Menu content positioned at the anchor point
            Rectangle {
                id: trayMenuRect
                x: Math.max(Style.marginS, Math.min(PanelManager.trayMenuX - width / 2, parent.width - width - Style.marginS))
                y: PanelManager.trayMenuY + Style.marginM

                width: trayMenuCol.implicitWidth + Style.marginL * 2
                height: trayMenuCol.implicitHeight + Style.marginS * 2
                radius: Style.radiusM
                color: Theme.panelBg
                border.color: Theme.cardBorder
                border.width: Style.borderS

                opacity: PanelManager.trayMenuOpen ? 1.0 : 0.0
                scale: PanelManager.trayMenuOpen ? 1.0 : 0.95
                transformOrigin: Item.Top

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

                // Prevent click-through to the backdrop
                MouseArea {
                    anchors.fill: parent
                    onClicked: {} // absorb
                }

                ColumnLayout {
                    id: trayMenuCol
                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: trayMenuOpener.children ? [...trayMenuOpener.children.values] : []

                        delegate: Rectangle {
                            id: trayMenuEntry
                            required property var modelData

                            Layout.preferredWidth: Math.max(180, trayMenuEntryRow.implicitWidth + Style.marginXL * 2)
                            Layout.preferredHeight: modelData?.isSeparator ? 8 : Math.max(28, trayMenuEntryText.implicitHeight + Style.marginS * 2)

                            color: "transparent"
                            radius: Style.radiusS

                            // Separator
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - Style.marginL
                                height: 1
                                color: Theme.cardBorder
                                visible: modelData?.isSeparator ?? false
                            }

                            // Menu item
                            Rectangle {
                                anchors.fill: parent
                                color: trayMenuItemMa.containsMouse ? Theme.hoverBg : "transparent"
                                radius: Style.radiusS
                                visible: !(modelData?.isSeparator ?? false)

                                RowLayout {
                                    id: trayMenuEntryRow
                                    anchors.fill: parent
                                    anchors.leftMargin: Style.marginM
                                    anchors.rightMargin: Style.marginM
                                    spacing: Style.marginS

                                    // Checkbox / Radio indicator
                                    Item {
                                        visible: (modelData?.buttonType ?? 0) !== 0
                                        implicitWidth: 14
                                        implicitHeight: 14
                                        Layout.alignment: Qt.AlignVCenter

                                        readonly property bool isChecked: modelData?.checkState === Qt.Checked || (modelData?.checked ?? false)
                                        readonly property bool isRadio: (modelData?.buttonType ?? 0) === 2

                                        Rectangle {
                                            visible: !parent.isRadio
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: Style.radiusXS
                                            color: "transparent"
                                            border.color: parent.isChecked ? Theme.primary : Theme.overlay1
                                            border.width: Style.borderM

                                            IconText {
                                                visible: parent.parent.isChecked
                                                anchors.centerIn: parent
                                                text: "\uf00c"
                                                font.pixelSize: 8
                                                color: Theme.primary
                                            }
                                        }

                                        Rectangle {
                                            visible: parent.isRadio
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: "transparent"
                                            border.color: parent.isChecked ? Theme.primary : Theme.overlay1
                                            border.width: Style.borderM

                                            Rectangle {
                                                visible: parent.parent.isChecked
                                                anchors.centerIn: parent
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: Theme.primary
                                            }
                                        }
                                    }

                                    PanelText {
                                        id: trayMenuEntryText
                                        Layout.fillWidth: true
                                        text: modelData?.text !== "" ? modelData?.text.replace(/[\n\r]+/g, ' ') : "..."
                                        pointSize: Style.fontS
                                        color: (modelData?.enabled ?? true) ? (trayMenuItemMa.containsMouse ? Theme.onHover : Theme.text) : Theme.overlay1
                                        verticalAlignment: Text.AlignVCenter
                                        wrapMode: Text.WordWrap
                                    }

                                    Image {
                                        Layout.preferredWidth: Style.marginL
                                        Layout.preferredHeight: Style.marginL
                                        source: modelData?.icon ?? ""
                                        visible: (modelData?.icon ?? "") !== ""
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    IconText {
                                        text: "\uf054"
                                        font.pixelSize: 8
                                        visible: modelData?.hasChildren ?? false
                                        color: trayMenuItemMa.containsMouse ? Theme.onHover : Theme.subtext0
                                    }
                                }

                                MouseArea {
                                    id: trayMenuItemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && PanelManager.trayMenuOpen

                                    onClicked: {
                                        if (modelData && !modelData.isSeparator && !modelData.hasChildren) {
                                            modelData.triggered();
                                            PanelManager.closeTrayMenu();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
