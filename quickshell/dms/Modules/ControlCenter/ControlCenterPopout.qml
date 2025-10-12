import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules.ControlCenter
import qs.Modules.ControlCenter.Widgets
import qs.Modules.ControlCenter.Details
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Components
import qs.Modules.ControlCenter.Models

DankPopout {
    id: root

    // ==== Local properties ====
    property string expandedSection: ""
    property var triggerScreen: null
    property bool editMode: false
    property int expandedWidgetIndex: -1
    property var expandedWidgetData: null
    property bool shouldBeVisible: false

    // ==== Hardcoded Catppuccin Mocha Blue palette ====
    property color colorPrimary: "#89b4fa"
    property color colorSurface: "#1e1e2e"
    property color colorSurfaceContainer: "#2a2b3b"
    property color colorSurfaceTint: "#89b4fa"
    property color colorOutline: "#89dceb"
    property color colorText: "#cdd6f4"
    property color colorAccent: "#f5c2e7"
    property color colorError: "#f38ba8"
    property color colorWarning: "#f9e2af"
    property real popupTransparency: 1
    property int spacingXS: 4
    property int spacingS: 8
    property int spacingM: 16
    property int spacingL: 24
    property int cornerRadius: 12
    property int longDuration: 600
    property int extraLongDuration: 1200
    property int barHeight: 40
    property int dankBarSpacing: 10

    margins {
        top: -5
        left: 290
    }

    signal lockRequested

    // ==== Methods ====
    function collapseAll() {
        expandedSection = "";
        expandedWidgetIndex = -1;
        expandedWidgetData = null;
    }

    onEditModeChanged: if (editMode)
        collapseAll()
    onVisibleChanged: if (!visible)
        collapseAll()

    function setTriggerPosition(x, y, width, section, screen) {
        // simplified trigger logic
        triggerScreen = screen;
        triggerX = (screen ? screen.width : Screen.width) - popupWidth - spacingL;
        triggerY = barHeight + dankBarSpacing;
        triggerWidth = width;
    }

    function openWithSection(section) {
        shouldBeVisible = true;
        expandedSection = section;
    }

    function toggleSection(section) {
        expandedSection = expandedSection === section ? "" : section;
    }

    // ==== Popup layout ====
    popupWidth: 550
    popupHeight: Math.min((triggerScreen?.height ?? 1080) - 100, contentLoader.item && contentLoader.item.implicitHeight > 0 ? contentLoader.item.implicitHeight + 20 : 400)
    triggerX: (triggerScreen?.width ?? 1920) - 600 - spacingL
    triggerY: barHeight + dankBarSpacing
    triggerWidth: 80
    positioning: ""
    screen: triggerScreen
    visible: shouldBeVisible

    onShouldBeVisibleChanged: {
        if (shouldBeVisible) {
            // placeholder for network/user updates
            console.log("Control center opened");
        } else {
            editMode = false;
            console.log("Control center closed");
        }
    }

    WidgetModel {
        id: widgetModel
    }

    // ==== Main content ====
    content: Component {
        Rectangle {
            id: controlContent
            color: Qt.rgba(colorSurfaceContainer.r, colorSurfaceContainer.g, colorSurfaceContainer.b, popupTransparency)
            radius: cornerRadius
            border.color: Qt.rgba(colorOutline.r, colorOutline.g, colorOutline.b, 0.1)
            border.width: 1
            antialiasing: true
            smooth: true
            implicitHeight: mainColumn.implicitHeight + spacingM

            Column {
                id: mainColumn
                width: parent.width - spacingL * 2
                x: spacingL
                y: spacingL
                spacing: spacingS

                HeaderPane {
                    id: headerPane
                    width: parent.width
                    editMode: root.editMode
                    onEditModeToggled: root.editMode = !root.editMode
                }

                DragDropGrid {
                    id: widgetGrid
                    width: parent.width
                    editMode: root.editMode
                    expandedSection: root.expandedSection
                    expandedWidgetIndex: root.expandedWidgetIndex
                    expandedWidgetData: root.expandedWidgetData
                    model: widgetModel
                    colorPickerModal: root.colorPickerModal
                    onExpandClicked: (widgetData, globalIndex) => {
                        root.expandedWidgetIndex = globalIndex;
                        root.expandedWidgetData = widgetData;
                        root.toggleSection(widgetData.id);
                    }
                    onRemoveWidget: index => widgetModel.removeWidget(index)
                    onMoveWidget: (fromIndex, toIndex) => widgetModel.moveWidget(fromIndex, toIndex)
                    onToggleWidgetSize: index => widgetModel.toggleWidgetSize(index)
                }

                EditControls {
                    width: parent.width
                    visible: editMode
                    popoutContent: controlContent
                    availableWidgets: editMode ? widgetModel.baseWidgetDefinitions.concat(widgetModel.getPluginWidgets()) : []
                    onAddWidget: widgetId => widgetModel.addWidget(widgetId)
                    onResetToDefault: () => widgetModel.resetToDefault()
                    onClearAll: () => widgetModel.clearAll()
                }
            }

            BluetoothCodecSelector {
                id: bluetoothCodecSelector
                anchors.fill: parent
                z: 10000
            }
        }
    }

    // ==== Detail components ====
    Component {
        id: networkDetailComponent
        NetworkDetail {}
    }
    Component {
        id: bluetoothDetailComponent
        BluetoothDetail {
            id: bluetoothDetail
            onShowCodecSelector: device => {
                if (contentLoader.item && contentLoader.item.bluetoothCodecSelector) {
                    contentLoader.item.bluetoothCodecSelector.show(device);
                    contentLoader.item.bluetoothCodecSelector.codecSelected.connect(function (deviceAddress, codecName) {
                        bluetoothDetail.updateDeviceCodecDisplay(deviceAddress, codecName);
                    });
                }
            }
        }
    }
    Component {
        id: audioOutputDetailComponent
        AudioOutputDetail {}
    }
    Component {
        id: audioInputDetailComponent
        AudioInputDetail {}
    }
    Component {
        id: batteryDetailComponent
        BatteryDetail {}
    }
}
