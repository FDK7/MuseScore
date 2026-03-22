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
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Muse.Ui
import Muse.UiComponents
import MuseScore.NotationScene

StyledFlickable {
    id: root

    contentWidth: Math.max(groupBox.implicitWidth, root.width)
    contentHeight: groupBox.implicitHeight

    readonly property real controlAreaWidth: 204

    signal goToTextStylePage(string s)

    FretboardsPageModel {
        id: fretboardsPage
    }

    StyledGroupBox {
        id: groupBox
        width: parent.width

        title: qsTrc("notation", "Fretboard diagrams")

        ColumnLayout {
            spacing: 12
            width: parent.width

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretY
                label: qsTrc("notation", "Position above staff:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
                step: 0.05
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretMinDistance
                label: qsTrc("notation", "Min. space to notation:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
                step: 0.05
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretMag
                label: qsTrc("notation", "Scale:")
                inPercentage: true
                controlAreaWidth: root.controlAreaWidth
            }

            IconAndTextButtonSelector {
                styleItem: fretboardsPage.fretOrientation
                label: qsTrc("notation", "Orientation:")
                controlAreaWidth: root.controlAreaWidth

                model: [
                    { iconCode: IconCode.FRETBOARD_VERTICAL, text: qsTrc("notation", "Vertical"), value: 0 },
                    { iconCode: IconCode.FRETBOARD_HORIZONTAL, text: qsTrc("notation", "Horizontal"), value: 1 }
                ]
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretNutType.value === 0
                           ? fretboardsPage.fretNutThickness
                           : fretboardsPage.fretNutDoubleThickness
                label: qsTrc("notation", "Nut line thickness:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
            }

            // Nut type selector — same structure as IconAndTextButtonSelector
            StyleControlRowWithReset {
                styleItem: fretboardsPage.fretNutType
                label: qsTrc("notation", "Nut line type:")
                controlAreaWidth: root.controlAreaWidth

                RadioButtonGroup {
                    id: nutTypeGroup
                    anchors.fill: parent

                    model: [
                        { value: 0, text: qsTrc("notation", "Single line"), isDouble: false },
                        { value: 1, text: qsTrc("notation", "Double line"), isDouble: true }
                    ]

                    delegate: FlatRadioButton {
                        id: nutTypeButton
                        required property var modelData
                        required property int index

                        height: 70

                        checked: fretboardsPage.fretNutType.value === modelData.value
                        onToggled: fretboardsPage.fretNutType.value = modelData.value

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Canvas {
                                width: 56
                                height: 36
                                anchors.horizontalCenter: parent.horizontalCenter

                                readonly property bool isDouble: nutTypeButton.modelData.isDouble
                                readonly property bool isSelected: nutTypeButton.checked

                                onPaint: {
                                    var ctx2 = getContext("2d")
                                    ctx2.clearRect(0, 0, width, height)

                                    var strings = 6
                                    var frets = 2
                                    var margin = 2
                                    var strDist = (width - 2 * margin) / (strings - 1)
                                    var y0 = 14
                                    var fretDist = (height - y0 - margin) / frets
                                    var x0 = margin
                                    var x1 = x0 + (strings - 1) * strDist
                                    var lw = 0.8
                                    var nutLw = isDouble ? 1.5 : 3.0
                                    var col = isSelected ? "white" : ui.theme.fontPrimaryColor

                                    ctx2.strokeStyle = col
                                    ctx2.lineCap = "square"

                                    // Fret lines
                                    ctx2.lineWidth = lw
                                    for (var f = 0; f <= frets; f++) {
                                        var fy = y0 + f * fretDist
                                        ctx2.beginPath()
                                        ctx2.moveTo(x0, fy)
                                        ctx2.lineTo(x1, fy)
                                        ctx2.stroke()
                                    }

                                    // Strings
                                    var stringTop = isDouble ? y0 - nutLw * 3 : y0 - nutLw * 0.5
                                    for (var s = 0; s < strings; s++) {
                                        var sx = x0 + s * strDist
                                        ctx2.beginPath()
                                        ctx2.moveTo(sx, stringTop)
                                        ctx2.lineTo(sx, y0 + frets * fretDist)
                                        ctx2.stroke()
                                    }

                                    // Nut
                                    ctx2.lineWidth = nutLw
                                    if (isDouble) {
                                        ctx2.beginPath()
                                        ctx2.moveTo(x0, y0 - nutLw * 2.5)
                                        ctx2.lineTo(x1, y0 - nutLw * 2.5)
                                        ctx2.stroke()
                                        ctx2.beginPath()
                                        ctx2.moveTo(x0, y0 - nutLw * 0.5)
                                        ctx2.lineTo(x1, y0 - nutLw * 0.5)
                                        ctx2.stroke()
                                    } else {
                                        ctx2.beginPath()
                                        ctx2.moveTo(x0, y0 - nutLw * 0.5)
                                        ctx2.lineTo(x1, y0 - nutLw * 0.5)
                                        ctx2.stroke()
                                    }
                                }

                                Connections {
                                    target: fretboardsPage.fretNutType
                                    function onValueChanged() { parent.requestPaint() }
                                }
                            }

                            StyledTextLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: nutTypeButton.modelData.text
                            }
                        }
                    }
                }
            }

            StyledGroupBox {
                Layout.fillWidth: true

                title: qsTrc("notation", "Fret number")

                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    RowLayout {
                        spacing: 12

                        StyledTextLabel {
                            horizontalAlignment: Text.AlignLeft
                            text: qsTrc("notation", "Position:")
                        }

                        RoundedRadioButton {
                            text: fretboardsPage.fretOrientation.value === 0 ? qsTrc("notation", "Left") : qsTrc("notation", "Bottom")
                            checked: fretboardsPage.fretNumPos.value === 0
                            onToggled: fretboardsPage.fretNumPos.value = 0
                        }

                        RoundedRadioButton {
                            text: fretboardsPage.fretOrientation.value === 0 ? qsTrc("notation", "Right") : qsTrc("notation", "Top")
                            checked: fretboardsPage.fretNumPos.value === 1
                            onToggled: fretboardsPage.fretNumPos.value = 1
                        }
                    }

                    StyledGroupBox {
                        title: qsTrc("notation", "Format:")
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 12

                            RoundedRadioButton {
                                text: qsTrc("notation", "Number only")
                                checked: fretboardsPage.fretUseCustomSuffix.value === false
                                onToggled: fretboardsPage.fretUseCustomSuffix.value = false
                            }

                            RowLayout {
                                spacing: 8

                                RoundedRadioButton {
                                    text: qsTrc("notation", "Custom suffix:")
                                    checked: fretboardsPage.fretUseCustomSuffix.value === true
                                    onToggled: fretboardsPage.fretUseCustomSuffix.value = true
                                }

                                TextInputField {
                                    Layout.preferredWidth: 60
                                    enabled: fretboardsPage.fretUseCustomSuffix.value === true
                                    currentText: fretboardsPage.fretCustomSuffix.value
                                    onTextEdited: function(newTextValue) {
                                        fretboardsPage.fretCustomSuffix.value = newTextValue
                                    }
                                }

                                StyledTextLabel {
                                    visible: fretboardsPage.fretUseCustomSuffix.value === true
                                    horizontalAlignment: Text.AlignLeft
                                    text: qsTrc("notation", "Preview:") + " 3" + fretboardsPage.fretCustomSuffix.value
                                }
                            }
                        }
                    }

                    FlatButton {
                        text: qsTrc("notation", "Edit fret number text style")

                        onClicked: {
                            root.goToTextStylePage("fretboard-diagram-fret-number")
                        }
                    }
                }
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretDotSpatiumSize
                label: qsTrc("notation", "Dot size:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
            }

            StyledGroupBox {
                Layout.fillWidth: true

                title: qsTrc("notation", "Barré")

                ColumnLayout {
                    width: parent.width
                    spacing : 12

                    IconAndTextButtonSelector {
                        styleItem: fretboardsPage.barreAppearanceSlur
                        label: qsTrc("notation", "Appearance:")
                        controlAreaWidth: root.controlAreaWidth

                        model: [
                            { iconCode: IconCode.FRETBOARD_BARRE_LINE, text: qsTrc("notation", "Line"), value: false },
                            { iconCode: IconCode.FRETBOARD_BARRE_SLUR, text: qsTrc("notation", "Slur"), value: true }
                        ]
                    }

                    StyleSpinboxWithReset {
                        styleItem: fretboardsPage.barreLineWidth
                        label: qsTrc("notation", "Line thickness:")
                        inPercentage: true
                        controlAreaWidth: root.controlAreaWidth
                    }
                }
            }

            CheckBox {
                text: qsTrc("notation", "Show fingerings")
                checked: fretboardsPage.fretShowFingerings.value === true
                onClicked: fretboardsPage.fretShowFingerings.value = !fretboardsPage.fretShowFingerings.value
            }

            FlatButton {
                text: qsTrc("notation", "Edit fingering text style")

                onClicked: {
                    root.goToTextStylePage("fretboard-diagram-fingering")
                }
            }

            IconAndTextButtonSelector {
                styleItem: fretboardsPage.fretStyleExtended
                label: qsTrc("notation", "Fretboard style:")
                controlAreaWidth: root.controlAreaWidth

                model: [
                    { iconCode: IconCode.FRETBOARD_VERTICAL, text: qsTrc("notation", "Trimmed"), value: false },
                    { iconCode: IconCode.FRETBOARD_EXTENDED, text: qsTrc("notation", "Extended"), value: true }
                ]
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretStringSpacing
                label: qsTrc("notation", "String spacing:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
            }

            StyleSpinboxWithReset {
                styleItem: fretboardsPage.fretFretSpacing
                label: qsTrc("notation", "Fret spacing:")
                suffix: qsTrc("global", "sp")
                controlAreaWidth: root.controlAreaWidth
            }
        }
    }
}
