import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.configs
import qs.components

Item {
    id: root

    default property alias content: contentContainer.data

    property real cardWidth: 780
    property real cardHeight: 700
    property real horizontalPadding: 24
    property real verticalPadding: 60
    property real contentMargin: 8
    property real radius: Config.radius
    property real borderWidth: 1

    property color cardColor: Color.background
    property color borderColor: Color.overlay
    property color backdropColor: "transparent"

    property bool showCloseButton: true
    property real closeButtonMargin: 8
    property int closeButtonZ: 10
    property int closeButtonSize: 32
    property int closeButtonIconSize: 20
    property string closeButtonIcon: "\ue5cd"

    property bool closeOnBackdropClick: true
    property bool closeOnEscape: true
    property string escapeKeySequence: "Escape"

    signal closed

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: root.backdropColor
        visible: root.backdropColor !== "transparent"
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.closeOnBackdropClick
        onClicked: root.closed()
    }

    Rectangle {
        id: mainCard
        width: Math.min(root.cardWidth, parent.width - root.horizontalPadding)
        height: Math.min(root.cardHeight, parent.height - root.verticalPadding)
        anchors.centerIn: parent
        radius: root.radius
        color: root.cardColor
        border.color: root.borderColor
        border.width: root.borderWidth

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        CloseButton {
            visible: root.showCloseButton
            size: root.closeButtonSize
            iconSize: root.closeButtonIconSize
            iconText: root.closeButtonIcon
            z: root.closeButtonZ

            anchors {
                top: parent.top
                right: parent.right
                margins: root.closeButtonMargin
            }

            onClicked: root.closed()
        }

        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: root.contentMargin
        }
    }

    Shortcut {
        sequence: root.escapeKeySequence
        enabled: root.visible && root.closeOnEscape
        onActivated: root.closed()
    }
}
