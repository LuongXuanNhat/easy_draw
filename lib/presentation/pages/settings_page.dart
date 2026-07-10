import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/app_settings_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        final svc = AppSettingsService.instance;
        final s = svc.settings;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
        final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
        final primaryText = isDark ? Colors.white : const Color(0xFF111827);
        final secondaryText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final dividerColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0,
            title: Text(
              'Cài đặt',
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: Icon(CupertinoIcons.chevron_left, color: primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- NHÓM: Chất lượng ảnh chụp ---
              _SectionHeader(
                icon: CupertinoIcons.camera_fill,
                title: 'Chất lượng ảnh chụp màn hình',
                color: Colors.blue.shade600,
                cardBg: cardBg,
                primaryText: primaryText,
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                cardBg: cardBg,
                dividerColor: dividerColor,
                children: [
                  _QualityTile(
                    label: 'Thấp',
                    description: 'Dung lượng nhỏ, độ nét cơ bản',
                    scale: 1,
                    badge: '1×',
                    badgeColor: Colors.grey.shade500,
                    selected: s.screenshotQualityScale == 1,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setScreenshotQuality(1),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _QualityTile(
                    label: 'Bình thường',
                    description: 'Cân bằng giữa chất lượng và dung lượng',
                    scale: 2,
                    badge: '2×',
                    badgeColor: Colors.green.shade500,
                    selected: s.screenshotQualityScale == 2,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setScreenshotQuality(2),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _QualityTile(
                    label: 'Cao',
                    description: 'Sắc nét cao, khuyến nghị dùng hàng ngày',
                    scale: 4,
                    badge: '4×',
                    badgeColor: Colors.blue.shade500,
                    isDefault: true,
                    selected: s.screenshotQualityScale == 4,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setScreenshotQuality(4),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _QualityTile(
                    label: 'Siêu nét',
                    description: 'Độ phân giải tối đa, dung lượng lớn',
                    scale: 6,
                    badge: '6×',
                    badgeColor: Colors.purple.shade500,
                    selected: s.screenshotQualityScale == 6,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setScreenshotQuality(6),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- NHÓM: Màu bảng vẽ ---
              _SectionHeader(
                icon: CupertinoIcons.paintbrush_fill,
                title: 'Màu bảng vẽ',
                color: Colors.orange.shade600,
                cardBg: cardBg,
                primaryText: primaryText,
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                cardBg: cardBg,
                dividerColor: dividerColor,
                children: [
                  _ThemeTile(
                    label: 'Trắng',
                    description: 'Bảng vẽ màu trắng truyền thống',
                    previewColor: Colors.white,
                    previewBorder: true,
                    theme: CanvasThemeMode.white,
                    selected: s.canvasTheme == CanvasThemeMode.white,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setCanvasTheme(CanvasThemeMode.white),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _ThemeTile(
                    label: 'Đen',
                    description: 'Nền tối, immersive dark mode',
                    previewColor: const Color(0xFF1A1A1A),
                    theme: CanvasThemeMode.black,
                    selected: s.canvasTheme == CanvasThemeMode.black,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setCanvasTheme(CanvasThemeMode.black),
                  ),
                  Divider(height: 1, color: dividerColor),
                  _ThemeTile(
                    label: 'Theo điện thoại',
                    description: 'Tự động theo chế độ sáng/tối hệ thống',
                    previewGradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFF1A1A1A)],
                    ),
                    previewBorder: true,
                    theme: CanvasThemeMode.system,
                    selected: s.canvasTheme == CanvasThemeMode.system,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => svc.setCanvasTheme(CanvasThemeMode.system),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- NHÓM: Về ứng dụng ---
              _SectionHeader(
                icon: CupertinoIcons.info_circle_fill,
                title: 'Về ứng dụng',
                color: Colors.teal.shade600,
                cardBg: cardBg,
                primaryText: primaryText,
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                cardBg: cardBg,
                dividerColor: dividerColor,
                children: [
                  ListTile(
                    leading: Icon(CupertinoIcons.app, color: Colors.teal.shade500, size: 22),
                    title: Text('Easy Draw', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
                    subtitle: Text('Phiên bản 1.0.0', style: TextStyle(color: secondaryText, fontSize: 13)),
                    trailing: Icon(Icons.chevron_right, color: secondaryText, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tiêu đề nhóm ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color cardBg;
  final Color primaryText;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.cardBg,
    required this.primaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card bọc nhóm settings ──────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Color cardBg;
  final Color dividerColor;
  final List<Widget> children;

  const _SettingsCard({
    required this.cardBg,
    required this.dividerColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: children,
      ),
    );
  }
}

// ─── Tile chất lượng ảnh ─────────────────────────────────────────────────────

class _QualityTile extends StatelessWidget {
  final String label;
  final String description;
  final int scale;
  final String badge;
  final Color badgeColor;
  final bool isDefault;
  final bool selected;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onTap;

  const _QualityTile({
    required this.label,
    required this.description,
    required this.scale,
    required this.badge,
    required this.badgeColor,
    this.isDefault = false,
    required this.selected,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Mặc định',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.blue : secondaryText.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile chế độ màu canvas ──────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  final String label;
  final String description;
  final Color? previewColor;
  final Gradient? previewGradient;
  final bool previewBorder;
  final CanvasThemeMode theme;
  final bool selected;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.description,
    this.previewColor,
    this.previewGradient,
    this.previewBorder = false,
    required this.theme,
    required this.selected,
    required this.primaryText,
    required this.secondaryText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: previewColor,
                gradient: previewGradient,
                borderRadius: BorderRadius.circular(10),
                border: previewBorder ? Border.all(color: Colors.grey.shade300, width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: previewGradient != null
                  ? const Icon(Icons.brightness_auto, color: Colors.grey, size: 18)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.blue : secondaryText.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
