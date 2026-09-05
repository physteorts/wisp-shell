pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import qs.configs

Singleton {
    id: service

    property string currentTime: ""
    property string currentDate: ""
    property string statusMessage: ""
    property bool isAuthenticating: false
    property string pendingPassword: ""
    property bool isLocked: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const date = new Date();
            service.currentTime = Qt.formatTime(date, "hh:mm");
            service.currentDate = Qt.formatDateTime(date, "dddd, MMMM d");
        }
    }

    PamContext {
        id: pam
        config: "login"
        user: Config.targetUser

        onPamMessage: {
            if (pam.responseRequired) {
                pam.respond(service.pendingPassword);
                service.pendingPassword = "";
            }
        }

        onCompleted: result => {
            service.isAuthenticating = false;
            service.pendingPassword = "";

            if (result === PamResult.Success) {
                service.statusMessage = "Unlocked";
                service.isLocked = false;
            } else {
                service.statusMessage = "Incorrect password";
            }
        }

        onError: error => {
            service.isAuthenticating = false;
            service.pendingPassword = "";
            service.statusMessage = PamError.toString(error);
        }
    }

    function unlock(password: string): void {
        if (!password || isAuthenticating || !Config.targetUser)
            return;

        pendingPassword = password;
        isAuthenticating = true;
        statusMessage = "Unlocking...";
        if (!pam.start()) {
            isAuthenticating = false;
            pendingPassword = "";
            statusMessage = "Could not start authentication";
        }
    }

    function lock(): void {
        pendingPassword = "";
        statusMessage = "";
        isLocked = true;
    }

    property IpcHandler lockIpc: IpcHandler {
        target: "lockscreen"

        function lock(): void {
            service.lock();
        }
    }
}