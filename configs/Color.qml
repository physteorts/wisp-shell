pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.configs

Singleton {
    id: root

    readonly property string configDir: Config.configDir
    readonly property string configPath: configDir + "/colors.json"

    readonly property var darkPalette: ({
            background: "#0e1513",
            surface: "#171d1b",
            overlay: "#252b29",
            muted: "#89938f",
            subtle: "#3f4945",
            text: "#dee4e0",
            primary: "#85d6c0",
            secondary: "#b1ccc3",
            tertiary: "#aacbe3",
            warning: "#aacbe3",
            info: "#b1ccc3",
            error: "#ffb4ab"
        })

    readonly property var lightPalette: ({
            background: "#f5fbf7",
            surface: "#eff5f1",
            overlay: "#e3eae6",
            muted: "#6f7975",
            subtle: "#bfc9c4",
            text: "#171d1b",
            primary: "#0a6b5a",
            secondary: "#4b635c",
            tertiary: "#426277",
            warning: "#426277",
            info: "#4b635c",
            error: "#ba1a1a"
        })

    property bool isDark: true
    property bool isDynamicPalette: true
    property int revision: 0

    property var colorData: ({
            dark: darkPalette,
            light: lightPalette
        })

    readonly property var palette: {
        root.revision; // Re-evaluate whenever revision increments
        return isDark ? colorData.dark : colorData.light;
    }

    function getColor(key) {
        root.revision;
        return palette?.[key] ?? "#000000";
    }

    readonly property color background: getColor("background")
    readonly property color surface: getColor("surface")
    readonly property color overlay: getColor("overlay")
    readonly property color muted: getColor("muted")
    readonly property color subtle: getColor("subtle")
    readonly property color text: getColor("text")
    readonly property color primary: getColor("primary")
    readonly property color secondary: getColor("secondary")
    readonly property color tertiary: getColor("tertiary")
    readonly property color warning: getColor("warning")
    readonly property color info: getColor("info")
    readonly property color error: getColor("error")

    Process {
        id: initProcess
        command: ["sh", "-c", "mkdir -p '" + root.configDir + "' && " + "if [ ! -f '" + root.configPath + "' ]; then " + "  cat << 'EOF' > '" + root.configPath + "'\n" + JSON.stringify({
                isDark: root.isDark,
                isDynamicPalette: root.isDynamicPalette,
                dark: root.darkPalette,
                light: root.lightPalette
            }, null, 2) + "\nEOF\n" + "fi"]
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
            if (exitCode !== 0) {
                console.error("[Color] Error writing colors.json:", exitCode);
            }
        }
    }

    FileView {
        id: fileView
        path: root.configPath

        onLoaded: root.load()
        onPathChanged: root.load()
    }

    function load() {
        const text = fileView.text();
        if (!text || text.trim() === "")
            return;

        try {
            const parsed = JSON.parse(text);
            if (typeof parsed.isDark === "boolean") {
                root.isDark = parsed.isDark;
            }
            if (typeof parsed.isDynamicPalette === "boolean") {
                root.isDynamicPalette = parsed.isDynamicPalette;
            }
            if (parsed.dark || parsed.light) {
                colorData = {
                    dark: Object.assign({}, darkPalette, parsed.dark ?? {}),
                    light: Object.assign({}, lightPalette, parsed.light ?? {})
                };
                root.revision++;
            }
        } catch (e) {
            console.warn("[Color] Failed to parse colors.json:", e);
        }
    }

    function updatePalette(newPaletteData, saveToFile) {
        if (!newPaletteData)
            return;

        if (saveToFile === undefined) {
            saveToFile = true;
        }

        colorData = {
            dark: Object.assign({}, colorData.dark, newPaletteData.dark ?? {}),
            light: Object.assign({}, colorData.light, newPaletteData.light ?? {})
        };
        root.revision++;

        if (saveToFile) {
            save();
        }
    }

    function setColor(key, value) {
        const mode = isDark ? "dark" : "light";
        const updated = Object.assign({}, colorData);
        const modeCopy = Object.assign({}, updated[mode]);

        modeCopy[key] = value;
        updated[mode] = modeCopy;

        colorData = updated;
        root.revision++;
        save();
    }

    function setPalette(mode, newPalette) {
        if (mode !== "dark" && mode !== "light")
            return;
        const updated = Object.assign({}, colorData);
        updated[mode] = Object.assign({}, updated[mode], newPalette);
        colorData = updated;
        root.revision++;
        save();
    }

    function setDark(dark) {
        if (root.isDark !== dark) {
            root.isDark = dark;
            root.revision++;
            save();
        }
    }

    function setDynamicPalette(dynamic) {
        if (root.isDynamicPalette !== dynamic) {
            root.isDynamicPalette = dynamic;
            save();
        }
    }

    function save() {
        const payload = {
            isDark: root.isDark,
            isDynamicPalette: root.isDynamicPalette,
            dark: colorData.dark,
            light: colorData.light
        };

        writeProcess.command = ["sh", "-c", "cat << 'EOF' > '" + root.configPath + "'\n" + JSON.stringify(payload, null, 2) + "\nEOF"];
        writeProcess.running = true;
    }

    property IpcHandler colorIpc: IpcHandler {
        target: "color"

        function set(key: string, val: string): void {
            root.setColor(key, val);
        }

        function get(key: string): string {
            return root.palette[key] ?? "";
        }

        function toggleMode(): void {
            root.setDark(!root.isDark);
        }

        function setDarkMode(val: bool): void {
            root.setDark(val);
        }

        function setDynamic(val: bool): void {
            root.setDynamicPalette(val);
        }
    }
}
