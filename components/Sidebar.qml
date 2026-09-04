import QtQuick
import QtQuick.Layouts
import qs.configs
import qs.components

Rectangle {
    id: root

    property var model: []
    property int currentTab: 0

    property string titleKey: "name"
    property string iconKey: "icon"
    property string tabKey: "tab"

    property real sidebarWidth: 200
    property real sidebarRadius: Config.radius
    property real containerPadding: 12
    property real sectionSpacing: 12

    property color backgroundColor: Color.surface

    property bool showHeader: true
    property string titleText: "Settings"
    property real titleSpacing: 8
    property real titleFontSize: 15
    property bool titleFontBold: true
    property color titleColor: Color.text
    property string textFontFamily: Config.textFont
    property real iconHeaderWidth: 22
    property real iconHeaderHeight: 22
    property color headerIconColor: Color.text

    property real itemSpacing: 4
    property real itemHeight: 38
    property real itemRadius: Config.radius
    property real itemHorizontalPadding: 12
    property real itemContentSpacing: 10

    property real itemFontSize: 13
    property string iconFontFamily: Config.iconFont
    property real itemIconSize: 18

    property color activeColor: Color.primary
    property color activeTextColor: Color.background
    property color hoverColor: Color.overlay
    property color idleColor: "transparent"
    property color idleTextColor: Color.text

    property bool showFooter: true
    property string footerText: "wisp v0.1"
    property real footerFontSize: 14
    property color footerTextColor: Color.muted

    signal tabSelected(int index)

    Layout.fillHeight: true
    Layout.preferredWidth: root.sidebarWidth
    color: root.backgroundColor
    radius: root.sidebarRadius

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.containerPadding
        spacing: root.sectionSpacing

        RowLayout {
            visible: root.showHeader
            Layout.fillWidth: true
            Layout.bottomMargin: 4
            Layout.leftMargin: 4
            spacing: root.titleSpacing

            WispIcon {
                Layout.preferredWidth: root.iconHeaderWidth
                Layout.preferredHeight: root.iconHeaderHeight
                Layout.alignment: Qt.AlignVCenter
                iconColor: root.headerIconColor
            }

            Text {
                text: root.titleText
                font.family: root.textFontFamily
                font.pixelSize: root.titleFontSize
                font.bold: root.titleFontBold
                color: root.titleColor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.itemSpacing

            Repeater {
                model: root.model

                delegate: Rectangle {
                    id: navItem

                    readonly property var itemData: modelData
                    readonly property int itemTargetTab: {
                        if (typeof itemData === "object" && itemData !== null && root.tabKey in itemData) {
                            return itemData[root.tabKey];
                        }
                        return index;
                    }
                    readonly property bool isSelected: root.currentTab === itemTargetTab
                    readonly property bool isHovered: navMouseArea.containsMouse

                    Layout.fillWidth: true
                    height: root.itemHeight
                    radius: root.itemRadius
                    color: isSelected ? root.activeColor : (isHovered ? root.hoverColor : root.idleColor)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.itemHorizontalPadding
                        anchors.rightMargin: root.itemHorizontalPadding
                        spacing: root.itemContentSpacing

                        Text {
                            text: (typeof itemData === "object" && itemData !== null && root.iconKey in itemData) ? itemData[root.iconKey] : ""
                            visible: text.length > 0
                            font.family: root.iconFontFamily
                            font.pixelSize: root.itemIconSize
                            color: navItem.isSelected ? root.activeTextColor : root.idleTextColor
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: (typeof itemData === "object" && itemData !== null && root.titleKey in itemData) ? itemData[root.titleKey] : (typeof itemData === "string" ? itemData : "")
                            font.family: root.textFontFamily
                            font.pixelSize: root.itemFontSize
                            font.bold: navItem.isSelected
                            color: navItem.isSelected ? root.activeTextColor : root.idleTextColor
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tabSelected(navItem.itemTargetTab)
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            visible: root.showFooter && root.footerText.length > 0
            text: root.footerText
            font.family: root.textFontFamily
            font.pixelSize: root.footerFontSize
            color: root.footerTextColor
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
