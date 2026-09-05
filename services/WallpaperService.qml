pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.configs
import qs.services

Singleton {
    id: service

    readonly property var _matugen: MatugenService

    property string currentWallpaper: Config.wallpaper
    property int revision: 0
    readonly property bool hasWallpaper: currentWallpaper !== ""
    readonly property string imageSource: hasWallpaper ? currentWallpaper + "?revision=" + revision : ""
    readonly property string wallpaperPath: Config.configDir + "/wallpaper.jpg"
    property string pendingWallpaper: ""
    property string copyingWallpaper: ""

    Process {
        id: copyProcess

        onExited: exitCode => {
            const copiedWallpaper = service.copyingWallpaper;
            service.copyingWallpaper = "";

            if (exitCode === 0) {
                service.currentWallpaper = "";
                const copiedPath = service.formatPath(service.wallpaperPath);
                service.currentWallpaper = copiedPath;
                service.revision++;
                Config.setWallpaper(copiedPath);
                service._matugen.generateColors(copiedPath);
            } else {
                console.warn("[WallpaperService] Failed to copy wallpaper:", copiedWallpaper);
            }

            if (service.pendingWallpaper && service.pendingWallpaper !== copiedWallpaper) {
                const nextWallpaper = service.pendingWallpaper;
                service.pendingWallpaper = "";
                service.copyWallpaper(nextWallpaper);
            } else {
                service.pendingWallpaper = "";
            }
        }
    }

    Connections {
        target: Config
        function onWallpaperChanged(): void {
            service.copyWallpaper(Config.wallpaper);
        }

        function onTargetHomeChanged(): void {
            service.copyWallpaper(Config.wallpaper);
        }
    }

    function copyWallpaper(path: string): void {
        const formatted = formatPath(path);
        if (!formatted || !formatted.startsWith("file://")) {
            currentWallpaper = formatted;
            if (formatted && typeof Config.setWallpaper === "function")
                Config.setWallpaper(formatted);
            return;
        }

        const sourcePath = formatted.replace(/^file:\/\//, "");
        if (sourcePath === wallpaperPath)
            return;

        if (copyProcess.running) {
            pendingWallpaper = formatted;
            return;
        }

        copyingWallpaper = formatted;
        copyProcess.command = ["install", "-m", "0644", sourcePath, wallpaperPath];
        copyProcess.running = true;
    }

    function formatPath(path: string): string {
        if (!path || path.trim() === "")
            return "";
        if (path.startsWith("file://") || path.startsWith("http://") || path.startsWith("https://")) {
            return path;
        }
        return "file://" + path;
    }

    function setWallpaper(path: string): void {
        copyWallpaper(path);
    }

    function clear(): void {
        currentWallpaper = "";
        if (typeof Config.setWallpaper === "function") {
            Config.setWallpaper("");
        }
    }

    property IpcHandler wallpaperIpc: IpcHandler {
        target: "wallpaper"

        function set(path: string): void {
            service.setWallpaper(path);
        }

        function clear(): void {
            service.clear();
        }

        function get(): string {
            return service.currentWallpaper;
        }
    }
}
