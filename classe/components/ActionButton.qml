/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root

    //property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    //property alias font: label.font
    //property alias labelRendering: label.renderType
    property alias circleOpacity: iconCircle.opacity
    property alias circleVisiblity: iconCircle.visible
    //property int fontSize: PlasmaCore.Theme.defaultFont.pointSize + 1
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    signal clicked

    activeFocusOnTab: true

    property int iconSize: PlasmaCore.Units.gridUnit

    implicitWidth: Math.max(iconSize + PlasmaCore.Units.largeSpacing * 2)
    implicitHeight: iconSize + PlasmaCore.Units.smallSpacing

    opacity: activeFocus || containsMouse ? 1 : 0.85
    Behavior on opacity {
        PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: iconCircle
        anchors.centerIn: icon
        width: iconSize + PlasmaCore.Units.smallSpacing
        height: width
        radius: width / 2
        color: softwareRendering ?  PlasmaCore.ColorScope.backgroundColor : PlasmaCore.ColorScope.textColor
        opacity: root.activeFocus || containsMouse ? (softwareRendering ? 0.8 : 0.15) : (softwareRendering ? 0.6 : 0)
        Behavior on opacity {
            PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        anchors.centerIn: iconCircle
        width: iconCircle.width
        height: width
        radius: width / 2
        scale: mouseArea.containsPress ? 1 : 0
        color: PlasmaCore.ColorScope.textColor
        opacity: 0.55
        Behavior on scale {
            PropertyAnimation {
                duration: PlasmaCore.Units.shortDuration
                easing.type: Easing.InOutQuart
            }
        }
    }

    PlasmaCore.IconItem {
        id: icon

        anchors.centerIn: parent
        width: iconSize
        height: iconSize

        colorGroup: PlasmaCore.ColorScope.colorGroup
        active: mouseArea.containsMouse || root.activeFocus
     }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

    }

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
}
