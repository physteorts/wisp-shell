pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string configDir: homeDir + "/.config/wisp-shell"
    readonly property string configPath: configDir + "/settings.json"

    property var settings: ({
            wallpaper: ""
        })

    readonly property string wallpaper: settings.wallpaper ?? ""

    Process {
        id: initProcess
        command: ["sh", "-c", "mkdir -p '" + config.configDir + "' && " + "if [ ! -f '" + config.configPath + "' ]; then " + "  echo '{\"wallpaper\": \"\"}' > '" + config.configPath + "'; " + "fi"]
        running: true

        onExited: exitCode => {
            if (exitCode === 0) {
                fileView.reload();
            }
        }
    }

    Process {
        id: writeProcess
        property string payload: ""

        command: ["sh", "-c", "cat << 'EOF' > '" + config.configPath + "'\n" + payload + "\nEOF"]

        onExited: exitCode => {
            if (exitCode === 0) {
                fileView.reload();
            } else {
                console.error("[Config] Error writing settings.json:", exitCode);
            }
        }
    }

    FileView {
        id: fileView
        path: config.configPath

        onLoaded: {
            config.load();
        }

        onPathChanged: {
            config.load();
        }
    }

    function load(): void {
        const text = fileView.text();
        if (!text || text.trim() === "")
            return;

        try {
            const parsed = JSON.parse(text);
            settings = Object.assign({}, settings, parsed);
        } catch (e) {
            console.warn("[Config] Failed parsing settings.json:", e);
        }
    }

    function setWallpaper(path: string): void {
        const updated = Object.assign({}, settings);
        updated.wallpaper = path;
        settings = updated;
        save();
    }

    function save(): void {
        writeProcess.payload = JSON.stringify(settings, null, 2);
        writeProcess.running = true;
    }
}
