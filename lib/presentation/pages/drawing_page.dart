import 'package:easy_draw/core/di/injection_container.dart';
import 'package:easy_draw/core/di/utils/shape_icon.dart';
import 'package:easy_draw/data/datasources/isar_datasource.dart';
import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:easy_draw/presentation/pages/home_page.dart';
import 'package:easy_draw/presentation/widgets/app_canvas_painter.dart';
import 'package:easy_draw/presentation/widgets/shape_picker_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:draw_core/draw_core.dart';
import '../bloc/canvas/canvas_bloc.dart';
import '../bloc/canvas/canvas_event.dart';
import '../bloc/canvas/canvas_state.dart';
import '../../data/mappers/canvas_mapper.dart';
import '../widgets/style_popover.dart';
import 'dart:math' as math;

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // Trạng thái Local: Chỉ dùng để vẽ nét HIỆN TẠI nhằm đảm bảo hiệu năng (60fps)
  DrawStroke? _activeStroke;
  Offset? _shapeStart;
  Offset? _shapeEnd;
  final TransformationController _transformController =
      TransformationController();
  final LayerLink _shapeMenuLink = LayerLink();
  
  // Các link liên kết cho các PopOver cấu hình
  final LayerLink _widthLink = LayerLink();
  final LayerLink _colorLink = LayerLink();
  final LayerLink _textStyleLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  OverlayEntry? _styleOverlayEntry;

  int? _currentDocumentId;

  // Theo dõi số lượng ngón tay đang chạm màn hình
  int _pointerCount = 0;
  // Lưu lại ID của ngón tay đầu tiên chạm vào (để tránh nhiễu khi vẽ)
  int _activePointerId = -1;

  // Trạng thái chọn và biến đổi vật thể
  CanvasElement? _selectedElement;
  int _selectedElementIndex = -1;
  String _manipulationMode = 'none'; // 'move', 'rotate', 'scale', 'none'
  Offset? _dragStartPoint;
  Offset? _elementStartTranslation;
  double _elementStartRotation = 0.0;
  double _elementStartScale = 1.0;
  Offset? _scaleRefPoint;

  void _resetCenter() {
    _transformController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _closeStyleMenu();
    _transformController.dispose();
    super.dispose();
  }

  void _closeStyleMenu() {
    _styleOverlayEntry?.remove();
    _styleOverlayEntry = null;
  }

  void _openStyleMenu(StylePopoverMode mode, LayerLink link, CanvasState state) {
    _closeStyleMenu();
    final canvasBloc = context.read<CanvasBloc>();
    _styleOverlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeStyleMenu,
            ),
          ),
          CompositedTransformFollower(
            link: link,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -16),
            child: Material(
              color: Colors.transparent,
              child: StylePopover(
                mode: mode,
                currentWidth: _selectedElement != null
                    ? (_selectedElement!.strokeWidth ?? 3.0)
                    : state.currentStrokeWidth,
                currentColor: _selectedElement != null
                    ? Color(_selectedElement!.colorValue ?? 0xFF000000)
                    : state.currentColor,
                onWidthChanged: (val) {
                  if (_selectedElement != null) {
                    setState(() {
                      _selectedElement!.strokeWidth = val;
                    });
                    canvasBloc.add(
                        ElementUpdated(_selectedElementIndex, _selectedElement!));
                  } else {
                    canvasBloc.add(
                        StrokePropertiesChanged(width: val));
                  }
                },
                onColorChanged: (val) {
                  if (_selectedElement != null) {
                    setState(() {
                      _selectedElement!.colorValue = val.value;
                    });
                    canvasBloc.add(
                        ElementUpdated(_selectedElementIndex, _selectedElement!));
                  } else {
                    canvasBloc.add(
                        StrokePropertiesChanged(color: val));
                  }
                  _closeStyleMenu();
                },
                currentFontSize: _selectedElement?.fontSize ?? 20.0,
                currentFontFamily: _selectedElement?.fontFamily ?? 'Roboto',
                isBold: _selectedElement?.isBold ?? false,
                onFontSizeChanged: (val) {
                  if (_selectedElement != null) {
                    setState(() {
                      _selectedElement!.fontSize = val;
                    });
                    canvasBloc.add(
                        ElementUpdated(_selectedElementIndex, _selectedElement!));
                  }
                },
                onFontFamilyChanged: (val) {
                  if (_selectedElement != null) {
                    setState(() {
                      _selectedElement!.fontFamily = val;
                    });
                    canvasBloc.add(
                        ElementUpdated(_selectedElementIndex, _selectedElement!));
                  }
                },
                onBoldChanged: (val) {
                  if (_selectedElement != null) {
                    setState(() {
                      _selectedElement!.isBold = val;
                    });
                    canvasBloc.add(
                        ElementUpdated(_selectedElementIndex, _selectedElement!));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_styleOverlayEntry!);
  }

  void _showTextInputDialog(
      BuildContext context, Offset position, CanvasState state) {
    final canvasBloc = context.read<CanvasBloc>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gõ văn bản'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập nội dung...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final textElement = CanvasElement()
                  ..type = ElementType.text
                  ..textContent = text
                  ..colorValue = state.currentColor.value
                  ..fontSize = 20.0
                  ..fontFamily = 'Roboto'
                  ..isBold = false
                  ..boundingLeft = position.dx
                  ..boundingTop = position.dy
                  ..boundingRight = position.dx + 120.0
                  ..boundingBottom = position.dy + 30.0;

                canvasBloc.add(ElementAdded(textElement));
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  CanvasElement? _hitTest(Offset tapPos, List<CanvasElement> elements) {
    for (int i = elements.length - 1; i >= 0; i--) {
      final el = elements[i];
      final rect = getElementBoundingBox(el);
      final tx = el.translationX ?? 0.0;
      final ty = el.translationY ?? 0.0;
      final rotatedRect = rect.translate(tx, ty);
      final hitBox = rotatedRect.inflate(20.0);
      if (hitBox.contains(tapPos)) {
        return el;
      }
    }
    return null;
  }

  void _toggleShapeMenu() {
    if (_isMenuOpen) {
      _closeShapeMenu();
    } else {
      _openShapeMenu();
    }
  }

  void _closeShapeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isMenuOpen = false);
  }

  void _openShapeMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuOpen = true);
  }

  OverlayEntry _createOverlayEntry() {
    final canvasBloc = context.read<CanvasBloc>();

    return OverlayEntry(
      builder: (context) => BlocProvider.value(
        value: canvasBloc,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeShapeMenu,
              ),
            ),
            CompositedTransformFollower(
              link: _shapeMenuLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              offset: const Offset(0, -16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: ShapePickerMenu(onClose: _closeShapeMenu),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Nền xám nhạt như UI hiện đại
      body: SafeArea(
        child: Stack(
          children: [
            // Lớp Canvas
            _buildCanvasArea(),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.house_fill,
                    color: Colors.black87,
                  ),
                  onPressed: () async {
                    final state = context.read<CanvasBloc>().state;

                    // Nếu canvas có dữ liệu, thực hiện Auto-save dạng nháp
                    if (state.elements.isNotEmpty) {
                      // Giả sử bạn tạo hàm saveDraft trong IsarDataSource
                      await sl<IsarDataSource>().saveDraft(
                        'Bản nháp tự động',
                        state.elements,
                      );
                    }

                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            // Lớp Toolbar nổi
            _buildFloatingToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    final screenSize = MediaQuery.of(context).size;
    final canvasWidth = screenSize.width * 8;
    final canvasHeight = screenSize.height * 6;

    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, state) {
        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.20,
          maxScale: 10.0,
          boundaryMargin: EdgeInsets.symmetric(
            horizontal: canvasWidth / 2,
            vertical: canvasHeight / 2,
          ),
          constrained: false,

          // CẤU HÌNH GESTURE CHUẨN: Tắt kéo 1 ngón, bật Zoom+Kéo 2 ngón
          panEnabled: false,
          scaleEnabled: true,

          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            // SỬ DỤNG LISTENER THAY CHO GESTURE DETECTOR
            child: Listener(
              onPointerDown: (event) {
                _pointerCount++;
                if (_pointerCount == 1) {
                  _activePointerId = event.pointer;
                  setState(() {
                    if (state.currentTool == ElementType.freehand) {
                      _activeStroke = DrawStroke(
                        points: [
                          DrawPoint(
                            x: event.localPosition.dx,
                            y: event.localPosition.dy,
                          ),
                        ],
                        color: state.currentColor,
                        strokeWidth: state.currentStrokeWidth,
                      );
                    } else if (state.currentTool == ElementType.shape) {
                      _shapeStart = event.localPosition;
                      _shapeEnd = event.localPosition;
                    } else if (state.currentTool == ElementType.text) {
                      _showTextInputDialog(context, event.localPosition, state);
                    } else if (state.currentTool == ElementType.select) {
                      if (_selectedElement != null) {
                        final rect = getElementBoundingBox(_selectedElement!);
                        final tx = _selectedElement!.translationX ?? 0.0;
                        final ty = _selectedElement!.translationY ?? 0.0;
                        final rotated = _selectedElement!.rotationAngle ?? 0.0;
                        final scaled = _selectedElement!.scale ?? 1.0;
                        final cx = rect.center.dx;
                        final cy = rect.center.dy;

                        Offset transformOffset(Offset pt) {
                          final localPt = pt - Offset(cx, cy);
                          final scaledPt = localPt * scaled;
                          final rotatedX =
                              scaledPt.dx * math.cos(rotated) -
                              scaledPt.dy * math.sin(rotated);
                          final rotatedY =
                              scaledPt.dx * math.sin(rotated) +
                              scaledPt.dy * math.cos(rotated);
                          return Offset(rotatedX, rotatedY) +
                              Offset(cx, cy) +
                              Offset(tx, ty);
                        }

                        final inflated = rect.inflate(4.0);
                        final topLeft = transformOffset(inflated.topLeft);
                        final topRight = transformOffset(inflated.topRight);
                        final bottomLeft = transformOffset(inflated.bottomLeft);
                        final bottomRight = transformOffset(
                          inflated.bottomRight,
                        );
                        final rotHandle = transformOffset(
                          Offset(inflated.center.dx, inflated.top - 20.0),
                        );

                        if ((event.localPosition - rotHandle).distance < 12.0) {
                          _manipulationMode = 'rotate';
                          _dragStartPoint = event.localPosition;
                          _elementStartRotation =
                              _selectedElement!.rotationAngle ?? 0.0;
                        } else if ((event.localPosition - topLeft).distance <
                                12.0 ||
                            (event.localPosition - topRight).distance < 12.0 ||
                            (event.localPosition - bottomLeft).distance <
                                12.0 ||
                            (event.localPosition - bottomRight).distance <
                                12.0) {
                          _manipulationMode = 'scale';
                          _dragStartPoint = event.localPosition;
                          _elementStartScale = _selectedElement!.scale ?? 1.0;
                          _scaleRefPoint = Offset(cx + tx, cy + ty);
                        } else {
                          final hitRect = rect.translate(tx, ty).inflate(15.0);
                          if (hitRect.contains(event.localPosition)) {
                            _manipulationMode = 'move';
                            _dragStartPoint = event.localPosition;
                            _elementStartTranslation = Offset(tx, ty);
                          } else {
                            final hit = _hitTest(
                              event.localPosition,
                              state.elements,
                            );
                            if (hit != null) {
                              _selectedElement = hit;
                              _selectedElementIndex = state.elements.indexOf(
                                hit,
                              );
                              _manipulationMode = 'move';
                              _dragStartPoint = event.localPosition;
                              _elementStartTranslation = Offset(
                                hit.translationX ?? 0.0,
                                hit.translationY ?? 0.0,
                              );
                            } else {
                              _selectedElement = null;
                              _selectedElementIndex = -1;
                              _manipulationMode = 'none';
                            }
                          }
                        }
                      } else {
                        final hit = _hitTest(
                          event.localPosition,
                          state.elements,
                        );
                        if (hit != null) {
                          _selectedElement = hit;
                          _selectedElementIndex = state.elements.indexOf(hit);
                          _manipulationMode = 'move';
                          _dragStartPoint = event.localPosition;
                          _elementStartTranslation = Offset(
                            hit.translationX ?? 0.0,
                            hit.translationY ?? 0.0,
                          );
                        } else {
                          _selectedElement = null;
                          _selectedElementIndex = -1;
                          _manipulationMode = 'none';
                        }
                      }
                    }
                  });
                } else {
                  setState(() {
                    _activeStroke = null;
                    _shapeStart = null;
                    _shapeEnd = null;
                  });
                }
              },
              onPointerMove: (event) {
                if (_pointerCount == 1 && event.pointer == _activePointerId) {
                  setState(() {
                    if (state.currentTool == ElementType.freehand &&
                        _activeStroke != null) {
                      _activeStroke!.addPoint(
                        DrawPoint(
                          x: event.localPosition.dx,
                          y: event.localPosition.dy,
                        ),
                      );
                    } else if (state.currentTool == ElementType.shape &&
                        _shapeStart != null) {
                      _shapeEnd = event.localPosition;
                    } else if (state.currentTool == ElementType.select &&
                        _selectedElement != null &&
                        _dragStartPoint != null) {
                      final delta = event.localPosition - _dragStartPoint!;
                      if (_manipulationMode == 'move' &&
                          _elementStartTranslation != null) {
                        _selectedElement!.translationX =
                            _elementStartTranslation!.dx + delta.dx;
                        _selectedElement!.translationY =
                            _elementStartTranslation!.dy + delta.dy;
                      } else if (_manipulationMode == 'rotate') {
                        final rect = getElementBoundingBox(_selectedElement!);
                        final cx =
                            rect.center.dx +
                            (_selectedElement!.translationX ?? 0.0);
                        final cy =
                            rect.center.dy +
                            (_selectedElement!.translationY ?? 0.0);

                        final angleStart = math.atan2(
                          _dragStartPoint!.dy - cy,
                          _dragStartPoint!.dx - cx,
                        );
                        final angleCurrent = math.atan2(
                          event.localPosition.dy - cy,
                          event.localPosition.dx - cx,
                        );
                        _selectedElement!.rotationAngle =
                            _elementStartRotation +
                            (angleCurrent - angleStart);
                      } else if (_manipulationMode == 'scale' &&
                          _scaleRefPoint != null) {
                        final distStart =
                            (_dragStartPoint! - _scaleRefPoint!).distance;
                        final distCurrent =
                            (event.localPosition - _scaleRefPoint!).distance;
                        if (distStart > 5.0) {
                          _selectedElement!.scale =
                              _elementStartScale * (distCurrent / distStart);
                        }
                      }
                    }
                  });
                }
              },
              onPointerUp: (event) {
                _pointerCount--;
                if (event.pointer == _activePointerId) {
                  if (_activeStroke != null &&
                      state.currentTool == ElementType.freehand) {
                    final element = _activeStroke!.toIsarElement();
                    // Đặt độ dày và màu mặc định cho vẽ tay tự do
                    element.strokeWidth = state.currentStrokeWidth;
                    element.colorValue = state.currentColor.value;

                    context.read<CanvasBloc>().add(ElementAdded(element));
                    setState(() => _activeStroke = null);
                  } else if (_shapeStart != null &&
                      _shapeEnd != null &&
                      state.currentTool == ElementType.shape) {
                    final shapeElement = CanvasElement()
                      ..type = ElementType.shape
                      ..shapeType = state.currentShapeType
                      ..colorValue = state.currentColor.value
                      ..strokeWidth = state.currentStrokeWidth
                      ..boundingLeft = _shapeStart!.dx
                      ..boundingTop = _shapeStart!.dy
                      ..boundingRight = _shapeEnd!.dx
                      ..boundingBottom = _shapeEnd!.dy;

                    context.read<CanvasBloc>().add(ElementAdded(shapeElement));
                    setState(() {
                      _shapeStart = null;
                      _shapeEnd = null;
                    });
                  } else if (state.currentTool == ElementType.select &&
                      _selectedElement != null &&
                      _manipulationMode != 'none') {
                    context.read<CanvasBloc>().add(
                      ElementUpdated(_selectedElementIndex, _selectedElement!),
                    );
                    setState(() {
                      _manipulationMode = 'none';
                      _dragStartPoint = null;
                    });
                  }
                  _activePointerId = -1;
                }
              },
              onPointerCancel: (event) {
                _pointerCount--;
                if (event.pointer == _activePointerId) {
                  setState(() {
                    _activeStroke = null;
                    _shapeStart = null;
                    _shapeEnd = null;
                    _activePointerId = -1;
                  });
                }
              },

              // 2 LỚP CUSTOM PAINT ĐỂ ĐẢM BẢO HIỆU NĂNG MƯỢT MÀ
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(canvasWidth, canvasHeight),
                      isComplex: true,
                      willChange: false,
                      painter: HistoryCanvasPainter(
                        elements: state.elements,
                        selectedElement: _selectedElement,
                        isSelectMode: state.currentTool == ElementType.select,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: Size(canvasWidth, canvasHeight),
                    painter: ActiveCanvasPainter(
                      activeStroke: _activeStroke,
                      shapeStart: _shapeStart,
                      shapeEnd: _shapeEnd,
                      activeShapeType: state.currentShapeType,
                      currentColor: state.currentColor,
                      currentStrokeWidth: state.currentStrokeWidth,
                      selectedElement: _selectedElement,
                      selectedIndex: _selectedElementIndex,
                      isSelectMode: state.currentTool == ElementType.select,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingToolbar() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: BlocBuilder<CanvasBloc, CanvasState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DÒNG 1: CÁC CÔNG CỤ CHÍNH & THAO TÁC FILE
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.arrow_uturn_left,
                            color: Colors.black87,
                          ),
                          onPressed: () =>
                              context.read<CanvasBloc>().add(UndoRequested()),
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.arrow_uturn_right,
                            color: Colors.black87,
                          ),
                          onPressed: () =>
                              context.read<CanvasBloc>().add(RedoRequested()),
                        ),
                        _buildDivider(),

                        // Freehand
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.pencil,
                            color: state.currentTool == ElementType.freehand
                                ? Colors.blue
                                : Colors.black87,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedElement = null;
                              _selectedElementIndex = -1;
                            });
                            context.read<CanvasBloc>().add(
                              const ToolChanged(ElementType.freehand),
                            );
                          },
                        ),

                        // Shape Picker
                        CompositedTransformTarget(
                          link: _shapeMenuLink,
                          child: IconButton(
                            icon: Icon(
                              state.currentTool == ElementType.shape
                                  ? state.currentShapeType.icon
                                  : CupertinoIcons.rectangle,
                              color: _isMenuOpen ||
                                      state.currentTool == ElementType.shape
                                  ? Colors.blue
                                  : Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedElement = null;
                                _selectedElementIndex = -1;
                              });
                              _toggleShapeMenu();
                            },
                          ),
                        ),

                        // Text tool
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.t_bubble,
                            color: state.currentTool == ElementType.text
                                ? Colors.blue
                                : Colors.black87,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedElement = null;
                              _selectedElementIndex = -1;
                            });
                            context.read<CanvasBloc>().add(
                              const ToolChanged(ElementType.text),
                            );
                          },
                        ),

                        // Object select tool
                        IconButton(
                          icon: Icon(
                            Icons.pan_tool_alt_outlined,
                            color: state.currentTool == ElementType.select
                                ? Colors.blue
                                : Colors.black87,
                          ),
                          onPressed: () {
                            context.read<CanvasBloc>().add(
                              const ToolChanged(ElementType.select),
                            );
                          },
                        ),

                        _buildDivider(),
                        // Scope center
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.scope,
                            color: Colors.black87,
                          ),
                          onPressed: _resetCenter,
                        ),
                        // Save
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.square_arrow_down,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            final state = context.read<CanvasBloc>().state;
                            if (state.elements.isEmpty) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang lưu bản vẽ...'),
                              ),
                            );

                            _currentDocumentId =
                                await sl<IsarDataSource>().saveFile(
                              'Bản vẽ chưa đặt tên',
                              state.elements,
                              documentId: _currentDocumentId,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu thành công!'),
                                ),
                              );
                            }
                          },
                        ),
                        // Clear
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.trash,
                            color: CupertinoColors.destructiveRed,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedElement = null;
                              _selectedElementIndex = -1;
                            });
                            context.read<CanvasBloc>().add(CanvasCleared());
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DÒNG 2: CẤU HÌNH THUỘC TÍNH CHI TIẾT
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildSubToolbarItems(state),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  List<Widget> _buildSubToolbarItems(CanvasState state) {
    if (state.currentTool == ElementType.freehand ||
        state.currentTool == ElementType.shape) {
      return [
        // Thickness
        CompositedTransformTarget(
          link: _widthLink,
          child: TextButton.icon(
            onPressed: () => _openStyleMenu(
              StylePopoverMode.strokeWidth,
              _widthLink,
              state,
            ),
            icon: const Icon(Icons.line_weight, size: 18),
            label: Text('${state.currentStrokeWidth.toInt()}px'),
          ),
        ),
        _buildDivider(),
        // Color
        CompositedTransformTarget(
          link: _colorLink,
          child: InkWell(
            onTap: () => _openStyleMenu(
              StylePopoverMode.strokeColor,
              _colorLink,
              state,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: state.currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Màu nét', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ];
    } else if (state.currentTool == ElementType.text) {
      return [
        // Color
        CompositedTransformTarget(
          link: _colorLink,
          child: InkWell(
            onTap: () => _openStyleMenu(
              StylePopoverMode.strokeColor,
              _colorLink,
              state,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: state.currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Màu chữ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ];
    } else if (state.currentTool == ElementType.select) {
      if (_selectedElement != null) {
        final List<Widget> items = [];
        final typeStr = _selectedElement!.type == ElementType.text
            ? 'Văn bản'
            : (_selectedElement!.type == ElementType.shape
                ? 'Hình khối'
                : 'Nét vẽ');

        items.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$typeStr được chọn',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ));
        items.add(_buildDivider());

        // Delete button
        items.add(IconButton(
          icon: const Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
          onPressed: () {
            _closeStyleMenu();
            context.read<CanvasBloc>().add(
              ElementDeleted(_selectedElementIndex),
            );
            setState(() {
              _selectedElement = null;
              _selectedElementIndex = -1;
            });
          },
        ));
        items.add(_buildDivider());

        if (_selectedElement!.type == ElementType.freehand ||
            _selectedElement!.type == ElementType.shape) {
          // Thickness
          items.add(CompositedTransformTarget(
            link: _widthLink,
            child: TextButton.icon(
              onPressed: () => _openStyleMenu(
                StylePopoverMode.strokeWidth,
                _widthLink,
                state,
              ),
              icon: const Icon(Icons.line_weight, size: 18),
              label: Text(
                '${(_selectedElement!.strokeWidth ?? 3.0).toInt()}px',
              ),
            ),
          ));
          items.add(_buildDivider());
          // Color
          items.add(CompositedTransformTarget(
            link: _colorLink,
            child: InkWell(
              onTap: () => _openStyleMenu(
                StylePopoverMode.strokeColor,
                _colorLink,
                state,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(_selectedElement!.colorValue ?? 0xFF000000),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Đổi màu', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ));
        } else if (_selectedElement!.type == ElementType.text) {
          // Text format
          items.add(CompositedTransformTarget(
            link: _textStyleLink,
            child: TextButton.icon(
              onPressed: () => _openStyleMenu(
                StylePopoverMode.textStyle,
                _textStyleLink,
                state,
              ),
              icon: const Icon(Icons.font_download_outlined, size: 18),
              label: Text('${(_selectedElement!.fontSize ?? 20.0).toInt()}px'),
            ),
          ));
          items.add(_buildDivider());
          // Color
          items.add(CompositedTransformTarget(
            link: _colorLink,
            child: InkWell(
              onTap: () => _openStyleMenu(
                StylePopoverMode.strokeColor,
                _colorLink,
                state,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(_selectedElement!.colorValue ?? 0xFF000000),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Đổi màu', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ));
        }
        return items;
      } else {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Chọn đối tượng trên canvas để chỉnh sửa',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ];
      }
    }
    return const [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Công cụ không có cấu hình phụ',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    ];
  }
}
