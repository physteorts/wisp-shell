import QtQuick
import QtQuick.Layouts
import qs.configs

Rectangle {
    id: root

    // Content
    property string text: ""
    property string leadingIcon: ""
    property string trailingIcon: ""

    // Style Variant: "primary" | "secondary" | "ghost" | "danger"
    property string variant: "primary"

    // Dimensions & Geometry
    property real buttonHeight: 38
    property real horizontalPadding: 16
    property real contentSpacing: 8
    property real radiusValue: Config.radius
    property real iconSize: 18
    property real fontSize: 13
    property bool fontBold: true

    // Typography & Fonts
    property string textFontFamily: Config.textFont
    property string iconFontFamily: Config.iconFont

    // State Flags
    property bool enabled: true

    // Colors & Tokens
    readonly property color baseColor: {
        if (!root.enabled)
            return Color.overlay; // Drop to neutral surface when disabled
        if (root.variant === "primary")
            return Color.primary;
        if (root.variant === "secondary")
            return Color.overlay;
        if (root.variant === "danger")
            return Color.danger || "#ef4444";
        return "transparent";
    }

    readonly property color contentColor: {
        if (!root.enabled)
            return Color.muted; // Clean muted text against overlay background
        if (root.variant === "primary" || root.variant === "danger")
            return Color.background;
        return Color.text;
    }

    property color hoverColor: {
        if (root.variant === "primary")
            return Qt.lighter(Color.primary, 1.1);
        if (root.variant === "secondary")
            return Qt.lighter(Color.overlay, 1.2);
        if (root.variant === "danger")
            return Qt.lighter(Color.danger || "#ef4444", 1.1);
        return Color.overlay;
    }

    property color pressedColor: {
        if (root.variant === "primary")
            return Qt.darker(Color.primary, 1.1);
        if (root.variant === "secondary")
            return Qt.darker(Color.overlay, 1.1);
        if (root.variant === "danger")
            return Qt.darker(Color.danger || "#ef4444", 1.1);
        return Color.surface;
    }

    property real borderWidthValue: (root.variant === "secondary" || root.variant === "ghost") ? 1 : 0
    property color borderColorValue: root.variant === "secondary" ? Color.overlay : "transparent"

    signal clicked

    implicitWidth: contentRow.implicitWidth + (root.horizontalPadding * 2)
    implicitHeight: root.buttonHeight
    radius: root.radiusValue
    border.width: root.borderWidthValue
    border.color: root.borderColorValue

    // Keep full 1.0 opacity so muted text renders sharp and legible without double fading
    opacity: 1.0

    color: {
        if (!root.enabled)
            return root.baseColor;
        if (mouseArea.pressed)
            return root.pressedColor;
        if (mouseArea.containsMouse)
            return root.hoverColor;
        return root.baseColor;
    }

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.contentSpacing

        Text {
            visible: root.leadingIcon.length > 0
            text: root.leadingIcon
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.contentColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.text.length > 0
            text: root.text
            font.family: root.textFontFamily
            font.pixelSize: root.fontSize
            font.bold: root.fontBold
            color: root.contentColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.trailingIcon.length > 0
            text: root.trailingIcon
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.contentColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
