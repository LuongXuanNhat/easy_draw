import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/canvas/canvas_bloc.dart';
import '../../data/datasources/isar_datasource.dart';
import '../../data/models/drawing_document.dart';
import '../../core/di/injection_container.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách bản vẽ'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đã lưu'),
              Tab(text: 'Bản nháp'),
            ],
          ),
          actions: [
            // Nút Quay lại Board (vẽ tiếp bản vẽ trống hoặc bản vẽ hiện hành)
            IconButton(
              icon: const Icon(Icons.draw),
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
              icon: const Icon(Icons.settings_outlined),
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
            _buildDocumentList(_savedDocsFuture),
            _buildDocumentList(_draftDocsFuture),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
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
  }

  Widget _buildDocumentList(Future<List<DrawingDocument>> futureDocs) {
    return FutureBuilder<List<DrawingDocument>>(
      future: futureDocs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu.'));
        }

        final docs = snapshot.data!;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return ListTile(
              leading: Icon(
                doc.isPinned ? Icons.push_pin : Icons.insert_drive_file,
                color: doc.isPinned ? Colors.red : Colors.grey,
              ),
              title: Text(doc.title ?? 'Bản vẽ không tên'),
              subtitle: Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(doc.updatedAt ?? DateTime.now())}',
              ),
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
            );
          },
        );
      },
    );
  }
}
