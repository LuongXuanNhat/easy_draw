<div align="center">

# 🎨 Easy Draw

**Ứng dụng vẽ tay đa năng, mượt mà và trực quan — xây dựng bằng Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)](.)
[![Version](https://img.shields.io/badge/Version-1.0.0-green)](.)

</div>

---

## 📖 Giới thiệu

**Easy Draw** là ứng dụng vẽ tay dành cho di động, được xây dựng bằng Flutter theo kiến trúc **Clean Architecture** kết hợp với **BLoC pattern**. Ứng dụng cho phép người dùng vẽ nét tự do, chèn hình học, thêm văn bản, quản lý bản vẽ và xuất ảnh chất lượng cao — tất cả trong một giao diện trực quan và hiện đại.

---

## ✨ Tính năng chính

### 🖌️ Công cụ vẽ

| Công cụ | Mô tả |
|---|---|
| **Nét tự do (Freehand)** | Vẽ bằng tay mượt mà với áp lực và màu sắc tuỳ chỉnh |
| **Hình học (Shape)** | Chèn 50+ hình học qua bộ chọn hình có phân nhóm |
| **Văn bản (Text)** | Thêm và chỉnh sửa chữ trực tiếp trên canvas |
| **Chọn & Thao tác (Select)** | Chọn, di chuyển, xoay, phóng to/thu nhỏ đối tượng |

### 🔷 Thư viện hình học (50+ hình)

Được phân thành 6 nhóm rõ ràng trong bộ chọn hình:

- **Hình học cơ bản** — Hình chữ nhật, hình vuông, hình tròn, tam giác, elip, thoi, hình thang, lục giác, bát giác, thập giác, khối lập phương, hình vành khăn, cung tròn, dây cung, khung, v.v.
- **Đường & Nét vẽ** — Đường thẳng, đường mũi tên, đường cong, nét vẽ tự do, nét nguệch ngoạc
- **Mũi tên khối** — Mũi tên trái/phải/lên/xuống, hai chiều, bốn chiều, chữ U, cong, hình ngũ giác
- **Hộp thoại (Callouts)** — Bong bóng hội thoại kiểu chữ nhật, bo tròn, bầu dục, đám mây, đường thẳng
- **Ngôi sao** — Sao 4, 5, 6 cánh
- **Hình khác** — Trái tim, mặt cười, mặt trăng, mặt trời, đám mây, tia sét, bông hoa, góc gập, biểu tượng cấm, vòng tròn cộng

### 🎯 Thao tác với đối tượng (Select Mode)

Khi ở chế độ **Select**, người dùng có thể:

- **Di chuyển** — Kéo thả đối tượng đến vị trí bất kỳ trên canvas
- **Xoay** — Kéo tay cầm xoay phía trên để quay đối tượng tự do
- **Phóng to/Thu nhỏ** — Kéo các góc bounding box để thay đổi kích thước
- **Xoá đối tượng** — Xoá riêng lẻ từng đối tượng đang chọn
- **Chỉnh sửa văn bản** — Mở popover chỉnh sửa nội dung chữ (chỉ dành cho Text element)
- **Thay đổi thứ tự Z-Index** — Điều chỉnh vị trí hiển thị (lớp trên/dưới) của đối tượng

### 🎨 Tùy chỉnh thuộc tính

- **Màu nét** — Bảng 25 màu được tuyển chọn (kể cả màu trắng cho canvas tối)
- **Độ dày nét** — Slider từ 1px đến 12px
- **Màu viền hình** — Đổi màu stroke của hình geometry/freehand đã chọn
- **Tô màu hình (Fill)** — Tô màu nền bên trong hình geometry
- **Màu chữ** — Đổi màu của text element
- **Cỡ chữ** — Slider từ 12px đến 72px
- **Font chữ** — Chọn trong danh sách: Roboto, Times New Roman, Courier New, Georgia, Arial
- **In đậm** — Bật/tắt kiểu chữ Bold

### ↩️ Undo / Redo (Lịch sử thao tác)

Hệ thống Undo/Redo đầy đủ, hỗ trợ **toàn bộ loại hành động**:

- Thêm nét vẽ / hình học / văn bản mới
- Di chuyển đối tượng
- Xoay đối tượng
- Phóng to / thu nhỏ đối tượng
- Thay đổi màu sắc, độ dày, font, in đậm
- Xoá đối tượng
- Xoá sạch canvas (Clear all)

> Được triển khai bằng **State History Stack** trong `CanvasBloc` — lưu deep copy độc lập tại mỗi snapshot, đảm bảo không mất dữ liệu.

### 🖼️ Xuất ảnh HD (Chụp màn hình)

- Xuất bản vẽ hiện tại thành ảnh PNG và lưu thẳng vào **Thư viện ảnh (Photos/Gallery)** của điện thoại
- **4 mức chất lượng** có thể cấu hình:
  - Thấp (1×) — Dung lượng nhỏ
  - Bình thường (2×) — Cân bằng
  - **Cao (4×)** — Mặc định, khuyến nghị
  - Siêu nét (6×) — Độ phân giải tối đa
- Hiển thị preview ảnh vừa chụp ngay sau khi xuất

### 💾 Lưu & Quản lý bản vẽ

- **Lưu thủ công** — Đặt tên tuỳ ý với tên mặc định theo ngày/giờ
- **Tự động lưu nháp** — Khi thoát khỏi canvas, bản vẽ chưa lưu tự động được lưu vào mục *Bản nháp*
- **Tiếp tục vẽ** — Mở lại bất kỳ bản vẽ đã lưu để tiếp tục chỉnh sửa
- **Xóa sạch canvas** — Nút Clear toàn bộ nội dung trên canvas

### 📋 Màn hình Danh sách bản vẽ (Home)

- **Tab "Đã lưu"** — Hiển thị các bản vẽ đã đặt tên và lưu thủ công, sắp xếp theo thời gian cập nhật
- **Tab "Bản nháp"** — Hiển thị các bản nháp tự động được lưu khi thoát
- Mỗi bản vẽ hiển thị: tên, thời gian cập nhật, biểu tượng ghim
- Bản vẽ được ghim nổi lên đầu danh sách
- Nhanh chóng tạo bản vẽ mới bằng nút **FAB (+)**

### ⚙️ Cài đặt ứng dụng

- **Chất lượng ảnh chụp màn hình** — Chọn trong 4 mức: Thấp / Bình thường / Cao / Siêu nét
- **Màu nền bảng vẽ** — Chọn trong 3 chế độ:
  - Trắng — Nền trắng truyền thống
  - Đen — Dark mode immersive
  - Theo điện thoại — Tự động sáng/tối theo hệ thống
- Thiết lập được lưu vào **SharedPreferences** và áp dụng ngay lập tức

### 🔍 Canvas & Điều hướng

- **Zoom** — Pinch to zoom từ 0.2× đến 10×, hỗ trợ đa điểm chạm
- **Pan** — Kéo để di chuyển khắp canvas rộng (8× chiều rộng, 6× chiều cao màn hình)
- **Reset về trung tâm** — Nút scope đưa canvas về vị trí ban đầu
- Phân tầng render: **HistoryCanvasPainter** (các đối tượng đã lưu) + **ActiveCanvasPainter** (đối tượng đang vẽ) để đảm bảo 60fps

---

## 🏗️ Kiến trúc

```
lib/
├── core/
│   ├── di/               # Dependency Injection (get_it)
│   └── services/         # AppSettingsService (SharedPreferences)
│
├── data/
│   ├── datasources/      # IsarDataSource — CRUD với Isar DB
│   ├── mappers/          # Chuyển đổi CanvasElement ↔ DrawStroke
│   └── models/           # CanvasElement, DrawingDocument (Isar schemas)
│
├── domain/               # (Entities & Repositories — cấu trúc sẵn sàng mở rộng)
│
└── presentation/
    ├── bloc/canvas/      # CanvasBloc, CanvasEvent, CanvasState
    ├── pages/            # DrawingPage, HomePage, SettingsPage
    └── widgets/          # AppCanvasPainter, ShapePickerMenu, StylePopover, TextEntryPopover
```

**Pattern:** Clean Architecture + BLoC (flutter_bloc)  
**Database:** Isar Community (local, embedded)  
**Canvas Engine:** [draw_core](https://github.com/LuongXuanNhat/draw_core) (thư viện riêng)

---

## 📦 Thư viện sử dụng

| Package | Mục đích |
|---|---|
| `flutter_bloc` | State management (BLoC pattern) |
| `equatable` | So sánh state trong BLoC |
| `isar_community` | Cơ sở dữ liệu local |
| `path_provider` | Lấy đường dẫn thư mục hệ thống |
| `draw_core` | Engine vẽ tự do (thư viện riêng) |
| `get_it` | Dependency Injection |
| `gal` | Lưu ảnh vào Gallery/Photos |
| `shared_preferences` | Lưu cài đặt người dùng |
| `intl` | Định dạng ngày giờ |
| `permission_handler` | Quản lý quyền truy cập |

---

## 🚀 Khởi động dự án

```bash
# Cài đặt dependencies
flutter pub get

# Sinh code cho Isar
dart run build_runner build

# Sinh app icon
dart run flutter_launcher_icons

# Chạy ứng dụng
flutter run
```

---

## 📱 Nền tảng hỗ trợ

| Nền tảng | Trạng thái |
|---|---|
| Android | ✅ Hỗ trợ |
| iOS | ✅ Hỗ trợ |
| Web | 🔧 Cấu trúc có sẵn |
| Windows | 🔧 Cấu trúc có sẵn |
| macOS | 🔧 Cấu trúc có sẵn |
| Linux | 🔧 Cấu trúc có sẵn |

---

<div align="center">

**Easy Draw** — Được phát triển bởi [LuongXuanNhat](https://github.com/LuongXuanNhat) • Phiên bản 1.0.0

</div>
