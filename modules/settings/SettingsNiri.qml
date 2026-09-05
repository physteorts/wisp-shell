import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.configs
import qs.components
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true

    Card {
        Layout.fillWidth: true
        title: "Lock screen"
        iconText: "\ue897"

        CardRow {
            Layout.fillWidth: true
            leadingIcon: "\uea9b"
            title: "Lock when idle"
            subtitle: "Automatically lock the session after inactivity"

            ComboBox {
                id: idleTimeoutBox
                implicitWidth: 150
                model: [
                    { label: "Disabled", minutes: 0 },
                    { label: "5 minutes", minutes: 5 },
                    { label: "10 minutes", minutes: 10 },
                    { label: "15 minutes", minutes: 15 },
                    { label: "30 minutes", minutes: 30 },
                    { label: "1 hour", minutes: 60 }
                ]
                textRole: "label"
                currentIndex: {
                    const selected = model.findIndex(option => option.minutes === Config.idleLockTimeout);
                    return selected >= 0 ? selected : 0;
                }

                onActivated: index => SettingsService.setIdleLockTimeout(model[index].minutes)
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
