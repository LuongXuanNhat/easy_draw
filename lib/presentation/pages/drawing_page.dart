import 'package:easy_draw/core/di/injection_container.dart';
import 'package:easy_draw/core/di/utils/shape_icon.dart';
import 'package:easy_draw/data/datasources/isar_datasource.dart';
import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:easy_draw/presentation/pages/home_page.dart';
import 'package:easy_draw/presentation/widgets/app_canvas_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:draw_core/draw_core.dart';
import '../bloc/canvas/canvas_bloc.dart';
import '../bloc/canvas/canvas_event.dart';
import '../bloc/canvas/canvas_state.dart';
import '../../data/mappers/canvas_mapper.dart';

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
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  int? _currentDocumentId;

  // Theo dõi số lượng ngón tay đang chạm màn hình
  int _pointerCount = 0;
  // Lưu lại ID của ngón tay đầu tiên chạm vào (để tránh nhiễu khi vẽ)
  int _activePointerId = -1;

  void _resetCenter() {
    _transformController.value = Matrix4.identity();
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
                // DÙNG BLOCBUILDER ĐỂ CẬP NHẬT TRẠNG THÁI ACTIVE TRONG MENU
                child: BlocBuilder<CanvasBloc, CanvasState>(
                  builder: (context, state) {
                    return Container(
                      width: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: ShapeType.values.length - 1,
                        itemBuilder: (context, index) {
                          final shape = ShapeType.values[index];
                          // Kiểm tra xem hình này có đang được active không
                          final isActive =
                              state.currentTool == ElementType.shape &&
                              state.currentShapeType == shape;

                          return InkWell(
                            onTap: () {
                              canvasBloc.add(ShapeTypeChanged(shape));
                              _closeShapeMenu();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                // Highlight màu nền và viền nếu đang Active
                                color: isActive
                                    ? Colors.blue.withOpacity(0.15)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isActive
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: isActive ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  shape.icon, // Sử dụng extension của bạn
                                  color: isActive
                                      ? Colors.blue
                                      : Colors.black87,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
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
                  // Chỉ vẽ khi có đúng 1 ngón tay chạm màn hình
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
                    }
                  });
                } else {
                  // Ngón thứ 2 chạm vào -> Hủy vẽ ngay lập tức để ưu tiên Zoom/Pan
                  setState(() {
                    _activeStroke = null;
                    _shapeStart = null;
                    _shapeEnd = null;
                  });
                }
              },
              onPointerMove: (event) {
                // Chỉ tiếp tục vẽ nếu vẫn là 1 ngón tay và đúng ngón ban đầu
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
                    }
                  });
                }
              },
              onPointerUp: (event) {
                _pointerCount--;
                if (event.pointer == _activePointerId) {
                  // Hoàn thành và lưu nét vẽ vào Bloc
                  if (_activeStroke != null &&
                      state.currentTool == ElementType.freehand) {
                    final element = _activeStroke!.toIsarElement();
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
                      painter: HistoryCanvasPainter(elements: state.elements),
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
      bottom: 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20,
            ), // Tăng độ bo tròn cho hợp với style Cupertino
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
              return Row(
                mainAxisSize: MainAxisSize.min,
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
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),

                  // NÚT BÚT VẼ TỰ DO (FREEHAND)
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.pencil,
                      // Đổi màu xanh nếu đang là chế độ vẽ tay
                      color: state.currentTool == ElementType.freehand
                          ? Colors.blue
                          : Colors.black87,
                    ),
                    onPressed: () {
                      context.read<CanvasBloc>().add(
                        const ToolChanged(ElementType.freehand),
                      );
                    },
                  ),

                  // NÚT CHỌN HÌNH KHỐI (SHAPE)
                  CompositedTransformTarget(
                    link: _shapeMenuLink,
                    child: IconButton(
                      icon: Icon(
                        state.currentTool == ElementType.shape
                            ? state.currentShapeType.icon
                            : CupertinoIcons.rectangle,
                        // Đổi màu xanh nếu đang mở popover HOẶC đang chọn công cụ vẽ hình
                        color:
                            _isMenuOpen ||
                                state.currentTool == ElementType.shape
                            ? Colors.blue
                            : Colors.black87,
                      ),
                      onPressed: _toggleShapeMenu,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),

                  // Nút Về trung tâm
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.scope,
                      color: Colors.black87,
                    ),
                    onPressed: _resetCenter,
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.square_arrow_down,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      final state = context.read<CanvasBloc>().state;
                      if (state.elements.isEmpty) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang lưu bản vẽ...')),
                      );

                      // Gọi hàm saveFile
                      _currentDocumentId = await sl<IsarDataSource>().saveFile(
                        'Bản vẽ chưa đặt tên',
                        state.elements,
                        documentId: _currentDocumentId, // Lưu đè nếu đã tồn tại
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu thành công!')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.trash,
                      color: CupertinoColors.destructiveRed,
                    ),
                    onPressed: () =>
                        context.read<CanvasBloc>().add(CanvasCleared()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
