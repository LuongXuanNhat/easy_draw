# 🎨 EASY DRAW — ROADMAP PHÁT TRIỂN SẢN PHẨM
### Từ "Công cụ vẽ tay" → "All-in-one Note & Draw App" thương mại
**Team:** 3 người | **Thời gian:** 12–15 tháng | **Ngày lập roadmap:** 07/2026

---

## 0. TẦM NHÌN SẢN PHẨM

**Định vị:** Easy Draw đi theo hướng **"Notes + Annotate App"** (giống GoodNotes/Notability nhưng bản địa hoá cho thị trường Việt Nam), tận dụng lợi thế sẵn có: shape library phong phú, canvas engine mượt, kiến trúc Clean Architecture dễ mở rộng.

**Đối tượng người dùng mục tiêu:**
- Học sinh, sinh viên (ghi chú, học bài, làm bài tập trên PDF)
- Giáo viên/giảng viên (giảng bài, annotate tài liệu)
- Dân văn phòng (ghi chú họp, brainstorm, ký/annotate hợp đồng)
- Freelancer thiết kế/sáng tạo nội dung (sketch nhanh, storyboard)

**Mô hình kinh doanh:** Freemium — Free (giới hạn số trang/tài liệu, không cloud sync) + Pro subscription (không giới hạn, AI features, cloud sync, collaboration).

---

## 1. NGUYÊN TẮC TỔ CHỨC ROADMAP

### 1.1. Phân vai trò đề xuất cho 3 người
Vì Flutter cho phép 1 codebase đa nền tảng, đề xuất chia vai trò theo **chức năng** thay vì theo platform:

| Vai trò | Trách nhiệm chính |
|---|---|
| **Dev A — Flutter Core/Canvas Lead** | Canvas engine, rendering, gesture, performance, draw_core, layer system |
| **Dev B — Backend/Platform Lead** | Backend API, database cloud, auth, sync, thanh toán, DevOps |
| **Dev C — Product/Feature & AI Lead** | Tính năng UI/UX, AI integration, tích hợp bên thứ 3, QA, marketing content |

> Cả 3 đều có thể code Flutter chung ở giai đoạn đầu; sự phân chia rõ nét hơn khi có backend riêng (từ Giai đoạn 2).

### 1.2. Nguyên tắc ưu tiên (MoSCoW)
- **Must have** — Không có thì sản phẩm không thể bán
- **Should have** — Tăng giá trị cạnh tranh rõ rệt
- **Could have** — Tính năng làm nổi bật, differentiator
- **Won't have (giai đoạn này)** — Đẹp nhưng để sau, tránh dàn trải

### 1.3. Cấu trúc thời gian
5 giai đoạn, mỗi giai đoạn ~2.5–3 tháng, tổng 13 tháng + 1 buffer tháng cuối.

```
GĐ 0: Nền móng kỹ thuật      (Tháng 1)
GĐ 1: Core Upgrade            (Tháng 2–4)
GĐ 2: Cloud & Account         (Tháng 5–7)
GĐ 3: AI & Collaboration      (Tháng 8–10)
GĐ 4: Monetization & Polish   (Tháng 11–13)
GĐ 5: Launch & Mở rộng        (Tháng 14+)
```

---

## 2. GIAI ĐOẠN 0 — NỀN MÓNG KỸ THUẬT (Tháng 1)

**Mục tiêu:** Chuẩn hoá kiến trúc hiện tại để dễ mở rộng, tránh phải refactor lớn giữa chừng.

### 2.1. Việc cần làm
- [ ] Audit code hiện tại: đánh giá `CanvasElement`, `CanvasBloc`, `IsarDataSource` có dễ mở rộng cho multi-page, layer không
- [ ] Thiết kế lại data model: từ "1 canvas = 1 bản vẽ" → "1 Document = nhiều Page = nhiều Layer = nhiều Element"
- [ ] Chuẩn hoá `domain/` layer (hiện đang để trống — cấu trúc sẵn sàng nhưng chưa dùng) — implement Repository pattern thật sự để tách biệt Isar khỏi business logic (quan trọng để sau này thêm cloud sync không phải sửa lại toàn bộ)
- [ ] Thiết lập CI/CD cơ bản (GitHub Actions): build Android/iOS tự động, chạy test
- [ ] Thiết lập môi trường staging/production tách biệt
- [ ] Chọn & POC (proof of concept) các quyết định kỹ thuật lớn:
  - Backend: Firebase/Supabase (nhanh) vs custom (.NET/Node — tận dụng kinh nghiệm sẵn có) 
  - Realtime collaboration: CRDT (Yjs/Automerge) vs Operational Transform
  - AI: on-device (TFLite) vs cloud API (OpenAI/Gemini/Claude)

