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
  // ── Dark mode ──────────────────────────────────────────────────────────────
  final bool isDark;

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
    this.isDark = false,
  });

  // 25 màu — thêm trắng ở đầu để dễ dùng trên canvas tối
  static const List<Color> strokeColors = [
    Colors.white,
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

  // ── Màu nền và text theo dark/light ────────────────────────────────────────
  Color get _bgColor => isDark ? const Color(0xFF1E2235) : Colors.white;
  Color get _textColor => isDark ? const Color(0xFFE2E8F0) : Colors.black87;
  Color get _subTextColor => isDark ? const Color(0xFF94A3B8) : Colors.black54;
  Color get _dividerColor => isDark ? const Color(0xFF2D3748) : Colors.grey.shade200;
  Color get _borderColor => isDark ? const Color(0xFF374151) : Colors.grey.shade300;
  Color get _listBgColor => isDark ? const Color(0xFF16182A) : Colors.grey.shade50;

  Widget _buildStrokeWidthLayout() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: _bgColor,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Độ dày nét vẽ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
                ),
                Text(
                  '${currentWidth.toInt()}px',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: Colors.blue,
                activeTrackColor: Colors.blue,
                inactiveTrackColor: isDark ? const Color(0xFF374151) : Colors.grey.shade300,
              ),
              child: Slider(
                value: currentWidth,
                min: 1.0,
                max: 12.0,
                divisions: 11,
                label: '${currentWidth.toInt()}px',
                onChanged: onWidthChanged,
              ),
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
      color: _bgColor,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn màu sắc',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strokeColors.map((color) {
                final isSelected = currentColor.toARGB32() == color.toARGB32();
                // Màu trắng cần viền đậm hơn để nhìn thấy trên nền trắng
                final isWhite = color.toARGB32() == Colors.white.toARGB32();
                return InkWell(
                  onTap: () => onColorChanged?.call(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : (isWhite ? Colors.grey.shade400 : _borderColor),
                        width: isSelected ? 3.0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            // Check trắng trên màu tối, check đen trên màu sáng
                            color: _luminance(color) > 0.5 ? Colors.black87 : Colors.white,
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

  double _luminance(Color c) {
    return (c.r * 0.299 + c.g * 0.587 + c.b * 0.114) / 255.0;
  }

  Widget _buildTextStyleLayout() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: _bgColor,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cấu hình văn bản',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
            ),
            const SizedBox(height: 12),
            // Kích thước chữ (Font Size)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cỡ chữ', style: TextStyle(fontSize: 13, color: _textColor)),
                Text(
                  '${currentFontSize.toInt()}px',
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: Colors.blue,
                activeTrackColor: Colors.blue,
                inactiveTrackColor: isDark ? const Color(0xFF374151) : Colors.grey.shade300,
              ),
              child: Slider(
                value: currentFontSize,
                min: 12.0,
                max: 72.0,
                divisions: 60,
                onChanged: onFontSizeChanged,
              ),
            ),
            Divider(height: 16, color: _dividerColor),
            // Kiểu chữ Bold & Font family
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Độ đậm', style: TextStyle(fontSize: 13, color: _textColor)),
                TextButton.icon(
                  onPressed: () => onBoldChanged?.call(!isBold),
                  icon: Icon(
                    isBold ? Icons.format_bold : Icons.format_bold_outlined,
                    color: isBold ? Colors.blue : _subTextColor,
                  ),
                  label: Text(
                    isBold ? 'Bản đậm' : 'Thường',
                    style: TextStyle(
                      color: isBold ? Colors.blue : _subTextColor,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 16, color: _dividerColor),
            Text('Font chữ', style: TextStyle(fontSize: 13, color: _textColor)),
            const SizedBox(height: 6),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: _listBgColor,
                border: Border.all(color: _borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                shrinkWrap: true,
                children: fontFamilies.map((font) {
                  final isSelected = currentFontFamily == font;
                  return ListTile(
                    dense: true,
                    tileColor: isSelected
                        ? Colors.blue.withValues(alpha: isDark ? 0.2 : 0.08)
                        : null,
                    title: Text(
                      font,
                      style: TextStyle(
                        fontFamily: font,
                        color: _textColor,
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
