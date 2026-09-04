import QtQuick
import QtQuick.Layouts
import qs.configs

ColumnLayout {
    id: root

    default property alias content: innerContainer.data

    property bool showHeader: true
    property string title: ""
    property string iconText: ""
    property real headerSpacing: 6
    property real headerTopMargin: 4
    property real iconSize: 18
    property real titleSize: 14
    property bool titleBold: true
    property color headerColor: Color.text
    property string iconFontFamily: Config.iconFont
    property string textFontFamily: Config.textFont

    property real cardRadius: Config.radius
    property color cardColor: Color.surface
    property color borderColor: "transparent"
    property real borderWidth: 0
    property real containerPadding: 12
    property real innerSpacing: 8
    property real sectionSpacing: 10

    Layout.fillWidth: true
    spacing: root.sectionSpacing

    RowLayout {
        visible: root.showHeader && (root.title.length > 0 || root.iconText.length > 0)
        spacing: root.headerSpacing
        Layout.topMargin: root.headerTopMargin

        Text {
            visible: root.iconText.length > 0
            text: root.iconText
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.headerColor
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: root.title.length > 0
            text: root.title
            font.family: root.textFontFamily
            font.pixelSize: root.titleSize
            font.bold: root.titleBold
            color: root.headerColor
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: innerContainer.implicitHeight + (root.containerPadding * 2)
        radius: root.cardRadius
        color: root.cardColor
        border.color: root.borderColor
        border.width: root.borderWidth

        ColumnLayout {
            id: innerContainer
            anchors.fill: parent
            anchors.margins: root.containerPadding
            spacing: root.innerSpacing
        }
    }
}
