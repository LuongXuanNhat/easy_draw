import 'package:flutter/material.dart';

class TextEntryPopover extends StatefulWidget {
  final Offset tapPosition; // Vị trí click trên màn hình (global)
  final String initialText; // Nội dung text ban đầu (để chỉnh sửa)
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  final bool isDark;

  const TextEntryPopover({
    super.key,
    required this.tapPosition,
    this.initialText = '',
    required this.onSubmit,
    required this.onCancel,
    this.isDark = false,
  });

  @override
  State<TextEntryPopover> createState() => _TextEntryPopoverState();
}

class _TextEntryPopoverState extends State<TextEntryPopover> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late DateTime _createdAt;

  @override
  void initState() {
    super.initState();
    _createdAt = DateTime.now();
    // Nếu có text ban đầu, load vào controller và chọn tất cả text
    if (widget.initialText.isNotEmpty) {
      _controller.text = widget.initialText;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialText.length,
      );
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final visibleHeight = screenHeight - keyboardHeight;

    // ── Dark mode colors ──────────────────────────────────────────────────────
    final bubbleBg = widget.isDark ? const Color(0xFF1E2235) : Colors.white;
    final textColor = widget.isDark ? const Color(0xFFE2E8F0) : Colors.black87;
    final hintColor = widget.isDark ? const Color(0xFF64748B) : Colors.grey;
    final borderColor = widget.isDark ? const Color(0xFF374151) : Colors.grey.shade300;

    const double bubbleWidth = 260.0;
    const double bubbleHeight = 125.0;

    double left = widget.tapPosition.dx - bubbleWidth / 2;
    left = left.clamp(12.0, screenWidth - bubbleWidth - 12.0);

    double arrowX = widget.tapPosition.dx - left;
    arrowX = arrowX.clamp(12.0, bubbleWidth - 12.0);

    final bool placeAbove = widget.tapPosition.dy > (visibleHeight - 100.0);

    double top;
    if (placeAbove) {
      top = widget.tapPosition.dy - bubbleHeight - 12.0;
    } else {
      top = widget.tapPosition.dy + 12.0;
    }
    top = top.clamp(12.0, visibleHeight - bubbleHeight - 12.0);

    return Stack(
      children: [
        // Barrier bắt sự kiện tap ra ngoài để đóng
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              final age = DateTime.now().difference(_createdAt);
              if (age.inMilliseconds > 400) {
                widget.onCancel();
              }
            },
          ),
        ),
        // Bong bóng nhập liệu
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: bubbleBg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!placeAbove)
                  CustomPaint(
                    size: const Size(bubbleWidth, 10),
                    painter: _ArrowUpPainter(arrowX: arrowX, color: bubbleBg),
                  ),
                Container(
                  width: bubbleWidth,
                  height: bubbleHeight - 10.0,
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Nhập nội dung văn bản...',
                          hintStyle: TextStyle(color: hintColor),
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        onSubmitted: (val) {
                          final text = val.trim();
                          if (text.isNotEmpty) {
                            widget.onSubmit(text);
                          } else {
                            widget.onCancel();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: widget.onCancel,
                            child: Text(
                              'Hủy',
                              style: TextStyle(color: hintColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                widget.onSubmit(text);
                              } else {
                                widget.onCancel();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (placeAbove)
                  CustomPaint(
                    size: const Size(bubbleWidth, 10),
                    painter: _ArrowDownPainter(arrowX: arrowX, color: bubbleBg),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowUpPainter extends CustomPainter {
  final double arrowX;
  final Color color;
  _ArrowUpPainter({required this.arrowX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(arrowX - 8, size.height);
    path.lineTo(arrowX, size.height - 8);
    path.lineTo(arrowX + 8, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowDownPainter extends CustomPainter {
  final double arrowX;
  final Color color;
  _ArrowDownPainter({required this.arrowX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(arrowX - 8, 0);
    path.lineTo(arrowX, 8);
    path.lineTo(arrowX + 8, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
