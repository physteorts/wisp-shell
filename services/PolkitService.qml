pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

QtObject {
    id: service

    property bool dialogOpen: false
    readonly property var flow: agent.flow

    readonly property string systemUser: {
        if (agent.flow && agent.flow.identity) {
            return agent.flow.identity.replace(/^unix-user:/, "");
        }
        return Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user";
    }

    readonly property string avatarPath: "file://" + (Quickshell.env("HOME") || "") + "/.face"

    readonly property string message: (agent.flow && agent.flow.message && agent.flow.message.length > 0) ? agent.flow.message : "An application is attempting to perform an action that requires administrative privileges."

    property PolkitAgent agent: PolkitAgent {
        id: agent
        onFlowChanged: {
            service.dialogOpen = (flow !== null);
        }
    }

    function submit(password: string): void {
        if (agent.flow && password && password.length > 0) {
            agent.flow.submit(password);
        }
    }

    function dismiss(): void {
        service.dialogOpen = false;
        if (!agent.flow)
            return;

        if (typeof agent.flow.cancel === "function") {
            agent.flow.cancel();
        } else if (typeof agent.cancel === "function") {
            agent.cancel();
        } else {
            agent.flow.submit("");
        }
    }
}
