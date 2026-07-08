import 'package:flutter/material.dart';

enum StylePopoverMode {
  strokeWidth,
  strokeColor,
  textStyle,
}

class StylePopover extends StatelessWidget {
  final StylePopoverMode mode;
  final double currentWidth;
  final ValueChanged<double>? onWidthChanged;
  final Color currentColor;
  final ValueChanged<Color>? onColorChanged;
  final double currentFontSize;
  final ValueChanged<double>? onFontSizeChanged;
  final String currentFontFamily;
  final ValueChanged<String>? onFontFamilyChanged;
  final bool isBold;
  final ValueChanged<bool>? onBoldChanged;

  const StylePopover({
    super.key,
    required this.mode,
    this.currentWidth = 3.0,
    this.onWidthChanged,
    this.currentColor = Colors.black,
    this.onColorChanged,
    this.currentFontSize = 20.0,
    this.onFontSizeChanged,
    this.currentFontFamily = 'Roboto',
    this.onFontFamilyChanged,
    this.isBold = false,
    this.onBoldChanged,
  });

  static const List<Color> strokeColors = [
    Colors.black,
    Colors.grey,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00E676),
    Color(0xFFFF3D00),
  ];

  static const List<String> fontFamilies = [
    'Roboto',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Arial',
  ];

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case StylePopoverMode.strokeWidth:
        return _buildStrokeWidthLayout();
      case StylePopoverMode.strokeColor:
        return _buildColorPickerLayout();
      case StylePopoverMode.textStyle:
        return _buildTextStyleLayout();
    }
  }

  Widget _buildStrokeWidthLayout() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Độ dày nét vẽ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${currentWidth.toInt()}px',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: currentWidth,
              min: 1.0,
              max: 12.0,
              divisions: 11,
              label: '${currentWidth.toInt()}px',
              onChanged: onWidthChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerLayout() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn màu sắc',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strokeColors.map((color) {
                final isSelected = currentColor.value == color.value;
                return InkWell(
                  onTap: () => onColorChanged?.call(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 3.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStyleLayout() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình văn bản',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Kích thước chữ (Font Size)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cỡ chữ', style: TextStyle(fontSize: 13)),
                Text('${currentFontSize.toInt()}px',
                    style: const TextStyle(fontSize: 13, color: Colors.blue)),
              ],
            ),
            Slider(
              value: currentFontSize,
              min: 12.0,
              max: 72.0,
              divisions: 60,
              onChanged: onFontSizeChanged,
            ),
            const Divider(height: 16),
            // Kiểu chữ Bold & Font family
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Độ đậm', style: TextStyle(fontSize: 13)),
                TextButton.icon(
                  onPressed: () => onBoldChanged?.call(!isBold),
                  icon: Icon(
                    isBold ? Icons.format_bold : Icons.format_bold_outlined,
                    color: isBold ? Colors.blue : Colors.black87,
                  ),
                  label: Text(
                    isBold ? 'Bản đậm' : 'Thường',
                    style: TextStyle(
                      color: isBold ? Colors.blue : Colors.black87,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            const Text('Font chữ', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                shrinkWrap: true,
                children: fontFamilies.map((font) {
                  final isSelected = currentFontFamily == font;
                  return ListTile(
                    dense: true,
                    title: Text(
                      font,
                      style: TextStyle(
                        fontFamily: font,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.blue, size: 16)
                        : null,
                    onTap: () => onFontFamilyChanged?.call(font),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
