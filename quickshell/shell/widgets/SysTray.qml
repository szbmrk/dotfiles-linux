import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../"
import "../components"

Row {
    id: trayRoot
    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayDelegate
            required property var modelData

            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: trayIcon
                anchors.fill: parent
                source: modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true

                opacity: iconMa.containsMouse ? 0.8 : 1.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.animFast
                    }
                }
            }

            // Tooltip
            Rectangle {
                id: trayTooltip
                visible: iconMa.containsMouse && !PanelManager.trayMenuOpen
                z: 999

                anchors.bottom: trayDelegate.top
                anchors.horizontalCenter: trayDelegate.horizontalCenter
                anchors.bottomMargin: Style.marginM

                width: tooltipLabel.implicitWidth + Style.marginL * 2
                height: tooltipLabel.implicitHeight + Style.marginS * 2
                radius: Style.radiusS
                color: Theme.panelBg
                border.color: Theme.cardBorder
                border.width: Style.borderS

                opacity: visible ? 1.0 : 0.0
                scale: visible ? 1.0 : 0.9
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

                PanelText {
                    id: tooltipLabel
                    anchors.centerIn: parent
                    text: modelData.tooltipTitle || modelData.title || modelData.id || "Tray Item"
                    pointSize: Style.fontS
                    color: Theme.text
                }
            }

            MouseArea {
                id: iconMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        if (!modelData.onlyMenu)
                            modelData.activate();
                    } else if (mouse.button === Qt.MiddleButton) {
                        if (modelData.secondaryActivate)
                            modelData.secondaryActivate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu && modelData.menu) {
                            var globalPos = trayDelegate.mapToItem(null, trayDelegate.width / 2, trayDelegate.height);
                            PanelManager.openTrayMenu(modelData, modelData.menu, globalPos.x, globalPos.y);
                        }
                    }
                }
            }
        }
    }

    Text {
        text: "|"
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Style.fontXXL
        font.weight: Style.weightRegular
        visible: SystemTray.items.values.length > 0
    }
}
