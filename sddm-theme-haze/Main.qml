import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#1e1e2e"

    // 1. Fondo: el cielo completo
    Image {
        id: sky
        anchors.fill: parent
        source: "backgrounds/mountain_background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // 2. El reloj, entre las dos capas
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: 205
        color: "#ffffff"
        font.pixelSize: 190
        font.bold: false
        font.family: config.fontFamily || "Chillax"
        text: Qt.formatTime(new Date(), "hh:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }

    // 2b. Fecha, justo arriba del reloj, mismo estilo (misma familia y color)
    Text {
        id: dateWidget
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: clock.top
        anchors.bottomMargin: 8
        color: "#ffffff"
        font.pixelSize: 32
        font.bold: false
        font.family: config.fontFamily || "Chillax"
        text: Qt.formatDate(new Date(), "dddd, d MMMM")

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: dateWidget.text = Qt.formatDate(new Date(), "dddd, d MMMM")
        }
    }

    // 3. Primer plano: la montaña con transparencia real
    Image {
        id: mountainForeground
        anchors.fill: parent
        source: "backgrounds/mountain.png"
        fillMode: Image.PreserveAspectCrop
    }

    // 4. Panel de login estilo glass oscuro, sin título
    //    (vidrio oscuro en vez de claro: mucho más contraste para texto blanco)
    Rectangle {
        id: loginPanel
        width: 340
        height: 170
        radius: 20
        color: "#000000"
        opacity: 0.35
        border.color: "#ffffff"
        border.width: 1
        anchors.centerIn: parent
    }

    // Borde superior más claro para dar sensación de luz/cristal
    Rectangle {
        anchors.top: loginPanel.top
        anchors.horizontalCenter: loginPanel.horizontalCenter
        width: loginPanel.width
        height: 1
        radius: 20
        color: "#ffffff"
        opacity: 0.3
        anchors.topMargin: 1
    }

    // Contenido del panel (encima de la capa glass, sin heredar su opacidad)
    ColumnLayout {
        anchors.centerIn: loginPanel
        width: loginPanel.width - 60
        spacing: 18

        TextField {
            id: userField
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            placeholderText: "Username"
            placeholderTextColor: "#c8c8cd"
            color: "#ffffff"
            font.pixelSize: 16
            leftPadding: 16
            opacity: 1

            background: Rectangle {
                color: "#000000"
                opacity: 0.25
                radius: 12
                border.color: userField.activeFocus ? "#ffffff" : "#ffffff"
                border.width: userField.activeFocus ? 1 : 0.5
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            onAccepted: passwordField.forceActiveFocus()
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            echoMode: TextInput.Password
            placeholderText: "Password"
            placeholderTextColor: "#c8c8cd"
            color: "#ffffff"
            font.pixelSize: 16
            leftPadding: 16
            opacity: 1

            background: Rectangle {
                color: "#000000"
                opacity: 0.25
                radius: 12
                border.color: "#ffffff"
                border.width: passwordField.activeFocus ? 1 : 0.5
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            onAccepted: sddm.login(userField.text, passwordField.text, sessionCombo.currentIndex)
        }
    }

    // 5. Mensaje de error/estado
    Text {
        id: statusMessage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginPanel.bottom
        anchors.topMargin: 18
        color: "#ffffff"
        font.pixelSize: 13
        font.family: config.fontFamily || "Chillax"
        text: ""
        visible: text !== ""
        opacity: 0.85
    }

    // 6. Manejo de eventos de login
    Connections {
        target: sddm

        function onLoginFailed() {
            statusMessage.text = "Incorrect Username or Password"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }

        function onLoginSucceeded() {
            statusMessage.text = "Signing in.."
        }
    }

    // 7. Esquina inferior derecha: sesión + apagar/reiniciar, discretos
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 28
        anchors.rightMargin: 48
        spacing: 20

        // Cápsula glass para el selector de sesión, mismo estilo que user/passwd
        // (el fondo va como hermano, no como padre, para que su opacidad no se
        // propague al texto del combo)
        Item {
            id: sessionWrapper
            width: 130
            height: 40
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: sessionCapsule
                anchors.fill: parent
                radius: 12
                color: "#000000"
                opacity: 0.25
                border.color: "#ffffff"
                border.width: sessionCombo.activeFocus ? 1 : 0.5
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            ComboBox {
                id: sessionCombo
                anchors.fill: parent
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex

                background: Rectangle { color: "transparent" }

                contentItem: Text {
                    text: sessionCombo.displayText
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 14
                    rightPadding: 22
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                indicator: Text {
                    text: "⌄"
                    color: "#ffffff"
                    opacity: 0.8
                    font.pixelSize: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Alinea el borde derecho del popup con el de la cápsula,
                // para que no se corte con el borde de la pantalla
                popup: Popup {
                    x: sessionCombo.width - width
                    y: -implicitHeight - 8
                    width: 150
                    implicitHeight: listView.contentHeight + 8
                    padding: 4

                    background: Rectangle {
                        color: "#1e1e2e"
                        opacity: 0.95
                        radius: 10
                        border.color: "#ffffff"
                        border.width: 1
                    }

                    contentItem: ListView {
                        id: listView
                        clip: true
                        implicitHeight: contentHeight
                        model: sessionCombo.popup.visible ? sessionCombo.delegateModel : null
                        currentIndex: sessionCombo.highlightedIndex
                    }
                }

                delegate: ItemDelegate {
                    width: 150
                    height: 34
                    contentItem: Text {
                        text: name
                        color: "#ffffff"
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 12
                    }
                    background: Rectangle {
                        color: "#ffffff"
                        opacity: highlighted ? 0.12 : 0
                    }
                    highlighted: sessionCombo.highlightedIndex === index
                }
            }
        }
    }

    // 8. Esquina inferior izquierda: apagar / reiniciar, mismo estilo cápsula
    //    que el selector de sesión y los campos de usuario/contraseña
    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 28
        anchors.leftMargin: 48
        spacing: 16

        Item {
            id: rebootWrapper
            width: 44
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#000000"
                opacity: 0.25
                border.color: "#ffffff"
                border.width: rebootArea.containsMouse ? 1 : 0.5
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            Text {
                anchors.centerIn: parent
                text: "\u27F2"
                color: "#ffffff"
                font.pixelSize: 20
            }

            MouseArea {
                id: rebootArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }

        Item {
            id: powerOffWrapper
            width: 44
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#000000"
                opacity: 0.25
                border.color: "#ffffff"
                border.width: powerOffArea.containsMouse ? 1 : 0.5
                Behavior on border.width { NumberAnimation { duration: 120 } }
            }

            Text {
                anchors.centerIn: parent
                text: "\u23FB"
                color: "#ffffff"
                font.pixelSize: 20
            }

            MouseArea {
                id: powerOffArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    Component.onCompleted: userField.forceActiveFocus()
}
