# HỆ THỐNG THIẾT KẾ TOÀN DIỆN (DESIGN SYSTEM SPECIFICATION)
## Dự án: TRAVEL_APP — Premium Outdoor Travel Experience

> **Triết lý thiết kế:** Tối giản (Minimalist), Đậm chất dã ngoại (Nature-inspired), Đắm chìm (Immersive), Tương tác cao (Interactive).  
> **Cảm hứng:** AllTrails Pro, Airbnb, Polarsteps, Komoot, Apple Fitness/Watch Ultra.

---

## 1. BẢNG MÀU CHUẨN MỰC (COLOR TOKENS)

Ứng dụng tuân thủ nghiêm ngặt **Quy tắc 60-30-10** trong thiết kế UI cao cấp:
- **60% (Nền & Bề mặt):** Obsidian & Forest Dark — Giảm chói mắt ban đêm, tiết kiệm 100% pin OLED trong rừng.
- **30% (Cấu trúc thẻ & Text):** Card Glassmorphic & Text tương phản cao chuẩn WCAG 2.1 AA.
- **10% (Điểm nhấn hành động & Cảnh báo):** Emerald Adventure, Tactical Orange & SOS Red.

```dart
class AppColors {
  // 1. Tầng Nền & Bề mặt (60%)
  static const Color bgDark = Color(0xFF090D0B);          // Nền đen thẳm chống chói
  static const Color surfaceBase = Color(0xFF121915);      // Thẻ mặt phẳng cấp 1
  static const Color surfaceHigh = Color(0xFF1A241F);      // Thẻ nổi bật / Header cấp 2
  static const Color surfaceElevated = Color(0xFF222F29);  // Dialog / Floating Sheets
  static const Color surfaceGlass = Color(0x331E2D26);     // Kính mờ (Frosted Glass)

  // Đường viền tinh xảo (Borders)
  static const Color borderSubtle = Color(0x14FFFFFF);     // Viền mờ 8%
  static const Color borderMedium = Color(0x24FFFFFF);     // Viền rõ 14%
  static const Color borderActive = Color(0xFF10B981);     // Viền khi được chọn

  // 2. Tầng Điểm Nhấn Sinh Tồn & Dã Ngoại (10%)
  static const Color emerald = Color(0xFF10B981);         // Màu chủ đạo: Thiên nhiên, an toàn
  static const Color emeraldDark = Color(0xFF059669);     // Gradient / Nút nhấn
  static const Color tacticalOrange = Color(0xFFF59E0B);  // Cảnh báo thời tiết, đường mòn
  static const Color emergencyRed = Color(0xFFEF4444);    // SOS khẩn cấp, nguy hiểm
  static const Color alpineCyan = Color(0xFF06B6D4);      // Nguồn nước, cao độ, tuyết lạnh
  static const Color summitGold = Color(0xFFFBBF24);      // Đánh giá 5 sao, mốc thành tích

  // 3. Tầng Văn Bản (Typography Contrast - 30%)
  static const Color textPrimary = Color(0xFFF9FAFB);     // Tiêu đề chính, số liệu lớn
  static const Color textSecondary = Color(0xFF9CA3AF);   // Phụ đề, mô tả
  static const Color textMuted = Color(0xFF6B7280);       // Chú thích, đơn vị đo
}
```

---

## 2. HỆ THỐNG TYPOGRAPHY (TYPOGRAPHY SCALE)

Thiết kế phân tầng theo phong cách **Tạp chí dã ngoại (Editorial Outdoor)**, tạo sự tương phản rõ nét giữa con số địa hình và nhãn nội dung:

| Token Name | Size / LineHeight | Weight | Letter Spacing | Ngữ cảnh sử dụng |
| :--- | :---: | :---: | :---: | :--- |
| **`displayHero`** | 32px / 38px | Black (w900) | -1.2px | Tiêu đề địa danh Hero, chỉ số SOS |
| **`headlineLarge`** | 24px / 30px | ExtraBold (w800)| -0.8px | Tên cung đường trên Card chính |
| **`headlineMedium`**| 20px / 26px | Bold (w700) | -0.5px | Tiêu đề phân mục (Featured, Nearby) |
| **`titleMedium`** | 16px / 22px | SemiBold (w600)| -0.2px | Tên điểm dừng chân, tiêu đề bài học |
| **`bodyLarge`** | 15px / 22px | Regular (w400) | 0.0px | Đoạn văn mô tả chi tiết, hướng dẫn sơ cứu |
| **`bodyMedium`** | 13px / 18px | Regular (w400) | 0.0px | Vị trí địa lý, đánh giá phụ |
| **`labelMetric`** | 12px / 14px | Bold (w700) | +0.4px | Số đo cao độ, cự ly (1,485m, 55km) |
| **`captionBadge`** | 10px / 12px | SemiBold (w600)| +0.6px | Badge độ khó (KHÓ, DỄ), chip danh mục (UPPERCASE) |

---

## 3. HỆ THỐNG KHOẢNG CÁCH & LƯỚI (SPACING & GRID SYSTEM)

Tuân thủ nguyên tắc **Hệ lưới Bội số 4px & 8px (8-Point Grid)**:

