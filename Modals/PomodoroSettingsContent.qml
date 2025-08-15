import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Modules.Settings

DankFlickable {
    id: root

    anchors.fill: parent
    contentHeight: mainColumn.height
    contentWidth: width
    clip: true

    property var settingsModel: [
        {
            label: "Work Duration (min)",
            getValue: () => PomodoroSettings.workTime,
            setValue: (value) => PomodoroSettings.setWorkTime(value)
        },
        {
            label: "Short Break (min)",
            getValue: () => PomodoroSettings.shortBreakTime,
            setValue: (value) => PomodoroSettings.setShortBreakTime(value)
        },
        {
            label: "Long Break (min)",
            getValue: () => PomodoroSettings.longBreakTime,
            setValue: (value) => PomodoroSettings.setLongBreakTime(value)
        },
        {
            label: "Sessions for Long Break",
            getValue: () => PomodoroSettings.sessionsForLongBreak,
            setValue: (value) => PomodoroSettings.setSessionsForLongBreak(value)
        },
        {
            label: "Daily Target (sessions)",
            getValue: () => PomodoroSettings.targetSessions,
            setValue: (value) => PomodoroSettings.setTargetSessions(value)
        }
    ]

    ColumnLayout {
        id: mainColumn
        width: parent.width
        spacing: Theme.spacingL

        SettingsSection {
            title: "General Settings"
            iconName: "timer"
            collapsible: false
            width: parent.width

            content: Component {
                ColumnLayout {
                    width: parent.width
                    spacing: Theme.spacingM

                    Repeater {
                        model: root.settingsModel

                        RowLayout {
                            id: row
                            width: parent.width
                            spacing: Theme.spacingM
                            Layout.minimumHeight: 48

                            StyledText {
                                // Manually calculate width as Layout.fillWidth is not working
                                width: row.width - settingsField.width - row.spacing
                                text: modelData.label
                                verticalAlignment: Text.AlignVCenter
                            }
                            DankTextField {
                                id: settingsField
                                Layout.preferredWidth: 80
                                text: modelData.getValue()

                                validator: IntValidator { bottom: 1; top: 180; }

                                Timer {
                                    id: saveDebounce
                                    interval: 800
                                    repeat: false
                                    onTriggered: {
                                        if (settingsField.text !== "") {
                                            var _value = parseInt(settingsField.text, 10)
                                            modelData.setValue(_value)
                                        }
                                    }
                                }

                                onTextChanged: {
                                    saveDebounce.restart()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}