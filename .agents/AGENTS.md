# Agent Instructions & Guidelines

## Undo / Redo Stack Behavior
- **Yêu cầu**: Chức năng Undo và Redo phải hỗ trợ quay lại (restore) cho tất cả các loại hành động chỉnh sửa của người dùng trên bảng vẽ, bao gồm:
  - Thêm nét vẽ/hình học mới (`ElementType.freehand`, `ElementType.shape`, `ElementType.text`).
  - Di chuyển (Move/Translate) một đối tượng.
  - Xoay (Rotate) một đối tượng.
  - Phóng to/Thu nhỏ (Scale) một đối tượng.
  - Thay đổi độ dày, màu sắc, font chữ, trạng thái in đậm của đối tượng.
  - Xóa đối tượng (`ElementDeleted`).
  - Xóa sạch canvas (`CanvasCleared`).
- **Giải pháp triển khai**: CanvasBloc phải duy trì lịch sử trạng thái bằng State History Stack (`_undoHistory` và `_redoHistory`), lưu bản sao độc lập (deep copy/clone) của danh sách đối tượng thay vì chỉ xóa/phục hồi nét vẽ cuối cùng.
