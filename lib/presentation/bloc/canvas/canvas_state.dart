import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// Import file model chứa ElementType và ShapeType
import '../../../data/models/canvas_element.dart';

class CanvasState extends Equatable {
  final List<CanvasElement> elements;
  final List<CanvasElement> redoStack;

  // Trạng thái công cụ hiện tại
  final ElementType currentTool;
  final ShapeType currentShapeType; // Đã thêm biến này
  final StrokeStyle currentStrokeStyle;
  final Color currentColor;
  final double currentStrokeWidth;

  const CanvasState({
    this.elements = const [],
    this.redoStack = const [],
    this.currentTool = ElementType.freehand,
    this.currentShapeType = ShapeType.rectangle, // Giá trị mặc định
    this.currentStrokeStyle = StrokeStyle.solid,
    this.currentColor = Colors.black,
    this.currentStrokeWidth = 3.0,
  });

  CanvasState copyWith({
    List<CanvasElement>? elements,
    List<CanvasElement>? redoStack,
    ElementType? currentTool,
    ShapeType? currentShapeType, // Thêm tham số
    StrokeStyle? currentStrokeStyle,
    Color? currentColor,
    double? currentStrokeWidth,
  }) {
    return CanvasState(
      elements: elements ?? this.elements,
      redoStack: redoStack ?? this.redoStack,
      currentTool: currentTool ?? this.currentTool,
      currentShapeType:
          currentShapeType ?? this.currentShapeType, // Cập nhật state
      currentStrokeStyle: currentStrokeStyle ?? this.currentStrokeStyle,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
    );
  }

  @override
  List<Object> get props => [
    elements,
    redoStack,
    currentTool,
    currentShapeType, // Thêm vào danh sách so sánh
    currentStrokeStyle,
    currentColor,
    currentStrokeWidth,
  ];
}
