import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.10


Window {
    id: root

    visible: true
    visibility: "FullScreen"
    width: Screen.width
    height: Screen.height

    Rectangle {
        id: background

        color: "black"
        height: parent.height
        width: parent.width
        anchors.centerIn: parent
    }

    ColumnLayout {
        id: layout

        visible: title.text.length > 0 || subtitle.text.length > 0
        anchors.centerIn: parent
        Layout.maximumWidth: 0.9 * Screen.width

        Text {
            objectName: "title"
            id: title

            text: ""

            visible: text.length > 0
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.maximumWidth: 0.9 * Screen.width
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 24
            font.bold: true
        }

        Text {
            objectName: "subtitle"
            id: subtitle

            text: ""

            visible: text.length > 0
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.maximumWidth: 0.9 * Screen.width
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 18
        }
    }

    Timer {
        interval: 150; running: true; repeat: false

        onTriggered: {
            background.color = "white"
            shutdownTimer.start()
        }
    }

    Timer {
        id: shutdownTimer

        interval: 150; running: false; repeat: false

        onTriggered: {
            Qt.callLater(Qt.quit)
        }
    }
}
