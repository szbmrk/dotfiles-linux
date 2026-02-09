pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property int maxVisible: 5
    property int maxHistory: 100
    property bool doNotDisturb: false

    property real lastSeenTs: 0

    // State
    property ListModel activeList: ListModel {}
    property ListModel historyList: ListModel {}
    property var activeNotifications: ({})  // id → { notification, metadata }
    property int nextId: 1

    // Unseen count (notifications added after last panel open)
    readonly property int unseenCount: {
        var c = 0;
        for (var i = 0; i < historyList.count; i++) {
            var item = historyList.get(i);
            if (item && item.timestampMs > lastSeenTs)
                c++;
        }
        return c;
    }

    // History file path
    readonly property string historyDir: (Quickshell.cacheDir || "/tmp") + "/shell-notifications"
    readonly property string historyFile: historyDir + "/history.json"
    readonly property string stateFile: historyDir + "/state.json"

    // Progress timer
    Timer {
        interval: 50
        repeat: true
        running: activeList.count > 0
        onTriggered: updateAllProgress()
    }

    // Debounced save timer
    Timer {
        id: saveTimer
        interval: 200
        onTriggered: performSaveHistory()
    }

    // Notification server
    NotificationServer {
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        onNotification: notification => handleNotification(notification)
    }

    signal animateAndRemove(string notificationId)

    Component.onCompleted: {
        ensureDirProc.running = true;
    }

    // Ensure cache directory exists
    Process {
        id: ensureDirProc
        command: ["mkdir", "-p", root.historyDir]
        onExited: function (exitCode, exitStatus) {
            loadState();
            loadHistory();
        }
    }

    function handleNotification(notification) {
        var data = createData(notification);

        // Always add to history (even in DND)
        addToHistory(data);

        if (doNotDisturb)
            return;

        // Duplicate check disabled - show all notifications separately
        // var dupIdx = findDuplicateIndex(data.appName, data.summary);
        // if (dupIdx >= 0) {
        //     activeList.setProperty(dupIdx, "body", data.body);
        //     activeList.setProperty(dupIdx, "urgency", data.urgency);
        //     activeList.setProperty(dupIdx, "progress", 1.0);
        //     activeList.setProperty(dupIdx, "originalImage", data.originalImage);
        //     activeList.setProperty(dupIdx, "actionsJson", data.actionsJson);
        //     var existingId = activeList.get(dupIdx).id;
        //     if (activeNotifications[existingId]) {
        //         activeNotifications[existingId].metadata.timestamp = Date.now();
        //         activeNotifications[existingId].notification = notification;
        //     }
        //     notification.tracked = true;
        //     return;
        // }

        // Store active
        activeNotifications[data.id] = {
            notification: notification,
            metadata: {
                timestamp: Date.now(),
                duration: calculateDuration(data),
                paused: false,
                pauseTime: 0
            }
        };

        notification.tracked = true;
        activeList.insert(0, data);

        while (activeList.count > maxVisible) {
            var last = activeList.get(activeList.count - 1);
            cleanupNotification(last.id);
            activeList.remove(activeList.count - 1);
        }
    }

    function createData(n) {
        var id = "notif_" + (nextId++);
        var image = n.image || "";
        if (!image && n.appIcon) {
            if (n.appIcon.startsWith("/") || n.appIcon.startsWith("file://"))
                image = n.appIcon;
        }

        var now = new Date();
        return {
            id: id,
            summary: n.summary || "",
            body: stripTags(n.body || ""),
            appName: getAppName(n.appName || n.desktopEntry || ""),
            urgency: (n.urgency >= 0 && n.urgency <= 2) ? n.urgency : 1,
            timestamp: now,
            timestampMs: now.getTime(),
            progress: 1.0,
            originalImage: image,
            actionsJson: JSON.stringify((n.actions || []).map(function (a) {
                return {
                    text: (a.text || "").trim() || "Action",
                    identifier: a.identifier || ""
                };
            }))
        };
    }

    // ═══════════════════════════════════════════
    //  History management
    // ═══════════════════════════════════════════

    function addToHistory(data) {
        // Insert a copy at front
        historyList.insert(0, {
            id: data.id,
            summary: data.summary,
            body: data.body,
            appName: data.appName,
            urgency: data.urgency,
            timestampMs: data.timestampMs,
            originalImage: data.originalImage,
            actionsJson: data.actionsJson
        });

        // Trim overflow
        while (historyList.count > maxHistory)
            historyList.remove(historyList.count - 1);

        saveHistory();
    }

    function removeFromHistory(id) {
        for (var i = 0; i < historyList.count; i++) {
            if (historyList.get(i).id === id) {
                historyList.remove(i);
                saveHistory();
                return;
            }
        }
    }

    function clearHistory() {
        historyList.clear();
        saveHistory();
    }

    function updateLastSeenTs() {
        lastSeenTs = Date.now();
        saveState();
    }

    // ═══════════════════════════════════════════
    //  Persistence
    // ═══════════════════════════════════════════

    function saveHistory() {
        saveTimer.restart();
    }

    function performSaveHistory() {
        var arr = [];
        for (var i = 0; i < historyList.count; i++) {
            var item = historyList.get(i);
            arr.push({
                id: item.id,
                summary: item.summary,
                body: item.body,
                appName: item.appName,
                urgency: item.urgency,
                timestampMs: item.timestampMs,
                originalImage: item.originalImage || "",
                actionsJson: item.actionsJson || "[]"
            });
        }
        var jsonStr = JSON.stringify(arr).replace(/'/g, "'\\''");
        historyWriteProc.command = ["bash", "-c", "printf '%s' '" + jsonStr + "' > " + historyFile];
        historyWriteProc.running = true;
    }

    Process {
        id: historyWriteProc
    }

    function loadHistory() {
        historyReadProc.running = true;
    }

    Process {
        id: historyReadProc
        command: ["cat", root.historyFile]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var arr = JSON.parse(data);
                    historyList.clear();
                    for (var i = 0; i < arr.length; i++) {
                        var item = arr[i];
                        historyList.append({
                            id: item.id || ("hist_" + i),
                            summary: item.summary || "",
                            body: item.body || "",
                            appName: item.appName || "Unknown",
                            urgency: item.urgency || 1,
                            timestampMs: item.timestampMs || 0,
                            originalImage: item.originalImage || "",
                            actionsJson: item.actionsJson || "[]"
                        });
                    }
                } catch (e)
                // No history or corrupt file — start fresh
                {}
            }
        }
    }

    function saveState() {
        var jsonStr = JSON.stringify({
            lastSeenTs: lastSeenTs
        }).replace(/'/g, "'\\''");
        stateWriteProc.command = ["bash", "-c", "printf '%s' '" + jsonStr + "' > " + stateFile];
        stateWriteProc.running = true;
    }

    Process {
        id: stateWriteProc
    }

    function loadState() {
        stateReadProc.running = true;
    }

    Process {
        id: stateReadProc
        command: ["cat", root.stateFile]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var obj = JSON.parse(data);
                    if (obj.lastSeenTs)
                        root.lastSeenTs = obj.lastSeenTs;
                } catch (e) {}
            }
        }
    }

    // ═══════════════════════════════════════════
    //  Active notification management
    // ═══════════════════════════════════════════

    function calculateDuration(data) {
        var durations = [3000, 8000, 15000];  // low, normal, critical
        return durations[data.urgency] || 8000;
    }

    function findDuplicateIndex(appName, summary) {
        for (var i = 0; i < activeList.count; i++) {
            var existing = activeList.get(i);
            if (existing.appName === appName && existing.summary === summary)
                return i;
        }
        return -1;
    }

    function updateAllProgress() {
        var now = Date.now();
        var toRemove = [];

        for (var i = 0; i < activeList.count; i++) {
            var notif = activeList.get(i);
            var nd = activeNotifications[notif.id];
            if (!nd)
                continue;
            var meta = nd.metadata;
            if (meta.duration === -1 || meta.paused)
                continue;

            var elapsed = now - meta.timestamp;
            var progress = Math.max(1.0 - (elapsed / meta.duration), 0.0);

            if (progress <= 0) {
                toRemove.push(notif.id);
            } else if (Math.abs(notif.progress - progress) > 0.005) {
                activeList.setProperty(i, "progress", progress);
            }
        }

        for (var j = 0; j < toRemove.length; j++) {
            animateAndRemove(toRemove[j]);
        }
    }

    function pauseTimeout(id) {
        var nd = activeNotifications[id];
        if (nd && !nd.metadata.paused) {
            nd.metadata.paused = true;
            nd.metadata.pauseTime = Date.now();
        }
    }

    function resumeTimeout(id) {
        var nd = activeNotifications[id];
        if (nd && nd.metadata.paused) {
            nd.metadata.timestamp += Date.now() - nd.metadata.pauseTime;
            nd.metadata.paused = false;
        }
    }

    function dismissActiveNotification(id) {
        var index = findNotificationIndex(id);
        if (index >= 0)
            activeList.remove(index);
        cleanupNotification(id);
    }

    function dismissAllActive() {
        activeList.clear();
        activeNotifications = {};
    }

    function invokeAction(id, actionId) {
        var nd = activeNotifications[id];
        if (!nd || !nd.notification)
            return false;

        var actions = nd.notification.actions || [];
        for (var i = 0; i < actions.length; i++) {
            if (actions[i].identifier === actionId) {
                try {
                    actions[i].invoke();
                } catch (e) {}
                return true;
            }
        }
        return false;
    }

    function findNotificationIndex(id) {
        for (var i = 0; i < activeList.count; i++) {
            if (activeList.get(i).id === id)
                return i;
        }
        return -1;
    }

    function cleanupNotification(id) {
        delete activeNotifications[id];
    }

    // ═══════════════════════════════════════════
    //  Utility
    // ═══════════════════════════════════════════

    function formatRelativeTime(timestampMs) {
        var now = Date.now();
        var diffMs = now - timestampMs;
        var diffSec = Math.floor(diffMs / 1000);
        var diffMin = Math.floor(diffSec / 60);
        var diffHour = Math.floor(diffMin / 60);
        var diffDay = Math.floor(diffHour / 24);

        if (diffSec < 60)
            return "Just now";
        if (diffMin < 60)
            return diffMin + "m ago";
        if (diffHour < 24)
            return diffHour + "h ago";
        if (diffDay === 1)
            return "Yesterday";
        if (diffDay < 7)
            return diffDay + "d ago";

        var d = new Date(timestampMs);
        return d.toLocaleDateString(Qt.locale(), "MMM d");
    }

    function getAppName(name) {
        if (!name || name.trim() === "")
            return "Unknown";
        name = name.trim();

        if (name.includes(".") && (name.startsWith("com.") || name.startsWith("org.") || name.startsWith("io."))) {
            var parts = name.split(".");
            var appPart = parts[parts.length - 1];
            if (appPart === "app" || appPart === "desktop")
                appPart = parts[parts.length - 2] || parts[0];
            if (appPart)
                name = appPart;
        }

        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    function stripTags(text) {
        return text.replace(/<[^>]*>?/gm, '');
    }
}
