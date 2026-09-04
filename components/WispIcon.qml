import QtQuick
import qs.configs

Item {
    id: root

    property color iconColor: Color.primary

    implicitWidth: 24
    implicitHeight: 24

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        antialiasing: true

        function drawStream(ctx, w, h, startX, startY, midBottomX, botTipX, topReturnX) {
            ctx.beginPath();
            ctx.moveTo(w * startX, h * startY);
            ctx.bezierCurveTo(w * (startX + 0.06), h * 0.48, w * (midBottomX - 0.11), h * 0.78, w * midBottomX, h * 0.86);
            ctx.bezierCurveTo(w * (midBottomX + 0.04), h * 0.89, w * (botTipX + 0.02), h * 0.86, w * botTipX, h * 0.80);
            ctx.bezierCurveTo(w * (botTipX - 0.05), h * 0.65, w * (topReturnX + 0.04), h * 0.42, w * topReturnX, h * 0.22);
            ctx.bezierCurveTo(w * (topReturnX - 0.02), h * 0.17, w * (startX + 0.02), h * 0.17, w * startX, h * startY);
            ctx.closePath();
            ctx.fill();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;

            ctx.fillStyle = root.iconColor;

            drawStream(ctx, w, h, 0.12, 0.22, 0.36, 0.42, 0.26);

            drawStream(ctx, w, h, 0.40, 0.16, 0.54, 0.60, 0.54);

            ctx.save();
            ctx.translate(w, 0);
            ctx.scale(-1, 1);
            drawStream(ctx, w, h, 0.12, 0.22, 0.36, 0.42, 0.26);
            ctx.restore();
        }

        Connections {
            target: Color
            function onPrimaryChanged() {
                canvas.requestPaint();
            }
        }
    }
}
