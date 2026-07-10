import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'canvas_event.dart';
import 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  final List<List<CanvasElement>> _undoHistory = [];
  final List<List<CanvasElement>> _redoHistory = [];

  List<CanvasElement> _cloneList(List<CanvasElement> source) {
    return source.map((el) => el.clone()).toList();
  }

  void _saveToHistory(List<CanvasElement> currentElements) {
    _undoHistory.add(_cloneList(currentElements));
    _redoHistory.clear();
  }

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
      _saveToHistory(state.elements);
      final updatedElements = _cloneList(state.elements)
        ..add(event.element);
      emit(state.copyWith(elements: updatedElements));
    });

    on<UndoRequested>((event, emit) {
      if (_undoHistory.isEmpty) return;

      _redoHistory.add(_cloneList(state.elements));
      final previousElements = _undoHistory.removeLast();
      emit(state.copyWith(elements: previousElements));
    });

    on<RedoRequested>((event, emit) {
      if (_redoHistory.isEmpty) return;

      _undoHistory.add(_cloneList(state.elements));
      final nextElements = _redoHistory.removeLast();
      emit(state.copyWith(elements: nextElements));
    });

    on<ElementUpdated>((event, emit) {
      _saveToHistory(state.elements);
      final updatedElements = _cloneList(state.elements);
      if (event.index >= 0 && event.index < updatedElements.length) {
        updatedElements[event.index] = event.updatedElement;
        emit(state.copyWith(elements: updatedElements));
      }
    });

    on<ElementDeleted>((event, emit) {
      _saveToHistory(state.elements);
      final updatedElements = _cloneList(state.elements);
      if (event.index >= 0 && event.index < updatedElements.length) {
        updatedElements.removeAt(event.index);
        emit(state.copyWith(elements: updatedElements));
      }
    });

    on<CanvasCleared>((event, emit) {
      _saveToHistory(state.elements);
      emit(state.copyWith(elements: []));
    });

    on<ShapeTypeChanged>((event, emit) {
      emit(
        state.copyWith(
          currentTool: ElementType.shape, // Tự động chuyển sang công cụ vẽ hình
          currentShapeType: event.shapeType,
        ),
      );
    });

    on<DocumentElementsLoaded>((event, emit) {
      _undoHistory.clear();
      _redoHistory.clear();
      emit(state.copyWith(elements: _cloneList(event.elements)));
    });

    on<ElementsReordered>((event, emit) {
      _saveToHistory(state.elements);
      emit(state.copyWith(elements: _cloneList(event.elements)));
    });
  }
}
