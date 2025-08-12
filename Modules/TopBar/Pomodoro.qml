import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

StyledRect {
    id: root

    property bool pomodoroPopupVisible: false
    property string section: "left" // or "right", depending on layout
    property var popupTarget: null
    property var parentScreen: null

    signal togglePomodoroPopup

    implicitWidth: layout.implicitWidth + 16
    implicitHeight: 30
    radius: Theme.cornerRadius

    color: mouseArea.containsMouse || pomodoroPopupVisible ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(Theme.surfaceTextHover.r, Theme.surfaceTextHover.g, Theme.surfaceTextHover.b, Theme.surfaceTextHover.a * Theme.widgetTransparency)


    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        DankIcon {
            id: stateIcon
            size: 18
            color: Theme.primary
            name: {
                switch (PomodoroService.currentState) {
                case PomodoroService.stateWork:
                    return "brain";
                case PomodoroService.stateShortBreak:
                case PomodoroService.stateLongBreak:
                    return "coffee";
                default:
                    return "timer";
                }
            }
        }

        StyledText {
            id: timeLabel
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            font.weight: Font.Medium
            text: PomodoroService.formatTime(PomodoroService.remainingTime)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                var globalPos = mapToGlobal(0, 0)
                var currentScreen = parentScreen || Screen
                var screenX = currentScreen.x || 0
                var relativeX = globalPos.x - screenX
                popupTarget.setTriggerPosition(relativeX,
                                               Theme.barHeight + Theme.spacingXS,
                                               width, section, currentScreen)
            }
            togglePomodoroPopup()
        }
    }

    Connections {
        target: PomodoroService
        function onPomodoroTimeChanged() {
            timeLabel.text = PomodoroService.formatTime(PomodoroService.remainingTime);
        }
        function onStateChanged() {
            stateIcon.name = stateIcon.name;
        }
    }
}
