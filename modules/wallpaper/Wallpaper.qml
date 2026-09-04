import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.configs

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: bgWindow
                required property var modelData
                screen: modelData

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "quickshell-wallpaper"
                exclusionMode: ExclusionMode.Ignore
                color: Color.background

                Image {
                    id: sourceImage
                    anchors.fill: parent
                    visible: WallpaperService.hasWallpaper
                    source: WallpaperService.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    smooth: true
                }
            }
        }
    }
}
