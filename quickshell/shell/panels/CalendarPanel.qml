import QtQuick
import QtQuick.Layouts
import Quickshell
import "../"
import "../components"

PopupPanel {
    id: root

    property var now: new Date()
    property int calMonth: now.getMonth()
    property int calYear: now.getFullYear()

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function prevMonth() {
        if (calMonth === 0) {
            calMonth = 11;
            calYear--;
        } else
            calMonth--;
        rebuildGrid();
    }

    function nextMonth() {
        if (calMonth === 11) {
            calMonth = 0;
            calYear++;
        } else
            calMonth++;
        rebuildGrid();
    }

    function goToday() {
        var today = new Date();
        calMonth = today.getMonth();
        calYear = today.getFullYear();
        rebuildGrid();
    }

    property var daysModel: []

    function rebuildGrid() {
        var result = [];
        var firstDay = new Date(calYear, calMonth, 1);
        var startDow = (firstDay.getDay() + 6) % 7;
        var daysInMonth = new Date(calYear, calMonth + 1, 0).getDate();
        var daysInPrev = new Date(calYear, calMonth, 0).getDate();

        var today = new Date();
        var isCurrentMonth = (calMonth === today.getMonth() && calYear === today.getFullYear());

        for (var i = startDow - 1; i >= 0; i--)
            result.push({
                day: daysInPrev - i,
                current: false,
                today: false
            });

        for (var d = 1; d <= daysInMonth; d++)
            result.push({
                day: d,
                current: true,
                today: isCurrentMonth && d === today.getDate()
            });

        var remaining = 42 - result.length;
        for (var n = 1; n <= remaining; n++)
            result.push({
                day: n,
                current: false,
                today: false
            });

        daysModel = result;
    }

    Component.onCompleted: rebuildGrid()

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    panelContent: Component {
        ColumnLayout {
            spacing: Style.marginL

            // ── Header card with date + time ──
            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: Theme.primary

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            spacing: Style.marginS

                            PanelText {
                                text: new Date().getDate().toString()
                                pointSize: Style.fontXXXL
                                font.weight: Style.weightBold
                                color: Theme.base
                            }

                            ColumnLayout {
                                spacing: -2

                                PanelText {
                                    text: monthNames[calMonth].toUpperCase()
                                    pointSize: Style.fontXL
                                    font.weight: Style.weightBold
                                    color: Theme.base
                                }
                                PanelText {
                                    text: calYear.toString()
                                    pointSize: Style.fontM
                                    color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.7)
                                }
                            }
                        }
                    }

                    PanelText {
                        text: Qt.formatTime(sysClock.date, "hh:mm")
                        pointSize: Style.fontXXL
                        font.weight: Style.weightBold
                        color: Theme.base
                    }
                }
            }

            // ── Month grid ──
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    // Navigation row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        PanelText {
                            text: monthNames[calMonth].toUpperCase() + " " + calYear
                            pointSize: Style.fontM
                            font.weight: Style.weightBold
                            Layout.fillWidth: true
                        }

                        IconButton {
                            icon: "\uf053"  // chevron-left
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            implicitWidth: 24
                            implicitHeight: 24
                            onClicked: prevMonth()
                        }

                        IconButton {
                            icon: "\uf015"  // home (today)
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            implicitWidth: 24
                            implicitHeight: 24
                            onClicked: goToday()
                        }

                        IconButton {
                            icon: "\uf054"  // chevron-right
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            implicitWidth: 24
                            implicitHeight: 24
                            onClicked: nextMonth()
                        }
                    }

                    // Day-of-week headers
                    Row {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: dayNames
                            delegate: Item {
                                width: parent.width / 7
                                height: 24

                                PanelText {
                                    anchors.centerIn: parent
                                    text: modelData
                                    pointSize: Style.fontXS
                                    font.weight: Style.weightBold
                                    color: Theme.overlay1
                                }
                            }
                        }
                    }

                    // Days grid
                    Grid {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rows: 6
                        spacing: 0

                        Repeater {
                            model: daysModel

                            delegate: Item {
                                required property var modelData
                                width: parent.width / 7
                                height: parent.height / 6

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: modelData.today ? Theme.primary : "transparent"
                                }

                                PanelText {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    pointSize: Style.fontS
                                    color: {
                                        if (modelData.today)
                                            return Theme.base;
                                        if (modelData.current)
                                            return Theme.text;
                                        return Theme.overlay0;
                                    }
                                    font.weight: modelData.today ? Style.weightBold : Style.weightMedium
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            now = new Date();
            calMonth = now.getMonth();
            calYear = now.getFullYear();
            rebuildGrid();
        }
    }
}
