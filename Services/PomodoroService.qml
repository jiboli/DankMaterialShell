pragma Singleton

import QtQuick
import "../Common"

Item {
    id: root

    // Enum for states
    readonly property int stateIdle: 0
    readonly property int stateWork: 1
    readonly property int stateShortBreak: 2
    readonly property int stateLongBreak: 3

    property int currentState: stateIdle
    property int remainingTime: PomodoroSettings.workTime * 60
    property int currentSession: 0
    property bool isRunning: false

    signal stateChanged
    signal timeChanged
    signal sessionChanged

    Timer {
        id: timer
        interval: 1000 // 1 second
        repeat: true
        running: isRunning

        onTriggered: {
            if (remainingTime > 0) {
                remainingTime--;
                timeChanged();
            } else {
                nextState();
            }
        }
    }

    function playPause() {
        if (currentState === stateIdle) {
            startFirstSession();
        } else {
            isRunning = !isRunning;
        }
    }

    function skip() {
        nextState(true);
    }

    function reset() {
        isRunning = false;
        currentState = stateIdle;
        currentSession = 0;
        remainingTime = PomodoroSettings.workTime * 60;
        stateChanged();
        timeChanged();
        sessionChanged();
    }

    function startFirstSession() {
        isRunning = true;
        currentState = stateWork;
        currentSession = 1;
        remainingTime = PomodoroSettings.workTime * 60;
        stateChanged();
        timeChanged();
        sessionChanged();
    }

    function nextState(skipped = false) {
        isRunning = false;

        if (currentState === stateWork) {
            if (currentSession > 0 && currentSession % PomodoroSettings.sessionsForLongBreak === 0) {
                currentState = stateLongBreak;
                remainingTime = PomodoroSettings.longBreakTime * 60;
            } else {
                currentState = stateShortBreak;
                remainingTime = PomodoroSettings.shortBreakTime * 60;
            }
        } else {
            // From a break to work
            currentState = stateWork;
            currentSession++;
            remainingTime = PomodoroSettings.workTime * 60;
            sessionChanged();
        }

        stateChanged();
        timeChanged();

        // Automatically start the next session timer
        isRunning = true;
    }

    // When settings change, update the timer if it's not running in that state
    Connections {
        target: PomodoroSettings
        function onWorkTimeChanged() {
            if (currentState === stateWork || currentState === stateIdle) {
                remainingTime = PomodoroSettings.workTime * 60;
                timeChanged();
            }
        }
        function onShortBreakTimeChanged() {
            if (currentState === stateShortBreak) {
                remainingTime = PomodoroSettings.shortBreakTime * 60;
                timeChanged();
            }
        }
        function onLongBreakTimeChanged() {
            if (currentState === stateLongBreak) {
                remainingTime = PomodoroSettings.longBreakTime * 60;
                timeChanged();
            }
        }
    }
}
