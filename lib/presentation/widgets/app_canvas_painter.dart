import 'package:flutter/material.dart';
import 'package:draw_core/draw_core.dart';
import '../../data/models/canvas_element.dart';
import '../../data/mappers/canvas_mapper.dart';
import 'dart:math' as math;

// --- LỚP 1: VẼ LỊCH SỬ (CHỈ VẼ LẠI KHI CÓ NÉT MỚI HOÀN THÀNH) ---
class HistoryCanvasPainter extends CustomPainter {
  final List<CanvasElement> elements;
  HistoryCanvasPainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    for (var el in elements) {
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
      }
    }
  }

  @override
  bool shouldRepaint(covariant HistoryCanvasPainter oldDelegate) {
    return oldDelegate.elements !=
        elements; // Chỉ vẽ lại khi data lịch sử thay đổi
  }
}

// --- LỚP 2: VẼ THỜI GIAN THỰC (VẼ LIÊN TỤC 60FPS) ---
class ActiveCanvasPainter extends CustomPainter {
  final DrawStroke? activeStroke;
  final Offset? shapeStart;
  final Offset? shapeEnd;
  final ShapeType activeShapeType;
  final Color currentColor;
  final double currentStrokeWidth;

  ActiveCanvasPainter({
    this.activeStroke,
    this.shapeStart,
    this.shapeEnd,
    required this.activeShapeType,
    required this.currentColor,
    required this.currentStrokeWidth,
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
  }

  @override
  bool shouldRepaint(covariant ActiveCanvasPainter oldDelegate) => true; // Luôn vẽ lại khi ngón tay di chuyển
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
    ..style = PaintingStyle.stroke;
  final rect = Rect.fromPoints(start, end);
  // (Giữ nguyên toàn bộ logic khối switch-case vẽ 20 hình học của bạn ở đây)
  switch (type) {
    case ShapeType.line:
      canvas.drawLine(start, end, paint);
      break;
    case ShapeType.rectangle:
      canvas.drawRect(rect, paint);
      break;
    case ShapeType.ellipse:
      canvas.drawOval(rect, paint);
      break;
    default:
      canvas.drawRect(rect, paint);
      break;
  }
}
