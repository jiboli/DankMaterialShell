import QtQuick
import QtQuick.Layouts
import "../Common"
import "../Widgets"

DankModal {
  id: root

  title: "Pomodoro Settings"

  content: [
    ColumnLayout {
      width: parent.width
      spacing: 15

      // Helper component for each setting row
      Component {
        id: settingRow
        RowLayout {
          property alias label: label.text
          property alias value: textField.text
          property alias onAccepted: textField.onAccepted

          StyledText {
            id: label
            Layout.fillWidth: true
            text: "Setting"
            verticalAlignment: Text.AlignVCenter
          }
          DankTextField {
            id: textField
            Layout.preferredWidth: 80
            horizontalAlignment: Text.AlignHCenter
            validator: IntValidator { bottom: 1; top: 180; }
          }
        }
      }

      // Instantiate rows for each setting
      Loader {
        Layout.fillWidth: true
        sourceComponent: settingRow
        onLoaded: {
          item.label = "Work Duration (min)"
          item.value = PomodoroSettings.workTime
          item.onAccepted = () => PomodoroSettings.setWorkTime(parseInt(item.value))
        }
      }

      Loader {
        Layout.fillWidth: true
        sourceComponent: settingRow
        onLoaded: {
          item.label = "Short Break (min)"
          item.value = PomodoroSettings.shortBreakTime
          item.onAccepted = () => PomodoroSettings.setShortBreakTime(parseInt(item.value))
        }
      }

      Loader {
        Layout.fillWidth: true
        sourceComponent: settingRow
        onLoaded: {
          item.label = "Long Break (min)"
          item.value = PomodoroSettings.longBreakTime
          item.onAccepted = () => PomodoroSettings.setLongBreakTime(parseInt(item.value))
        }
      }

      Loader {
        Layout.fillWidth: true
        sourceComponent: settingRow
        onLoaded: {
          item.label = "Sessions for Long Break"
          item.value = PomodoroSettings.sessionsForLongBreak
          item.onAccepted = () => PomodoroSettings.setSessionsForLongBreak(parseInt(item.value))
        }
      }

      Loader {
        Layout.fillWidth: true
        sourceComponent: settingRow
        onLoaded: {
          item.label = "Daily Target (sessions)"
          item.value = PomodoroSettings.targetSessions
          item.onAccepted = () => PomodoroSettings.setTargetSessions(parseInt(item.value))
        }
      }
    }
  ]
}
