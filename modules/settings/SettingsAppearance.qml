import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.configs
import qs.components
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 16

    Card {
        Layout.fillWidth: true
        title: "Wallpaper"
        iconText: "\ue3f4"

        Item {
            id: previewContainer
            Layout.fillWidth: true
            height: 180

            Rectangle {
                anchors.fill: parent
                radius: Config.radius
                color: Color.overlay
                antialiasing: true
                smooth: true
                visible: !WallpaperService.hasWallpaper

                Text {
                    anchors.centerIn: parent
                    text: "\ue3f4"
                    font.family: Config.iconFont
                    font.pixelSize: 36
                    color: Color.muted
                }
            }

            Image {
                id: previewImage
                anchors.fill: parent
                visible: false
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                mipmap: true
                smooth: true
                layer.enabled: true
                layer.smooth: true
                source: WallpaperService.hasWallpaper ? (WallpaperService.currentWallpaper.startsWith("file://") ? WallpaperService.currentWallpaper : "file://" + WallpaperService.currentWallpaper) : ""
            }

            Rectangle {
                id: previewMask
                anchors.fill: parent
                visible: false
                radius: Config.radius
                color: "black"
                antialiasing: true
                smooth: true

                layer.enabled: true
                layer.smooth: true
                layer.effect: null
            }

            MultiEffect {
                anchors.fill: parent
                source: previewImage
                maskSource: previewMask
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                visible: WallpaperService.hasWallpaper
            }
        }

        CardRow {
            Layout.fillWidth: true
            leadingIcon: "\ue1bc"
            title: "Wallpaper"
            subtitle: WallpaperService.hasWallpaper ? WallpaperService.currentWallpaper.replace(/^file:\/\//, "") : "No wallpaper selected"
            onClicked: SettingsService.openWallpaperPicker()
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
