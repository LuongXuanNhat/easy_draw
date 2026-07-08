import 'package:flutter/material.dart';
import 'package:draw_core/draw_core.dart';
import '../../data/models/canvas_element.dart';
import '../../data/mappers/canvas_mapper.dart';
import 'dart:math' as math;

// --- LỚP 1: VẼ LỊCH SỬ (CHỈ VẼ LẠI KHI CÓ NÉT MỚI HOÀN THÀNH) ---
Rect getElementBoundingBox(CanvasElement el) {
  if (el.type == ElementType.freehand && el.points != null && el.points!.isNotEmpty) {
    double minX = el.points!.first.x ?? 0.0;
    double maxX = el.points!.first.x ?? 0.0;
    double minY = el.points!.first.y ?? 0.0;
    double maxY = el.points!.first.y ?? 0.0;
    for (var p in el.points!) {
      final px = p.x ?? 0.0;
      final py = p.y ?? 0.0;
      if (px < minX) minX = px;
      if (px > maxX) maxX = px;
      if (py < minY) minY = py;
      if (py > maxY) maxY = py;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  } else if (el.type == ElementType.text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: el.textContent ?? '',
        style: TextStyle(
          fontSize: el.fontSize ?? 20.0,
          fontFamily: el.fontFamily ?? 'Roboto',
          fontWeight: (el.isBold ?? false) ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return Rect.fromLTWH(
      el.boundingLeft ?? 0.0,
      el.boundingTop ?? 0.0,
      textPainter.width,
      textPainter.height,
    );
  } else {
    return Rect.fromLTRB(
      el.boundingLeft ?? 0.0,
      el.boundingTop ?? 0.0,
      el.boundingRight ?? 0.0,
      el.boundingBottom ?? 0.0,
    );
  }
}

void _applyTransformations(Canvas canvas, CanvasElement el) {
  final rect = getElementBoundingBox(el);
  final cx = rect.center.dx;
  final cy = rect.center.dy;

  final tx = el.translationX ?? 0.0;
  final ty = el.translationY ?? 0.0;
  final rot = el.rotationAngle ?? 0.0;
  final sc = el.scale ?? 1.0;

  if (tx != 0.0 || ty != 0.0) {
    canvas.translate(tx, ty);
  }
  if (rot != 0.0 || sc != 1.0) {
    canvas.translate(cx, cy);
    if (rot != 0.0) canvas.rotate(rot);
    if (sc != 1.0) canvas.scale(sc);
    canvas.translate(-cx, -cy);
  }
}

void _paintTextHelper(
  Canvas canvas,
  String text,
  Offset position,
  Color color,
  double fontSize,
  String fontFamily,
  bool isBold,
) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, position);
}

