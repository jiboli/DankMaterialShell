pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell
import QtCore

Singleton {
  id: root

  property int workTime: 25
  property int shortBreakTime: 5
  property int longBreakTime: 15
  property int sessionsForLongBreak: 4
  property int targetSessions: 8

  FileView {
    id: settingsFile
    path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/DankMaterialShell/pomodoro.json"
    blockLoading: true
    blockWrites: false
    watchChanges: true
    onLoaded: parseSettings(settingsFile.text())
  }

  Component.onCompleted: {
    parseSettings(settingsFile.text())
  }

  function parseSettings(content) {
    if (!content || !content.trim()) return;
    try {
      var settings = JSON.parse(content)
      workTime = settings.workTime !== undefined ? settings.workTime : 25
      shortBreakTime = settings.shortBreakTime !== undefined ? settings.shortBreakTime : 5
      longBreakTime = settings.longBreakTime !== undefined ? settings.longBreakTime : 15
      sessionsForLongBreak = settings.sessionsForLongBreak !== undefined ? settings.sessionsForLongBreak : 4
      targetSessions = settings.targetSessions !== undefined ? settings.targetSessions : 8
    } catch (e) {
      console.error("Failed to parse pomodoro settings:", e)
    }
  }

  function saveSettings() {
    var _content = JSON.stringify({
      "workTime": workTime,
      "shortBreakTime": shortBreakTime,
      "longBreakTime": longBreakTime,
      "sessionsForLongBreak": sessionsForLongBreak,
      "targetSessions": targetSessions
    }, null, 2)
    console.log("PomodoroSettings: saveSettings called with content - " + _content)
    settingsFile.setText(_content)
    console.log("PomodoroSettings: setText() finished.")
  }

  function setWorkTime(time) {
    if (workTime !== time) {
      workTime = time
      saveSettings()
    }
  }

  function setShortBreakTime(time) {
    if (shortBreakTime !== time) {
      shortBreakTime = time
      saveSettings()
    }
  }

  function setLongBreakTime(time) {
    if (longBreakTime !== time) {
      longBreakTime = time
      saveSettings()
    }
  }

  function setSessionsForLongBreak(sessions) {
    if (sessionsForLongBreak !== sessions) {
      sessionsForLongBreak = sessions
      saveSettings()
    }
  }

  function setTargetSessions(sessions) {
    if (targetSessions !== sessions) {
      targetSessions = sessions
      saveSettings()
    }
  }
}
