import QtQuick
import qs.configs

Rectangle {
    id: root

    signal clicked

    property int size: 32
    property int iconSize: 20
    property string iconText: "\ue5cd"

    width: size
    height: size
    radius: Config.radius
    color: mouseArea.containsMouse ? Color.overlay : "transparent"

    Text {
        anchors.centerIn: parent
        text: root.iconText
        font.family: Config.iconFont
        font.pixelSize: root.iconSize
        color: mouseArea.containsMouse ? Color.text : Color.muted
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
