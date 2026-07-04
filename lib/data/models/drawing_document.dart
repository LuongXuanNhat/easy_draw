import 'package:isar_community/isar.dart';

part 'drawing_document.g.dart';

@collection
class DrawingDocument {
  Id id = Isar.autoIncrement;

  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnailPath;

  // Bạn phải có 2 dòng này
  bool isDraft = true;
  bool isPinned = false;
}
