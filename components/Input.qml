import QtQuick
import QtQuick.Layouts
import qs.configs

Rectangle {
    id: root

    // Content & Bindings
    property alias text: textInput.text
    property alias input: textInput
    property string placeholderText: ""
    property int echoMode: TextInput.Normal
    property bool readOnly: false
    property int maximumLength: 32767
    property var validator: null
    property int inputMethodHints: Qt.ImhNone

    // Icons
    property string leadingIcon: ""
    property string trailingIcon: ""
    property bool showClearButton: false

    // Sizing & Geometry
    property real inputHeight: 42
    property real radiusValue: Config.radius
    property real horizontalPadding: 12
    property real contentSpacing: 8
    property real iconSize: 18
    property real fontSize: 13
    property string textFontFamily: Config.textFont
    property string iconFontFamily: Config.iconFont

    // Colors
    property color backgroundColor: Color.surface
    property color activeBorderColor: Color.primary
    property color idleBorderColor: Color.overlay
    property color textColor: Color.text
    property color placeholderColor: Color.muted
    property color iconColor: textInput.activeFocus ? Color.primary : Color.muted
    property color clearButtonHoverColor: Color.overlay
    property real borderWidthValue: 1

    // Signals
    signal accepted
    signal textEdited
    signal cleared

    Layout.fillWidth: true
    implicitHeight: root.inputHeight
    radius: root.radiusValue
    color: root.backgroundColor
    border.color: textInput.activeFocus ? root.activeBorderColor : root.idleBorderColor
    border.width: root.borderWidthValue

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.contentSpacing

        // Leading Icon
        Text {
            visible: root.leadingIcon.length > 0
            text: root.leadingIcon
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.iconColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        // Input Field & Placeholder
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextInput {
                id: textInput
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                font.family: root.textFontFamily
                font.pixelSize: root.fontSize
                color: root.textColor
                echoMode: root.echoMode
                readOnly: root.readOnly
                maximumLength: root.maximumLength
                validator: root.validator
                inputMethodHints: root.inputMethodHints
                selectByMouse: true
                selectionColor: Color.primary
                selectedTextColor: Color.background
                clip: true

                onAccepted: root.accepted()
                onTextEdited: root.textEdited()
            }

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: root.placeholderText
                font.family: root.textFontFamily
                font.pixelSize: root.fontSize
                color: root.placeholderColor
                visible: !textInput.text && !textInput.inputMethodComposing
                elide: Text.ElideRight
            }
        }

        // Optional Clear Action Button
        Rectangle {
            id: clearBtn
            visible: root.showClearButton && textInput.text.length > 0 && !root.readOnly
            implicitWidth: root.iconSize + 6
            implicitHeight: root.iconSize + 6
            radius: root.radiusValue
            color: clearMouse.containsMouse ? root.clearButtonHoverColor : "transparent"
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "\ue5cd" // Close / Clear icon
                font.family: root.iconFontFamily
                font.pixelSize: root.iconSize - 2
                color: root.placeholderColor
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    textInput.text = "";
                    root.cleared();
                    textInput.forceActiveFocus();
                }
            }
        }

        // Trailing Icon
        Text {
            visible: root.trailingIcon.length > 0 && !clearBtn.visible
            text: root.trailingIcon
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.placeholderColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        acceptedButtons: Qt.NoButton
    }

    function forceActiveFocus(): void {
        textInput.forceActiveFocus();
    }
}
