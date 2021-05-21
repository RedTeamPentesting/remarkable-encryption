import QtQuick 2.6
import QtQuick.Window 2.6
import QtQml 2.6
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.10


Window {
    id: root

    visible: true
    visibility: "FullScreen"
    width: Screen.width
    height: Screen.height


    Rectangle {
        id: page

        width: Screen.width; height: Screen.height
        color: "lightgray"

        Image {
            id: banner

            source: "banner.png"

            anchors.top: page.top
            width: page.width
        }

        Rectangle {
            id: center

            anchors.top: banner.bottom
            anchors.bottom: keyboard.top
            width: Screen.width
            color: "transparent"

            Column {
                id: inputColumn

                spacing: 30
                anchors.centerIn: parent
                width: 0.8 * parent.width

                Text {
                    text: "Enter Crypto Passphrase:"

                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 20; font.bold: true
                }

                Text {
                    objectName: "incorrectNotification"
                    id: incorrectNotification

                    text: "Passphrase was incorrect!"
                    visible: false

                    font.pointSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: passwordFrame

                    color: "white"
                    border.color: "black"
                    border.width: 5
                    height: passphraseField.height + 40
                    width: parent.width

                    TextInput {
                        objectName: "passphraseField"
                        id: passphraseField

                        focus: false
                        width: parent.width - 40
                        cursorVisible: true
                        activeFocusOnPress: false
                        autoScroll: true
                        echoMode: passwordVisible.checked? TextInput.Normal : TextInput.Password
                        wrapMode: TextInput.Wrap
                        anchors.centerIn: parent
                        font.pointSize: 18
                    }
                }

                CheckBox {
                    id: passwordVisible

                    text: " Show Passphrase"
                    checked: false

                    width: parent.width
                    font.pointSize: 14
                    indicator.width: 60
                    indicator.height: 60
                    Layout.alignment: Qt.AlignLeft
                }
            }


        }

        Keyboard {
            id: keyboard

            onKeypress: {
                keyboard.shift = false;
                passphraseField.insert(passphraseField.cursorPosition, key)
            }

            onSubmit: Qt.quit()

            onReset: passphraseField.clear()

            onBackspace: {
                if (passphraseField.cursorPosition == 0) {
                    return;
                }

                var cursor = passphraseField.cursorPosition;
                passphraseField.remove(cursor-1, cursor);
            }
        }
    }
}
