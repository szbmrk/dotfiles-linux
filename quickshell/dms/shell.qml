import QtQuick
import Quickshell

ShellRoot {
    id: entrypoint

    Loader {
        id: dmsShellLoader
        asynchronous: false
        sourceComponent: DMSShell {}
    }
}
