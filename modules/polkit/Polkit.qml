import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
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
            id: polkitDialogWindow
            required property var modelData
            screen: modelData

            visible: PolkitService.flow !== null && PolkitService.dialogOpen
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            Modal {
                cardWidth: 440
                cardHeight: contentCol.implicitHeight + 84
                showCloseButton: true
                closeOnBackdropClick: false
                onClosed: PolkitService.dismiss()

                Card {
                    anchors.fill: parent
                    title: "Password Required"
                    iconText: "\ue897"

                    ColumnLayout {
                        id: contentCol
                        Layout.fillWidth: true
                        spacing: 12

                        CardRow {
                            Layout.fillWidth: true
                            title: PolkitService.systemUser
                            subtitle: PolkitService.message
                            subtitleMaxWidth: 300

                            leadingContent: Item {
                                implicitWidth: 36
                                implicitHeight: 36

                                // 1. Source Avatar Image
                                Image {
                                    id: avatarImage
                                    anchors.fill: parent
                                    source: PolkitService.avatarPath
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                    mipmap: true
                                    visible: false
                                    layer.enabled: true
                                    layer.smooth: true
                                }

                                // 2. Rounded Mask
                                Rectangle {
                                    id: avatarMask
                                    anchors.fill: parent
                                    radius: Config.radius // or width / 2 for a full circle
                                    color: "black"
                                    antialiasing: true
                                    smooth: true
                                    visible: false
                                    layer.enabled: true
                                    layer.smooth: true
                                }

                                // 3. Masked Rendered Output
                                MultiEffect {
                                    anchors.fill: parent
                                    source: avatarImage
                                    maskSource: avatarMask
                                    maskEnabled: true
                                    maskThresholdMin: 0.5
                                    maskSpreadAtMin: 1.0
                                    visible: avatarImage.status === Image.Ready
                                }

                                // 4. Fallback Icon Frame (when no image exists)
                                Rectangle {
                                    anchors.fill: parent
                                    radius: Config.radius
                                    color: Color.overlay
                                    visible: avatarImage.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\ue7fd"
                                        font.family: Config.iconFont
                                        font.pixelSize: 20
                                        color: Color.primary
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Input {
                                id: passwordInput
                                Layout.fillWidth: true
                                inputHeight: 40
                                leadingIcon: "\ue897"
                                placeholderText: "Enter password"
                                echoMode: TextInput.Password

                                onAccepted: {
                                    if (text.length > 0) {
                                        PolkitService.submit(text);
                                        text = "";
                                    }
                                }
                            }

                            Button {
                                text: "Authenticate"
                                enabled: passwordInput.text.length > 0
                                buttonHeight: 40
                                Layout.preferredWidth: 120

                                onClicked: {
                                    PolkitService.submit(passwordInput.text);
                                    passwordInput.text = "";
                                }
                            }
                        }
                    }
                }
            }

            Connections {
                target: PolkitService
                function onDialogOpenChanged() {
                    if (PolkitService.dialogOpen) {
                        passwordInput.text = "";
                        passwordInput.forceActiveFocus();
                    }
                }
            }
        }
    }
}
