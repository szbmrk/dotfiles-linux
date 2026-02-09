pragma Singleton

import Quickshell
import QtQuick

// Centralized panel state — tracks which panel is open
Singleton {
    id: root

    property var openPanel: null
    property var registeredPanels: ({})

    // ── Tray context menu state ──
    property bool trayMenuOpen: false
    property var trayMenuItem: null      // the SystemTray item
    property var trayMenuHandle: null    // the QsMenuHandle
    property real trayMenuX: 0
    property real trayMenuY: 0

    function openTrayMenu(trayItem, menuHandle, globalX, globalY) {
        trayMenuItem = trayItem;
        trayMenuHandle = menuHandle;
        trayMenuX = globalX;
        trayMenuY = globalY;
        trayMenuOpen = true;
    }

    function closeTrayMenu() {
        trayMenuOpen = false;
        trayMenuItem = null;
        trayMenuHandle = null;
    }

    signal panelOpened(string panelId)
    signal panelClosed(string panelId)

    function register(panel) {
        var panels = registeredPanels;
        panels[panel.panelId] = panel;
        registeredPanels = panels;
    }

    function open(panel) {
        if (openPanel && openPanel !== panel) {
            openPanel.close();
        }
        openPanel = panel;
        panel.isOpen = true;
        panelOpened(panel.panelId);
    }

    function close(panel) {
        if (openPanel === panel) {
            openPanel = null;
        }
        panel.isOpen = false;
        panelClosed(panel.panelId);
    }

    function closeAll() {
        if (openPanel) {
            openPanel.close();
        }
    }

    function toggle(panel) {
        if (openPanel === panel) {
            panel.close();
        } else {
            open(panel);
        }
    }

    function toggleById(panelId) {
        var panel = registeredPanels[panelId];
        if (panel) {
            toggle(panel);
        }
    }

    function openById(panelId) {
        var panel = registeredPanels[panelId];
        if (panel) {
            open(panel);
        }
    }
}
