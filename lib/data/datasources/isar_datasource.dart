import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/canvas_element.dart';
import '../models/drawing_document.dart';

class IsarDataSource {
  late Isar isar;

  Future<void> initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        DrawingDocumentSchema,
        CanvasElementSchema,
      ], // Truyền các schema được sinh ra
      directory: dir.path,
    );
  }

  /// Khởi tạo một bản vẽ mới (Document)
  Future<int> createNewDocument(String title) async {
    final doc = DrawingDocument()
      ..title = title
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return await isar.writeTxn(() async {
      return await isar.drawingDocuments.put(doc); // Trả về ID của bản vẽ
    });
  }

  /// Lưu/Cập nhật danh sách nét vẽ của một Document
  Future<void> saveElements(
    int documentId,
    List<CanvasElement> elements,
  ) async {
    await isar.writeTxn(() async {
      // Logic: Xóa các nét vẽ cũ của Document này trước khi lưu bản mới
      // Điều này tránh việc dữ liệu bị rác khi user xóa (Undo/Eraser) các nét vẽ
      await isar.canvasElements
          .filter()
          .documentIdEqualTo(documentId)
          .deleteAll();

      // Gán ID cho toàn bộ phần tử và lưu lại
      for (var el in elements) {
        el.documentId = documentId;
      }
      await isar.canvasElements.putAll(elements);
    });
  }

  /// Lấy toàn bộ nét vẽ của một bản vẽ cụ thể
  Future<List<CanvasElement>> getElementsForDocument(int documentId) async {
    return await isar.canvasElements
        .filter()
        .documentIdEqualTo(documentId)
        .findAll();
  }

  Future<List<DrawingDocument>> getSavedDocuments() async {
    return await isar.drawingDocuments
        .filter()
        .isDraftEqualTo(false) // Chỉ lấy file đã lưu
        .sortByIsPinnedDesc() // Ghim (true) lên đầu
        .thenByUpdatedAtDesc() // Sau đó xếp theo thời gian mới nhất
        .findAll();
  }

  /// Lấy danh sách BẢN NHÁP
  Future<List<DrawingDocument>> getDraftDocuments() async {
    return await isar.drawingDocuments
        .filter()
        .isDraftEqualTo(true)
        .sortByIsPinnedDesc()
        .thenByUpdatedAtDesc()
        .findAll();
  }

  Future<int> _saveDocument(
    String title,
    List<CanvasElement> elements,
    bool isDraft, {
    int? existingId,
  }) async {
    return await isar.writeTxn(() async {
      final doc = DrawingDocument()
        ..id =
            existingId ??
            Isar
                .autoIncrement // Nếu có existingId thì ghi đè, không thì tạo mới
        ..title = title
        ..isDraft = isDraft
        ..updatedAt = DateTime.now();

      // Nếu là tạo mới, set thời gian tạo
      if (existingId == null) {
        doc.createdAt = DateTime.now();
      }

      // Lưu Document và lấy ra ID
      final documentId = await isar.drawingDocuments.put(doc);

      // Xóa các nét vẽ cũ của document này (nếu có)
      await isar.canvasElements
          .filter()
          .documentIdEqualTo(documentId)
          .deleteAll();

      // Gán ID cho các phần tử mới và lưu xuống
      for (var el in elements) {
        el.documentId = documentId;
      }
      await isar.canvasElements.putAll(elements);

      return documentId;
    });
  }

  Future<int> saveFile(
    String title,
    List<CanvasElement> elements, {
    int? documentId,
  }) async {
    return await _saveDocument(title, elements, false, existingId: documentId);
  }

  /// Auto-save (Bản nháp hệ thống tự lưu)
  Future<int> saveDraft(
    String title,
    List<CanvasElement> elements, {
    int? documentId,
  }) async {
    return await _saveDocument(title, elements, true, existingId: documentId);
  }
}
