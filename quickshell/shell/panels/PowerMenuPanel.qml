import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"
import "../components"

PopupPanel {
    id: root

    property string pendingAction: ""
    property bool timerActive: false
    property int timeRemaining: 0
    readonly property int timerDuration: 3000

    readonly property var powerOptions: [
        {
            action: "lock",
            icon: "\uf023",
            title: "Lock",
            color: Theme.blue,
            command: ["loginctl", "lock-session"]
        },
        {
            action: "suspend",
            icon: "\uf186",
            title: "Suspend",
            color: Theme.lavender,
            command: ["systemctl", "suspend"]
        },
        {
            action: "reboot",
            icon: "\uf2f1",
            title: "Reboot",
            color: Theme.peach,
            command: ["systemctl", "reboot"]
        },
        {
            action: "logout",
            icon: "\uf2f5",
            title: "Logout",
            color: Theme.green,
            command: ["loginctl", "terminate-user", ""]
        },
        {
            action: "shutdown",
            icon: "\uf011",
            title: "Shutdown",
            color: Theme.red,
            command: ["systemctl", "poweroff"]
        }
    ]

    property int selectedIndex: -1

    function startTimer(action) {
        if (timerActive && pendingAction === action) {
            executeAction(action);
            return;
        }
        if (timerActive) {
            cancelTimer();
        }
        pendingAction = action;
        timeRemaining = timerDuration;
        timerActive = true;
        countdownTimer.start();
    }

    function cancelTimer() {
        timerActive = false;
        pendingAction = "";
        timeRemaining = 0;
        countdownTimer.stop();
    }

    function executeAction(action) {
        countdownTimer.stop();
        for (var i = 0; i < powerOptions.length; i++) {
            if (powerOptions[i].action === action) {
                actionProc.command = powerOptions[i].command;
                actionProc.running = true;
                break;
            }
        }
        cancelTimer();
        root.close();
    }

    Timer {
        id: countdownTimer
        interval: 100
        repeat: true
        onTriggered: {
            timeRemaining -= interval;
            if (timeRemaining <= 0) {
                executeAction(pendingAction);
            }
        }
    }

    Process {
        id: actionProc
        command: []
    }

    panelContent: Component {
        Item {
            focus: true

            Keys.onEscapePressed: {
                if (timerActive) {
                    cancelTimer();
                } else {
                    root.close();
                }
            }

            Keys.onUpPressed: {
                if (selectedIndex <= 0)
                    selectedIndex = powerOptions.length - 1;
                else
                    selectedIndex--;
            }
            Keys.onDownPressed: {
                if (selectedIndex >= powerOptions.length - 1)
                    selectedIndex = 0;
                else
                    selectedIndex++;
            }
            Keys.onReturnPressed: {
                if (selectedIndex >= 0 && selectedIndex < powerOptions.length)
                    startTimer(powerOptions[selectedIndex].action);
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: Style.marginL

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginM

                    IconText {
                        text: "\uf011"
                        pointSize: Style.fontXXL
                        color: Theme.red
                    }

                    PanelText {
                        text: timerActive ? powerOptions.find(o => o.action === pendingAction).title + " in " + Math.ceil(timeRemaining / 1000) + "s…" : "Session"
                        pointSize: Style.fontXL
                        font.weight: Style.weightBold
                        color: timerActive ? Theme.primary : Theme.text
                        Layout.fillWidth: true
                    }

                    IconButton {
                        icon: timerActive ? "\uf04d" : "\uf00d"
                        iconColor: timerActive ? Theme.red : Theme.subtext0
                        bgColor: "transparent"
                        tooltip: timerActive ? "Cancel" : "Close"
                        onClicked: {
                            if (timerActive)
                                cancelTimer();
                            else
                                root.close();
                        }
                    }
                }

                Divider {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    Repeater {
                        model: powerOptions

                        delegate: Rectangle {
                            id: btn
                            required property var modelData
                            required property int index

                            readonly property bool isPending: timerActive && pendingAction === modelData.action
                            readonly property bool isSelected: index === selectedIndex
                            readonly property bool isHovered: btnMa.containsMouse

                            Layout.fillWidth: true
                            Layout.preferredHeight: 48

                            radius: Style.radiusM
                            color: {
                                if (isPending)
                                    return Qt.alpha(modelData.color, 0.15);
                                if (isSelected || isHovered)
                                    return Theme.hoverBg;
                                return "transparent";
                            }
                            border.width: isPending ? Style.borderM : 0
                            border.color: modelData.color

                            Behavior on color {
                                ColorAnimation {
                                    duration: Style.animFast
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Style.marginL
                                anchors.rightMargin: Style.marginL
                                spacing: Style.marginL

                                // Icon
                                IconText {
                                    text: modelData.icon
                                    pointSize: Style.fontXL
                                    color: {
                                        if (isPending)
                                            return modelData.color;
                                        if (isSelected || isHovered)
                                            return Theme.onHover;
                                        return modelData.color;
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Style.animFast
                                        }
                                    }
                                }

                                // Title
                                PanelText {
                                    text: modelData.title
                                    pointSize: Style.fontL
                                    font.weight: Style.weightSemiBold
                                    Layout.fillWidth: true
                                    color: {
                                        if (isPending)
                                            return modelData.color;
                                        if (isSelected || isHovered)
                                            return Theme.onHover;
                                        return Theme.text;
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Style.animFast
                                        }
                                    }
                                }

                                // Countdown or keybind hint
                                PanelText {
                                    visible: isPending
                                    text: Math.ceil(timeRemaining / 1000) + "s"
                                    pointSize: Style.fontM
                                    font.weight: Style.weightBold
                                    color: modelData.color
                                }
                            }

                            MouseArea {
                                id: btnMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: selectedIndex = index
                                onExited: {
                                    if (selectedIndex === index)
                                        selectedIndex = -1;
                                }
                                onClicked: {
                                    selectedIndex = index;
                                    startTimer(modelData.action);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
