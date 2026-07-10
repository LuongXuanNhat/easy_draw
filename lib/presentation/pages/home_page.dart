import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/canvas/canvas_bloc.dart';
import '../../data/datasources/isar_datasource.dart';
import '../../data/models/drawing_document.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/app_settings_service.dart';
import 'drawing_page.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DrawingDocument>> _savedDocsFuture;
  late Future<List<DrawingDocument>> _draftDocsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _savedDocsFuture = sl<IsarDataSource>().getSavedDocuments();
    _draftDocsFuture = sl<IsarDataSource>().getDraftDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService.instance,
      builder: (context, _) {
        final sysB = MediaQuery.of(context).platformBrightness;
        final isDark = AppSettingsService.instance.settings.isDarkCanvas(sysB);

        // ── Bảng màu theo chế độ ─────────────────────────────────────────────
        final scaffoldBg = isDark ? const Color(0xFF111827) : null;
        final appBarBg = isDark ? const Color(0xFF1F2937) : null;
        final primaryText = isDark ? Colors.white : Colors.black87;
        final secondaryText = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        final tabIndicator = isDark ? Colors.blue.shade300 : null;
        final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
        final dividerColor = isDark ? const Color(0xFF374151) : Colors.grey.shade200;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              backgroundColor: appBarBg,
              foregroundColor: isDark ? Colors.white : null,
              title: Text('Danh sách bản vẽ', style: TextStyle(color: primaryText)),
              bottom: TabBar(
                labelColor: isDark ? Colors.blue.shade300 : Colors.blue,
                unselectedLabelColor: secondaryText,
                indicatorColor: tabIndicator ?? Colors.blue,
                dividerColor: isDark ? const Color(0xFF374151) : null,
                tabs: const [
                  Tab(text: 'Đã lưu'),
                  Tab(text: 'Bản nháp'),
                ],
              ),
              actions: [
                // Nút vẽ tiếp
                IconButton(
                  icon: Icon(Icons.draw, color: isDark ? Colors.white70 : null),
                  tooltip: 'Vẽ tiếp',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<CanvasBloc>(
                        create: (_) => sl<CanvasBloc>(),
                        child: const DrawingPage(),
                      ),
                    ),
                  ),
                ),
                // Nút Cài đặt
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : null),
                  tooltip: 'Cài đặt',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: TabBarView(
              children: [
                _buildDocumentList(
                  _savedDocsFuture,
                  isDark: isDark,
                  cardBg: cardBg,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  dividerColor: dividerColor,
                ),
                _buildDocumentList(
                  _draftDocsFuture,
                  isDark: isDark,
                  cardBg: cardBg,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  dividerColor: dividerColor,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: isDark ? const Color(0xFF3B82F6) : null,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<CanvasBloc>(
                      create: (_) => sl<CanvasBloc>(),
                      child: const DrawingPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentList(
    Future<List<DrawingDocument>> futureDocs, {
    required bool isDark,
    required Color cardBg,
    required Color primaryText,
    required Color secondaryText,
    required Color dividerColor,
  }) {
    return FutureBuilder<List<DrawingDocument>>(
      future: futureDocs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Chưa có dữ liệu.',
              style: TextStyle(color: secondaryText),
            ),
          );
        }

        final docs = snapshot.data!;
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: dividerColor,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final doc = docs[index];
            return Material(
              color: cardBg,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc.isPinned ? Icons.push_pin : Icons.article_outlined,
                    color: doc.isPinned ? Colors.amber : Colors.blue.shade400,
                    size: 20,
                  ),
                ),
                title: Text(
                  doc.title ?? 'Bản vẽ không tên',
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(doc.updatedAt ?? DateTime.now())}',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: secondaryText, size: 18),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<CanvasBloc>(
                        create: (_) => sl<CanvasBloc>(),
                        child: DrawingPage(documentId: doc.id),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
