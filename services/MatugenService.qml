pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.configs
import qs.services

Singleton {
    id: service

    property string stdoutBuffer: ""
    property string stderrBuffer: ""
    property bool running: matugenProc.running

    Component.onCompleted: {
        console.info("[MatugenService] Initialized.");
        if (WallpaperService.hasWallpaper) {
            service.generateColors(WallpaperService.currentWallpaper);
        }
    }

    Connections {
        target: WallpaperService
        function onCurrentWallpaperChanged(): void {
            if (WallpaperService.hasWallpaper) {
                service.generateColors(WallpaperService.currentWallpaper);
            }
        }
    }

    Connections {
        target: Color
        function onIsDarkChanged(): void {
            if (WallpaperService.hasWallpaper) {
                service.generateColors(WallpaperService.currentWallpaper);
            }
        }
    }

    Process {
        id: matugenProc

        stdout: SplitParser {
            onRead: data => {
                service.stdoutBuffer += data;
            }
        }

        stderr: SplitParser {
            onRead: data => {
                service.stderrBuffer += data;
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && service.stdoutBuffer.trim() !== "") {
                try {
                    const parsed = JSON.parse(service.stdoutBuffer.trim());
                    if (typeof Color.updatePalette === "function") {
                        Color.updatePalette(parsed, true);
                    }
                } catch (e) {
                    console.warn("[MatugenService] Failed to parse generated palette:", e);
                }
            } else if (exitCode !== 0) {
                console.warn("[MatugenService] Matugen exited with code", exitCode, ":", service.stderrBuffer);
            }
            service.stdoutBuffer = "";
            service.stderrBuffer = "";
        }
    }

    function sanitizePath(path: string): string {
        if (!path || path.trim() === "")
            return "";
        let cleanPath = path;
        if (cleanPath.startsWith("file://")) {
            cleanPath = cleanPath.slice(7);
        }
        try {
            cleanPath = decodeURIComponent(cleanPath);
        } catch (e) {}
        return cleanPath.trim();
    }

    function generateColors(imagePath: string): void {
        const cleanPath = sanitizePath(imagePath);
        console.info("[MatugenService] Triggered with path:", cleanPath);
        if (!cleanPath) {
            console.warn("[MatugenService] Aborting: Empty wallpaper path");
            return;
        }

        if (typeof Color.isDynamicPalette !== "undefined" && !Color.isDynamicPalette)
            return;

        service.stdoutBuffer = "";
        service.stderrBuffer = "";

        const pyScript = ["import sys, json", "raw = sys.stdin.read().strip()", "if not raw:", "    sys.exit(1)", "data = json.loads(raw)", "c = data.get('colors', {})", "keys = {", "    'background': 'background',", "    'surface': 'surface_container_low',", "    'overlay': 'surface_container_high',", "    'muted': 'outline',", "    'subtle': 'outline_variant',", "    'text': 'on_surface',", "    'primary': 'primary',", "    'secondary': 'secondary',", "    'tertiary': 'tertiary',", "    'warning': 'tertiary',", "    'info': 'secondary',", "    'error': 'error'", "}", "res = {}", "for m in ('dark', 'light'):", "    res[m] = {}", "    mode_colors = c.get(m, {}) if isinstance(c.get(m), dict) else {}", "    for k, src in keys.items():", "        val = ''", "        if src in mode_colors:", "            target = mode_colors[src]", "            val = target.get('color', target) if isinstance(target, dict) else str(target)", "        elif isinstance(c.get(src), dict):", "            sub = c[src].get(m, {})", "            val = sub.get('color', sub) if isinstance(sub, dict) else str(sub)", "        elif src in c and isinstance(c[src], str):", "            val = c[src]", "        if val and not val.startswith('#'):", "            val = '#' + val", "        res[m][k] = val", "print(json.dumps(res))"].join("\n");

        const mode = Color.isDark ? "dark" : "light";
        const matugenDir = Qt.resolvedUrl("../matugen").replace(/^file:\/\//, "");

        const fullCommand = `export PATH="$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:$PATH"; ` + `cd "${matugenDir}" && ` + `matugen image "${cleanPath}" -c config.toml -m "${mode}" -t scheme-tonal-spot --json hex | ` + `python3 -c "${pyScript}"`;

        if (matugenProc.running) {
            matugenProc.running = false;
        }

        matugenProc.command = ["sh", "-c", fullCommand];
        matugenProc.running = true;
    }

    property IpcHandler matugenIpc: IpcHandler {
        target: "matugen"

        function reload(): void {
            if (WallpaperService.hasWallpaper) {
                service.generateColors(WallpaperService.currentWallpaper);
            }
        }

        function run(path: string): void {
            service.generateColors(path);
        }
    }
}
