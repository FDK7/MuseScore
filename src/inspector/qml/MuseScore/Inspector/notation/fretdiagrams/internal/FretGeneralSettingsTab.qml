/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-Studio-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore Limited
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import Muse.Ui
import Muse.UiComponents
import MuseScore.Inspector

import "../../../common"

FocusableItem {
    id: root

    required property FretDiagramSettingsModel model

    property NavigationPanel navigationPanel: null
    property int navigationRowStart: 1

    implicitHeight: root.model && root.model.areSettingsAvailable ? contentColumn.height : multipleDiagramsError.implicitHeight
    width: parent.width

    Column {
        id: contentColumn

        height: childrenRect.height
        width: parent.width

        spacing: 12

        visible: root.model ? root.model.areSettingsAvailable : false

        Item {
            height: childrenRect.height
            width: parent.width

            CheckBox {
                id: barreModeCheckBox

                anchors.left: parent.left
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 2

                enabled: root.model ? !root.model.isMultipleDotsModeOn : false
                checked: root.model && enabled ? root.model.isBarreModeOn : false
                text: qsTrc("inspector", "Barré")

                navigation.name: "BarreModeCheckBox"
                navigation.panel: root.navigationPanel
                navigation.row: root.navigationRowStart + 1

                onClicked: { root.model.isBarreModeOn = !checked }
            }

            CheckBox {
                id: multipleDotsModeCheckBox

                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 2
                anchors.right: parent.right

                enabled: root.model ? !root.model.isBarreModeOn : false
                checked: root.model && enabled ? root.model.isMultipleDotsModeOn : false
                text: qsTrc("inspector", "Multiple dots")

                navigation.name: "MultipleDotsCheckBox"
                navigation.panel: root.navigationPanel
                navigation.row: root.navigationRowStart + 2

                onClicked: { root.model.isMultipleDotsModeOn = !checked }
            }
        }

        Column {
            width: parent.width

            spacing: 8

            StyledTextLabel {
                id: markerTypeLabel
                width: parent.width
                text: qsTrc("inspector", "Marker type")
                horizontalAlignment: Text.AlignLeft
            }

            RadioButtonGroup {
                id: lineStyleButtonList

                height: 30
                width: parent.width

                enabled: root.model ? !root.model.isBarreModeOn : false

                model: [
                    { iconCode: IconCode.FRETBOARD_MARKER_CIRCLE_FILLED,    value: FretDiagramTypes.DOT_NORMAL,           title: qsTrc("inspector", "Normal") },
                    { iconCode: IconCode.CLOSE_X_ROUNDED,                   value: FretDiagramTypes.DOT_CROSS,            title: qsTrc("inspector", "Cross") },
                    { iconCode: IconCode.STOP,                              value: FretDiagramTypes.DOT_SQUARE,           title: qsTrc("inspector", "Square") },
                    { iconCode: IconCode.FRETBOARD_MARKER_TRIANGLE,         value: FretDiagramTypes.DOT_TRIANGLE,         title: qsTrc("inspector", "Triangle") },
                    { iconCode: IconCode.NONE,                              value: FretDiagramTypes.DOT_TRIANGLE_FILLED,  title: qsTrc("inspector", "Triangle filled") }
                ]

                delegate: FlatRadioButton {
                    required property string title
                    required iconCode
                    required property int value
                    required property int index

                    checked: root.model ? root.model.currentFretDotType === value : false

                    navigation.name: "LineStyleGroup"
                    navigation.panel: root.navigationPanel
                    navigation.row: root.navigationRowStart + 3 + index
                    navigation.accessible.name: markerTypeLabel.text + " " + title

                    onToggled: {
                        root.model.currentFretDotType = value
                    }

                    Canvas {
                        id: filledTriangleCanvas
                        visible: value === FretDiagramTypes.DOT_TRIANGLE_FILLED
                        anchors.centerIn: parent
                        width: 14
                        height: 12

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle = ui.theme.fontPrimaryColor
                            ctx.beginPath()
                            ctx.moveTo(width / 2, 0)
                            ctx.lineTo(width, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }
                }
            }
        }
    }

    StyledTextLabel {
        id: multipleDiagramsError

        width: parent.width

        wrapMode: Text.Wrap
        text: qsTrc("inspector", "You have multiple fretboard diagrams selected. Select a single diagram to edit its settings.")
        visible: root.model ? !root.model.areSettingsAvailable : false
    }
}
