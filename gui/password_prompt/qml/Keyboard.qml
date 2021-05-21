import QtQuick 2.11
import QtQml 2.11


Column {
    id: keyboard

    signal keypress(string key)
    signal submit()
    signal reset()
    signal backspace()
    property bool shift: false

    spacing: 10
    width: page.width
    anchors.bottom: page.bottom
    anchors.bottomMargin: 10
    anchors.leftMargin: 10
    anchors.rightMargin: 10


    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        bottomPadding: 15

        Key { key: qsTr("^"); shiftKey: qsTr("°"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("~"); shiftKey: qsTr("x"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("\""); shiftKey: qsTr("§"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("#"); shiftKey: qsTr("$"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("*"); shiftKey: qsTr("%"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("+"); shiftKey: qsTr("&"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("="); shiftKey: qsTr("€"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("("); shiftKey: qsTr("`"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr(")"); shiftKey: qsTr("´"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("["); shiftKey: qsTr("{"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("]"); shiftKey: qsTr("}"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Key { key: qsTr("1"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("2"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("3"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("4"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("5"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("6"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("7"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("8"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("9"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("0"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("Backspace"); width: 220; onPressed: keyboard.backspace() }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Key { key: qsTr("q"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("w"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("e"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("r"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("t"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("z"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("u"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("i"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("o"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("p"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("ü"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("+"); shiftKey: qsTr("*"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Key { key: qsTr("a"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("s"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("d"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("f"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("g"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("h"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("j"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("k"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("l"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("ö"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("ä"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("#"); shiftKey: qsTr("'"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }

    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Key { key: qsTr("Shift"); onPressed: keyboard.shift = !keyboard.shift }
        Key { key: qsTr("<"); shiftKey: qsTr(">"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("y"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("x"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("c"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("v"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("b"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("n"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("m"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr(","); shiftKey: qsTr(";"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("."); shiftKey: qsTr(":"); shift: keyboard.shift; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("-"); shiftKey: qsTr("_"); onPressed: keyboard.keypress(k) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        bottomPadding: 15

        Key { key: qsTr("/"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("\\"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr(" "); width: 600; onPressed: keyboard.keypress(k) }
        Key { key: qsTr("!"); onPressed: keyboard.keypress(k) }
        Key { key: qsTr("?"); onPressed: keyboard.keypress(k) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Key { key: qsTr("Reset"); color: "lightgrey"; height: 100; width: 400;
                onPressed: keyboard.reset()}
        Key { key: qsTr("Submit"); color: "lightgrey";
                height: 100; width: 400; onPressed:  keyboard.submit()}
    }
}
