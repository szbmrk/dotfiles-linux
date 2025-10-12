import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Common
import qs.Services

Item {
    id: root

    required property var processListModalLoader
    required property var controlCenterLoader
    required property var dankDashPopoutLoader

    IpcHandler {
        function open(): string {
            root.processListModalLoader.active = true;
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.show();

            return "PROCESSLIST_OPEN_SUCCESS";
        }

        function close(): string {
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.hide();

            return "PROCESSLIST_CLOSE_SUCCESS";
        }

        function toggle(): string {
            root.processListModalLoader.active = true;
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.toggle();

            return "PROCESSLIST_TOGGLE_SUCCESS";
        }

        target: "processlist"
    }

    IpcHandler {
        function open(): string {
            root.controlCenterLoader.active = true;
            if (root.controlCenterLoader.item) {
                root.controlCenterLoader.item.open();
                return "CONTROL_CENTER_OPEN_SUCCESS";
            }
            return "CONTROL_CENTER_OPEN_FAILED";
        }

        function close(): string {
            if (root.controlCenterLoader.item) {
                root.controlCenterLoader.item.close();
                return "CONTROL_CENTER_CLOSE_SUCCESS";
            }
            return "CONTROL_CENTER_CLOSE_FAILED";
        }

        function toggle(): string {
            root.controlCenterLoader.active = true;
            if (root.controlCenterLoader.item) {
                root.controlCenterLoader.item.toggle();
                return "CONTROL_CENTER_TOGGLE_SUCCESS";
            }
            return "CONTROL_CENTER_TOGGLE_FAILED";
        }

        target: "control-center"
    }

    IpcHandler {
        function open(tab: string): string {
            root.dankDashPopoutLoader.active = true;
            if (root.dankDashPopoutLoader.item) {
                switch (tab.toLowerCase()) {
                case "media":
                    root.dankDashPopoutLoader.item.currentTabIndex = 1;
                    break;
                case "weather":
                    root.dankDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0;
                    break;
                default:
                    root.dankDashPopoutLoader.item.currentTabIndex = 0;
                    break;
                }
                root.dankDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen);
                root.dankDashPopoutLoader.item.dashVisible = true;
                return "DASH_OPEN_SUCCESS";
            }
            return "DASH_OPEN_FAILED";
        }

        function close(): string {
            if (root.dankDashPopoutLoader.item) {
                root.dankDashPopoutLoader.item.dashVisible = false;
                return "DASH_CLOSE_SUCCESS";
            }
            return "DASH_CLOSE_FAILED";
        }

        function toggle(tab: string): string {
            root.dankDashPopoutLoader.active = true;
            if (root.dankDashPopoutLoader.item) {
                if (root.dankDashPopoutLoader.item.dashVisible) {
                    root.dankDashPopoutLoader.item.dashVisible = false;
                } else {
                    switch (tab.toLowerCase()) {
                    case "media":
                        root.dankDashPopoutLoader.item.currentTabIndex = 1;
                        break;
                    case "weather":
                        root.dankDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0;
                        break;
                    default:
                        root.dankDashPopoutLoader.item.currentTabIndex = 0;
                        break;
                    }
                    root.dankDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen);
                    root.dankDashPopoutLoader.item.dashVisible = true;
                }
                return "DASH_TOGGLE_SUCCESS";
            }
            return "DASH_TOGGLE_FAILED";
        }

        target: "dash"
    }
}
