import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

DankModal {
    id: root

    title: "Pomodoro Settings"

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

    content: [
        ColumnLayout {
            width: parent.width
            spacing: 15

            Repeater {
                model: settingsModel

                RowLayout {
                    width: parent.width

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.label
                        verticalAlignment: Text.AlignVCenter
                    }
                    DankTextField {
                        Layout.preferredWidth: 80
                        text: modelData.getValue()
                        horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator { bottom: 1; top: 180; }
                        onAccepted: modelData.setValue(parseInt(text))
                    }
                }
            }
        }
    ]
}
