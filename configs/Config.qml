pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    readonly property string homeDir: Quickshell.env("HOME") ?? ""
    readonly property string configDir: homeDir + "/.config/wisp-shell"
    readonly property string configPath: configDir + "/settings.json"

    property var settings: ({
            wallpaper: "",
            radius: 12,
            iconFont: "Material Symbols Rounded",
            textFont: "Inter"
        })

    readonly property string wallpaper: settings.wallpaper
    readonly property int radius: settings.radius
    readonly property string iconFont: settings.iconFont
    readonly property string textFont: settings.textFont

    Process {
        id: initProcess
        command: ["sh", "-c", "mkdir -p '" + config.configDir + "' && " + "if [ ! -f '" + config.configPath + "' ]; then " + "  echo '{\"wallpaper\": \"\", \"radius\": 12, \"iconFont\": \"Material Symbols Rounded\", \"textFont\": \"Inter\"}' > '" + config.configPath + "'; " + "fi"]
        running: true

        onExited: exitCode => {
            if (exitCode === 0) {
                fileView.reload();
            }
        }
    }

    Process {
        id: writeProcess

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

    function setRadius(value: int): void {
        const updated = Object.assign({}, settings);
        updated.radius = value;
        settings = updated;
        save();
    }

    function setIconFont(fontName: string): void {
        const updated = Object.assign({}, settings);
        updated.iconFont = fontName;
        settings = updated;
        save();
    }

    function setTextFont(fontName: string): void {
        const updated = Object.assign({}, settings);
        updated.textFont = fontName;
        settings = updated;
        save();
    }

    function save(): void {
        writeProcess.command = ["sh", "-c", "cat << 'EOF' > '" + config.configPath + "'\n" + JSON.stringify(settings, null, 2) + "\nEOF"];
        writeProcess.running = true;
    }

    property IpcHandler configIpc: IpcHandler {
        target: "config"

        function setRadius(val: int): void {
            config.setRadius(val);
        }

        function getRadius(): int {
            return config.radius;
        }

        function setIconFont(val: string): void {
            config.setIconFont(val);
        }

        function setTextFont(val: string): void {
            config.setTextFont(val);
        }
    }
}
