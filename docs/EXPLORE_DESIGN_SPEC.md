# ĐẶC TẢ HỆ THỐNG THIẾT KẾ PHÂN HỆ KHÁM PHÁ (EXPLORE DESIGN SPECIFICATION)

> **Dự án:** TRAVEL_APP — Premium Global Travel Discovery Platform  
> **Phong cách chủ đạo:** Premium Outdoor Travel Editorial (Tạp chí Dã ngoại Cao cấp)  
> **Cảm hứng thiết kế:** Airbnb, AllTrails Pro, Komoot, Polarsteps, Apple Fitness  
> **Nguyên tắc thẩm mỹ:** Tinh tế, chân thực, đắm chìm hình ảnh thực địa, phân cấp thị giác nổi bật, không lạm dụng giao diện quân sự/đen tuyền đơn điệu.

---

## 1. HỆ THỐNG BẢNG MÀU (COLOR SYSTEM TOKENS)

Phân hệ Khám phá sử dụng bảng màu **Editorial Outdoor Paper & Canvas**, tạo sự tương phản tách bạch giữa nền dã ngoại mộc mạc và khung thẻ thông tin trắng sứ:

```dart
class AppColors {
  // Nền & Khung Bề mặt (Phân cấp rõ rệt)
  static const Color editorialBg = Color(0xFFEFECE4);           // Nền canvas giấy dã ngoại ấm mộc mạc
  static const Color editorialSurface = Color(0xFFFFFFFF);      // Thẻ trắng tinh khôi nổi bật trên nền giấy
  static const Color editorialSurfaceSubtle = Color(0xFFE5E0D5);// Chip lọc / Ô search / Container con
  static const Color editorialSurfaceAlt = Color(0xFFFAF7F0);   // Nền thẻ biến thể nhẹ nhàng
  
  // Đường viền định hình (Borders)
  static const Color editorialBorder = Color(0xFFD5CEC0);       // Viền rõ nét 1.2px phân định thẻ
  static const Color editorialBorderSubtle = Color(0xFFE2DDD2); // Viền mảnh ngăn cách nội bộ
  
  // Màu chữ & Độ tương phản (Typography Contrast)
  static const Color editorialInk = Color(0xFF17221B);          // Chữ đen mực rừng sâu (WCAG AAA)
  static const Color editorialMuted = Color(0xFF5A685F);        // Chữ phụ, mô tả, chú thích (WCAG AA)
  
  // Màu điểm nhấn thiên nhiên & An toàn
  static const Color editorialPine = Color(0xFF1E3A2B);         // Xanh thông rừng dã ngoại (Primary Brand)
  static const Color editorialTerracotta = Color(0xFFC26D38);   // Đất nung / Cam ấm hoàng hôn (Accent)
  static const Color emergencyRed = Color(0xFFEF4444);          // Đỏ cảnh báo nguy hiểm & cứu hộ
  static const Color summitGold = Color(0xFFFBBF24);            // Vàng biểu tượng nổi bật & di sản
  static const Color alpineCyan = Color(0xFF06B6D4);            // Xanh ngọc suối thác & nguồn nước
}
```

---

## 2. HỆ THỐNG TYPOGRAPHY (TYPOGRAPHY SCALE)

Tuân thủ nguyên tắc phân cấp tạp chí dã ngoại (Editorial Magazine Hierarchy):

