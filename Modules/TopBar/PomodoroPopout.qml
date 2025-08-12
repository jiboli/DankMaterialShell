import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modals

StyledRect {
  id: root
  width: 280
  height: 380
  radius: Theme.cornerRadius

  color: Qt.rgba(Theme.backgroundColor.r, Theme.backgroundColor.g, Theme.backgroundColor.b, 0.95)

  property bool visible: false
  property var settingsModal

  function formatTime(seconds) {
    var m = Math.floor(seconds / 60)
    var s = seconds % 60
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
  }

  function getTotalTime() {
    switch (PomodoroService.currentState) {
      case PomodoroService.stateWork:
        return PomodoroSettings.workTime * 60;
      case PomodoroService.stateShortBreak:
        return PomodoroSettings.shortBreakTime * 60;
      case PomodoroService.stateLongBreak:
        return PomodoroSettings.longBreakTime * 60;
      default:
        return PomodoroSettings.workTime * 60;
    }
  }

  function openSettings() {
    if (!settingsModal) {
      var component = Qt.createComponent("../../Modals/PomodoroSettingsModal.qml")
      if (component.status === Component.Ready) {
        settingsModal = component.createObject(root)
      }
    }
    if (settingsModal) {
      settingsModal.open()
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 16

    // Settings Button
    DankIcon {
      Layout.alignment: Qt.AlignRight
      icon.name: "settings"
      size: 20
      color: Theme.textColor
      onClicked: openSettings()
    }

    DankCircularProgress {
      id: progressBar
      Layout.fillWidth: true
      Layout.preferredHeight: root.width - 60
      Layout.topMargin: 10
      strokeWidth: 12
      color: Theme.accentColor
      backgroundColor: Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.2)
      value: PomodoroService.remainingTime / getTotalTime()

      content: [
        ColumnLayout {
          anchors.centerIn: parent

          DankIcon {
            id: stateIcon
            Layout.alignment: Qt.AlignHCenter
            size: 48
            color: Theme.textColor
            icon.name: {
              switch (PomodoroService.currentState) {
                case PomodoroService.stateWork:
                  return "brain";
                case PomodoroService.stateShortBreak:
                case PomodoroService.stateLongBreak:
                  return "coffee";
                default:
                  return "play";
              }
            }
          }

          StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            font.pixelSize: 48
            font.weight: Font.Light
            color: Theme.textColor
            text: formatTime(PomodoroService.remainingTime)
          }
        }
      ]
    }

    // Control Buttons
    RowLayout {
      Layout.fillWidth: true
      Layout.topMargin: 20

      DankActionButton {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        icon.name: "replay"
        onClicked: PomodoroService.reset()
      }

      DankActionButton {
        Layout.fillWidth: true
        Layout.preferredWidth: 80
        Layout.preferredHeight: 60
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        highlighted: true
        icon.name: PomodoroService.isRunning ? "pause" : "play"
        onClicked: PomodoroService.playPause()
      }

      DankActionButton {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        icon.name: "skip-forward"
        onClicked: PomodoroService.skip()
      }
    }
  }

  Connections {
    target: PomodoroService
    function onTimeChanged() {
      progressBar.value = PomodoroService.remainingTime / getTotalTime()
    }
    function onStateChanged() {
      progressBar.value = PomodoroService.remainingTime / getTotalTime()
    }
  }
}
