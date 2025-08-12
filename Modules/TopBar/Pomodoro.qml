import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

StyledRect {
  id: root

  implicitWidth: layout.implicitWidth + 16
  implicitHeight: 40
  color: "transparent"
  radius: Theme.cornerRadius

  property var popout

  function formatTime(seconds) {
    var m = Math.floor(seconds / 60)
    var s = seconds % 60
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
  }

  RowLayout {
    id: layout
    anchors.centerIn: parent
    spacing: 6

    DankIcon {
      id: stateIcon
      size: 18
      color: Theme.textColor
      icon.name: {
        switch (PomodoroService.currentState) {
          case PomodoroService.stateWork:
            return "brain";
          case PomodoroService.stateShortBreak:
          case PomodoroService.stateLongBreak:
            return "coffee";
          default:
            return "timer-outline";
        }
      }
    }

    StyledText {
      id: timeLabel
      font.pixelSize: 14
      color: Theme.textColor
      text: formatTime(PomodoroService.remainingTime)
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (!popout) {
        var component = Qt.createComponent("PomodoroPopout.qml")
        if (component.status === Component.Ready) {
          popout = component.createObject(root.parent, { "visible": true })
        } else {
          console.error("Failed to create PomodoroPopout:", component.errorString())
          return
        }
      }
      popout.visible = !popout.visible
    }
  }

  Connections {
    target: PomodoroService
    function onTimeChanged() {
      timeLabel.text = formatTime(PomodoroService.remainingTime)
    }
    function onStateChanged() {
      // Icon is already bound, but might need to trigger redraw if bindings are not live
      stateIcon.icon.name = stateIcon.icon.name
    }
  }
}
