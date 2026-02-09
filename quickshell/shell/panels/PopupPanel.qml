import QtQuick
import "../"

// Base for all popup panels — handles open/close animation, backdrop click
Item {
    id: root

    property string panelId: ""
    property alias panelContent: contentLoader.sourceComponent
    property int preferredWidth: Style.panelWidth
    property int preferredHeight: 400
    property bool isOpen: false

    // Anchor: where the panel appears relative to the bar
    // "top-right", "top-left", "top-center", "bottom-right", etc.
    property string anchor: "top-right"
    property int anchorMargin: Style.marginL

    function open() {
        isOpen = true;
        PanelManager.open(root);
    }

    function close() {
        isOpen = false;
        PanelManager.close(root);
    }

    function toggle() {
        PanelManager.toggle(root);
    }

    Component.onCompleted: {
        if (panelId !== "")
            PanelManager.register(root);
    }

    visible: isOpen
    z: 100

    // Dim background when panel is open
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: root.isOpen

        Behavior on opacity {
            NumberAnimation { duration: Style.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Panel container
    Rectangle {
        id: panelFrame
        width: root.preferredWidth
        height: Math.min(root.preferredHeight, root.height - Style.barHeight - Style.marginL * 2)
        color: Theme.panelBg
        radius: Style.radiusL
        border.color: Theme.cardBorder
        border.width: Style.borderS
        clip: true

        // Position based on anchor
        x: {
            switch (root.anchor) {
            case "top-right":
            case "bottom-right":
                return root.width - width - root.anchorMargin;
            case "top-left":
            case "bottom-left":
                return root.anchorMargin;
            case "top-center":
            case "bottom-center":
            default:
                return (root.width - width) / 2;
            }
        }

        y: {
            switch (root.anchor) {
            case "bottom-right":
            case "bottom-left":
            case "bottom-center":
                return root.height - height - Style.barHeight - root.anchorMargin;
            case "top-right":
            case "top-left":
            case "top-center":
            default:
                return Style.barHeight + root.anchorMargin;
            }
        }

        // Entry animation
        scale: root.isOpen ? 1.0 : 0.95
        opacity: root.isOpen ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: Style.animNormal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Style.animNormal
                easing.type: Easing.OutCubic
            }
        }

        // Prevent clicks from passing through
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            onPressed: function(mouse) { mouse.accepted = true; }
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.margins: Style.marginL
        }
    }

    // Close on Escape
    Keys.onEscapePressed: root.close()
}
