import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum cho chế độ màu nền bảng vẽ
enum CanvasThemeMode {
  white,  // Bảng trắng (mặc định)
  black,  // Bảng đen (immersive dark)
  system, // Theo điện thoại: sáng→trắng, tối→đen
}

/// Model chứa các thiết lập của app
class AppSettings {
  final int screenshotQualityScale; // 1 | 2 | 4 | 6
  final CanvasThemeMode canvasTheme;

  const AppSettings({
    this.screenshotQualityScale = 4,
    this.canvasTheme = CanvasThemeMode.white,
  });

  AppSettings copyWith({
    int? screenshotQualityScale,
    CanvasThemeMode? canvasTheme,
  }) {
    return AppSettings(
      screenshotQualityScale: screenshotQualityScale ?? this.screenshotQualityScale,
      canvasTheme: canvasTheme ?? this.canvasTheme,
    );
  }

  /// Tính màu nền canvas thực tế dựa trên theme và system brightness
  Color resolveCanvasBackground(Brightness systemBrightness) {
    switch (canvasTheme) {
      case CanvasThemeMode.white:
        return Colors.white;
      case CanvasThemeMode.black:
        return const Color(0xFF1A1A1A);
      case CanvasThemeMode.system:
        return systemBrightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white;
    }
  }

  /// Bảng vẽ có đang ở chế độ tối không?
  bool isDarkCanvas(Brightness systemBrightness) {
    switch (canvasTheme) {
      case CanvasThemeMode.white:
        return false;
      case CanvasThemeMode.black:
        return true;
      case CanvasThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }
}

/// Service singleton để đọc/ghi cài đặt, thông báo thay đổi
class AppSettingsService extends ChangeNotifier {
  static const _kQuality = 'screenshot_quality';
  static const _kTheme = 'canvas_theme';

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  AppSettingsService._();

  static AppSettingsService? _instance;
  static AppSettingsService get instance {
    _instance ??= AppSettingsService._();
    return _instance!;
  }

  /// Tải settings từ SharedPreferences khi khởi động
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final quality = prefs.getInt(_kQuality) ?? 4;
    final themeStr = prefs.getString(_kTheme) ?? 'white';
    final theme = CanvasThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => CanvasThemeMode.white,
    );
    _settings = AppSettings(
      screenshotQualityScale: quality,
      canvasTheme: theme,
    );
    notifyListeners();
  }

  Future<void> setScreenshotQuality(int scale) async {
    assert([1, 2, 4, 6].contains(scale));
    _settings = _settings.copyWith(screenshotQualityScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kQuality, scale);
    notifyListeners();
  }

  Future<void> setCanvasTheme(CanvasThemeMode theme) async {
    _settings = _settings.copyWith(canvasTheme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, theme.name);
    notifyListeners();
  }
}
