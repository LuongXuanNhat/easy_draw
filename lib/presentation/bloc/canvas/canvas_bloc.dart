import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'canvas_event.dart';
import 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  CanvasBloc() : super(const CanvasState()) {
    on<ToolChanged>((event, emit) {
      emit(state.copyWith(currentTool: event.tool));
    });

    on<StrokePropertiesChanged>((event, emit) {
      emit(
        state.copyWith(
          currentColor: event.color ?? state.currentColor,
          currentStrokeWidth: event.width ?? state.currentStrokeWidth,
          currentStrokeStyle: event.style ?? state.currentStrokeStyle,
        ),
      );
    });

    on<ElementAdded>((event, emit) {
      final updatedElements = List<CanvasElement>.from(state.elements)
        ..add(event.element);
      // Khi có hành động mới, xóa sạch Redo stack
      emit(state.copyWith(elements: updatedElements, redoStack: []));
    });

    on<UndoRequested>((event, emit) {
      if (state.elements.isEmpty) return;

      final elements = List<CanvasElement>.from(state.elements);
      final lastElement = elements.removeLast();

      final redoStack = List<CanvasElement>.from(state.redoStack)
        ..add(lastElement);

      emit(state.copyWith(elements: elements, redoStack: redoStack));
    });

    on<RedoRequested>((event, emit) {
      if (state.redoStack.isEmpty) return;

      final redoStack = List<CanvasElement>.from(state.redoStack);
      final elementToRestore = redoStack.removeLast();

      final elements = List<CanvasElement>.from(state.elements)
        ..add(elementToRestore);

      emit(state.copyWith(elements: elements, redoStack: redoStack));
    });

    on<ElementUpdated>((event, emit) {
      final updatedElements = List<CanvasElement>.from(state.elements);
      if (event.index >= 0 && event.index < updatedElements.length) {
        updatedElements[event.index] = event.updatedElement;
        emit(state.copyWith(elements: updatedElements, redoStack: []));
      }
    });

    on<ElementDeleted>((event, emit) {
      final updatedElements = List<CanvasElement>.from(state.elements);
      if (event.index >= 0 && event.index < updatedElements.length) {
        updatedElements.removeAt(event.index);
        emit(state.copyWith(elements: updatedElements, redoStack: []));
      }
    });

    on<CanvasCleared>((event, emit) {
      // Lưu lại snapshot hiện tại vào history nếu muốn Undo lệnh Clear
      emit(state.copyWith(elements: [], redoStack: []));
    });

    on<ShapeTypeChanged>((event, emit) {
      emit(
        state.copyWith(
          currentTool: ElementType.shape, // Tự động chuyển sang công cụ vẽ hình
          currentShapeType: event.shapeType,
        ),
      );
    });
  }
}
