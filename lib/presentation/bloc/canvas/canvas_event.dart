import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// import ElementType, StrokeStyle...

abstract class CanvasEvent extends Equatable {
  const CanvasEvent();
  @override
  List<Object> get props => [];
}

// 1. Nhóm Event thay đổi Công cụ & Thuộc tính
class ToolChanged extends CanvasEvent {
  final ElementType tool;
  const ToolChanged(this.tool);
}

class StrokePropertiesChanged extends CanvasEvent {
  final Color? color;
  final double? width;
  final StrokeStyle? style;
  const StrokePropertiesChanged({this.color, this.width, this.style});
}

// 2. Nhóm Event tương tác bản vẽ
class ElementAdded extends CanvasEvent {
  final CanvasElement element;
  const ElementAdded(this.element);
}

class ElementUpdated extends CanvasEvent {
  final int index;
  final CanvasElement updatedElement;
  const ElementUpdated(this.index, this.updatedElement);
}

class ShapeTypeChanged extends CanvasEvent {
  final ShapeType shapeType;
  const ShapeTypeChanged(this.shapeType);
}

// 3. Nhóm Event Undo/Redo & Clear
class UndoRequested extends CanvasEvent {}

class RedoRequested extends CanvasEvent {}

class CanvasCleared extends CanvasEvent {}

class ElementDeleted extends CanvasEvent {
  final int index;
  const ElementDeleted(this.index);

  @override
  List<Object> get props => [index];
}