```dart
class AppSpacing {
  static const double space2 = 2.0;
  static const double space4 = 4.0;    // Micro: Khoảng cách giữa icon và text
  static const double space8 = 8.0;    // XS: Khoảng cách giữa các chip, badge
  static const double space12 = 12.0;  // SM: Padding trong thẻ nhỏ
  static const double space16 = 16.0;  // MD: Padding màn hình chuẩn (Standard Horizontal Inset)
  static const double space20 = 20.0;  // LG: Khoảng cách giữa các Card
  static const double space24 = 24.0;  // XL: Khoảng cách giữa các Phân đoạn (Section gap)
  static const double space32 = 32.0;  // 2XL: Khoảng cách Hero Header
  static const double space48 = 48.0;  // 3XL: Khoảng trống đệm đáy an toàn (Bottom Clearance)
}
```

---

## 4. BO GÓC & ĐỘ NỔI (BORDER RADIUS & ELEVATION)

- **Bo góc có phân cấp (Concentric Radii):**
  - `radiusSm` (8px): Badge trạng thái nhỏ, Chip thông số.
  - `radiusMd` (14px): Nút bấm (Button), Thanh tìm kiếm (Input field).
  - `radiusLg` (20px): Card địa điểm chính, Hộp thoại thông tin.
  - `radiusXl` (28px): Khung hình ảnh Hero, Bottom Sheet kéo trượt.
  - `radiusPill` (999px): Viên thuốc thời tiết, Chip danh mục cuộn ngang.
- **Độ nổi & Kính mờ (Elevation & Scrim):**
  - Không lạm dụng bóng đổ xám thông thường. Sử dụng **Ánh bóng đen khuếch tán (Ambient Dark Shadow)** kết hợp **Viền kính phát quang 1px (`borderSubtle`)** để tách lớp giao diện mà vẫn giữ độ phẳng hiện đại.

---

## 5. THIẾT KẾ COMPONENT ĐẶC TRƯNG (SIGNATURE COMPONENTS)

### 5.1. Thẻ Địa Điểm Du Lịch Đắm Chìm (Immersive Destination Card)
- **Tỉ lệ vàng:** Khung hình thực địa khổ 16:9 hoặc 4:3 có lớp phủ Gradient Scrim tinh tế bảo vệ độ tương phản của chữ.
- **Hàng huy hiệu dã ngoại (4-Pill Tactical Bar):** Cự ly (km), Cao độ (m), Nguồn nước, Trạng thái sóng 4G.
- **Vùng bấm yêu thích:** Đường kính 48x48px (chuẩn Apple HIG / Material), có hiệu ứng nảy (Spring Bounce) khi bấm.
- **Chuyển cảnh:** Áp dụng `OpenContainer` mở bung thẻ thành màn hình chi tiết khi chạm.

### 5.2. Thanh Tìm Kiếm & Bộ Lọc Nổi (Floating Search & Filter Bar)
- Tích hợp icon tìm kiếm xanh ngọc, placeholder trực quan *"Tìm núi, thác, bãi cắm trại, đèo..."*.
- Nút Filter mở Bottom Sheet bộ lọc đa tiêu chí (Lọc theo độ dốc, cự ly, tình trạng mất sóng).

### 5.3. Nút Thao Tác Chuyên Nghiệp (Tactical Action Buttons)
- Chiều cao chuẩn 52px (dễ bấm bằng ngón tay cái khi đang di chuyển ngoài trời).
- Phản hồi xúc giác `HapticFeedback.mediumImpact()` khi chạm.
- Hiệu ứng co nhẹ kích thước (Scale down to `0.97`) khi ngón tay đè vào.

---

## 6. QUY CHUẨN CHUYỂN ĐỘNG & ANIMATION (MOTION GUIDELINES)

Tuân thủ nguyên tắc **"Chuyển động có mục đích UX — Không trang trí rườm rà"**:

1. **Thời lượng (Durations):**
   - Micro-interaction (Nút bấm, tim yêu thích, checkbox): **150ms – 200ms**.
   - Mở rộng thẻ, chuyển đổi Sheet: **300ms – 350ms**.
   - Nạp danh sách theo nhịp (Staggered List Entrance): **100ms giãn cách mỗi phần tử**.
2. **Đường cong chuyển động (Easing Curves):**
   - Mặc định: `Curves.easeOutCubic` (nhanh ở đầu, êm ái ở cuối).
   - Nảy nhẹ (Tactile bounce): `Curves.elasticOut` hoặc `Curves.easeOutBack`.
3. **Các ứng dụng cụ thể:**
   - **Hero Transition / OpenContainer:** Dùng cho mở thẻ địa điểm du lịch.
   - **Pulse Radar Animation (`flutter_animate`):** Dùng cho nút SOS và chấm xanh định vị GPS.
   - **Skeleton Shimmer:** Thay thế vòng xoay tròn loading nhàm chán bằng khung xương ánh sáng trượt.
   - **Tôn trọng người dùng:** Kiểm tra `MediaQuery.of(context).disableAnimations` để tự động tắt chuyển động nếu người dùng bật chế độ "Reduce Motion" trên điện thoại.

