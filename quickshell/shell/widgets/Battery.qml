import QtQuick
import Quickshell.Services.UPower
import "../"

Text {
    id: root

    property var bat: UPower.displayDevice
    property real pct: bat?.percentage ?? 0
    property var batState: bat?.state ?? UPowerDeviceState.Unknown

    property bool isCharging: batState === UPowerDeviceState.Charging || batState === UPowerDeviceState.PendingCharge
    property bool isPlugged: batState === UPowerDeviceState.FullyCharged

    property string batIcon: {
        if (isCharging)
            return "";
        if (isPlugged)
            return "";
        if (pct >= 90)
            return "";
        if (pct >= 70)
            return "";
        if (pct >= 50)
            return "";
        if (pct >= 20)
            return "";
        return "";
    }

    text: batIcon + " " + Math.round(pct) + "%"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    color: {
        if (isCharging)
            return Theme.green;
        if (pct <= 15)
            return Theme.red;
        return Theme.flamingo;
    }
}
