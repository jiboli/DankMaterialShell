import QtQuick 2.15

Item {
  id: root

  width: 200
  height: 200

  property real value: 0.0 // 0.0 to 1.0
  property color color: "#ffffff"
  property color backgroundColor: "#40ffffff"
  property real strokeWidth: 10

  default property alias content: contentItem.data

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true

    onPaint: {
      var ctx = getContext("2d");
      ctx.reset();

      var centerX = width / 2;
      var centerY = height / 2;
      var radius = Math.min(width, height) / 2 - root.strokeWidth / 2;
      var startAngle = -Math.PI / 2; // Start from the top
      var endAngle = startAngle + (2 * Math.PI * root.value);

      // Draw background circle
      ctx.beginPath();
      ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
      ctx.lineWidth = root.strokeWidth;
      ctx.strokeStyle = root.backgroundColor;
      ctx.stroke();

      // Draw foreground progress arc
      if (root.value > 0) {
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, startAngle, endAngle);
        ctx.lineWidth = root.strokeWidth;
        ctx.strokeStyle = root.color;
        ctx.lineCap = "round";
        ctx.stroke();
      }
    }
  }

  Item {
    id: contentItem
    anchors.fill: parent
    anchors.margins: root.strokeWidth
  }

  // Redraw when properties change
  onValueChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onBackgroundColorChanged: canvas.requestPaint()
  onStrokeWidthChanged: canvas.requestPaint()
}