### 2.2. Deliverable
- Data model mới (ERD) cho Document/Page/Layer/Element
- Kiến trúc backend đã chốt (kèm lý do lựa chọn)
- CI pipeline chạy được

### 2.3. Phân công
- Dev A: Refactor data model + canvas layer
- Dev B: POC backend, CI/CD, hạ tầng
- Dev C: Competitive research sâu (phân tích GoodNotes, Notability, Xodo, Concepts, Squid) + xác định feature gap cụ thể, viết spec chi tiết cho GĐ1

---

## 3. GIAI ĐOẠN 1 — CORE UPGRADE (Tháng 2–4)

**Mục tiêu:** Biến app từ "vẽ đơn giản" thành "công cụ ghi chú/annotate đầy đủ" — đây là giai đoạn quan trọng nhất vì lấp đầy khoảng trống lớn nhất so với đối thủ.

### 3.1. Must have

| Tính năng | Mô tả chi tiết | Ước lượng effort |
|---|---|---|
| **Import ảnh làm nền** | Chèn ảnh từ thư viện/camera vào canvas làm layer nền, vẽ đè lên trên | 1 tuần |
| **Import PDF làm nền** | Parse PDF (dùng `pdfx`/`syncfusion_flutter_pdfviewer` hoặc render qua `pdf_render`), mỗi trang PDF = 1 page trong Document, cho phép annotate trực tiếp | 3 tuần |
| **Multi-page trong 1 Document** | UI chuyển trang (vuốt/thumbnail sidebar), thêm/xoá/sắp xếp trang | 2 tuần |
| **Layer system thực sự** | Không chỉ z-index — cho phép tạo/xoá/ẩn/hiện/khoá/đổi thứ tự layer, mỗi layer chứa nhiều element | 2 tuần |
| **Xuất PDF** | Xuất toàn bộ Document (nhiều trang) ra file PDF, giữ chất lượng vector nếu có thể | 1.5 tuần |
| **Chia sẻ trực tiếp (Share Sheet)** | Dùng `share_plus` — share ảnh/PDF ngay tới Zalo, Messenger, Mail, Drive | 3 ngày |

### 3.2. Should have

| Tính năng | Mô tả |
|---|---|
| **Đa dạng brush** | Bút chì, marker (nét to, hơi trong suốt), highlighter (tô đè không che chữ), airbrush |
| **Eraser nâng cao** | Tẩy theo object / tẩy theo nét vẽ tự do / tẩy theo vùng (pixel-level cho freehand) |
| **Thước kẻ & công cụ đo** | Ruler ảo xoay được để vẽ đường thẳng chuẩn, compa ảo cho vẽ tròn chính xác |
| **Color picker nâng cao** | HEX/RGB input, gradient, độ trong suốt (opacity slider), lưu bảng màu tuỳ chỉnh (custom palette) |
| **Templates giấy nền** | Giấy kẻ ngang, ô ly, dot grid, storyboard, Cornell notes, mindmap layout — chọn khi tạo trang mới |
| **Snap-to-grid / Magnetic guide** | Căn chỉnh tự động khi kéo thả object gần nhau hoặc gần lưới |

### 3.3. Could have (nếu dư thời gian trong giai đoạn)
- Sticker/emoji picker chèn nhanh
- Text box với auto-resize, alignment (trái/giữa/phải/justify)
- Chèn bảng biểu (table) đơn giản

### 3.4. Phân công
- **Dev A:** Layer system, multi-page canvas engine, brush engine, ruler/compa
- **Dev B:** PDF import/export pipeline, share sheet, templates storage
- **Dev C:** UI/UX cho toàn bộ tính năng trên (thumbnail sidebar, layer panel, color picker UI), QA liên tục

### 3.5. Milestone cuối GĐ1
✅ App có thể: mở PDF → annotate nhiều trang → xuất lại PDF → chia sẻ trực tiếp. Đây là **MVP thương mại tối thiểu** có thể demo cho nhà đầu tư/beta tester.

---

## 4. GIAI ĐOẠN 2 — CLOUD & ACCOUNT SYSTEM (Tháng 5–7)

**Mục tiêu:** Thoát khỏi giới hạn "chỉ lưu local" — điều kiện tiên quyết cho monetization, đa thiết bị, và collaboration sau này.

