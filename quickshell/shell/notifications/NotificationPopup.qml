import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../"
import "../components"

Variants {
    model: Quickshell.screens

    delegate: Loader {
        id: root
        required property var modelData

        property ListModel notificationModel: NotificationService.activeList

        active: notificationModel.count > 0 || delayTimer.running

        Timer {
            id: delayTimer
            interval: 500
            repeat: false
        }

        Connections {
            target: notificationModel
            function onCountChanged() {
                if (notificationModel.count === 0 && root.active)
                    delayTimer.restart();
            }
        }

        sourceComponent: PanelWindow {
            id: notifWindow
            screen: modelData

            WlrLayershell.namespace: "shell-notifications"
            WlrLayershell.layer: WlrLayer.Overlay

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true
            }

            margins {
                top: Style.barHeight + Style.marginL
                right: Style.marginS
            }

            readonly property int notifWidth: 400
            readonly property int maxNotifHeight: (screen ? screen.height : 1080) * 0.75

            implicitWidth: notifWidth + Style.marginXL * 2
            implicitHeight: Math.max(1, Math.min(notificationStack.implicitHeight + Style.marginL, maxNotifHeight))

            mask: Region {
                item: notificationStack
            }

            ColumnLayout {
                id: notificationStack

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: Style.marginL

                spacing: Style.marginM

                Behavior on implicitHeight {
                    SpringAnimation {
                        spring: 2.0
                        damping: 0.4
                        epsilon: 0.01
                        mass: 0.8
                    }
                }

                Repeater {
                    id: notifRepeater
                    model: notificationModel

                    delegate: Item {
                        id: card

                        property string notificationId: model.id
                        property int hoverCount: 0
                        property bool isRemoving: false

                        Layout.preferredWidth: notifWindow.notifWidth
                        Layout.preferredHeight: cardContent.implicitHeight + Style.marginXL
                        Layout.maximumHeight: Layout.preferredHeight

                        property real scaleValue: 0.8
                        property real opacityValue: 0.0
                        property real slideOffset: -100

                        scale: scaleValue
                        opacity: opacityValue
                        transform: Translate {
                            y: card.slideOffset
                        }

                        Behavior on y {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            id: cardBg
                            anchors.fill: parent
                            radius: Style.radiusL
                            border.color: Theme.cardBorder
                            border.width: Style.borderS
                            color: Theme.panelBg

                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 2
                                color: "transparent"

                                Rectangle {
                                    readonly property real progressWidth: cardBg.width - (2 * cardBg.radius)
                                    height: parent.height
                                    x: cardBg.radius + (progressWidth * (1 - model.progress)) / 2
                                    width: progressWidth * model.progress
                                    color: model.urgency === 2 ? Theme.red : model.urgency === 0 ? Theme.subtext0 : Theme.primary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 100
                                            easing.type: Easing.Linear
                                        }
                                    }
                                    Behavior on x {
                                        NumberAnimation {
                                            duration: 100
                                            easing.type: Easing.Linear
                                        }
                                    }
                                }
                            }
                        }

                        onHoverCountChanged: {
                            if (hoverCount > 0) {
                                resumeTimer.stop();
                                NotificationService.pauseTimeout(notificationId);
                            } else {
                                resumeTimer.start();
                            }
                        }

                        Timer {
                            id: resumeTimer
                            interval: 50
                            onTriggered: {
                                if (card.hoverCount === 0)
                                    NotificationService.resumeTimeout(card.notificationId);
                            }
                        }

                        MouseArea {
                            anchors.fill: cardBg
                            acceptedButtons: Qt.RightButton
                            hoverEnabled: true
                            onEntered: card.hoverCount++
                            onExited: card.hoverCount--
                            onClicked: function (mouse) {
                                if (mouse.button === Qt.RightButton)
                                    animateOut();
                            }
                        }

                        function triggerEntryAnimation() {
                            isRemoving = false;
                            slideOffset = -100;
                            scaleValue = 0.8;
                            opacityValue = 0.0;
                            animInTimer.interval = 20;  // All notifications slide in together
                            animInTimer.start();
                        }

                        Component.onCompleted: triggerEntryAnimation()
                        onNotificationIdChanged: triggerEntryAnimation()

                        Timer {
                            id: animInTimer
                            interval: 0
                            onTriggered: {
                                if (!card.isRemoving) {
                                    slideOffset = 0;
                                    scaleValue = 1.0;
                                    opacityValue = 1.0;
                                }
                            }
                        }

                        function animateOut() {
                            if (isRemoving)
                                return;
                            isRemoving = true;
                            slideOffset = -100;
                            scaleValue = 0.8;
                            opacityValue = 0.0;
                        }

                        Timer {
                            id: removalTimer
                            interval: 350
                            running: card.isRemoving
                            onTriggered: NotificationService.dismissActiveNotification(card.notificationId)
                        }

                        Behavior on scaleValue {
                            SpringAnimation {
                                spring: 3
                                damping: 0.4
                                epsilon: 0.01
                                mass: 0.8
                            }
                        }
                        Behavior on opacityValue {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on slideOffset {
                            SpringAnimation {
                                spring: 2.5
                                damping: 0.3
                                epsilon: 0.01
                                mass: 0.6
                            }
                        }

                        ColumnLayout {
                            id: cardContent
                            anchors.fill: cardBg
                            anchors.margins: Style.marginM
                            spacing: Style.marginM

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Style.marginL
                                Layout.margins: Style.marginS

                                // App icon placeholder
                                Rectangle {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: Style.radiusM
                                    color: Theme.surface0

                                    IconText {
                                        anchors.centerIn: parent
                                        text: "\uf0f3"  // bell
                                        pointSize: Style.fontL
                                        color: Theme.primary
                                    }

                                    Image {
                                        anchors.fill: parent
                                        source: model.originalImage || ""
                                        fillMode: Image.PreserveAspectCrop
                                        visible: status === Image.Ready
                                        smooth: true
                                        asynchronous: true

                                        layer.enabled: true
                                        layer.effect:
                                        Item {}
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.marginXS

                                    // Header
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Style.marginS

                                        // Urgency dot
                                        Rectangle {
                                            Layout.preferredWidth: 6
                                            Layout.preferredHeight: 6
                                            Layout.alignment: Qt.AlignVCenter
                                            radius: 3
                                            color: model.urgency === 2 ? Theme.red : model.urgency === 0 ? Theme.subtext0 : Theme.primary
                                        }

                                        PanelText {
                                            text: model.appName || "Unknown"
                                            pointSize: Style.fontL
                                            font.weight: Style.weightSemiBold
                                            color: Theme.flamingo
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Summary
                                    PanelText {
                                        text: model.summary || ""
                                        pointSize: Style.fontM
                                        font.weight: Style.weightSemiBold
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                        Layout.fillWidth: true
                                    }

                                    // Body
                                    PanelText {
                                        text: model.body || ""
                                        pointSize: Style.fontS
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                        Layout.fillWidth: true
                                        color: Theme.subtext0
                                    }

                                    // Actions
                                    Flow {
                                        Layout.fillWidth: true
                                        spacing: Style.marginS
                                        Layout.topMargin: Style.marginXS
                                        visible: actionRepeater.count > 0

                                        property string parentNotifId: card.notificationId
                                        property var parsedActions: {
                                            try {
                                                return model.actionsJson ? JSON.parse(model.actionsJson) : [];
                                            } catch (e) {
                                                return [];
                                            }
                                        }

                                        Repeater {
                                            id: actionRepeater
                                            model: parent.parsedActions

                                            delegate: Rectangle {
                                                required property var modelData
                                                width: actionText.implicitWidth + Style.marginXL
                                                height: 24
                                                radius: Style.radiusS
                                                color: actMa.containsMouse ? Theme.hoverBg : Theme.primary

                                                PanelText {
                                                    id: actionText
                                                    anchors.centerIn: parent
                                                    text: {
                                                        var t = modelData.text || "Open";
                                                        if (t.includes(","))
                                                            return t.split(",")[1] || t;
                                                        return t;
                                                    }
                                                    pointSize: Style.fontS
                                                    color: actMa.containsMouse ? Theme.onHover : Theme.onPrimary
                                                    font.weight: Style.weightSemiBold
                                                }

                                                MouseArea {
                                                    id: actMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onEntered: card.hoverCount++
                                                    onExited: card.hoverCount--
                                                    onClicked: NotificationService.invokeAction(card.notificationId, modelData.identifier)
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
                        }

                        // Close button
                        Rectangle {
                            anchors.top: cardBg.top
                            anchors.topMargin: Style.marginS
                            anchors.right: cardBg.right
                            anchors.rightMargin: Style.marginS
                            width: 20
                            height: 20
                            radius: 10
                            color: closeMa.containsMouse ? Theme.hoverBg : Theme.surface1

                            IconText {
                                anchors.centerIn: parent
                                text: "\uf00d"
                                pointSize: 8
                                color: closeMa.containsMouse ? Theme.onHover : Theme.subtext0
                            }

                            MouseArea {
                                id: closeMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: card.hoverCount++
                                onExited: card.hoverCount--
                                onClicked: {
                                    card.animateOut();
                                }
                            }
                        }
                    }
                }
            }

            property var animConnection: null
            Component.onCompleted: {
                animConnection = function (notifId) {
                    for (var i = 0; i < notifRepeater.count; i++) {
                        var item = notifRepeater.itemAt(i);
                        if (item && item.notificationId === notifId) {
                            item.animateOut();
                            return;
                        }
                    }
                    NotificationService.dismissActiveNotification(notifId);
                };
                NotificationService.animateAndRemove.connect(animConnection);
            }
            Component.onDestruction: {
                if (animConnection)
                    NotificationService.animateAndRemove.disconnect(animConnection);
            }
        }
    }
}