| Token Name | Cỡ chữ / Line Height | Font Weight | Letter Spacing | Ngữ cảnh sử dụng |
| :--- | :---: | :---: | :---: | :--- |
| **`editorialHero`** | 28px / 34px | Black (w900) | -0.8px | Tiêu đề chính màn hình Explore, tên đỉnh núi lớn |
| **`titleLarge`** | 22px / 28px | ExtraBold (w800)| -0.5px | Tên điểm đến trên Hero Card & Bento Grid |
| **`titleMedium`** | 17px / 22px | Bold (w700) | -0.3px | Tên cung đường trên thẻ danh sách, tiêu đề phân mục |
| **`titleSmall`** | 14px / 18px | SemiBold (w600)| -0.1px | Tiêu đề chặng trekking, tên tác giả ảnh |
| **`bodyLarge`** | 14px / 22px | Regular (w400) | 0.0px | Đoạn văn tóm tắt biên tập, mô tả lộ trình |
| **`bodyMedium`** | 12px / 16px | Regular (w400) | 0.0px | Mô tả phụ, vị trí địa lý, độ cao tham chiếu |
| **`labelMetric`** | 12px / 14px | Bold (w700) | +0.3px | Số liệu kỹ thuật cự ly, độ cao (55 km, 2,287 m) |
| **`badgeText`** | 10px / 12px | Bold (w800) | +0.5px | Nhãn độ khó, huy hiệu xác minh (UPPERCASE) |

---

## 3. HỆ THỐNG KHOẢNG CÁCH & BO GÓC (SPACING & RADII)

- **Hệ thống khoảng cách 8-Point Grid:**
  - `space4` (4px): Khoảng cách giữa icon và nhãn text.
  - `space8` (8px): Khoảng cách giữa các chip bộ lọc, khoảng đệm trong badge nhỏ.
  - `space12` (12px): Đệm trong các thẻ danh sách compact.
  - `space16` (16px): Lề chuẩn hai bên màn hình (Standard Horizontal Inset).
  - `space20` (20px): Khoảng cách giữa các Card lớn.
  - `space24` (24px): Khoảng cách giữa các phân đoạn chính (Sections).
  - `space32` (32px): Khoảng đệm phân cách Hero.
- **Hệ thống bo góc (Concentric Radii):**
  - `radiusSm` (8px): Badge thông số kỹ thuật, ô chỉ số an toàn.
  - `radiusMd` (14px): Nút bấm, thanh tìm kiếm, filter chip.
  - `radiusLg` (20px): Card điểm đến chính, Bento Grid container.
  - `radiusXl` (28px): Khung ảnh Hero lớn, Bottom Sheet kéo trượt.
  - `radiusPill` (999px): Segmented Bar Trong Nước/Quốc Tế, viên thuốc thời tiết.

---

## 4. BỐ CỤC PHÂN TẦNG THỊ GIÁC (VISUAL HIERARCHY & LAYOUT)

```
┌────────────────────────────────────────────────────────┐
│ [ Header: Vị trí hiện tại • Thời tiết GPS vi khí hậu ] │
│ Tiêu đề: Khám Phá & Dã Ngoại                          │
│                                                        │
│ [== TRONG NƯỚC (VIỆT NAM) ==] [   QUỐC TẾ (THẾ GIỚI)  ] │ <- Segmented Bar
│                                                        │
│ (Tất cả) (Miền Bắc) (Miền Trung) (Tây Nguyên) (Miền Nam) <- Region Filter Chips
│                                                        │
│ [ Thanh Tìm Kiếm & Lọc Độ Khó: Dễ / Vừa / Khó / Cực ]   │
│                                                        │
│ [ Chip Danh mục: Trekking / Cắm Trại / Thác / Đèo... ] │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ HERO CARD TRUYỀN CẢM HỨNG (Ảnh thực địa + Tóm tắt) │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ BENTO GRID SPOTLIGHT (Đa dạng kích cỡ thẻ 2x1, 1x1)     │
│                                                        │
│ DANH SÁCH CUNG ĐƯỜNG DÃ NGOẠI (Compact Trail Rows)     │
└────────────────────────────────────────────────────────┘
```

### 4.1. Thanh Chuyển Vùng Lớn (Segmented Control: Trong Nước / Quốc Tế)
- Vị trí nổi bật ngay dưới tiêu đề chính.
- Nền `editorialSurfaceSubtle`, con trượt màu trắng `editorialSurface` có đổ bóng nhẹ và viền `editorialBorder`.
- Chuyển tab mượt mà với animation thời gian 220ms, phản hồi rung nhẹ (`HapticFeedback.selectionClick()`).

