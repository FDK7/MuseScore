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
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Muse.Ui
import Muse.UiComponents
import MuseScore.Inspector

import "../../common"
import "internal"

Item {
    id: root

    required property FretDiagramSettingsModel model

    property NavigationPanel navigationPanel: null
    property int navigationRowStart: 1

    objectName: "FretDiagramSettings"

    implicitHeight: content.implicitHeight

    function focusOnFirst() {
        fretDiagramTabPanel.focusOnFirst()
    }

    Column {
        id: content

        width: parent.width

        spacing: 12

        FretDiagramTabPanel {
            id: fretDiagramTabPanel

            model: root.model

            width: parent.width

            navigationPanel: root.navigationPanel
            navigationRowStart: root.navigationRowStart
        }

        Column {
            height: childrenRect.height
            width: parent.width
            spacing: 12

            visible: root.model ? root.model.areSettingsAvailable : false

            FretCanvas {
                id: fretCanvas

                diagram: root.model ? root.model.fretDiagram : null
                isBarreModeOn: root.model ? root.model.isBarreModeOn : false
                isMultipleDotsModeOn: root.model ? root.model.isMultipleDotsModeOn : false
                currentFretDotType: root.model ? root.model.currentFretDotType : false
                color: ui.theme.fontPrimaryColor

                width: parent.width

                // TODO: keyboard navigation

                onMarkerSelectionRequested: function(string, x, y) {
                    markerMenu.targetString = string
                    markerMenu.popup(fretCanvas, x, y)
                }

                QQC2.Menu {
                    id: markerMenu
                    property int targetString: 0
                    implicitWidth: 76

                    QQC2.MenuItem { text: qsTrc("inspector", "None");      onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 0) }
                    QQC2.MenuItem { text: qsTrc("inspector", "O (open)");  onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 1) }
                    QQC2.MenuItem { text: qsTrc("inspector", "X (muted)"); onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 2) }
                    QQC2.MenuItem { text: qsTrc("inspector", "1 (index)"); onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 3) }
                    QQC2.MenuItem { text: qsTrc("inspector", "2 (middle)");onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 4) }
                    QQC2.MenuItem { text: qsTrc("inspector", "3 (ring)");  onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 5) }
                    QQC2.MenuItem { text: qsTrc("inspector", "4 (pinky)"); onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 6) }
                    QQC2.MenuItem { text: qsTrc("inspector", "D (thumb)"); onTriggered: fretCanvas.setTopMarker(markerMenu.targetString, 7) }
                }
            }

            PropertyToggle {
                id: showFingerings
                width: parent.width

                text: qsTrc("inspector", "Show fingerings")
                propertyItem: root.model ? root.model.showFingerings : null

                navigation.name: "Show fingerings toggle"
                navigation.panel: root.navigationPanel
                navigation.row: fretDiagramTabPanel.navigationRowEnd + 1
            }

            GridLayout {
                visible: root.model ? root.model.showFingerings.value : false
                width: parent.width
                columns: 6
                rowSpacing: 12

                Repeater {
                    id: repeater

                    readonly property int navigationRowStart: showFingerings.navigation.row + 1
                    readonly property int navigationRowEnd: navigationRowStart + repeater.count - 1

                    //! NOTE: If we put `root.model.fingerings` here, the repeater would destroy all generated items
                    //! whenever one of the fingerings is changed. This results in focus being lost when clicking
                    //! on a second TextInputField after editing one, instead of focussing that second TextInputField.
                    //! By giving the repeater only an integer value, that happens only when the number of items changes,
                    //! which is less problematic.
                    model: root.model ? root.model.fingerings.length : 0

                    Column {
                        id: repeaterItem

                        required property int index

                        property int string: repeater.count - index - 1
                        property string finger: root.model ? root.model.fingerings[string] : 0

                        Layout.preferredWidth: 40
                        spacing: 8

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: numberLabel.height + 4
                            width: height

                            color: "transparent"
                            radius: height / 2
                            border.color: ui.theme.fontPrimaryColor
                            border.width: 1

                            StyledTextLabel {
                                id: numberLabel
                                anchors.centerIn: parent
                                text: repeaterItem.string + 1
                            }
                        }

                        TextInputField {
                            id: fingerInput

                            textHorizontalAlignment: Qt.AlignHCenter
                            indeterminateText: '-'
                            isIndeterminate: {
                                const fingerInt = parseInt(repeaterItem.finger)
                                return isNaN(fingerInt) || fingerInt < 1 || fingerInt > 5
                            }

                            currentText: isIndeterminate ? '' : repeaterItem.finger

                            validator: IntInputValidator {
                                top: 5
                                bottom: 0
                            }

                            navigation.name: `Finger ${repeaterItem.string + 1} text input`
                            navigation.panel: root.navigationPanel
                            navigation.row: repeater.navigationRowStart + repeaterItem.index
                            navigation.accessible.name: qsTrc("inspector", "Finger for string %1").arg(repeaterItem.string + 1)

                            onTextEditingFinished: function (newTextValue) {
                                var newFinger = parseInt(newTextValue)
                                if (root.model) {
                                    root.model.setFingering(repeaterItem.string, newFinger)
                                }
                            }
                        }
                    }
                }
            }

            FlatButton {
                width: parent.width

                text: qsTrc("global", "Clear")

                navigation.name: "Clear"
                navigation.panel: root.navigationPanel
                navigation.row: repeater.navigationRowEnd + 1

                onClicked: {
                    fretCanvas.clear()
                    root.model.fretNumber.resetToDefault()
                    root.model.resetFingerings()
                }
            }
        }
    }
}