void _paintIndexLabel(Canvas canvas, int index, Offset position) {
  final circlePaint = Paint()
    ..color = Colors.blue.withOpacity(0.9)
    ..style = PaintingStyle.fill;

  final borderPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  canvas.drawCircle(position, 10.0, circlePaint);
  canvas.drawCircle(position, 10.0, borderPaint);

  final textPainter = TextPainter(
    text: TextSpan(
      text: '$index',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  final textPos = position - Offset(textPainter.width / 2, textPainter.height / 2);
  textPainter.paint(canvas, textPos);
}

class HistoryCanvasPainter extends CustomPainter {
  final List<CanvasElement> elements;
  final CanvasElement? selectedElement;
  final bool isSelectMode;

  HistoryCanvasPainter({
    required this.elements,
    this.selectedElement,
    this.isSelectMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < elements.length; i++) {
      final el = elements[i];
      if (el == selectedElement) continue; // Skip to paint on ActiveCanvasPainter layer instead

      canvas.save();
      _applyTransformations(canvas, el);

      if (el.type == ElementType.freehand) {
        final stroke = el.toDrawStroke();
        if (stroke != null) {
          DrawPainter(strokes: [stroke]).paint(canvas, size);
        }
      } else if (el.type == ElementType.shape) {
        _paintShapeHelper(
          canvas,
          el.shapeType,
          Offset(el.boundingLeft ?? 0, el.boundingTop ?? 0),
          Offset(el.boundingRight ?? 0, el.boundingBottom ?? 0),
          Color(el.colorValue ?? 0xFF000000),
          el.strokeWidth ?? 3.0,
        );
      } else if (el.type == ElementType.text) {
        _paintTextHelper(
          canvas,
          el.textContent ?? '',
          Offset(el.boundingLeft ?? 0, el.boundingTop ?? 0),
          Color(el.colorValue ?? 0xFF000000),
          el.fontSize ?? 20.0,
          el.fontFamily ?? 'Roboto',
          el.isBold ?? false,
        );
      }

      canvas.restore();

      // Vẽ nhãn thứ tự index layout cho object
      if (isSelectMode) {
        final rect = getElementBoundingBox(el);
        final tx = el.translationX ?? 0.0;
        final ty = el.translationY ?? 0.0;
        final labelPos = rect.topLeft + Offset(tx, ty);
        _paintIndexLabel(canvas, i + 1, labelPos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HistoryCanvasPainter oldDelegate) {
    return oldDelegate.elements != elements ||
        oldDelegate.selectedElement != selectedElement ||
        oldDelegate.isSelectMode != isSelectMode;
  }
}

class ActiveCanvasPainter extends CustomPainter {
  final DrawStroke? activeStroke;
  final Offset? shapeStart;
  final Offset? shapeEnd;
  final ShapeType activeShapeType;
  final Color currentColor;
  final double currentStrokeWidth;
  final CanvasElement? selectedElement;
  final int selectedIndex;
  final bool isSelectMode;

  ActiveCanvasPainter({
    this.activeStroke,
    this.shapeStart,
    this.shapeEnd,
    required this.activeShapeType,
    required this.currentColor,
    required this.currentStrokeWidth,
    this.selectedElement,
    this.selectedIndex = -1,
    this.isSelectMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (activeStroke != null) {
      DrawPainter(strokes: [activeStroke!]).paint(canvas, size);
    }
    if (shapeStart != null && shapeEnd != null) {
      _paintShapeHelper(
        canvas,
        activeShapeType,
        shapeStart!,
        shapeEnd!,
        currentColor,
        currentStrokeWidth,
      );
    }
    if (selectedElement != null) {
      // 1. Vẽ bản thân đối tượng đang được chỉnh sửa
      canvas.save();
      _applyTransformations(canvas, selectedElement!);

      if (selectedElement!.type == ElementType.freehand) {
        final stroke = selectedElement!.toDrawStroke();
        if (stroke != null) {
          DrawPainter(strokes: [stroke]).paint(canvas, size);
        }
      } else if (selectedElement!.type == ElementType.shape) {
        _paintShapeHelper(
          canvas,
          selectedElement!.shapeType,
          Offset(selectedElement!.boundingLeft ?? 0, selectedElement!.boundingTop ?? 0),
          Offset(selectedElement!.boundingRight ?? 0, selectedElement!.boundingBottom ?? 0),
          Color(selectedElement!.colorValue ?? 0xFF000000),
          selectedElement!.strokeWidth ?? 3.0,
        );
      } else if (selectedElement!.type == ElementType.text) {
        _paintTextHelper(
          canvas,
          selectedElement!.textContent ?? '',
          Offset(selectedElement!.boundingLeft ?? 0, selectedElement!.boundingTop ?? 0),
          Color(selectedElement!.colorValue ?? 0xFF000000),
          selectedElement!.fontSize ?? 20.0,
          selectedElement!.fontFamily ?? 'Roboto',
          selectedElement!.isBold ?? false,
        );
      }
      canvas.restore();

      // 2. Vẽ viền selector và tay cầm
      final rect = getElementBoundingBox(selectedElement!);
      final tx = selectedElement!.translationX ?? 0.0;
      final ty = selectedElement!.translationY ?? 0.0;
      final rotated = selectedElement!.rotationAngle ?? 0.0;
      final scaled = selectedElement!.scale ?? 1.0;

      canvas.save();
      final cx = rect.center.dx;
      final cy = rect.center.dy;
      canvas.translate(cx + tx, cy + ty);
      if (rotated != 0.0) canvas.rotate(rotated);
      if (scaled != 1.0) canvas.scale(scaled);
      canvas.translate(-cx, -cy);

      final selectionPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final inflated = rect.inflate(4.0);
      canvas.drawRect(inflated, selectionPaint);

      final handlePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      // 4 corners
      canvas.drawCircle(inflated.topLeft, 6.0, handlePaint);
      canvas.drawCircle(inflated.topRight, 6.0, handlePaint);
      canvas.drawCircle(inflated.bottomLeft, 6.0, handlePaint);
      canvas.drawCircle(inflated.bottomRight, 6.0, handlePaint);

      // Rotation handle (green dot at top-center - 20px)
      final rotLineStart = Offset(inflated.center.dx, inflated.top);
      final rotLineEnd = Offset(inflated.center.dx, inflated.top - 20.0);
      canvas.drawLine(rotLineStart, rotLineEnd, selectionPaint);
      canvas.drawCircle(rotLineEnd, 6.0, Paint()..color = Colors.green);

      canvas.restore();

      // 3. Vẽ nhãn thứ tự index của vật thể đang được chọn
      if (isSelectMode && selectedIndex >= 0) {
        final labelPos = rect.topLeft + Offset(tx, ty);
        _paintIndexLabel(canvas, selectedIndex + 1, labelPos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ActiveCanvasPainter oldDelegate) => true;
}

// --- HÀM HELPER VẼ HÌNH (Dùng chung cho cả 2 lớp) ---
void _paintShapeHelper(
  Canvas canvas,
  ShapeType type,
  Offset start,
  Offset end,
  Color color,
  double width,
) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = width
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final rect = Rect.fromPoints(start, end);
  final w = rect.width;
  final h = rect.height;
  final L = rect.left;
  final T = rect.top;
  final R = rect.right;
  final B = rect.bottom;
  final cx = rect.center.dx;
  final cy = rect.center.dy;

  switch (type) {
    // === Basic Geometrical ===
    case ShapeType.rectangle:
      canvas.drawRect(rect, paint);
      break;

    case ShapeType.roundedRectangle:
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(math.min(w, h) * 0.15)),
        paint,
      );
      break;

    case ShapeType.square:
      final side = math.min(w, h);
      final squareRect = Rect.fromLTWH(
        start.dx,
        start.dy,
        (end.dx - start.dx).sign * side,
        (end.dy - start.dy).sign * side,
      );
      canvas.drawRect(squareRect, paint);
      break;

    case ShapeType.ellipse:
      canvas.drawOval(rect, paint);
      break;

    case ShapeType.circle:
      final side = math.min(w, h);
      final circleRect = Rect.fromLTWH(
        start.dx,
        start.dy,
        (end.dx - start.dx).sign * side,
        (end.dy - start.dy).sign * side,
      );
      canvas.drawOval(circleRect, paint);
      break;

    case ShapeType.triangle: // Isosceles Triangle
      final path = Path()
        ..moveTo(cx, T)
        ..lineTo(R, B)
        ..lineTo(L, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.rightTriangle:
      final path = Path()
        ..moveTo(L, T)
        ..lineTo(R, B)
        ..lineTo(L, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.diamond:
      final path = Path()
        ..moveTo(cx, T)
        ..lineTo(R, cy)
        ..lineTo(cx, B)
        ..lineTo(L, cy)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.parallelogram:
      final shift = w * 0.25;
      final path = Path()
        ..moveTo(L + shift, T)
        ..lineTo(R, T)
        ..lineTo(R - shift, B)
        ..lineTo(L, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.trapezoid:
      final path = Path()
        ..moveTo(L + w * 0.2, T)
        ..lineTo(R - w * 0.2, T)
        ..lineTo(R, B)
        ..lineTo(L, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.pentagon:
      final path = Path()
        ..moveTo(cx, T)
        ..lineTo(R, T + h * 0.38)
        ..lineTo(L + w * 0.81, B)
        ..lineTo(L + w * 0.19, B)
        ..lineTo(L, T + h * 0.38)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.hexagon:
      final path = Path()
        ..moveTo(L + w * 0.25, T)
        ..lineTo(R - w * 0.25, T)
        ..lineTo(R, cy)
        ..lineTo(R - w * 0.25, B)
        ..lineTo(L + w * 0.25, B)
        ..lineTo(L, cy)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.octagon:
      final cx1 = L + w * 0.29;
      final cx2 = R - w * 0.29;
      final cy1 = T + h * 0.29;
      final cy2 = B - h * 0.29;
      final path = Path()
        ..moveTo(cx1, T)
        ..lineTo(cx2, T)
        ..lineTo(R, cy1)
        ..lineTo(R, cy2)
        ..lineTo(cx2, B)
        ..lineTo(cx1, B)
        ..lineTo(L, cy2)
        ..lineTo(L, cy1)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.decagon:
      final path = Path();
      for (int i = 0; i < 10; i++) {
        final angle = -math.pi / 2 + i * (2 * math.pi / 10);
        final px = cx + (w / 2) * math.cos(angle);
        final py = cy + (h / 2) * math.sin(angle);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.cross:
      final lx = L + w * 0.35;
      final rx = R - w * 0.35;
      final ty = T + h * 0.35;
      final by = B - h * 0.35;
      final path = Path()
        ..moveTo(lx, T)
        ..lineTo(rx, T)
        ..lineTo(rx, ty)
        ..lineTo(R, ty)
        ..lineTo(R, by)
        ..lineTo(rx, by)
        ..lineTo(rx, B)
        ..lineTo(lx, B)
        ..lineTo(lx, by)
        ..lineTo(L, by)
        ..lineTo(L, ty)
        ..lineTo(lx, ty)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.cube:
      final offsetW = w * 0.2;
      final offsetH = h * 0.2;
      final front = Rect.fromLTWH(L, T + offsetH, w - offsetW, h - offsetH);
      final back = Rect.fromLTWH(L + offsetW, T, w - offsetW, h - offsetH);
      canvas.drawRect(front, paint);
      canvas.drawRect(back, paint);
      canvas.drawLine(front.topLeft, back.topLeft, paint);
      canvas.drawLine(front.topRight, back.topRight, paint);
      canvas.drawLine(front.bottomLeft, back.bottomLeft, paint);
      canvas.drawLine(front.bottomRight, back.bottomRight, paint);
      break;

    case ShapeType.frame:
      final borderW = w * 0.15;
      final borderH = h * 0.15;
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect.deflate(math.min(borderW, borderH)), paint);
      break;

    case ShapeType.donut:
      canvas.drawOval(rect, paint);
      canvas.drawOval(rect.deflate(math.min(w, h) * 0.25), paint);
      break;

    case ShapeType.arc:
      canvas.drawArc(rect, 0.0, math.pi * 1.5, false, paint);
      break;

    case ShapeType.chord:
      final chordPath = Path()
        ..addArc(rect, 0.0, math.pi * 1.5)
        ..close();
      canvas.drawPath(chordPath, paint);
      break;

    // === Lines & Curves ===
    case ShapeType.line:
      canvas.drawLine(start, end, paint);
      break;

    case ShapeType.arrowLine:
      canvas.drawLine(start, end, paint);
      final dX = end.dx - start.dx;
      final dY = end.dy - start.dy;
      final angle = math.atan2(dY, dX);
      final arrowSize = math.max(width * 3, 15.0);
      final arrowAngle = math.pi / 6;
      final path = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - arrowSize * math.cos(angle - arrowAngle),
          end.dy - arrowSize * math.sin(angle - arrowAngle),
        )
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - arrowSize * math.cos(angle + arrowAngle),
          end.dy - arrowSize * math.sin(angle + arrowAngle),
        );
      canvas.drawPath(path, paint);
      break;

    case ShapeType.curve:
      final cp = Offset(
        (start.dx + end.dx) / 2 - (end.dy - start.dy) / 4,
        (start.dy + end.dy) / 2 + (end.dx - start.dx) / 4,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(cp.dx, cp.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);
      break;

    case ShapeType.freeform:
      final path = Path()..moveTo(start.dx, start.dy);
      const steps = 20;
      for (int i = 1; i <= steps; i++) {
        final t = i / steps;
        final px = start.dx + t * (end.dx - start.dx);
        final py =
            start.dy +
            t * (end.dy - start.dy) +
            math.sin(t * math.pi * 4) * (w / 10);
        path.lineTo(px, py);
      }
      canvas.drawPath(path, paint);
      break;

    case ShapeType.scribble:
      final path = Path()..moveTo(start.dx, start.dy);
      const loops = 15;
      for (int i = 1; i <= loops; i++) {
        final t = i / loops;
        final cxVal = start.dx + t * (end.dx - start.dx);
        final cyVal = start.dy + t * (end.dy - start.dy);
        final rVal = math.min(w, h) * 0.15;
        final angle = t * 6 * math.pi;
        path.lineTo(
          cxVal + rVal * math.cos(angle),
          cyVal + rVal * math.sin(angle),
        );
      }
      canvas.drawPath(path, paint);
      break;

    // === Arrows ===
    case ShapeType.arrowRight:
      final path = Path()
        ..moveTo(L, T + h * 0.25)
        ..lineTo(L + w * 0.6, T + h * 0.25)
        ..lineTo(L + w * 0.6, T)
        ..lineTo(R, cy)
        ..lineTo(L + w * 0.6, B)
        ..lineTo(L + w * 0.6, B - h * 0.25)
        ..lineTo(L, B - h * 0.25)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowLeft:
      final path = Path()
        ..moveTo(R, T + h * 0.25)
        ..lineTo(R - w * 0.6, T + h * 0.25)
        ..lineTo(R - w * 0.6, T)
        ..lineTo(L, cy)
        ..lineTo(R - w * 0.6, B)
        ..lineTo(R - w * 0.6, B - h * 0.25)
        ..lineTo(R, B - h * 0.25)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowUp:
      final path = Path()
        ..moveTo(L + w * 0.25, B)
        ..lineTo(L + w * 0.25, T + h * 0.6)
        ..lineTo(L, T + h * 0.6)
        ..lineTo(cx, T)
        ..lineTo(R, T + h * 0.6)
        ..lineTo(R - w * 0.25, T + h * 0.6)
        ..lineTo(R - w * 0.25, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowDown:
      final path = Path()
        ..moveTo(L + w * 0.25, T)
        ..lineTo(L + w * 0.25, T + h * 0.4)
        ..lineTo(L, T + h * 0.4)
        ..lineTo(cx, B)
        ..lineTo(R, T + h * 0.4)
        ..lineTo(R - w * 0.25, T + h * 0.4)
        ..lineTo(R - w * 0.25, T)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowLeftRight:
      final path = Path()
        ..moveTo(L + w * 0.2, T + h * 0.25)
        ..lineTo(R - w * 0.2, T + h * 0.25)
        ..lineTo(R - w * 0.2, T)
        ..lineTo(R, cy)
        ..lineTo(R - w * 0.2, B)
        ..lineTo(R - w * 0.2, B - h * 0.25)
        ..lineTo(L + w * 0.2, B - h * 0.25)
        ..lineTo(L + w * 0.2, B)
        ..lineTo(L, cy)
        ..lineTo(L + w * 0.2, T)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowFourWay:
      final path = Path()
        ..moveTo(cx, T)
        ..lineTo(cx - w * 0.15, T + h * 0.2)
        ..lineTo(cx - w * 0.05, T + h * 0.2)
        ..lineTo(cx - w * 0.05, cy - h * 0.05)
        ..lineTo(L + w * 0.2, cy - h * 0.05)
        ..lineTo(L + w * 0.2, cy - h * 0.15)
        ..lineTo(L, cy)
        ..lineTo(L + w * 0.2, cy + h * 0.15)
        ..lineTo(L + w * 0.2, cy + h * 0.05)
        ..lineTo(cx - w * 0.05, cy + h * 0.05)
        ..lineTo(cx - w * 0.05, B - h * 0.2)
        ..lineTo(cx - w * 0.15, B - h * 0.2)
        ..lineTo(cx, B)
        ..lineTo(cx + w * 0.15, B - h * 0.2)
        ..lineTo(cx + w * 0.05, B - h * 0.2)
        ..lineTo(cx + w * 0.05, cy + h * 0.05)
        ..lineTo(R - w * 0.2, cy + h * 0.05)
        ..lineTo(R - w * 0.2, cy + h * 0.15)
        ..lineTo(R, cy)
        ..lineTo(R - w * 0.2, cy - h * 0.15)
        ..lineTo(R - w * 0.2, cy - h * 0.05)
        ..lineTo(cx + w * 0.05, cy - h * 0.05)
        ..lineTo(cx + w * 0.05, T + h * 0.2)
        ..lineTo(cx + w * 0.15, T + h * 0.2)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowUTurn:
      final path = Path()
        ..moveTo(L + w * 0.1, B)
        ..lineTo(L + w * 0.1, T + h * 0.3)
        ..arcTo(
          Rect.fromLTWH(L + w * 0.1, T, w * 0.8, h * 0.6),
          math.pi,
          math.pi,
          false,
        )
        ..lineTo(R - w * 0.1, B - h * 0.25)
        ..lineTo(R, B - h * 0.25)
        ..lineTo(R - w * 0.2, B)
        ..lineTo(L + w * 0.6, B - h * 0.25)
        ..lineTo(R - w * 0.3, B - h * 0.25)
        ..lineTo(R - w * 0.3, T + h * 0.3)
        ..arcTo(
          Rect.fromLTWH(L + w * 0.3, T + h * 0.2, w * 0.4, h * 0.2),
          0.0,
          -math.pi,
          false,
        )
        ..lineTo(L + w * 0.3, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowCurved:
      final path = Path()
        ..moveTo(L, B)
        ..quadraticBezierTo(cx, cy, R - w * 0.2, T + h * 0.2)
        ..lineTo(R - w * 0.3, T)
        ..lineTo(R, T)
        ..lineTo(R, T + h * 0.3)
        ..lineTo(R - w * 0.1, T + h * 0.2)
        ..quadraticBezierTo(cx, cy + h * 0.2, L + w * 0.2, B)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.chevron:
      final path = Path()
        ..moveTo(L, T)
        ..lineTo(L + w * 0.5, T)
        ..lineTo(R, cy)
        ..lineTo(L + w * 0.5, B)
        ..lineTo(L, B)
        ..lineTo(L + w * 0.5, cy)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.arrowPentagon:
      final path = Path()
        ..moveTo(L, T + h * 0.2)
        ..lineTo(L + w * 0.6, T + h * 0.2)
        ..lineTo(R, cy)
        ..lineTo(L + w * 0.6, B - h * 0.2)
        ..lineTo(L, B - h * 0.2)
        ..close();
      canvas.drawPath(path, paint);
      break;

    // === Callouts ===
    case ShapeType.calloutRectangular:
      final path = Path()
        ..moveTo(L, T)
        ..lineTo(R, T)
        ..lineTo(R, B - h * 0.2)
        ..lineTo(L + w * 0.5, B - h * 0.2)
        ..lineTo(L + w * 0.35, B)
        ..lineTo(L + w * 0.3, B - h * 0.2)
        ..lineTo(L, B - h * 0.2)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.calloutRounded:
      final r = math.min(w, h) * 0.1;
      final path = Path()
        ..moveTo(L + r, T)
        ..lineTo(R - r, T)
        ..arcToPoint(Offset(R, T + r), radius: Radius.circular(r))
        ..lineTo(R, B - h * 0.2 - r)
        ..arcToPoint(Offset(R - r, B - h * 0.2), radius: Radius.circular(r))
        ..lineTo(L + w * 0.5, B - h * 0.2)
        ..lineTo(L + w * 0.35, B)
        ..lineTo(L + w * 0.3, B - h * 0.2)
        ..lineTo(L + r, B - h * 0.2)
        ..arcToPoint(Offset(L, B - h * 0.2 - r), radius: Radius.circular(r))
        ..lineTo(L, T + r)
        ..arcToPoint(Offset(L + r, T), radius: Radius.circular(r))
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.calloutOval:
      final path = Path()
        ..addOval(Rect.fromLTWH(L, T, w, h * 0.8))
        ..moveTo(cx - w * 0.1, B - h * 0.23)
        ..lineTo(L + w * 0.2, B)
        ..lineTo(cx + w * 0.05, B - h * 0.21);
      canvas.drawPath(path, paint);
      break;

    case ShapeType.calloutCloud:
      final path = Path()
        ..moveTo(L + w * 0.2, cy)
        ..quadraticBezierTo(L + w * 0.1, T + h * 0.2, L + w * 0.3, T + h * 0.2)
        ..quadraticBezierTo(cx, T, L + w * 0.7, T + h * 0.2)
        ..quadraticBezierTo(R - w * 0.1, T + h * 0.2, R - w * 0.2, cy)
        ..quadraticBezierTo(R, B - h * 0.4, R - w * 0.3, B - h * 0.3)
        ..quadraticBezierTo(cx, B - h * 0.1, L + w * 0.3, B - h * 0.3)
        ..quadraticBezierTo(L, B - h * 0.4, L + w * 0.2, cy);
      canvas.drawPath(path, paint);
      canvas.drawCircle(
        Offset(L + w * 0.25, B - h * 0.2),
        math.min(w, h) * 0.05,
        paint,
      );
      canvas.drawCircle(
        Offset(L + w * 0.15, B - h * 0.1),
        math.min(w, h) * 0.03,
        paint,
      );
      break;

    case ShapeType.calloutLine:
      canvas.drawLine(start, Offset(cx, cy), paint);
      canvas.drawLine(Offset(cx, cy), Offset(end.dx - w * 0.1, cy), paint);
      canvas.drawRect(
        Rect.fromLTWH(end.dx - w * 0.2, cy - h * 0.2, w * 0.2, h * 0.4),
        paint,
      );
      break;

    // === Stars ===
    case ShapeType.star4:
      final path = Path()
        ..moveTo(cx, T)
        ..quadraticBezierTo(cx, cy, R, cy)
        ..quadraticBezierTo(cx, cy, cx, B)
        ..quadraticBezierTo(cx, cy, L, cy)
        ..quadraticBezierTo(cx, cy, cx, T)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.star5:
      final path = Path();
      final double innerRadius = math.min(w, h) * 0.2;
      final double outerRadius = math.min(w, h) * 0.5;
      for (int i = 0; i < 10; i++) {
        final angle = -math.pi / 2 + i * math.pi / 5;
        final rVal = i.isEven ? outerRadius : innerRadius;
        final px = cx + rVal * math.cos(angle);
        final py = cy + rVal * math.sin(angle);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.star6:
      final path = Path();
      final double innerRadius = math.min(w, h) * 0.288;
      final double outerRadius = math.min(w, h) * 0.5;
      for (int i = 0; i < 12; i++) {
        final angle = -math.pi / 2 + i * math.pi / 6;
        final rVal = i.isEven ? outerRadius : innerRadius;
        final px = cx + rVal * math.cos(angle);
        final py = cy + rVal * math.sin(angle);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      break;

    // === Others ===
    case ShapeType.heart:
      final path = Path()
        ..moveTo(cx, T + h * 0.25)
        ..cubicTo(L + w * 0.1, T, L, T + h * 0.5, cx, B)
        ..cubicTo(R, T + h * 0.5, R - w * 0.1, T, cx, T + h * 0.25)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.smileyFace:
      final r = math.min(w, h) / 2;
      canvas.drawCircle(Offset(cx, cy), r, paint);
      final eyePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.2), r * 0.1, eyePaint);
      canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.2), r * 0.1, eyePaint);
      final smileRect = Rect.fromCircle(
        center: Offset(cx, cy),
        radius: r * 0.5,
      );
      canvas.drawArc(smileRect, 0.1 * math.pi, 0.8 * math.pi, false, paint);
      break;

    case ShapeType.moon:
      final outerPath = Path()..addOval(rect);
      final innerPath = Path()..addOval(Rect.fromLTWH(L + w * 0.25, T, w, h));
      final moonPath = Path.combine(
        PathOperation.difference,
        outerPath,
        innerPath,
      );
      canvas.drawPath(moonPath, paint);
      break;

    case ShapeType.sun:
      final innerR = math.min(w, h) * 0.25;
      canvas.drawCircle(Offset(cx, cy), innerR, paint);
      final rayLen = math.min(w, h) * 0.45;
      for (int i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final x1 = cx + innerR * math.cos(angle);
        final y1 = cy + innerR * math.sin(angle);
        final x2 = cx + rayLen * math.cos(angle);
        final y2 = cy + rayLen * math.sin(angle);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
      break;

    case ShapeType.cloud:
      final path = Path()
        ..moveTo(L + w * 0.25, cy + h * 0.1)
        ..quadraticBezierTo(L + w * 0.1, T + h * 0.3, L + w * 0.3, T + h * 0.3)
        ..quadraticBezierTo(cx, T + h * 0.1, L + w * 0.7, T + h * 0.3)
        ..quadraticBezierTo(R - w * 0.1, T + h * 0.3, R - w * 0.2, cy + h * 0.1)
        ..quadraticBezierTo(R, B - h * 0.2, R - w * 0.3, B - h * 0.1)
        ..quadraticBezierTo(cx, B, L + w * 0.3, B - h * 0.1)
        ..quadraticBezierTo(L, B - h * 0.2, L + w * 0.25, cy + h * 0.1)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.lightning:
      final path = Path()
        ..moveTo(cx + w * 0.1, T)
        ..lineTo(L + w * 0.2, cy)
        ..lineTo(cx + w * 0.05, cy)
        ..lineTo(cx - w * 0.1, B)
        ..lineTo(R - w * 0.2, cy - h * 0.1)
        ..lineTo(cx - w * 0.05, cy - h * 0.1)
        ..close();
      canvas.drawPath(path, paint);
      break;

    case ShapeType.flower:
      final petalR = math.min(w, h) * 0.18;
      final centerR = math.min(w, h) * 0.15;
      canvas.drawCircle(Offset(cx, cy), centerR, paint);
      for (int i = 0; i < 6; i++) {
        final angle = i * math.pi / 3;
        final petalCenter = Offset(
          cx + (centerR + petalR * 0.6) * math.cos(angle),
          cy + (centerR + petalR * 0.6) * math.sin(angle),
        );
        canvas.drawCircle(petalCenter, petalR, paint);
      }
      break;

    case ShapeType.foldedCorner:
      final fold = math.min(w, h) * 0.2;
      final path = Path()
        ..moveTo(L, T)
        ..lineTo(R, T)
        ..lineTo(R, B - fold)
        ..lineTo(R - fold, B)
        ..lineTo(L, B)
        ..close();
      canvas.drawPath(path, paint);
      final flap = Path()
        ..moveTo(R, B - fold)
        ..lineTo(R - fold, B - fold)
        ..lineTo(R - fold, B);
      canvas.drawPath(flap, paint);
      break;

    case ShapeType.noSymbol:
      final r = math.min(w, h) / 2;
      canvas.drawCircle(Offset(cx, cy), r, paint);
      final angle = math.pi / 4;
      final dx = r * math.cos(angle);
      final dy = r * math.sin(angle);
      canvas.drawLine(Offset(cx - dx, cy - dy), Offset(cx + dx, cy + dy), paint);
      break;

    case ShapeType.circleWithPlus:
      final r = math.min(w, h) / 2;
      canvas.drawCircle(Offset(cx, cy), r, paint);
      canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
      canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);
      break;

    default:
      canvas.drawRect(rect, paint);
      break;
  }
}
