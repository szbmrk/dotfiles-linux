import QtQuick
import QtQuick.Layouts
import "../"
import "../components"

PopupPanel {
    id: root

    onIsOpenChanged: {
        if (isOpen) {
            NotificationService.updateLastSeenTs();
            recalcRangeCounts();
        } else {
            expandedId = "";
        }
    }

    property var rangeCounts: [0, 0, 0, 0]
    property int currentRange: 1
    property string expandedId: ""

    function dateOnly(d) {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate());
    }

    function rangeForTimestamp(tsMs) {
        var dt = new Date(tsMs);
        var today = dateOnly(new Date());
        var thatDay = dateOnly(dt);
        var diffDays = Math.floor((today - thatDay) / (1000 * 60 * 60 * 24));
        if (diffDays === 0)
            return 0;
        if (diffDays === 1)
            return 1;
        return 2;
    }

    function recalcRangeCounts() {
        var m = NotificationService.historyList;
        var counts = [m.count, 0, 0, 0];
        for (var i = 0; i < m.count; i++) {
            var item = m.get(i);
            if (item && item.timestampMs)
                counts[rangeForTimestamp(item.timestampMs) + 1]++;
        }
        rangeCounts = counts;
    }

    function isInCurrentRange(tsMs) {
        if (currentRange === 0)
            return true;
        return rangeForTimestamp(tsMs) === (currentRange - 1);
    }

    function hasNotificationsInRange() {
        var m = NotificationService.historyList;
        for (var i = 0; i < m.count; i++) {
            if (isInCurrentRange(m.get(i).timestampMs))
                return true;
        }
        return false;
    }

    Connections {
        target: NotificationService.historyList
        function onCountChanged() {
            root.recalcRangeCounts();
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: root.isOpen
        onTriggered: root.recalcRangeCounts()
    }

    panelContent: ColumnLayout {
        spacing: Style.marginM

        Card {
            Layout.fillWidth: true
            implicitHeight: headerCol.implicitHeight + Style.marginXL

            ColumnLayout {
                id: headerCol
                anchors.fill: parent
                anchors.margins: Style.marginM
                spacing: Style.marginM

                RowLayout {
                    spacing: Style.marginM

                    IconText {
                        text: "\uf0f3"
                        pointSize: Style.fontXXL
                        color: Theme.primary
                    }

                    PanelText {
                        text: "Notifications"
                        pointSize: Style.fontL
                        font.weight: Style.weightBold
                        Layout.fillWidth: true
                    }

                    // DND toggle
                    IconButton {
                        icon: NotificationService.doNotDisturb ? "\uf1f6" : "\uf0f3"  // bell-slash / bell
                        iconColor: NotificationService.doNotDisturb ? Theme.red : Theme.text
                        iconSize: Style.fontL
                        implicitWidth: 28
                        implicitHeight: 28
                        tooltip: "Do Not Disturb"
                        onClicked: NotificationService.doNotDisturb = !NotificationService.doNotDisturb
                    }

                    // Clear all
                    IconButton {
                        icon: ""  // trash
                        iconColor: Theme.red
                        iconSize: Style.fontL
                        implicitWidth: 28
                        implicitHeight: 28
                        tooltip: "Clear history"
                        visible: NotificationService.historyList.count > 0
                        onClicked: {
                            NotificationService.clearHistory();
                            root.close();
                        }
                    }

                    // Close
                    IconButton {
                        icon: "\uf00d"
                        iconColor: Theme.subtext0
                        iconSize: Style.fontL
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: root.close()
                    }
                }

                // ── Tab bar ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginXS
                    visible: NotificationService.historyList.count > 0

                    Repeater {
                        model: [
                            {
                                label: "All",
                                idx: 0
                            },
                            {
                                label: "Today",
                                idx: 1
                            },
                            {
                                label: "Yesterday",
                                idx: 2
                            },
                            {
                                label: "Earlier",
                                idx: 3
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: Style.radiusS
                            color: root.currentRange === modelData.idx ? Theme.primary : (tabMa.containsMouse ? Theme.hoverBg : Theme.surface0)

                            property int count: root.rangeCounts[modelData.idx] || 0

                            PanelText {
                                anchors.centerIn: parent
                                text: modelData.label + " (" + parent.count + ")"
                                pointSize: Style.fontXS
                                font.weight: Style.weightSemiBold
                                color: root.currentRange === modelData.idx ? Theme.onPrimary : Theme.text
                            }

                            MouseArea {
                                id: tabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentRange = modelData.idx
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Style.animFast
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════
        //  Notification list
        // ═══════════════════════════════════════
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Empty state
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.marginL
                visible: !root.hasNotificationsInRange()

                IconText {
                    text: "\uf1f6"
                    pointSize: NotificationService.historyList.count === 0 ? 48 : Style.fontXXL
                    color: Theme.overlay0
                    Layout.alignment: Qt.AlignHCenter
                }

                PanelText {
                    text: NotificationService.historyList.count === 0 ? "No notifications yet" : "Nothing in this range"
                    pointSize: NotificationService.historyList.count === 0 ? Style.fontL : Style.fontM
                    color: Theme.overlay0
                    Layout.alignment: Qt.AlignHCenter
                }

                PanelText {
                    visible: NotificationService.historyList.count === 0
                    text: "Notifications will appear here\nwhen you receive them."
                    pointSize: Style.fontS
                    color: Theme.overlay0
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentHeight: notifColumn.implicitHeight
                clip: true
                visible: root.hasNotificationsInRange()
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: notifColumn
                    width: flickable.width
                    spacing: Style.marginM

                    Repeater {
                        model: NotificationService.historyList

                        delegate: Item {
                            id: notifDelegate
                            Layout.fillWidth: true
                            visible: root.isInCurrentRange(model.timestampMs)
                            Layout.preferredHeight: visible ? contentCol.implicitHeight + Style.marginXL : 0

                            property string notificationId: model.id
                            property bool isExpanded: root.expandedId === notificationId
                            property bool canExpand: summaryText.truncated || bodyText.truncated
                            property var actionsList: {
                                try {
                                    return JSON.parse(model.actionsJson || "[]");
                                } catch (e) {
                                    return [];
                                }
                            }

                            // Card background
                            Rectangle {
                                anchors.fill: parent
                                radius: Style.radiusM
                                color: Theme.cardBg
                                border.color: Theme.cardBorder
                                border.width: Style.borderS
                            }

                            // Click to expand
                            MouseArea {
                                anchors.fill: parent
                                anchors.rightMargin: 36
                                enabled: notifDelegate.canExpand
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    root.expandedId = root.expandedId === notifDelegate.notificationId ? "" : notifDelegate.notificationId;
                                }
                            }

                            ColumnLayout {
                                id: contentCol
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Style.marginL
                                spacing: Style.marginM

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.marginL

                                    // App icon
                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        Layout.alignment: Qt.AlignTop
                                        radius: Style.radiusM
                                        color: Theme.surface0

                                        IconText {
                                            anchors.centerIn: parent
                                            text: "\uf0f3"
                                            pointSize: Style.fontL
                                            color: Theme.flamingo
                                        }

                                        Image {
                                            anchors.fill: parent
                                            source: model.originalImage || ""
                                            fillMode: Image.PreserveAspectCrop
                                            visible: status === Image.Ready
                                            smooth: true
                                            asynchronous: true
                                        }
                                    }

                                    // Text content
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Style.marginXS

                                        // App name + time
                                        RowLayout {
                                            spacing: Style.marginS

                                            // Urgency dot
                                            Rectangle {
                                                width: 6
                                                height: 6
                                                Layout.alignment: Qt.AlignVCenter
                                                radius: 3
                                                visible: model.urgency !== 1
                                                color: model.urgency === 2 ? Theme.red : model.urgency === 0 ? Theme.overlay0 : "transparent"
                                            }

                                            PanelText {
                                                text: model.appName || "Unknown"
                                                pointSize: Style.fontXS
                                                font.weight: Style.weightSemiBold
                                                color: Theme.text
                                            }

                                            PanelText {
                                                text: NotificationService.formatRelativeTime(model.timestampMs)
                                                pointSize: Style.fontXS
                                                color: Theme.overlay0
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Summary
                                        PanelText {
                                            id: summaryText
                                            text: model.summary || "No summary"
                                            color: Theme.subtext0
                                            pointSize: Style.fontM
                                            wrapMode: Text.Wrap
                                            maximumLineCount: notifDelegate.isExpanded ? 999 : 2
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        // Body
                                        PanelText {
                                            id: bodyText
                                            text: model.body || ""
                                            pointSize: Style.fontS
                                            color: Theme.subtext0
                                            wrapMode: Text.Wrap
                                            maximumLineCount: notifDelegate.isExpanded ? 999 : 3
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                            Layout.fillWidth: true
                                        }

                                        // Expand hint
                                        RowLayout {
                                            visible: !notifDelegate.isExpanded && notifDelegate.canExpand
                                            Layout.alignment: Qt.AlignRight
                                            spacing: Style.marginXS

                                            PanelText {
                                                text: "Click to expand"
                                                pointSize: Style.fontXS
                                                color: Theme.primary
                                            }
                                            IconText {
                                                text: "\uf078"  // chevron-down
                                                pointSize: Style.fontS
                                                color: Theme.primary
                                            }
                                        }

                                        // Actions
                                        Flow {
                                            Layout.fillWidth: true
                                            spacing: Style.marginS
                                            visible: notifDelegate.actionsList.length > 0

                                            Repeater {
                                                model: notifDelegate.actionsList

                                                delegate: Rectangle {
                                                    required property var modelData
                                                    width: actText.implicitWidth + Style.marginXL
                                                    height: 24
                                                    radius: Style.radiusS
                                                    color: actMa.containsMouse ? Theme.hoverBg : Theme.primary

                                                    PanelText {
                                                        id: actText
                                                        anchors.centerIn: parent
                                                        text: modelData.text || "Action"
                                                        pointSize: Style.fontS
                                                        color: actMa.containsMouse ? Theme.onHover : Theme.onPrimary
                                                        font.weight: Style.weightSemiBold
                                                    }

                                                    MouseArea {
                                                        id: actMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: NotificationService.invokeAction(notifDelegate.notificationId, modelData.identifier)
                                                    }

                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: Style.animFast
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    IconButton {
                                        icon: ""
                                        iconColor: Theme.red
                                        iconSize: Style.fontL
                                        implicitWidth: 28
                                        implicitHeight: 28
                                        Layout.alignment: Qt.AlignTop
                                        onClicked: NotificationService.removeFromHistory(notifDelegate.notificationId)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Scrollbar
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 4
                color: "transparent"
                visible: flickable.contentHeight > flickable.height

                Rectangle {
                    width: parent.width
                    radius: 2
                    color: Theme.surface2
                    opacity: flickable.moving ? 0.8 : 0.3

                    y: flickable.contentY / flickable.contentHeight * parent.height
                    height: Math.max(20, (flickable.height / flickable.contentHeight) * parent.height)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
