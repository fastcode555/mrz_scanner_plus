import 'dart:math';
import 'package:flutter/material.dart';

class MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // 护照标准尺寸比例为1.42:1
    final double cardWidth = size.width * 0.85;
    final double cardHeight = cardWidth / 1.42;
    final double left = (size.width - cardWidth) / 2;
    final double top = (size.height - cardHeight) / 2;

    const cornerRadius = 18.0;

    // Draw the semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, cardWidth, cardHeight),
            const Radius.circular(8.0),
          )),
      ),
      paint,
    );

    const lineLength = 40.0;

    const horizontalLineLength = 30.0;
    const verticalLineLength = 20.0;
    const offset = 4.0;

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = const Color(0xFFE1DED7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Top Left Corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(left + cornerRadius - offset, top + cornerRadius - offset),
        radius: cornerRadius,
      ),
      pi,
      pi / 2,
      false,
      cornerPaint,
    );
    // Top Left Extension Lines
    canvas.drawLine(
      Offset(left + cornerRadius - offset, top - offset),
      Offset(left + cornerRadius + horizontalLineLength - offset, top - offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left - offset, top + cornerRadius - offset),
      Offset(left - offset, top + cornerRadius + verticalLineLength - offset),
      cornerPaint,
    );

    // Top Right Corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(left + cardWidth - cornerRadius + offset, top + cornerRadius - offset),
        radius: cornerRadius,
      ),
      -pi / 2,
      pi / 2,
      false,
      cornerPaint,
    );
    // Top Right Extension Lines
    canvas.drawLine(
      Offset(left + cardWidth - cornerRadius + offset, top - offset),
      Offset(left + cardWidth - cornerRadius - horizontalLineLength + offset, top - offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + cardWidth + offset, top + cornerRadius - offset),
      Offset(left + cardWidth + offset, top + cornerRadius + verticalLineLength - offset),
      cornerPaint,
    );

    // Bottom Left Corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(left + cornerRadius - offset, top + cardHeight - cornerRadius + offset),
        radius: cornerRadius,
      ),
      pi / 2,
      pi / 2,
      false,
      cornerPaint,
    );
    // Bottom Left Extension Lines
    canvas.drawLine(
      Offset(left + cornerRadius - offset, top + cardHeight + offset),
      Offset(left + cornerRadius + horizontalLineLength - offset, top + cardHeight + offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left - offset, top + cardHeight - cornerRadius + offset),
      Offset(left - offset, top + cardHeight - cornerRadius - verticalLineLength + offset),
      cornerPaint,
    );

    // Bottom Right Corner
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(left + cardWidth - cornerRadius + offset, top + cardHeight - cornerRadius + offset),
        radius: cornerRadius,
      ),
      0,
      pi / 2,
      false,
      cornerPaint,
    );
    // Bottom Right Extension Lines
    canvas.drawLine(
      Offset(left + cardWidth - cornerRadius + offset, top + cardHeight + offset),
      Offset(left + cardWidth - cornerRadius - horizontalLineLength + offset, top + cardHeight + offset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + cardWidth + offset, top + cardHeight - cornerRadius + offset),
      Offset(left + cardWidth + offset, top + cardHeight - cornerRadius - verticalLineLength + offset),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
