import QtQuick
import Quickshell
import Quickshell.Io
import qs.Modals
import qs.Modules.DankDash
import qs.Modules.ControlCenter
import qs.Modules.OSD
import qs.Modules.ProcessList

Item {
    id: root

    Loader {
        id: dankDashPopoutLoader

        active: false
        asynchronous: true

        sourceComponent: Component {
            DankDashPopout {
                id: dankDashPopout

                Component.onCompleted: {
                    PopoutService.dankDashPopout = dankDashPopout;
                }
            }
        }
    }

    LazyLoader {
        id: controlCenterLoader

        active: false

        ControlCenterPopout {
            id: controlCenterPopout

            onLockRequested: {
                lockLoader.item.activate();
            }

            Component.onCompleted: {
                PopoutService.controlCenterPopout = controlCenterPopout;
            }
        }
    }

    LazyLoader {
        id: wifiPasswordModalLoader

        active: false

        WifiPasswordModal {
            id: wifiPasswordModal

            Component.onCompleted: {
                PopoutService.wifiPasswordModal = wifiPasswordModal;
            }
        }
    }

    LazyLoader {
        id: networkInfoModalLoader

        active: false

        NetworkInfoModal {
            id: networkInfoModal

            Component.onCompleted: {
                PopoutService.networkInfoModal = networkInfoModal;
            }
        }
    }

    LazyLoader {
        id: processListPopoutLoader

        active: false

        ProcessListPopout {
            id: processListPopout

            Component.onCompleted: {
                PopoutService.processListPopout = processListPopout;
            }
        }
    }

    LazyLoader {
        id: processListModalLoader

        active: false

        ProcessListModal {
            id: processListModal

            Component.onCompleted: {
                PopoutService.processListModal = processListModal;
            }
        }
    }

    DMSShellIPC {
        processListModalLoader: processListModalLoader
        controlCenterLoader: controlCenterLoader
        dankDashPopoutLoader: dankDashPopoutLoader
    }
}
