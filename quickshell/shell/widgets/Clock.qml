import QtQuick
import Quickshell
import "../"

Rectangle {
    id: root

    implicitHeight: 26
    implicitWidth: clockRow.implicitWidth + 16
    radius: 12
    color: Theme.pillBg

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "hh:mm")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            color: Theme.text
        }
    }
}
