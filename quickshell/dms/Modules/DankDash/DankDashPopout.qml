import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs.Common
import qs.Widgets
import qs.Modules.DankDash

DankPopout {
    id: root

    // === Hardcoded UI settings ===
    property bool dashVisible: false
    property var triggerScreen: null
    property int currentTabIndex: 0
    property string barPosition: "top"
    property bool weatherEnabled: true

    // === Hardcoded Catppuccin Mocha Blue palette ===
    property color colorPrimary: "#89b4fa"
    property color colorSurface: "#1e1e2e"
    property color colorSurfaceContainer: "#2a2b3b"
    property color colorSurfaceTint: "#89b4fa"
    property color colorText: "#cdd6f4"
    property color colorAccent: "#f5c2e7"
    property color colorError: "#f38ba8"
    property color colorWarning: "#f9e2af"
    property int spacingXS: 4
    property int spacingS: 8
    property int spacingM: 16
    property int spacingL: 24
    property int cornerRadius: 12
    property int longDuration: 600
    property int extraLongDuration: 1200

    // === Popup layout ===
    popupWidth: 700
    popupHeight: contentLoader.item ? contentLoader.item.implicitHeight : 500
    triggerX: Screen.width - 620 - spacingL
    triggerY: 20
    triggerWidth: 80
    shouldBeVisible: dashVisible
    visible: shouldBeVisible

    function setTriggerPosition(x, y, width, section, screen) {
        triggerSection = section;
        triggerScreen = screen;
        triggerY = y;

        const popupWidth = root.popupWidth;
        const popupHeight = root.popupHeight;

        if (section === "center" && (barPosition === "top" || barPosition === "bottom")) {
            const screenWidth = screen ? screen.width : Screen.width;
            triggerX = (screenWidth - popupWidth) / 2;
            triggerWidth = popupWidth;
        } else if (section === "center" && (barPosition === "left" || barPosition === "right")) {
            const screenHeight = screen ? screen.height : Screen.height;
            triggerX = (screenHeight - popupHeight) / 2;
            triggerWidth = popupHeight;
        } else {
            triggerX = x;
            triggerWidth = width;
        }
    }

    onDashVisibleChanged: dashVisible ? open() : close()
    onBackgroundClicked: dashVisible = false

    content: Component {
        Rectangle {
            id: mainContainer
            color: colorSurfaceContainer
            radius: cornerRadius
            implicitHeight: contentColumn.height + spacingM * 2
            focus: true

            Component.onCompleted: {
                if (root.shouldBeVisible)
                    forceActiveFocus();
            }

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    root.dashVisible = false;
                    event.accepted = true;
                }
            }

            Connections {
                target: root
                function onShouldBeVisibleChanged() {
                    if (root.shouldBeVisible)
                        Qt.callLater(() => mainContainer.forceActiveFocus());
                }
            }

            Column {
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: spacingM
                }
                spacing: spacingS

                DankTabBar {
                    id: tabBar
                    width: parent.width
                    height: 48
                    currentIndex: root.currentTabIndex
                    spacing: spacingS
                    equalWidthTabs: true

                    model: {
                        let tabs = [
                            {
                                icon: "dashboard",
                                text: I18n.tr("Overview")
                            },
                            {
                                icon: "music_note",
                                text: I18n.tr("Media")
                            }
                        ];
                        if (root.weatherEnabled) {
                            tabs.push({
                                icon: "wb_sunny",
                                text: I18n.tr("Weather")
                            });
                        }
                        return tabs;
                    }

                    onTabClicked: function (index) {
                        root.currentTabIndex = index;
                    }
                }

                Item {
                    width: parent.width
                    height: spacingXS
                }

                StackLayout {
                    id: pages
                    width: parent.width
                    implicitHeight: {
                        if (currentIndex === 0)
                            return overviewTab.implicitHeight;
                        if (currentIndex === 1)
                            return mediaTab.implicitHeight;
                        if (root.weatherEnabled && currentIndex === 2)
                            return weatherTab.implicitHeight;
                        return overviewTab.implicitHeight;
                    }
                    currentIndex: root.currentTabIndex

                    OverviewTab {
                        id: overviewTab

                        onSwitchToWeatherTab: {
                            if (root.weatherEnabled) {
                                tabBar.currentIndex = 2;
                                tabBar.tabClicked(2);
                            }
                        }

                        onSwitchToMediaTab: {
                            tabBar.currentIndex = 1;
                            tabBar.tabClicked(1);
                        }
                    }

                    MediaPlayerTab {
                        id: mediaTab
                    }

                    WeatherTab {
                        id: weatherTab
                        visible: root.weatherEnabled && root.currentTabIndex === 2
                    }
                }
            }
        }
    }
}
