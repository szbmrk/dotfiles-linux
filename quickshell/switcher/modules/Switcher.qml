pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "../services/"

Scope {
    id: switcherScope
    Variants {
        id: switcherVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            screen: modelData
            visible: GlobalStates.switcherOpen

            WlrLayershell.namespace: "quickshell:switcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            color: Qt.rgba(0, 0, 0, 0.5)

            property var windowByAddress: HyprlandData.windowByAddress
            property var windowsList: (function () {
                    const vals = Hyprland.toplevels.values.filter(toplevel => {
                        const address = `0x${toplevel.address}`;
                        return !!root.windowByAddress[address];
                    });
                    vals.sort(function (a, b) {
                        const wa = root.windowByAddress[`0x${a.address}`];
                        const wb = root.windowByAddress[`0x${b.address}`];
                        const fa = (wa && wa.focusHistoryID) ? wa.focusHistoryID : 0;
                        const fb = (wb && wb.focusHistoryID) ? wb.focusHistoryID : 0;
                        return fa - fb;
                    });
                    return vals;
                })()

            mask: Region {
                item: GlobalStates.switcherOpen ? keyHandler : null
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        GlobalStates.switcherOpen = false;
                }
            }

            Connections {
                target: GlobalStates
                function onSwitcherOpenChanged() {
                    if (GlobalStates.switcherOpen) {
                        delayedGrabTimer.start();
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: 150
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = GlobalStates.switcherOpen;
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            Item {
                id: keyHandler
                anchors.fill: parent
                visible: GlobalStates.switcherOpen
                focus: GlobalStates.switcherOpen
                property int windowCount: Hyprland.toplevels.values.length

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.switcherOpen = false;
                        Hyprland.dispatch("submap reset");
                        event.accepted = true;
                    }
                    if (event.key == Qt.Key_Left) {
                        GlobalStates.focusedWindowIndex = (GlobalStates.focusedWindowIndex - 1 + windowCount) % windowCount;
                        event.accepted = true;
                    }
                    if (event.key == Qt.Key_Right) {
                        GlobalStates.focusedWindowIndex = (GlobalStates.focusedWindowIndex + 1) % windowCount;
                        event.accepted = true;
                    }
                    if (event.key == Qt.Key_Return) {
                        Hyprland.dispatch(`focuswindow address:0x${root.windowsList[GlobalStates.focusedWindowIndex].address}`);
                        Hyprland.dispatch(`alterzorder top, address:0x${root.windowsList[GlobalStates.focusedWindowIndex].address}`);
                        Hyprland.dispatch("submap reset");
                        GlobalStates.switcherOpen = false;
                        GlobalStates.focusedWindowIndex = 1;
                        event.accepted = true;
                    }
                    if (event.key == Qt.Key_Tab && (event.modifiers & Qt.AltModifier)) {
                        GlobalStates.focusedWindowIndex = (GlobalStates.focusedWindowIndex + 1) % windowCount;
                        event.accepted = true;
                    }
                }

                Keys.onReleased: event => {
                    if (!(event.modifiers & Qt.AltModifier)) {
                        Hyprland.dispatch(`focuswindow address:0x${root.windowsList[GlobalStates.focusedWindowIndex].address}`);
                        Hyprland.dispatch(`alterzorder top, address:0x${root.windowsList[GlobalStates.focusedWindowIndex].address}`);
                        Hyprland.dispatch("submap reset");
                        GlobalStates.switcherOpen = false;
                        GlobalStates.focusedWindowIndex = 1;
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                visible: GlobalStates.switcherOpen
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 140
                }

                Loader {
                    id: switcherLoader
                    active: GlobalStates.switcherOpen
                    sourceComponent: SwitcherWidget {
                        panelWindow: root
                        windowsList: root.windowsList
                        visible: true
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "switcher"

        function toggle() {
            GlobalStates.switcherOpen = !GlobalStates.switcherOpen;
        }
        function close() {
            GlobalStates.switcherOpen = false;
        }
        function open() {
            GlobalStates.switcherOpen = true;
        }
    }
}
