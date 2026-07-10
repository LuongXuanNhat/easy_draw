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
import '../widgets/text_entry_popover.dart';
import '../../core/services/app_settings_service.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class DrawingPage extends StatefulWidget {
  final int? documentId;
  const DrawingPage({super.key, this.documentId});

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
  final LayerLink _fillColorLink = LayerLink();
  final LayerLink _indexLink = LayerLink();
 
  // Các GlobalKey để định vị tọa độ nút
  final GlobalKey _widthBtnKey = GlobalKey();
  final GlobalKey _colorBtnKey = GlobalKey();
  final GlobalKey _textStyleBtnKey = GlobalKey();
  final GlobalKey _fillColorBtnKey = GlobalKey();
  final GlobalKey _indexBtnKey = GlobalKey();
  final GlobalKey _canvasBoundaryKey = GlobalKey();

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

  @override
  void initState() {
    super.initState();
    _currentDocumentId = widget.documentId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Nếu canvas đang ở chế độ tối, đặt màu mặc định là trắng
      if (_isDarkCanvas()) {
        context.read<CanvasBloc>().add(
          const StrokePropertiesChanged(color: Colors.white),
        );
      }
      if (_currentDocumentId != null) {
        final elements = await sl<IsarDataSource>().getElementsForDocument(_currentDocumentId!);
        if (mounted) {
          context.read<CanvasBloc>().add(DocumentElementsLoaded(elements));
        }
      }
    });
  }

  void _resetCenter() {
    _transformController.value = Matrix4.identity();
  }

  Offset _screenToCanvas(Offset localPosition) {
    final matrix = _transformController.value;
    final double scale = matrix.getMaxScaleOnAxis();
    final double tx = matrix.entry(0, 3);
    final double ty = matrix.entry(1, 3);
    return Offset(
      (localPosition.dx - tx) / scale,
      (localPosition.dy - ty) / scale,
    );
  }

  /// Kiểm tra xem canvas hiện đang ở chế độ tối không
  bool _isDarkCanvas() {
    final sysB = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return AppSettingsService.instance.settings.isDarkCanvas(sysB);
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

  void _openStyleMenu(StylePopoverMode mode, LayerLink link, GlobalKey buttonKey, CanvasState state) {
    _closeStyleMenu();
    final canvasBloc = context.read<CanvasBloc>();
    _styleOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return BlocBuilder<CanvasBloc, CanvasState>(
          bloc: canvasBloc,
          builder: (context, blocState) {
            double xOffset = 0.0;
            final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final position = renderBox.localToGlobal(Offset.zero);
              final buttonCenterX = position.dx + renderBox.size.width / 2;
              final screenWidth = MediaQuery.of(overlayContext).size.width;

              double popoverWidth = mode == StylePopoverMode.strokeWidth ? 250.0 : 280.0;
              double left = buttonCenterX - popoverWidth / 2;

              double minLeft = 12.0;
              double maxLeft = screenWidth - popoverWidth - 12.0;

              double adjustedLeft = left.clamp(minLeft, maxLeft);
              xOffset = adjustedLeft - (buttonCenterX - popoverWidth / 2);
            }

            final currentWidthVal = _selectedElement != null
                ? (_selectedElement!.strokeWidth ?? 3.0)
                : blocState.currentStrokeWidth;

            final currentColorVal = _selectedElement != null
                ? (link == _fillColorLink
                    ? (_selectedElement!.fillColorValue != null
                        ? Color(_selectedElement!.fillColorValue!)
                        : Colors.transparent)
                    : Color(_selectedElement!.colorValue ?? 0xFF000000))
                : blocState.currentColor;

            return Stack(
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
                  offset: Offset(xOffset, -16),
                  child: Material(
                    color: Colors.transparent,
                    child: StylePopover(
                      mode: mode,
                      currentWidth: currentWidthVal,
                      currentColor: currentColorVal,
                      isDark: _isDarkCanvas(),
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
                        _styleOverlayEntry?.markNeedsBuild();
                      },
                      onColorChanged: (val) {
                        if (_selectedElement != null) {
                          setState(() {
                            if (link == _fillColorLink) {
                              _selectedElement!.fillColorValue = val.value;
                            } else {
                              _selectedElement!.colorValue = val.value;
                            }
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
                        _styleOverlayEntry?.markNeedsBuild();
                      },
                      onFontFamilyChanged: (val) {
                        if (_selectedElement != null) {
                          setState(() {
                            _selectedElement!.fontFamily = val;
                          });
                          canvasBloc.add(
                              ElementUpdated(_selectedElementIndex, _selectedElement!));
                        }
                        _styleOverlayEntry?.markNeedsBuild();
                      },
                      onBoldChanged: (val) {
                        if (_selectedElement != null) {
                          setState(() {
                            _selectedElement!.isBold = val;
                          });
                          canvasBloc.add(
                              ElementUpdated(_selectedElementIndex, _selectedElement!));
                        }
                        _styleOverlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_styleOverlayEntry!);
  }

  void _openTextEntryPopover(
      BuildContext context, Offset canvasPosition, Offset screenPosition, CanvasState state) {
    _closeStyleMenu();
    final canvasBloc = context.read<CanvasBloc>();
    _styleOverlayEntry = OverlayEntry(
      builder: (overlayContext) => TextEntryPopover(
        tapPosition: screenPosition,
        isDark: _isDarkCanvas(),
        onSubmit: (text) {
          final textElement = CanvasElement()
            ..type = ElementType.text
            ..textContent = text
            ..colorValue = state.currentColor.value
            ..fontSize = 20.0
            ..fontFamily = 'Roboto'
            ..isBold = false
            ..boundingLeft = canvasPosition.dx
            ..boundingTop = canvasPosition.dy
            ..boundingRight = canvasPosition.dx + 120.0
            ..boundingBottom = canvasPosition.dy + 30.0;

          canvasBloc.add(ElementAdded(textElement));
          _closeStyleMenu();
        },
        onCancel: _closeStyleMenu,
      ),
    );
    Overlay.of(context).insert(_styleOverlayEntry!);
  }

  /// Mở popover chỉnh sửa text cho object đã có
  void _openEditTextPopover(BuildContext context, CanvasElement element, CanvasState state) {
    _closeStyleMenu();
    final canvasBloc = context.read<CanvasBloc>();
    // Tính vị trí màn hình của element để hiện popover cạnh đó
    final matrix = _transformController.value;
    final double scale = matrix.getMaxScaleOnAxis();
    final double tx = matrix.entry(0, 3);
    final double ty = matrix.entry(1, 3);
    final elTx = element.translationX ?? 0.0;
    final elTy = element.translationY ?? 0.0;
    final elLeft = (element.boundingLeft ?? 0.0) + elTx;
    final elTop = (element.boundingTop ?? 0.0) + elTy;
    final screenX = elLeft * scale + tx;
    final screenY = elTop * scale + ty;
    final screenPos = Offset(screenX, screenY);

    _styleOverlayEntry = OverlayEntry(
      builder: (overlayContext) => TextEntryPopover(
        tapPosition: screenPos,
        initialText: element.textContent ?? '',
        isDark: _isDarkCanvas(),
        onSubmit: (text) {
          setState(() {
            element.textContent = text;
          });
          canvasBloc.add(ElementUpdated(_selectedElementIndex, element));
          _closeStyleMenu();
        },
        onCancel: _closeStyleMenu,
      ),
    );
    Overlay.of(context).insert(_styleOverlayEntry!);
  }

  void _showSaveDialog(BuildContext context, CanvasState state) {
    final defaultTitle = 'Bản vẽ ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}';
    final controller = TextEditingController(text: defaultTitle)
      ..selection = TextSelection(baseOffset: 0, extentOffset: defaultTitle.length);
    final focusNode = FocusNode();

    showDialog(
      context: context,
      barrierColor: Colors.black26, // "mờ màn hình nhẹ nhẹ thôi"
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đặt tên bản vẽ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên bản vẽ...',
            isDense: true,
          ),
          onSubmitted: (val) async {
            final title = val.trim().isNotEmpty ? val.trim() : defaultTitle;
            Navigator.of(dialogContext).pop();
            await _saveDocumentWithTitle(context, title, state.elements);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = controller.text.trim().isNotEmpty ? controller.text.trim() : defaultTitle;
              Navigator.of(dialogContext).pop();
              await _saveDocumentWithTitle(context, title, state.elements);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDocumentWithTitle(BuildContext context, String title, List<CanvasElement> elements) async {
    _currentDocumentId = await sl<IsarDataSource>().saveFile(
      title,
      elements,
      documentId: _currentDocumentId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu thành công: "$title"!'),
        ),
      );
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      _closeStyleMenu();
      await Future.delayed(const Duration(milliseconds: 50));

      final state = context.read<CanvasBloc>().state;
      if (state.elements.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bản vẽ trống, không thể chụp màn hình!')),
          );
        }
        return;
      }

      // Kích thước của khung nhìn (viewport) thực tế trên màn hình
      final viewportSize = MediaQuery.of(context).size;

      // Đọc chất lượng ảnh từ cài đặt người dùng
      final appSettings = AppSettingsService.instance.settings;
      final double hdScale = appSettings.screenshotQualityScale.toDouble();
      final double imageWidth = viewportSize.width * hdScale;
      final double imageHeight = viewportSize.height * hdScale;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Màu nền canvas theo cài đặt người dùng
      final systemBrightness = MediaQuery.of(context).platformBrightness;
      final canvasBgColor = appSettings.resolveCanvasBackground(systemBrightness);
      final bgPaint = Paint()..color = canvasBgColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight), bgPaint);

      // Áp dụng tỉ lệ HD trước, sau đó áp dụng ma trận biến đổi của InteractiveViewer
      canvas.save();
      canvas.scale(hdScale);
      canvas.transform(_transformController.value.storage);

      // Vẽ toàn bộ các đối tượng
      final double canvasWidth = viewportSize.width * 8;
      final double canvasHeight = viewportSize.height * 6;

      for (var el in state.elements) {
        canvas.save();
        applyTransformations(canvas, el);

        if (el.type == ElementType.freehand) {
          final stroke = el.toDrawStroke();
          if (stroke != null) {
            DrawPainter(strokes: [stroke]).paint(canvas, Size(canvasWidth, canvasHeight));
          }
        } else if (el.type == ElementType.shape) {
          paintShapeHelper(
            canvas,
            el.shapeType,
            Offset(el.boundingLeft ?? 0, el.boundingTop ?? 0),
            Offset(el.boundingRight ?? 0, el.boundingBottom ?? 0),
            Color(el.colorValue ?? 0xFF000000),
            el.strokeWidth ?? 3.0,
            fillColor: el.fillColorValue != null ? Color(el.fillColorValue!) : null,
          );
        } else if (el.type == ElementType.text) {
          paintTextHelper(
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
      }

      canvas.restore();

      // Kết xuất hình ảnh HD
      final picture = recorder.endRecording();
      final img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      // Lưu trực tiếp vào Thư viện ảnh (Photos/Gallery) của điện thoại
      await Gal.putImageBytes(
        pngBytes,
        name: 'EasyDraw_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Đã lưu vào bộ sưu tập'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Image.memory(pngBytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ảnh chụp màn hình (HD) đã được lưu thành công vào Thư viện ảnh (Photos/Gallery) trên điện thoại của bạn!',
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp màn hình hoặc quyền lưu ảnh: $e')),
        );
      }
    }
  }

  void _openIndexPopover(LayerLink link, GlobalKey buttonKey, CanvasState state) {
    _closeStyleMenu();
    final canvasBloc = context.read<CanvasBloc>();
    final controller = TextEditingController(text: '${_selectedElementIndex + 1}');
    final focusNode = FocusNode();

    _styleOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        double xOffset = 0.0;
        final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final buttonCenterX = position.dx + renderBox.size.width / 2;
          final screenWidth = MediaQuery.of(overlayContext).size.width;

          double popoverWidth = 200.0;
          double left = buttonCenterX - popoverWidth / 2;

          double minLeft = 12.0;
          double maxLeft = screenWidth - popoverWidth - 12.0;

          double adjustedLeft = left.clamp(minLeft, maxLeft);
          xOffset = adjustedLeft - (buttonCenterX - popoverWidth / 2);
        }

        return Stack(
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
              offset: Offset(xOffset, -16),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thứ tự hiển thị (Z-Index)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              int val = int.tryParse(controller.text) ?? 1;
                              if (val > 1) {
                                val--;
                                controller.text = '$val';
                              }
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              int val = int.tryParse(controller.text) ?? 1;
                              if (val < state.elements.length) {
                                val++;
                                controller.text = '$val';
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            final targetIndexStr = controller.text.trim();
                            final targetVal = int.tryParse(targetIndexStr);
                            if (targetVal != null) {
                              int newIndex = targetVal - 1;
                              newIndex = newIndex.clamp(0, state.elements.length - 1);
                              
                              if (newIndex != _selectedElementIndex) {
                                final elements = List<CanvasElement>.from(state.elements);
                                final item = elements.removeAt(_selectedElementIndex);
                                elements.insert(newIndex, item);
                                
                                canvasBloc.add(ElementsReordered(elements));
                                
                                setState(() {
                                  _selectedElementIndex = newIndex;
                                  _selectedElement = elements[newIndex];
                                });
                              }
                            }
                            _closeStyleMenu();
                          },
                          child: const Text('Áp dụng', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_styleOverlayEntry!);
  }

  CanvasElement? _hitTest(Offset tapPos, List<CanvasElement> elements) {
    final matrix = _transformController.value;
    final double scale = matrix.getMaxScaleOnAxis();

    for (int i = elements.length - 1; i >= 0; i--) {
      final el = elements[i];
      final rect = getElementBoundingBox(el);
      final tx = el.translationX ?? 0.0;
      final ty = el.translationY ?? 0.0;
      final rotatedRect = rect.translate(tx, ty);
      final hitBox = rotatedRect.inflate(20.0 / scale);
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
                child: ShapePickerMenu(
                  onClose: _closeShapeMenu,
                  isDark: _isDarkCanvas(),
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
      resizeToAvoidBottomInset: false,
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

                    if (state.elements.isNotEmpty) {
                      bool isCurrentlyDraft = true;
                      if (_currentDocumentId != null) {
                        final doc = await sl<IsarDataSource>().getDocument(_currentDocumentId!);
                        if (doc != null && doc.isDraft == false) {
                          isCurrentlyDraft = false;
                        }
                      }

                      if (isCurrentlyDraft) {
                        _currentDocumentId = await sl<IsarDataSource>().saveDraft(
                          'Bản nháp tự động',
                          state.elements,
                          documentId: _currentDocumentId,
                        );
                      } else {
                        final doc = await sl<IsarDataSource>().getDocument(_currentDocumentId!);
                        final title = doc?.title ?? 'Bản vẽ đã lưu';
                        _currentDocumentId = await sl<IsarDataSource>().saveFile(
                          title,
                          state.elements,
                          documentId: _currentDocumentId,
                        );
                      }
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
            if (MediaQuery.of(context).viewInsets.bottom == 0)
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
        // Đồng bộ hóa _selectedElement với state của BLoC để tránh sai lệch đối tượng (mismatch reference)
        if (_selectedElementIndex >= 0 &&
            _selectedElementIndex < state.elements.length) {
          _selectedElement = state.elements[_selectedElementIndex];
        }

        final matrix = _transformController.value;
        final double scale = matrix.getMaxScaleOnAxis();

        return RepaintBoundary(
          key: _canvasBoundaryKey,
          child: Listener(
            onPointerDown: (event) {
              _pointerCount++;
              if (_pointerCount == 1) {
                _activePointerId = event.pointer;
                setState(() {
                  final canvasPt = _screenToCanvas(event.localPosition);

                  if (state.currentTool == ElementType.freehand) {
                    _activeStroke = DrawStroke(
                      points: [
                        DrawPoint(
                          x: canvasPt.dx,
                          y: canvasPt.dy,
                        ),
                      ],
                      color: state.currentColor,
                      strokeWidth: state.currentStrokeWidth,
                    );
                  } else if (state.currentTool == ElementType.shape) {
                    _shapeStart = canvasPt;
                    _shapeEnd = canvasPt;
                  } else if (state.currentTool == ElementType.text) {
                    if (_styleOverlayEntry == null) {
                      _openTextEntryPopover(context, canvasPt, event.position, state);
                    }
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

                      // Đo khoảng cách pixel thực tế trên màn hình (nhân với scale của InteractiveViewer)
                      if ((canvasPt - rotHandle).distance * scale < 12.0) {
                        _manipulationMode = 'rotate';
                        _dragStartPoint = canvasPt;
                        _elementStartRotation =
                            _selectedElement!.rotationAngle ?? 0.0;
                      } else if ((canvasPt - topLeft).distance * scale < 12.0 ||
                          (canvasPt - topRight).distance * scale < 12.0 ||
                          (canvasPt - bottomLeft).distance * scale < 12.0 ||
                          (canvasPt - bottomRight).distance * scale < 12.0) {
                        _manipulationMode = 'scale';
                        _dragStartPoint = canvasPt;
                        _elementStartScale = _selectedElement!.scale ?? 1.0;
                        _scaleRefPoint = Offset(cx + tx, cy + ty);
                      } else {
                        // Inflate theo tỉ lệ màn hình
                        final hitRect = rect.translate(tx, ty).inflate(15.0 / scale);
                        if (hitRect.contains(canvasPt)) {
                          _manipulationMode = 'move';
                          _dragStartPoint = canvasPt;
                          _elementStartTranslation = Offset(tx, ty);
                        } else {
                          final hit = _hitTest(
                            canvasPt,
                            state.elements,
                          );
                          if (hit != null) {
                            _selectedElement = hit;
                            _selectedElementIndex = state.elements.indexOf(
                              hit,
                            );
                            _manipulationMode = 'move';
                            _dragStartPoint = canvasPt;
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
                        canvasPt,
                        state.elements,
                      );
                      if (hit != null) {
                        _selectedElement = hit;
                        _selectedElementIndex = state.elements.indexOf(hit);
                        _manipulationMode = 'move';
                        _dragStartPoint = canvasPt;
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
                  final canvasPt = _screenToCanvas(event.localPosition);

                  if (state.currentTool == ElementType.freehand &&
                      _activeStroke != null) {
                    _activeStroke!.addPoint(
                      DrawPoint(
                        x: canvasPt.dx,
                        y: canvasPt.dy,
                      ),
                    );
                  } else if (state.currentTool == ElementType.shape &&
                      _shapeStart != null) {
                    _shapeEnd = canvasPt;
                  } else if (state.currentTool == ElementType.select &&
                      _selectedElement != null &&
                      _dragStartPoint != null) {
                    final delta = canvasPt - _dragStartPoint!;
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
                        canvasPt.dy - cy,
                        canvasPt.dx - cx,
                      );
                      _selectedElement!.rotationAngle =
                          _elementStartRotation +
                          (angleCurrent - angleStart);
                    } else if (_manipulationMode == 'scale' &&
                        _scaleRefPoint != null) {
                      final distStart =
                          (_dragStartPoint! - _scaleRefPoint!).distance;
                      final distCurrent =
                          (canvasPt - _scaleRefPoint!).distance;
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
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.20,
              maxScale: 10.0,
              boundaryMargin: EdgeInsets.symmetric(
                horizontal: canvasWidth / 2,
                vertical: canvasHeight / 2,
              ),
              constrained: false,
              panEnabled: false,
              scaleEnabled: true,
              child: ListenableBuilder(
                listenable: AppSettingsService.instance,
                builder: (context, _) {
                  final sysB = MediaQuery.of(context).platformBrightness;
                  final canvasBg = AppSettingsService.instance.settings
                      .resolveCanvasBackground(sysB);
                  return Container(
                width: canvasWidth,
                height: canvasHeight,
                color: canvasBg,
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
              );
                },
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
        child: ListenableBuilder(
          listenable: AppSettingsService.instance,
          builder: (context, _) {
            final systemBrightness = MediaQuery.of(context).platformBrightness;
            final isDarkToolbar = AppSettingsService.instance.settings.isDarkCanvas(systemBrightness);
            return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkToolbar ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: BlocBuilder<CanvasBloc, CanvasState>(
            builder: (context, state) {
              // ─── Màu toolbar thích nghi theo chế độ bảng vẽ ───
              final systemBrightness = MediaQuery.of(context).platformBrightness;
              final appSettings = AppSettingsService.instance.settings;
              final isDarkCanvas = appSettings.isDarkCanvas(systemBrightness);

              final toolbarIcon = isDarkCanvas ? const Color(0xFFE2E8F0) : Colors.black87;
              final toolbarActiveIcon = isDarkCanvas ? const Color(0xFF60A5FA) : Colors.blue;
              final subToolbarBg = isDarkCanvas ? const Color(0xFF16162A) : Colors.grey.shade50;
              final subToolbarBorder = isDarkCanvas ? const Color(0xFF2D2D44) : Colors.grey.shade200;
              final dividerColor = isDarkCanvas ? const Color(0xFF374151) : Colors.grey.shade300;

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
                          icon: Icon(
                            CupertinoIcons.arrow_uturn_left,
                            color: toolbarIcon,
                          ),
                          onPressed: () =>
                              context.read<CanvasBloc>().add(UndoRequested()),
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.arrow_uturn_right,
                            color: toolbarIcon,
                          ),
                          onPressed: () =>
                              context.read<CanvasBloc>().add(RedoRequested()),
                        ),
                        _buildDivider(color: dividerColor),

                        // Freehand
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.pencil,
                            color: state.currentTool == ElementType.freehand
                                ? toolbarActiveIcon
                                : toolbarIcon,
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
                                  ? toolbarActiveIcon
                                  : toolbarIcon,
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
                                ? toolbarActiveIcon
                                : toolbarIcon,
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
                                ? toolbarActiveIcon
                                : toolbarIcon,
                          ),
                          onPressed: () {
                            context.read<CanvasBloc>().add(
                              const ToolChanged(ElementType.select),
                            );
                          },
                        ),

                        _buildDivider(color: dividerColor),
                        // Scope center
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.scope,
                            color: toolbarIcon,
                          ),
                          onPressed: _resetCenter,
                        ),
                        // Save
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.square_arrow_down,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _showSaveDialog(context, state);
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
                      color: subToolbarBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: subToolbarBorder),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(CupertinoIcons.camera, color: toolbarActiveIcon),
                            tooltip: 'Chụp màn hình',
                            onPressed: _takeScreenshot,
                          ),
                          _buildDivider(color: dividerColor),
                          ..._buildSubToolbarItems(state, toolbarIcon, toolbarActiveIcon, dividerColor),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
          }, // ListenableBuilder builder
        ),
      ),
    );
  }

  Widget _buildDivider({Color? color}) {
    return Container(
      width: 1,
      height: 24,
      color: color ?? Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  List<Widget> _buildSubToolbarItems(CanvasState state, Color iconColor, Color activeColor, Color divColor) {
    if (state.currentTool == ElementType.freehand ||
        state.currentTool == ElementType.shape) {
      return [
        // Thickness
        CompositedTransformTarget(
          key: _widthBtnKey,
          link: _widthLink,
          child: TextButton.icon(
            onPressed: () => _openStyleMenu(
              StylePopoverMode.strokeWidth,
              _widthLink,
              _widthBtnKey,
              state,
            ),
            icon: Icon(Icons.line_weight, size: 18, color: iconColor),
            label: Text('${state.currentStrokeWidth.toInt()}px', style: TextStyle(color: iconColor)),
          ),
        ),
        _buildDivider(color: divColor),
        // Color
        CompositedTransformTarget(
          key: _colorBtnKey,
          link: _colorLink,
          child: InkWell(
            onTap: () => _openStyleMenu(
              StylePopoverMode.strokeColor,
              _colorLink,
              _colorBtnKey,
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
          key: _colorBtnKey,
          link: _colorLink,
          child: InkWell(
            onTap: () => _openStyleMenu(
              StylePopoverMode.strokeColor,
              _colorLink,
              _colorBtnKey,
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
                Text('Màu chữ', style: TextStyle(fontSize: 13, color: iconColor)),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ];
    } else if (state.currentTool == ElementType.select) {
      if (_selectedElement != null) {
        final List<Widget> items = [];

        items.add(CompositedTransformTarget(
          key: _indexBtnKey,
          link: _indexLink,
          child: TextButton.icon(
            onPressed: () => _openIndexPopover(
              _indexLink,
              _indexBtnKey,
              state,
            ),
            icon: Icon(Icons.layers, size: 18, color: activeColor),
            label: Text(
              'Thứ tự: ${_selectedElementIndex + 1}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconColor),
            ),
          ),
        ));
        items.add(_buildDivider(color: divColor));

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
        items.add(_buildDivider(color: divColor));

        // Edit text button — chỉ hiện với text elements
        if (_selectedElement!.type == ElementType.text) {
          items.add(IconButton(
            icon: Icon(Icons.edit_rounded, color: activeColor, size: 20),
            tooltip: 'Sửa văn bản',
            onPressed: () => _openEditTextPopover(context, _selectedElement!, state),
          ));
          items.add(_buildDivider(color: divColor));
        }

        if (_selectedElement!.type == ElementType.freehand ||
            _selectedElement!.type == ElementType.shape) {
          // Thickness
          items.add(CompositedTransformTarget(
            key: _widthBtnKey,
            link: _widthLink,
            child: TextButton.icon(
              onPressed: () => _openStyleMenu(
                StylePopoverMode.strokeWidth,
                _widthLink,
                _widthBtnKey,
                state,
              ),
              icon: Icon(Icons.line_weight, size: 18, color: iconColor),
              label: Text(
                '${(_selectedElement!.strokeWidth ?? 3.0).toInt()}px',
                style: TextStyle(color: iconColor),
              ),
            ),
          ));
          items.add(_buildDivider(color: divColor));
          // Color
          items.add(CompositedTransformTarget(
            key: _colorBtnKey,
            link: _colorLink,
            child: InkWell(
              onTap: () => _openStyleMenu(
                StylePopoverMode.strokeColor,
                _colorLink,
                _colorBtnKey,
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
                  Text('Màu viền', style: TextStyle(fontSize: 13, color: iconColor)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ));

          // Tô màu hình (chỉ cho Shape)
          if (_selectedElement!.type == ElementType.shape) {
            items.add(_buildDivider(color: divColor));
            items.add(CompositedTransformTarget(
              key: _fillColorBtnKey,
              link: _fillColorLink,
              child: InkWell(
                onTap: () => _openStyleMenu(
                  StylePopoverMode.strokeColor,
                  _fillColorLink,
                  _fillColorBtnKey,
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
                        color: _selectedElement!.fillColorValue != null
                            ? Color(_selectedElement!.fillColorValue!)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Tô màu hình', style: TextStyle(fontSize: 13, color: iconColor)),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ));
          }
        } else if (_selectedElement!.type == ElementType.text) {
          // Text format
          items.add(CompositedTransformTarget(
            key: _textStyleBtnKey,
            link: _textStyleLink,
            child: TextButton.icon(
              onPressed: () => _openStyleMenu(
                StylePopoverMode.textStyle,
                _textStyleLink,
                _textStyleBtnKey,
                state,
              ),
              icon: Icon(Icons.font_download_outlined, size: 18, color: iconColor),
              label: Text('${(_selectedElement!.fontSize ?? 20.0).toInt()}px', style: TextStyle(color: iconColor)),
            ),
          ));
          items.add(_buildDivider(color: divColor));
          // Color
          items.add(CompositedTransformTarget(
            key: _colorBtnKey,
            link: _colorLink,
            child: InkWell(
              onTap: () => _openStyleMenu(
                StylePopoverMode.strokeColor,
                _colorLink,
                _colorBtnKey,
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
                  Text('Đổi màu', style: TextStyle(fontSize: 13, color: iconColor)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ));
        }
        return items;
      } else {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Chọn đối tượng trên canvas để chỉnh sửa',
              style: TextStyle(fontSize: 13, color: iconColor.withValues(alpha: 0.6)),
            ),
          ),
        ];
      }
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Công cụ không có cấu hình phụ',
          style: TextStyle(fontSize: 13, color: iconColor.withValues(alpha: 0.6)),
        ),
      ),
    ];
  }
}
