pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool switcherOpen: false
    property int focusedWindowIndex: 1
    property string focusedWindowAddress: ""
}
