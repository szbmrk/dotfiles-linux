import QtQuick
import Quickshell.Services.UPower
import "../"

Text {
    id: root

    property var bat: UPower.displayDevice
    property real pct: bat?.energyCapacity > 0
                   ? (bat.energy / bat.energyCapacity) * 100
                   : 0
    property var batState: bat?.state ?? UPowerDeviceState.Unknown

    property bool isPlugged: batState === UPowerDeviceState.Charging

    property string batIcon: {
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
        if (isPlugged)
            return Theme.green;
        if (pct <= 15)
            return Theme.red;
        return Theme.flamingo;
    }

    visible: UPower.displayDevice.isLaptopBattery == true
}
