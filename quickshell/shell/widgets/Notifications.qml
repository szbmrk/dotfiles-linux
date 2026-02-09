import QtQuick
import "../"

Text {
    id: root

    property int unseenCount: NotificationService.unseenCount
    property bool dnd: NotificationService.doNotDisturb

    visible: true
    text: !dnd ? "\uf0f3 " + unseenCount : "\uf1f6 " + unseenCount
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: dnd ? Theme.red : Theme.flamingo

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton)
                PanelManager.toggleById("notificationsPanel");
            else if (mouse.button === Qt.RightButton)
                NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
            else
                NotificationService.dismissAllActive();
        }
    }
}
