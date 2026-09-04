import QtQuick
import QtQuick.Layouts
import qs.configs

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string leadingIcon: ""
    property string trailingIcon: "\ue5cc"
    property real subtitleMaxWidth: 320

    property real rowHeight: 48
    property real rowRadius: Config.radius
    property real horizontalPadding: 8
    property real contentSpacing: 12
    property real iconSize: 20
    property real titleSize: 13
    property real subtitleSize: 11

    property color idleColor: "transparent"
    property color hoverColor: Color.overlay
    property color textColor: Color.text
    property color mutedColor: Color.muted

    default property alias trailingContent: trailingSlot.data

    signal clicked

    Layout.fillWidth: true
    height: root.rowHeight
    radius: root.rowRadius
    color: rowMouseArea.containsMouse ? root.hoverColor : root.idleColor

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.contentSpacing

        Text {
            visible: root.leadingIcon.length > 0
            text: root.leadingIcon
            font.family: Config.iconFont
            font.pixelSize: root.iconSize
            color: root.textColor
            verticalAlignment: Text.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                font.family: Config.textFont
                font.pixelSize: root.titleSize
                font.bold: true
                color: root.textColor
                visible: root.title.length > 0
            }

            Text {
                text: root.subtitle
                font.family: Config.textFont
                font.pixelSize: root.subtitleSize
                color: root.mutedColor
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                Layout.maximumWidth: root.subtitleMaxWidth
                visible: root.subtitle.length > 0
            }
        }

        Item {
            id: trailingSlot
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                visible: parent.children.length === 1 && root.trailingIcon.length > 0
                text: root.trailingIcon
                font.family: Config.iconFont
                font.pixelSize: root.iconSize
                color: root.textColor
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: rowMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
