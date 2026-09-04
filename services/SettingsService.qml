pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isOpen: false
    property int currentTab: 0

    function open(): void {
        isOpen = true;
    }

    function close(): void {
        isOpen = false;
    }

    function toggle(): void {
        isOpen = !isOpen;
    }

    function setTab(tabIndex: int): void {
        currentTab = tabIndex;
    }

    property IpcHandler settingsIpc: IpcHandler {
        target: "settings"

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }

        function toggle(): void {
            root.toggle();
        }

        function setTab(tabIndex: int): void {
            root.setTab(tabIndex);
        }

        function isOpen(): bool {
            return root.isOpen;
        }
    }
}
