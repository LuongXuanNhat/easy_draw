import 'package:flutter/material.dart';

class TextEntryPopover extends StatefulWidget {
  final Offset tapPosition; // Vị trí click trên màn hình (global)
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  const TextEntryPopover({
    super.key,
    required this.tapPosition,
    required this.onSubmit,
    required this.onCancel,
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

    const double bubbleWidth = 260.0;
    const double bubbleHeight = 125.0; // Fixed total height for calculations

    // Căn giữa bubble theo trục ngang của điểm click
    double left = widget.tapPosition.dx - bubbleWidth / 2;
    left = left.clamp(12.0, screenWidth - bubbleWidth - 12.0);

    // Tính toán tọa độ X của mũi tên tương đối với bong bóng (bubble)
    double arrowX = widget.tapPosition.dx - left;
    arrowX = arrowX.clamp(12.0, bubbleWidth - 12.0);

    // Quyết định đặt trên hay dưới điểm chạm:
    // Nếu điểm chạm nằm ở nửa dưới của vùng nhìn thấy (visibleHeight) thì đưa lên trên
    final bool placeAbove = widget.tapPosition.dy > (visibleHeight - 100.0);

    double top;
    if (placeAbove) {
      top = widget.tapPosition.dy - bubbleHeight - 12.0;
    } else {
      top = widget.tapPosition.dy + 12.0;
    }

    // Giới hạn trong vùng nhìn thấy
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
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!placeAbove)
                  CustomPaint(
                    size: const Size(bubbleWidth, 10),
                    painter: _ArrowUpPainter(arrowX: arrowX),
                  ),
                Container(
                  width: bubbleWidth,
                  height: bubbleHeight - 10.0, // Trừ đi chiều cao mũi tên (10px)
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
                        decoration: const InputDecoration(
                          hintText: 'Nhập nội dung văn bản...',
                          isDense: true,
                          border: UnderlineInputBorder(),
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
                            child: const Text(
                              'Hủy',
                              style: TextStyle(color: Colors.grey),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                    painter: _ArrowDownPainter(arrowX: arrowX),
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
  _ArrowUpPainter({required this.arrowX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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
  _ArrowDownPainter({required this.arrowX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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
