import "components"

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + PlasmaCore.Units.smallSpacing

    property int fontSize: parseInt(config.fontSize)

    signal loginRequest(string username, string password)


    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    onUserSelected: {
        // Don't startLogin() here, because the signal is connected to the
        // Escape key as well, for which it wouldn't make sense to trigger
        // login.
        focusFirstVisibleFormControl();
    }

    QQC2.StackView.onActivating: {
        // Controls are not visible yet.
        Qt.callLater(focusFirstVisibleFormControl);
    }

    function focusFirstVisibleFormControl() {
        const nextControl = (userNameInput.visible
            ? userNameInput
            : (passwordBox.visible
                ? passwordBox
                : loginButton));
        // Using TabFocusReason, so that the loginButton gets the visual highlight.
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    function startLogin() {
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        const password = passwordBox.text

        footer.enabled = false
        mainStack.enabled = false
        header.enabled = false
        userListComponent.userList.opacity = 0.5
        // This is partly because it looks nicer, but more importantly it
        // works round a Qt bug that can trigger if the app is closed with a
        // TextField focused.
        //
        // See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    ColumnLayout {
        Layout.fillWidth: true

        spacing: PlasmaCore.Units.largeSpacing


        PlasmaComponents3.TextField {
            id: userNameInput
            font.pointSize: fontSize + 1
            Layout.fillWidth: true

            text: lastUserName
            color: "White"

            background: Rectangle {
                width: parent.width + 20
                height: parent.height + 10

                implicitHeight: 30
                anchors.centerIn: parent

                color: "black"
                opacity: 0.5
                radius: 15
            }

            visible: showUsernamePrompt
            focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

            onAccepted: {
                if (root.loginScreenUiVisible) {
                    passwordBox.forceActiveFocus()
                }
            }
        }

        PlasmaExtras.PasswordField {
            id: passwordBox

            property list<QtObject> newRightActions: [ // no, I don't know what am I doing...
                QQC2.Action {
                    icon.name: passwordBox.showPassword ? "/usr/share/sddm/themes/classe/components/artwork/view-hidden.svg" : "/usr/share/sddm/themes/classe/components/artwork/view-visible.svg"
                    onTriggered: passwordBox.showPassword = !passwordBox.showPassword
                }
            ]

            font.pointSize: fontSize + 1

            Layout.fillWidth: true

            implicitHeight: 30

            color: "white"

            background: Rectangle {
                width: parent.width + 20
                height: parent.height + 10

                anchors.centerIn: parent

                color: "black"
                opacity: 0.5
                radius: 15
            }

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: !showUsernamePrompt || lastUserName

            rightActions: newRightActions


            onAccepted: {
                if (root.loginScreenUiVisible) {
                    startLogin();
                }
            }

            visible: root.showUsernamePrompt || userList.currentItem.needsPassword

            Keys.onEscapePressed: {
                mainStack.currentItem.forceActiveFocus();
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: sddm
                function onLoginFailed() {
                    passwordBox.selectAll()
                    passwordBox.forceActiveFocus()
                }
            }
        }

        PlasmaComponents3.Button {
            id: loginButton
            Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
            Layout.preferredHeight: passwordBox.implicitHeight
            Layout.fillWidth: true

            text: i18n("Log In")

            contentItem: Text {
                text: parent.text
                font: parent.font
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {

                width: parent.width + 10
                height: parent.height + 5

                anchors.centerIn: parent

                color: "black"
                opacity: 0.5
                radius: 15
            }

            onClicked: startLogin()
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
        }
    }
}
