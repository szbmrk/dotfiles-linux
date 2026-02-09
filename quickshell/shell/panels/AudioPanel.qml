import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../"
import "../components"

PopupPanel {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property var sourceNode: Pipewire.defaultAudioSource
    property real localOutputVol: sink?.audio?.volume ?? 0
    property bool localOutputChanging: false
    property real localInputVol: sourceNode?.audio?.volume ?? 0
    property bool localInputChanging: false

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    PwObjectTracker {
        objects: root.sourceNode ? [root.sourceNode] : []
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() {
            if (!localOutputChanging)
                localOutputVol = root.sink.audio.volume;
        }
    }
    Connections {
        target: root.sourceNode?.audio ?? null
        function onVolumeChanged() {
            if (!localInputChanging)
                localInputVol = root.sourceNode.audio.volume;
        }
    }

    Timer {
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            if (root.sink?.audio && Math.abs(localOutputVol - root.sink.audio.volume) >= 0.005)
                root.sink.audio.volume = localOutputVol;
            if (root.sourceNode?.audio && Math.abs(localInputVol - root.sourceNode.audio.volume) >= 0.005)
                root.sourceNode.audio.volume = localInputVol;
        }
    }

    PwNodeLinkTracker {
        id: linkTracker
        node: Pipewire.defaultAudioSink
    }

    PwObjectTracker {
        objects: linkTracker.linkGroups
    }

    property int currentTab: 0

    panelContent: Component {
        ColumnLayout {
            spacing: Style.marginL

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: headerCol.implicitHeight + Style.marginXL

                ColumnLayout {
                    id: headerCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        spacing: Style.marginM

                        IconText {
                            text: "\uf028"  // volume
                            pointSize: Style.fontXXL
                            color: Theme.primary
                        }

                        PanelText {
                            text: "Audio"
                            pointSize: Style.fontXL
                            font.weight: Style.weightBold
                            Layout.fillWidth: true
                        }

                        IconButton {
                            icon: "\uf00d"  // close
                            iconColor: Theme.subtext0
                            bgColor: "transparent"
                            onClicked: root.close()
                        }
                    }

                    // Tab bar
                    Row {
                        Layout.fillWidth: true
                        spacing: Style.marginXS

                        Repeater {
                            model: ["Volumes", "Devices"]
                            delegate: Rectangle {
                                required property int index
                                required property string modelData
                                width: parent.width / 2 - Style.marginXS / 2
                                height: 30
                                radius: Style.radiusS
                                color: currentTab === index ? Theme.primary : Theme.surface0
                                border.color: currentTab === index ? Theme.primary : Theme.cardBorder
                                border.width: Style.borderS

                                PanelText {
                                    anchors.centerIn: parent
                                    text: modelData
                                    pointSize: Style.fontS
                                    font.weight: Style.weightSemiBold
                                    color: currentTab === index ? Theme.onPrimary : Theme.text
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: currentTab = index
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

            ColumnLayout {
                visible: currentTab === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Style.marginM

                // Output Volume
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: outputCol.implicitHeight + Style.marginXL

                    ColumnLayout {
                        id: outputCol
                        anchors.fill: parent
                        anchors.margins: Style.marginM
                        spacing: Style.marginM

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXS

                            PanelText {
                                text: "Output"
                                color: Theme.primary
                            }
                            PanelText {
                                text: sink ? (" — " + (sink.description || sink.name || "")) : ""
                                pointSize: Style.fontS
                                color: Theme.subtext0
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginM

                            PanelSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1.0
                                stepSize: 0.01
                                value: localOutputVol
                                fillColor: Theme.blue
                                onMoved: {
                                    localOutputVol = value;
                                }
                                onPressedChanged: {
                                    localOutputChanging = pressed;
                                }
                            }

                            PanelText {
                                text: Math.round(localOutputVol * 100) + "%"
                                pointSize: Style.fontS
                                font.family: Theme.fontFamily
                                Layout.preferredWidth: 40
                                horizontalAlignment: Text.AlignRight
                            }

                            IconButton {
                                icon: (sink?.audio?.muted ?? false) ? "" : "\uf028"
                                iconColor: (sink?.audio?.muted ?? false) ? Theme.red : Theme.text
                                bgColor: "transparent"
                                implicitWidth: 28
                                implicitHeight: 28
                                onClicked: {
                                    if (sink?.audio)
                                        sink.audio.muted = !sink.audio.muted;
                                }
                            }
                        }
                    }
                }

                // Input Volume
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: inputCol.implicitHeight + Style.marginXL
                    visible: sourceNode !== null

                    ColumnLayout {
                        id: inputCol
                        anchors.fill: parent
                        anchors.margins: Style.marginM
                        spacing: Style.marginM

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginXS

                            PanelText {
                                text: "Input"
                                color: Theme.primary
                            }
                            PanelText {
                                text: sourceNode ? (" — " + (sourceNode.description || sourceNode.name || "")) : ""
                                pointSize: Style.fontS
                                color: Theme.subtext0
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginM

                            PanelSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1.0
                                stepSize: 0.01
                                value: localInputVol
                                fillColor: Theme.primary
                                onMoved: {
                                    localInputVol = value;
                                }
                                onPressedChanged: {
                                    localInputChanging = pressed;
                                }
                            }

                            PanelText {
                                text: Math.round(localInputVol * 100) + "%"
                                pointSize: Style.fontS
                                font.family: Theme.fontFamily
                                Layout.preferredWidth: 40
                                horizontalAlignment: Text.AlignRight
                            }

                            IconButton {
                                icon: (sourceNode?.audio?.muted ?? false) ? "\uf131" : "\uf130"
                                iconColor: (sourceNode?.audio?.muted ?? false) ? Theme.red : Theme.text
                                bgColor: "transparent"
                                implicitWidth: 28
                                implicitHeight: 28
                                onClicked: {
                                    if (sourceNode?.audio)
                                        sourceNode.audio.muted = !sourceNode.audio.muted;
                                }
                            }
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: appCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: appCol
                        width: parent.width
                        spacing: Style.marginM

                        Repeater {
                            model: linkTracker.linkGroups

                            delegate: Card {
                                id: appCard
                                required property PwLinkGroup modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: appRow.implicitHeight + Style.marginXL
                                visible: !isCaptureStream

                                PwObjectTracker {
                                    objects: modelData && modelData.source ? [modelData.source] : []
                                }

                                property PwNode appNode: modelData?.source ?? null
                                property PwNodeAudio nodeAudio: appNode?.audio ?? null
                                property real appVol: nodeAudio?.volume ?? 0
                                property bool appMuted: nodeAudio?.muted ?? false

                                readonly property bool isCaptureStream: {
                                    if (!appNode?.properties)
                                        return false;
                                    var mc = appNode.properties["media.class"] || "";
                                    return mc.includes("Capture") || mc === "Stream/Input/Audio";
                                }

                                readonly property string appName: {
                                    if (!appNode)
                                        return "Unknown";
                                    var p = appNode.properties;
                                    var n = p ? (p["application.name"] || "") : "";
                                    if (!n)
                                        n = appNode.description || appNode.name || "Unknown";
                                    return n.charAt(0).toUpperCase() + n.slice(1);
                                }

                                readonly property string appIconName: {
                                    if (!appNode?.properties)
                                        return "";
                                    var p = appNode.properties;
                                    return p["application.icon-name"] || p["application.process.binary"] || "";
                                }

                                readonly property string appIconPath: appIconName !== "" ? Quickshell.iconPath(appIconName) : ""

                                RowLayout {
                                    id: appRow
                                    anchors.fill: parent
                                    anchors.margins: Style.marginM
                                    spacing: Style.marginM

                                    // App icon
                                    Rectangle {
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: Style.radiusS
                                        color: Theme.surface1
                                        clip: true

                                        Image {
                                            id: appIconImage
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            source: appCard.appIconPath
                                            fillMode: Image.PreserveAspectFit
                                            sourceSize.width: 24
                                            sourceSize.height: 24
                                            smooth: true
                                            asynchronous: true
                                            visible: status === Image.Ready
                                        }

                                        IconText {
                                            anchors.centerIn: parent
                                            text: "\uf001"
                                            pointSize: Style.fontL
                                            color: Theme.primary
                                            visible: appIconImage.status !== Image.Ready
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Style.marginXS

                                        PanelText {
                                            text: appCard.appName
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Style.marginM

                                            PanelSlider {
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1.0
                                                stepSize: 0.01
                                                value: appCard.appVol
                                                fillColor: Theme.blue
                                                enabled: appCard.nodeAudio !== null
                                                onMoved: {
                                                    if (appCard.nodeAudio)
                                                        appCard.nodeAudio.volume = value;
                                                }
                                            }

                                            PanelText {
                                                text: Math.round(appCard.appVol * 100) + "%"
                                                pointSize: Style.fontS
                                                font.family: Theme.fontFamily
                                                Layout.preferredWidth: 40
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            IconButton {
                                                icon: appCard.appMuted ? "" : "\uf028"
                                                iconColor: appCard.appMuted ? Theme.red : Theme.text
                                                bgColor: "transparent"
                                                implicitWidth: 24
                                                implicitHeight: 24
                                                enabled: appCard.nodeAudio !== null
                                                onClicked: {
                                                    if (appCard.nodeAudio)
                                                        appCard.nodeAudio.muted = !appCard.appMuted;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        PanelText {
                            visible: linkTracker.linkGroups.length === 0
                            text: "No applications playing audio"
                            color: Theme.subtext0
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            Layout.topMargin: Style.marginXL
                        }
                    }
                }
            }

            Flickable {
                visible: currentTab === 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: devicesCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: devicesCol
                    width: parent.width
                    spacing: Style.marginM

                    // Output Devices
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sinkCol.implicitHeight + Style.marginXL

                        ColumnLayout {
                            id: sinkCol
                            anchors.fill: parent
                            anchors.margins: Style.marginM
                            spacing: Style.marginS

                            PanelText {
                                text: "Output Devices"
                                pointSize: Style.fontL
                                color: Theme.primary
                            }

                            Repeater {
                                model: Pipewire.nodes.values.filter(n => n.isStream === false && (n.properties?.["media.class"] === "Audio/Sink"))
                                delegate: Rectangle {
                                    required property PwNode modelData
                                    Layout.fillWidth: true
                                    implicitHeight: sinkRow.implicitHeight + Style.marginM
                                    radius: Style.radiusS
                                    color: Pipewire.defaultAudioSink?.id === modelData.id ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : "transparent"

                                    RowLayout {
                                        id: sinkRow
                                        anchors.fill: parent
                                        anchors.margins: Style.marginXS
                                        spacing: Style.marginM

                                        Rectangle {
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            radius: 8
                                            color: "transparent"
                                            border.color: Pipewire.defaultAudioSink?.id === modelData.id ? Theme.primary : Theme.overlay0
                                            border.width: 2

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 8
                                                height: 8
                                                radius: 4
                                                color: Theme.primary
                                                visible: Pipewire.defaultAudioSink?.id === modelData.id
                                            }
                                        }

                                        PanelText {
                                            text: modelData.description || modelData.name || "Unknown"
                                            pointSize: Style.fontS
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                                    }
                                }
                            }
                        }
                    }

                    // Input Devices
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sourceCol.implicitHeight + Style.marginXL

                        ColumnLayout {
                            id: sourceCol
                            anchors.fill: parent
                            anchors.margins: Style.marginM
                            spacing: Style.marginS

                            PanelText {
                                text: "Input Devices"
                                pointSize: Style.fontL
                                color: Theme.primary
                            }

                            Repeater {
                                model: Pipewire.nodes.values.filter(n => n.isStream === false && (n.properties?.["media.class"] === "Audio/Source"))
                                delegate: Rectangle {
                                    required property PwNode modelData
                                    Layout.fillWidth: true
                                    implicitHeight: srcRow.implicitHeight + Style.marginM
                                    radius: Style.radiusS
                                    color: Pipewire.defaultAudioSource?.id === modelData.id ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : "transparent"

                                    RowLayout {
                                        id: srcRow
                                        anchors.fill: parent
                                        anchors.margins: Style.marginXS
                                        spacing: Style.marginM

                                        Rectangle {
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            radius: 8
                                            color: "transparent"
                                            border.color: Pipewire.defaultAudioSource?.id === modelData.id ? Theme.primary : Theme.overlay0
                                            border.width: 2

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 8
                                                height: 8
                                                radius: 4
                                                color: Theme.primary
                                                visible: Pipewire.defaultAudioSource?.id === modelData.id
                                            }
                                        }

                                        PanelText {
                                            text: modelData.description || modelData.name || "Unknown"
                                            pointSize: Style.fontS
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Pipewire.preferredDefaultAudioSource = modelData
                                    }
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
            localOutputVol = sink?.audio?.volume ?? 0;
            localInputVol = sourceNode?.audio?.volume ?? 0;
        }
    }
}