### 4.1. Must have

| Tính năng | Mô tả |
|---|---|
| **Hệ thống tài khoản** | Đăng ký/đăng nhập (email, Google, Apple Sign-In), quên mật khẩu |
| **Backend API** | REST/GraphQL API cho User, Document, Page — đề xuất dùng .NET (tận dụng kinh nghiệm sẵn có của team) hoặc Supabase nếu ưu tiên tốc độ |
| **Cloud sync** | Đồng bộ Document giữa các thiết bị, xử lý conflict (last-write-wins ban đầu, nâng cấp CRDT ở GĐ3 nếu làm collaboration) |
| **Backup/Restore tự động** | Tự động backup định kỳ, khôi phục khi cài lại app/đổi máy |
| **Quản lý dung lượng** | Giới hạn dung lượng cloud cho tài khoản Free, hiển thị usage |

### 4.2. Should have
- Đăng nhập đa thiết bị đồng thời (session management)
- Thông báo đẩy (push notification) — nhắc nhở, đồng bộ hoàn tất
- Trang quản lý tài khoản (đổi mật khẩu, xoá tài khoản, export toàn bộ dữ liệu — chuẩn bị tuân thủ luật bảo vệ dữ liệu cá nhân)

### 4.3. Hạ tầng đi kèm
- [ ] Thiết lập Firebase/self-hosted analytics (theo dõi hành vi dùng tính năng)
- [ ] Thiết lập error tracking (Sentry/Crashlytics)
- [ ] Chính sách bảo mật & điều khoản sử dụng (Privacy Policy, ToS) — bắt buộc trước khi lên store với tính năng tài khoản

### 4.4. Phân công
- **Dev B:** Toàn bộ backend (auth, API, database cloud, DevOps, bảo mật)
- **Dev A:** Tích hợp sync logic vào Flutter app (offline-first architecture — vẫn phải hoạt động khi mất mạng, sync khi có mạng lại)
- **Dev C:** UI đăng nhập/tài khoản, luồng onboarding, viết chính sách bảo mật, chuẩn bị App Store/Play Store listing

### 4.5. Milestone cuối GĐ2
✅ Người dùng có tài khoản, dữ liệu an toàn trên cloud, dùng được trên nhiều thiết bị. Đây là điểm mốc **sẵn sàng launch bản Beta công khai** (soft launch).

---

## 5. GIAI ĐOẠN 3 — AI & COLLABORATION (Tháng 8–10)

**Mục tiêu:** Đây là giai đoạn tạo ra các tính năng "đắt giá" (signature features) — thứ khiến app khác biệt và có lý do để trả tiền.

### 5.1. Must have (chọn tối thiểu 2–3 tính năng dưới đây làm signature, không cần làm hết)

| Tính năng | Mô tả | Ghi chú kỹ thuật |
|---|---|---|
| **Shape recognition (AI)** | Vẽ tay nguệch ngoạc hình tròn/vuông/tam giác → tự động nhận diện và làm đẹp thành hình chuẩn | Có thể làm on-device bằng heuristic (so khớp đường cong) trước, không cần AI nặng — nhanh và rẻ |
| **Handwriting-to-Text (OCR)** | Chuyển chữ viết tay thành văn bản gõ | Dùng Google ML Kit (on-device, free) cho MVP; nâng cấp API cloud nếu cần độ chính xác cao hơn cho tiếng Việt |
| **Voice note đồng bộ bản vẽ** | Ghi âm khi đang vẽ/note, tua lại nghe đúng đoạn tương ứng với nét vẽ tại thời điểm đó | Tính năng rất được yêu thích ở Notability — độ khó trung bình |
| **AI tóm tắt nội dung ghi chú** | Dùng Claude/GPT API tóm tắt nội dung text đã OCR thành gạch đầu dòng | Cloud API, cần tính chi phí theo request |

### 5.2. Should have

| Tính năng | Mô tả |
|---|---|
| **Collaboration cơ bản (real-time)** | Nhiều người cùng xem/vẽ trên 1 canvas — bắt đầu bằng chế độ "share link xem" trước, sau đó "cùng chỉnh sửa" dùng CRDT (Yjs) |
| **Presentation Mode** | Trình chiếu full-screen, chuyển trang, ẩn toolbar, dùng cho giáo viên/thuyết trình |
| **Laser pointer ảo** | Nét vẽ tạm biến mất sau vài giây — dùng khi trình chiếu |
| **Version history** | Lưu lịch sử các phiên bản của Document qua thời gian (không chỉ undo trong phiên làm việc), cho phép khôi phục về bản cũ |