### 4.2. Bộ lọc Vùng Miền / Châu Lục (Region Filter Chips)
- **Khi chọn "Trong Nước":** Hiển thị 5 vùng miền Việt Nam:
  - *Tất cả*, *Miền Bắc*, *Miền Trung*, *Tây Nguyên*, *Miền Nam*, *Tây Nam Bộ*.
- **Khi chọn "Quốc Tế":** Hiển thị 6 châu lục toàn cầu:
  - *Tất cả*, *Châu Á*, *Châu Âu*, *Bắc Mỹ*, *Nam Mỹ*, *Châu Đại Dương*, *Châu Phi*.
- Chip cuộn ngang êm ái, hiển thị số lượng điểm đến sẵn có trong từng vùng.

### 4.3. Bento Grid Spotlight (Chống đơn điệu danh sách)
- Thay vì lặp lại các card giống hệt nhau, phân hệ Khám phá sử dụng **Bento Grid**:
  - 1 Thẻ Lớn (Feature 2x1): Chiếm toàn chiều rộng, ảnh tỷ lệ 16:9, hiển thị chi tiết điểm cao độ, cự ly và tag nổi bật nhất tháng.
  - 2 Thẻ Nhỏ (Compact 1x1): Nằm song song hai bên, tập trung vào điểm cắm trại hoặc thác nước gần gũi.

---

## 5. TƯƠNG TÁC CHUYỂN ĐỘNG & MOTION DESIGN

- **Chuyển cảnh từ danh sách sang chi tiết:**
  - Sử dụng `OpenContainer` từ thư viện `animations` với kiểu chuyển cảnh `fadeThrough`, thời lượng 320ms. Thẻ điểm đến mở rộng mượt mà thành màn hình chi tiết, tạo cảm giác đắm chìm và liền mạch.
- **Nút bấm & Card chạm:**
  - Bọc trong `BouncingButton`: Khi ngón tay chạm vào, thẻ hơi co lại (scale 0.97) kèm rung xúc giác nhẹ, khi thả ra bung trở lại kích thước chuẩn.
- **Hiệu ứng tải hình ảnh (Image Loading Shimmer):**
  - Sử dụng `SkeletonShimmer` với màu quét gradient nhẹ `editorialSurfaceSubtle` $\to$ `editorialSurfaceAlt` $\to$ `editorialSurfaceSubtle`. Không dùng màn hình trắng trơn hay spinner quay đơn điệu.
- **Tôn trọng cài đặt giảm chuyển động (Reduced Motion):**
  - Nếu người dùng bật tính năng giảm chuyển động trên hệ điều hành, thời lượng animation tự động hạ về 0ms.

---

## 6. THIẾT KẾ TRẠNG THÁI MÀN HÌNH (STATE DESIGN)

1. **Trạng thái Đang tải (Loading Skeleton State):**
   - Hiển thị skeleton đúng hình khối của Hero Card, Category Chips và Bento Grid để chống hiện tượng nhảy khung hình (Layout Shift).
2. **Trạng thái Trống Chân Thực (Honest Empty State):**
   - Khi bộ lọc không tìm thấy kết quả: Hiển thị minh họa dã ngoại tối giản, thông báo rõ: *"Không tìm thấy cung đường phù hợp với tiêu chí lọc"*, kèm nút bấm *"Đặt lại toàn bộ bộ lọc"* đưa người dùng về trạng thái mặc định.
3. **Trạng thái Ngoại Tuyến (Offline Badge):**
   - Khi mất kết nối Internet, hiển thị nhãn nhẹ nhàng: *"Chế độ ngoại tuyến • Đang hiển thị bản lưu trên máy"*. Ứng dụng vẫn hoạt động 100% bình thường với dữ liệu seed catalog.

