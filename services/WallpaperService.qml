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
    readonly property bool hasWallpaper: currentWallpaper !== ""

    Connections {
        target: Config
        function onWallpaperChanged(): void {
            if (Config.wallpaper !== service.currentWallpaper) {
                service.currentWallpaper = Config.wallpaper;
            }
        }
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
        const formatted = formatPath(path);
        if (formatted !== currentWallpaper) {
            currentWallpaper = formatted;
            if (typeof Config.setWallpaper === "function") {
                Config.setWallpaper(formatted);
            }
        }
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