### 5.3. Could have
- Text-to-Image AI chèn minh hoạ vào canvas
- Widget đếm giờ, spotlight cho giáo viên
- Animation replay (xuất video quá trình vẽ — tính năng viral cho mạng xã hội)

### 5.4. Rủi ro & lưu ý
- **Chi phí AI API:** cần tính toán rate-limit theo gói Free/Pro để tránh cháy chi phí (đây là lý do các tính năng AI nên gắn với Pro subscription ngay từ đầu)
- **Real-time collaboration** là tính năng khó nhất trong toàn bộ roadmap — nếu team cảm thấy quá tải, có thể lùi sang GĐ5, ưu tiên AI features trước vì ROI nhanh hơn

### 5.5. Phân công
- **Dev C:** Lead toàn bộ AI integration (OCR, shape recognition, tóm tắt AI)
- **Dev A:** Voice note sync, presentation mode, animation replay
- **Dev B:** Hạ tầng real-time (WebSocket/CRDT), version history backend

### 5.6. Milestone cuối GĐ3
✅ App có ít nhất 2–3 tính năng AI nổi bật + collaboration cơ bản. Đây là bộ tính năng dùng để **marketing chính** (video demo, so sánh với đối thủ).

---

## 6. GIAI ĐOẠN 4 — MONETIZATION & POLISH (Tháng 11–13)

**Mục tiêu:** Chuẩn hoá để thu tiền thật, tối ưu trải nghiệm, chuẩn bị launch chính thức.

### 6.1. Must have

| Hạng mục | Mô tả |
|---|---|
| **In-app Purchase / Subscription** | Tích hợp `in_app_purchase` (RevenueCat khuyến nghị để quản lý cross-platform dễ hơn), thiết kế gói Free/Pro/Team rõ ràng |
| **Paywall UX** | Màn hình giới thiệu Pro, trial 7 ngày, so sánh tính năng |
| **Onboarding hoàn chỉnh** | Hướng dẫn người dùng mới qua các tính năng chính, tối ưu tỉ lệ giữ chân (retention) |
| **Đa ngôn ngữ (i18n)** | Tối thiểu Tiếng Việt + Tiếng Anh để mở rộng thị trường quốc tế |
| **Tối ưu hiệu năng** | Test trên thiết bị cấu hình thấp, giảm giật lag khi Document nhiều trang/nhiều element |
| **Accessibility cơ bản** | Font size động, contrast, hỗ trợ screen reader ở mức tối thiểu |

### 6.2. Should have
- **Template Marketplace** (mua thêm gói shape/sticker/brush) — nguồn doanh thu phụ
- **Referral program** (mời bạn bè nhận Pro miễn phí có thời hạn)
- **Widget màn hình chính** (iOS/Android) hiển thị bản vẽ gần nhất, tạo nhanh bản vẽ mới
- **Tích hợp xuất sang Notion/Google Drive/OneDrive**

### 6.3. QA & Compliance
- [ ] Kiểm thử bảo mật (đặc biệt vì có tài khoản người dùng + thanh toán)
- [ ] Test đầy đủ trên Android (nhiều hãng máy) và iOS
- [ ] Chuẩn bị hồ sơ App Store Review / Google Play Policy (đặc biệt lưu ý chính sách subscription, chính sách trẻ em nếu học sinh dùng)
- [ ] Load testing cho backend (đặc biệt phần sync và collaboration)

### 6.4. Phân công
- **Dev B:** Backend cho subscription (webhook xác nhận thanh toán, quản lý entitlement)
- **Dev A:** Tối ưu performance, accessibility
- **Dev C:** Paywall UX, onboarding, i18n, chuẩn bị marketing/App Store listing (screenshots, mô tả, video demo)

### 6.5. Milestone cuối GĐ4
✅ App sẵn sàng **launch chính thức** trên App Store & Google Play với mô hình thu phí hoạt động ổn định.

---

## 7. GIAI ĐOẠN 5 — LAUNCH & MỞ RỘNG (Tháng 14+)

**Mục tiêu:** Ra mắt chính thức, thu thập phản hồi, mở rộng nền tảng.

### 7.1. Launch
- [ ] Soft launch tại thị trường Việt Nam trước (đã có sẵn ngôn ngữ + hiểu người dùng)
- [ ] Thu thập feedback, iterate nhanh trong 4–6 tuần đầu
- [ ] Mở rộng ra thị trường Đông Nam Á/quốc tế nếu retention tốt

