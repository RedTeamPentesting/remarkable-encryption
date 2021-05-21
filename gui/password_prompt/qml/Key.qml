import QtQuick 2.11
import QtQml 2.11


Item {
    id: container

    property color color: "white"
    property string key
    property string shiftKey: ""
    property bool shift: false
    signal pressed(string k)

    width: 105; height: 75

    function currentKeyValue() {
        if (container.shift) {
            return container.shiftKey == ""? container.key.toUpperCase(): container.shiftKey
        }

        return container.key
    }

    Rectangle {
        color: container.color
        border.color: "black"
        anchors.fill: parent

        Text {
            text: container.currentKeyValue()

            anchors.centerIn: parent
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: container.pressed(container.currentKeyValue())
    }
}
