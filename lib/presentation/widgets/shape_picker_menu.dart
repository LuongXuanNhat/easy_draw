import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/canvas_element.dart';
import '../../core/di/utils/shape_icon.dart';
import '../bloc/canvas/canvas_bloc.dart';
import '../bloc/canvas/canvas_state.dart';
import '../bloc/canvas/canvas_event.dart';

class ShapePickerMenu extends StatefulWidget {
  final VoidCallback onClose;
  final bool isDark;

  const ShapePickerMenu({
    super.key,
    required this.onClose,
    this.isDark = false,
  });

  @override
  State<ShapePickerMenu> createState() => _ShapePickerMenuState();
}

class _ShapePickerMenuState extends State<ShapePickerMenu> {
  final ScrollController _scrollController = ScrollController();

  static const List<ShapeType> geometryShapes = [
    ShapeType.rectangle,
    ShapeType.roundedRectangle,
    ShapeType.square,
    ShapeType.ellipse,
    ShapeType.circle,
    ShapeType.triangle,
    ShapeType.rightTriangle,
    ShapeType.diamond,
    ShapeType.parallelogram,
    ShapeType.trapezoid,
    ShapeType.pentagon,
    ShapeType.hexagon,
    ShapeType.octagon,
    ShapeType.decagon,
    ShapeType.cross,
    ShapeType.cube,
    ShapeType.frame,
    ShapeType.donut,
    ShapeType.arc,
    ShapeType.chord,
  ];

  static const List<ShapeType> lineShapes = [
    ShapeType.line,
    ShapeType.arrowLine,
    ShapeType.curve,
    ShapeType.freeform,
    ShapeType.scribble,
  ];

  static const List<ShapeType> arrowShapes = [
    ShapeType.arrowRight,
    ShapeType.arrowLeft,
    ShapeType.arrowUp,
    ShapeType.arrowDown,
    ShapeType.arrowLeftRight,
    ShapeType.arrowFourWay,
    ShapeType.arrowUTurn,
    ShapeType.arrowCurved,
    ShapeType.chevron,
    ShapeType.arrowPentagon,
  ];

  static const List<ShapeType> calloutShapes = [
    ShapeType.calloutRectangular,
    ShapeType.calloutRounded,
    ShapeType.calloutOval,
    ShapeType.calloutCloud,
    ShapeType.calloutLine,
  ];

  static const List<ShapeType> starShapes = [
    ShapeType.star4,
    ShapeType.star5,
    ShapeType.star6,
  ];

  static const List<ShapeType> otherShapes = [
    ShapeType.heart,
    ShapeType.smileyFace,
    ShapeType.moon,
    ShapeType.sun,
    ShapeType.cloud,
    ShapeType.lightning,
    ShapeType.flower,
    ShapeType.foldedCorner,
    ShapeType.noSymbol,
    ShapeType.circleWithPlus,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Màu theo theme ─────────────────────────────────────────────────────────
  Color get _bg => widget.isDark ? const Color(0xFF1E2235) : Colors.white;
  Color get _icon => widget.isDark ? const Color(0xFFE2E8F0) : Colors.black87;
  Color get _sectionLabel => widget.isDark ? const Color(0xFF64748B) : Colors.grey.shade600;
  Color get _itemBorder => widget.isDark ? const Color(0xFF374151) : Colors.grey.shade300;
  Color get _divider => widget.isDark ? const Color(0xFF2D3748) : Colors.grey.shade200;

  Widget _buildShapeGrid(
    List<ShapeType> shapes,
    CanvasBloc canvasBloc,
    CanvasState state,
  ) {
    const double spacing = 8.0;
    const int crossAxisCount = 5;
    const double itemWidth =
        (280 - 24 - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: shapes.map((shape) {
        final isActive =
            state.currentTool == ElementType.shape &&
            state.currentShapeType == shape;

        return InkWell(
          onTap: () {
            canvasBloc.add(ShapeTypeChanged(shape));
            widget.onClose();
          },
          child: Container(
            width: itemWidth,
            height: itemWidth,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: Border.all(
                color: isActive ? Colors.blue : _itemBorder,
                width: isActive ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                shape.icon,
                color: isActive ? Colors.blue : _icon,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupSection(
    String title,
    List<ShapeType> shapes,
    CanvasBloc canvasBloc,
    CanvasState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 2.0, left: 2.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _sectionLabel,
            ),
          ),
        ),
        _buildShapeGrid(shapes, canvasBloc, state),
      ],
    );
  }

  Widget _buildGroupDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: _divider, height: 1, thickness: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, state) {
        final canvasBloc = context.read<CanvasBloc>();
        return Container(
          width: 292,
          height: 380,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(right: 8.0, top: 4.0),
              children: [
                _buildGroupSection(
                  'Hình học cơ bản',
                  geometryShapes,
                  canvasBloc,
                  state,
                ),
                _buildGroupDivider(),
                _buildGroupSection(
                  'Đường & Nét vẽ',
                  lineShapes,
                  canvasBloc,
                  state,
                ),
                _buildGroupDivider(),
                _buildGroupSection(
                  'Mũi tên khối',
                  arrowShapes,
                  canvasBloc,
                  state,
                ),
                _buildGroupDivider(),
                _buildGroupSection(
                  'Hộp thoại (Callouts)',
                  calloutShapes,
                  canvasBloc,
                  state,
                ),
                _buildGroupDivider(),
                _buildGroupSection('Ngôi sao', starShapes, canvasBloc, state),
                _buildGroupDivider(),
                _buildGroupSection('Hình khác', otherShapes, canvasBloc, state),
              ],
            ),
          ),
        );
      },
    );
  }
}
