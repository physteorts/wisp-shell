import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.configs
import qs.services
import qs.components

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property var modelData
            screen: modelData
            visible: LockScreenService.isLocked
            color: Color.background

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "wisp-lockscreen"

            Image {
                anchors.fill: parent
                source: "file://" + Config.configDir + "/wallpaper.jpg"
                fillMode: Image.PreserveAspectCrop
                cache: false
                asynchronous: true
                opacity: 0.4
            }

            ColumnLayout {
                z: 1
                anchors.centerIn: parent
                width: 320
                spacing: 20

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2

                    Text {
                        text: LockScreenService.currentTime
                        font.family: Config.textFont
                        font.pixelSize: 56
                        font.bold: true
                        color: Color.text
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: LockScreenService.currentDate
                        font.family: Config.textFont
                        font.pixelSize: 14
                        color: Color.muted
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Item {
                    Layout.preferredHeight: 12
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 72
                    height: 72
                    radius: width / 2
                    color: Color.surface
                    border.color: Color.overlay
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "\ue7fd"
                        font.family: Config.iconFont
                        font.pixelSize: 36
                        color: Color.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Input {
                        id: passwordInput
                        Layout.fillWidth: true
                        inputHeight: 42
                        leadingIcon: "\ue897"
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        enabled: !LockScreenService.isAuthenticating
                        onAccepted: submit()

                        function submit(): void {
                            if (text.length > 0)
                                LockScreenService.unlock(text);
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        buttonHeight: 40
                        text: LockScreenService.isAuthenticating ? "Unlocking..." : "Unlock"
                        leadingIcon: "\ue898"
                        enabled: passwordInput.text.length > 0 && !LockScreenService.isAuthenticating
                        onClicked: passwordInput.submit()
                    }

                    Text {
                        visible: LockScreenService.statusMessage.length > 0
                        text: LockScreenService.statusMessage
                        font.family: Config.textFont
                        font.pixelSize: 12
                        color: LockScreenService.statusMessage === "Incorrect password" ? Color.error : Color.muted
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                    }
                }
            }

            RowLayout {
                z: 1
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    margins: 28
                }
                spacing: 12

                Button {
                    variant: "ghost"
                    leadingIcon: "\ue1b8"
                    buttonHeight: 38
                    horizontalPadding: 12
                    onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                }

                Button {
                    variant: "ghost"
                    leadingIcon: "\ue8ac"
                    buttonHeight: 38
                    horizontalPadding: 12
                    onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }

            onVisibleChanged: {
                if (visible) {
                    passwordInput.text = "";
                    passwordInput.forceActiveFocus();
                }
            }
        }
    }
}