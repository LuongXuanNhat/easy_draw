import 'dart:ui';
import 'package:draw_core/draw_core.dart';
import '../models/canvas_element.dart';

/// Extension chuyển đổi từ Model của draw_core sang Isar DB
extension DrawStrokeToIsar on DrawStroke {
  CanvasElement toIsarElement({int? documentId}) {
    // 1. Logic xử lý: Sử dụng simplify() của draw_core trước khi lưu để giảm dung lượng DB
    final optimizedStroke = this..simplify(tolerance: 1.0);

    return CanvasElement()
      ..documentId = documentId
      ..type = ElementType
          .freehand // Mặc định là vẽ tự do
      ..colorValue = color
          .value // Chuyển Color thành số nguyên (int)
      ..strokeWidth = strokeWidth
      ..points = optimizedStroke.points
          .map(
            (p) => IsarPoint()
              ..x = p.x
              ..y = p.y
              ..pressure = p.pressure,
          )
          .toList();
  }
}

/// Extension chuyển đổi ngược từ Isar DB lên màn hình hiển thị
extension IsarElementToDraw on CanvasElement {
  DrawStroke? toDrawStroke() {
    if (type != ElementType.freehand || points == null) return null;

    return DrawStroke(
      points: points!
          .map(
            (p) => DrawPoint(
              x: p.x ?? 0.0,
              y: p.y ?? 0.0,
              pressure: p.pressure ?? 0.5,
            ),
          )
          .toList(),
      color: Color(colorValue ?? 0xFF000000), // Phục hồi lại class Color
      strokeWidth: strokeWidth ?? 3.0,
    );
  }
}