### 7.2. Mở rộng nền tảng (theo README hiện tại đã có sẵn "cấu trúc" cho các nền tảng này)
- [ ] Hoàn thiện bản **Web** (rất quan trọng — cho phép dùng thử không cần cài app, SEO, chia sẻ dễ dàng)
- [ ] Hoàn thiện bản **Windows/macOS** — nhắm vào dân văn phòng, giáo viên dùng laptop kèm bút cảm ứng/máy tính bảng
- [ ] Đồng bộ trải nghiệm giữa mobile ↔ desktop ↔ web (điểm mạnh lớn nếu làm tốt: vẽ trên điện thoại, tiếp tục sửa trên laptop)

### 7.3. Tính năng nâng cao dài hạn (backlog cho năm 2)
- Real-time collaboration nâng cao (nếu chưa làm ở GĐ3): con trỏ chuột nhiều người, chat trong canvas
- AI nâng cao hơn: tự động vẽ theo mô tả, tự động làm đẹp toàn bộ trang note
- Tích hợp LMS (Google Classroom, Microsoft Teams for Education) cho phân khúc giáo dục
- Bản doanh nghiệp (Team plan): quản lý người dùng, phân quyền, không gian làm việc chung
- Marketplace cho creator bán template/brush riêng (revenue share)

---

## 8. BẢNG TỔNG HỢP THEO THÁNG (Gantt rút gọn)

| Tháng | Giai đoạn | Trọng tâm |
|---|---|---|
| 1 | GĐ0 | Refactor kiến trúc, chọn công nghệ backend/AI, CI/CD |
| 2–4 | GĐ1 | Import ảnh/PDF, multi-page, layer, brush, export PDF, share |
| 5–7 | GĐ2 | Tài khoản, backend, cloud sync, backup |
| 8–10 | GĐ3 | AI (OCR, shape recognition, voice sync), collaboration cơ bản |
| 11–13 | GĐ4 | Subscription, paywall, i18n, tối ưu, QA, compliance |
| 14+ | GĐ5 | Launch chính thức, mở rộng Web/Desktop, backlog năm 2 |

---

## 9. RỦI RO CHÍNH & CÁCH GIẢM THIỂU

| Rủi ro | Mức độ | Giải pháp |
|---|---|---|
| Team 3 người ôm quá nhiều hạng mục (backend + AI + mobile) | Cao | Ưu tiên nghiêm ngặt Must-have trước, sẵn sàng cắt Could-have; cân nhắc thuê ngoài (freelancer) cho phần thiết kế UI/UX hoặc DevOps nếu ngân sách cho phép |
| Chi phí AI API vượt kiểm soát | Trung bình | Giới hạn rate theo gói, ưu tiên on-device AI (ML Kit) trước khi dùng cloud LLM |
| Real-time collaboration quá phức tạp so với năng lực team | Cao | Có thể lược bỏ "cùng edit real-time", chỉ làm "share xem + comment" — vẫn tạo giá trị mà độ phức tạp thấp hơn nhiều |
| PDF rendering/export không ổn định trên các thiết bị | Trung bình | Test sớm và liên tục ở GĐ1, chọn thư viện PDF có cộng đồng lớn, đã kiểm chứng |
| Cạnh tranh với app đã có tên tuổi (GoodNotes, Notability) | Trung bình-Cao | Định vị rõ: "app note/vẽ tối ưu cho người Việt", giá rẻ hơn, hỗ trợ tiếng Việt tốt hơn (OCR, UI, support) |

---

## 10. CHỈ SỐ ĐO LƯỜNG THÀNH CÔNG (KPI theo giai đoạn)

- **GĐ1:** Số bản vẽ trung bình/người dùng, tỷ lệ dùng tính năng PDF import
- **GĐ2:** Tỷ lệ tạo tài khoản, tỷ lệ đồng bộ thành công, crash rate
- **GĐ3:** Tỷ lệ dùng tính năng AI, thời gian sử dụng app trung bình/phiên
- **GĐ4:** Tỷ lệ chuyển đổi Free → Pro (conversion rate), churn rate
- **GĐ5:** MAU (Monthly Active Users), rating trên store, retention D7/D30

---

*Roadmap này là bản sống — nên review lại mỗi 2–3 tháng dựa trên phản hồi thực tế và năng lực team để điều chỉnh độ ưu tiên.*