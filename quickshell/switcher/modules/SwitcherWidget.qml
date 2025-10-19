pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../services/"
import "../common/widgets/"

Item {
    id: root
    required property var panelWindow
    property color activeBorderColor: "#89b4fa"

    property var windowByAddress: HyprlandData.windowByAddress

    property var windowsList
    property real windowImplicitWidth: 320
    property real windowImplicitHeight: 180
    property real windowSpacing: 30
    property int maxColumns: 5

    property int windowCount: Hyprland.toplevels.values.length

    property int columns: Math.min(windowCount, maxColumns)
    property int rows: Math.ceil(windowCount / columns)

    implicitWidth: (windowImplicitWidth * columns) + (windowSpacing * (columns - 1)) + 120
    implicitHeight: (windowImplicitHeight * rows) + (windowSpacing * (rows - 1)) + 120

    function transparentize(color, percentage = 1) {
        var c = Qt.color(color);
        return Qt.rgba(c.r, c.g, c.b, c.a * (1 - percentage));
    }

    Rectangle {
        id: overviewBackground
        property real padding: 30
        anchors.centerIn: parent

        width: (root.windowImplicitWidth * root.columns) + (root.windowSpacing * (root.columns - 1)) + padding
        height: (root.windowImplicitHeight * root.rows) + (root.windowSpacing * (root.rows - 1)) + padding * 2

        radius: 16
        color: root.transparentize("#11111b", 0.1)
        border.width: 2
        border.color: "#313244"

        GridLayout {
            id: windowSpace
            anchors.centerIn: parent
            columns: root.columns
            rowSpacing: root.windowSpacing
            columnSpacing: root.windowSpacing

            Repeater {
                id: windowRepeater

                model: ScriptModel {
                    values: {
                        root.windowsList;
                    }
                }
                delegate: Rectangle {
                    id: window
                    required property int index
                    required property var modelData

                    property var windowData: root.windowByAddress[`0x${modelData.address}`]
                    property var iconPath: Quickshell.iconPath(windowData.class ?? "application-x-executable", "image-missing")

                    implicitWidth: root.windowImplicitWidth
                    implicitHeight: root.windowImplicitHeight + 30

                    MouseArea {
                        id: windowArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button == Qt.RightButton) {
                                Hyprland.dispatch(`closewindow address:${window.windowData.address}`);
                            } else {
                                Hyprland.dispatch(`focuswindow address:${window.windowData.address}`);
                                Hyprland.dispatch(`alterzorder top, address:${window.windowData.address}`);
                                Hyprland.dispatch("submap reset");
                                GlobalStates.focusedWindowIndex = 1;
                                GlobalStates.switcherOpen = false;
                            }
                        }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 0
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // === Title Bar ===
                            Rectangle {
                                id: titleBar
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                color: "#11111b"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Image {
                                        id: windowIcon
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20
                                        source: window.iconPath
                                        sourceSize: Qt.size(20, 20)
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    StyledText {
                                        text: window.windowData.initialTitle || "Untitled"
                                        color: "#cdd6f4"
                                        elide: Text.ElideRight
                                        font.pixelSize: 14
                                        Layout.fillWidth: true
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // === Window Preview ===
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#181825"

                                ScreencopyView {
                                    id: windowPreview
                                    anchors.fill: parent
                                    live: true
                                    captureSource: GlobalStates.switcherOpen ? window.modelData.wayland : null
                                }
                            }
                        }
                    }

                    // === Focus Highlight Overlay ===
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        clip: true
                        color: "transparent"
                        border.width: 2
                        border.color: window.windowData.focusHistoryID == GlobalStates.focusedWindowIndex ? root.activeBorderColor : "#313244"
                    }
                }
            }
        }
    }
}
