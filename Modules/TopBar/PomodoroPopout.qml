import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modals

PanelWindow {
    id: root

    property bool pomodoroPopoutVisible: false
    property real triggerX: Screen.width / 2 - 140
    property real triggerY: Theme.barHeight + Theme.spacingS
    property real triggerWidth: 100
    property string triggerSection: "left"
    property var triggerScreen: null
    property var settingsModal

    function setTriggerPosition(x, y, width, section, screen) {
        triggerX = x;
        triggerY = y;
        triggerWidth = width;
        triggerSection = section;
        triggerScreen = screen;
    }

    visible: pomodoroPopoutVisible
    screen: triggerScreen
    implicitWidth: 400
    implicitHeight: 300
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: pomodoroPopoutVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function (mouse) {
            var localPos = mapToItem(contentLoader, mouse.x, mouse.y);
            if (localPos.x < 0 || localPos.x > contentLoader.width || localPos.y < 0 || localPos.y > contentLoader.height)
                pomodoroPopoutVisible = false;
        }
    }

    Loader {
        id: contentLoader

        readonly property real screenWidth: root.screen ? root.screen.width : Screen.width
        readonly property real screenHeight: root.screen ? root.screen.height : Screen.height
        readonly property real targetWidth: Math.min(280, screenWidth - Theme.spacingL * 2)
        readonly property real targetHeight: Math.min(380, screenHeight - Theme.barHeight - Theme.spacingS * 2)
        readonly property real calculatedX: {
            var centerX = root.triggerX + (root.triggerWidth / 2) - (targetWidth / 2);
            if (centerX >= Theme.spacingM && centerX + targetWidth <= screenWidth - Theme.spacingM) {
                return centerX;
            }
            if (centerX < Theme.spacingM) {
                return Theme.spacingM;
            }
            if (centerX + targetWidth > screenWidth - Theme.spacingM) {
                return screenWidth - targetWidth - Theme.spacingM;
            }
            return centerX;
        }

        asynchronous: true
        active: pomodoroPopoutVisible
        width: targetWidth
        height: targetHeight
        x: calculatedX
        y: root.triggerY
        opacity: pomodoroPopoutVisible ? 1 : 0
        scale: pomodoroPopoutVisible ? 1 : 0.9

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.durMed
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Anims.emphasized
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Anims.durMed
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Anims.emphasized
            }
        }

        sourceComponent: Rectangle {
            color: Theme.popupBackground()
            radius: Theme.cornerRadius
            border.color: Theme.outlineMedium
            border.width: 1
            antialiasing: true
            smooth: true
            focus: true
            Component.onCompleted: {
                if (pomodoroPopoutVisible)
                    forceActiveFocus();
            }
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Escape) {
                    pomodoroPopoutVisible = false;
                    event.accepted = true;
                }
            }

            Connections {
                function onPomodoroPopoutVisibleChanged() {
                    if (pomodoroPopoutVisible)
                        Qt.callLater(function () {
                            parent.forceActiveFocus();
                        });
                }
                target: root
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
                    var component = Qt.createComponent("../../Modals/PomodoroSettingsModal.qml");
                    if (component.status === Component.Ready) {
                        settingsModal = component.createObject(root);
                    }
                }
                if (settingsModal) {
                    settingsModal.open();
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16

                // Settings Button
                Item {
                    Layout.alignment: Qt.AlignRight
                    width: 30
                    height: 30

                    DankIcon {
                        id: settingsIcon
                        anchors.centerIn: parent
                        name: "settings"
                        size: 20
                        color: Theme.surfaceText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: openSettings()
                    }
                }

                DankCircularProgress {
                    id: progressBar
                    Layout.preferredWidth: 174
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: progressBar.width
                    Layout.topMargin: 10
                    strokeWidth: 12
                    color: Theme.primary
                    backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                    value: PomodoroService.remainingTime > 0 ? (PomodoroService.remainingTime / getTotalTime()) : 0

                    content: [
                        ColumnLayout {
                            width: parent.width
                            height: parent.height
                            spacing: 10

                            Item {
                                Layout.fillHeight: true
                            }

                            DankIcon {
                                id: stateIcon
                                Layout.alignment: Qt.AlignHCenter
                                size: 48
                                color: Theme.primary
                                name: {
                                    switch (PomodoroService.currentState) {
                                    case PomodoroService.stateWork:
                                        return "psychology";
                                    case PomodoroService.stateShortBreak:
                                    case PomodoroService.stateLongBreak:
                                        return "coffee";
                                    default:
                                        return "psychology";
                                    }
                                }
                            }

                            StyledText {
                                id: timeText
                                Layout.alignment: Qt.AlignHCenter
                                font.pixelSize: 24
                                font.weight: Font.Light
                                color: Theme.surfaceText
                                text: PomodoroService.formatTime(PomodoroService.remainingTime)
                            }

                            Item {
                                Layout.fillHeight: true
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
                        iconName: "replay"
                        onClicked: PomodoroService.reset()
                    }

                    DankActionButton {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 60
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        iconName: PomodoroService.isRunning ? "pause" : "play_arrow"
                        onClicked: PomodoroService.playPause()
                    }

                    DankActionButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        iconName: "skip_next"
                        onClicked: PomodoroService.skip()
                    }
                }
            }

            Connections {
                target: PomodoroService
                function onPomodoroTimeChanged() {
                    progressBar.value = PomodoroService.remainingTime > 0 ? (PomodoroService.remainingTime / getTotalTime()) : 0;
                    timeText.text = PomodoroService.formatTime(PomodoroService.remainingTime);
                }
                function onPomodoroStateChanged() {
                    progressBar.value = PomodoroService.remainingTime > 0 ? (PomodoroService.remainingTime / getTotalTime()) : 0;
                }
            }
        }
    }
}
