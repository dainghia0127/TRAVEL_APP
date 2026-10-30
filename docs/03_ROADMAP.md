# 03. LỘ TRÌNH TRIỂN KHAI DỰ ÁN (ROADMAP)

---

## Giai Đoạn 1: MVP Cốt Lõi & Ngoại Tuyến (Phase 1 — Core Offline MVP)
> **Mục tiêu**: Đảm bảo ứng dụng hoạt động mượt mà khi không có mạng Internet, bản đồ và định vị GPS chính xác.

- [ ] **Khởi tạo dự án Mobile (Flutter)**:
  - Cấu hình kiến trúc thư mục chuẩn (Clean Architecture / Feature-first).
  - Tích hợp State Management (Riverpod) và Local Database (Isar / SQLite).
- [ ] **Tích hợp Bản đồ Ngoại tuyến (MapLibre Native)**:
  - Tải và render thử nghiệm file vector tile `.mbtiles` mẫu (khu vực Đà Lạt / Ba Vì / Fansipan).
  - Bắt tín hiệu GPS thiết bị, hiển thị chấm xanh vị trí thực tế trên bản đồ.
- [ ] **Xây dựng Cẩm nang Sinh tồn (Outdoor Skills - Offline-First)**:
  - Biên soạn dữ liệu Markdown + hình ảnh SVG/WebP về nút dây, dựng lều, xử lý sơ cứu khi bị rắn cắn/hạ thân nhiệt.
  - Tích hợp danh bạ khẩn cấp ngoại tuyến.

---

## Giai Đoạn 2: Lập Kế Hoạch & Thời Tiết (Phase 2 — Trip Planner & Weather)
> **Mục tiêu**: Giúp người dùng lên lịch trình, dự trù ngân sách và nắm bắt thời tiết trước chuyến đi.

- [ ] **Phân hệ Trip Planner**:
  - Giao diện kéo thả sắp xếp các điểm đến theo ngày (Day 1, Day 2...).
  - Thuật toán định tuyến sắp xếp thứ tự điểm đến tối ưu quãng đường.
  - Máy tính chi phí tự động theo loại phương tiện di chuyển.
- [ ] **Tích hợp Dịch vụ Thời tiết (Open-Meteo API)**:
  - Hiển thị dự báo chi tiết theo tọa độ: Gió giật, giông bão, lượng mưa.
  - Tự động sinh Checklist đồ dùng thông minh dựa trên điều kiện thời tiết.

---

## Giai Đoạn 3: Bộ Công Cụ An Toàn Sinh Tồn (Phase 3 — Safety & Survival Suite)
> **Mục tiêu**: Tạo ra sự khác biệt đột phá của app so với các ứng dụng du lịch thông thường.

- [ ] **Chế độ SOS khẩn cấp**:
  - Module kích hoạt đèn Flash phát tín hiệu mã Morse quốc tế (`··· --- ···`).
  - Còi hú báo động âm tần cao định vị trong bóng tối.
  - Tự động soạn sẵn tin nhắn SMS kèm tọa độ GPS gửi đến số điện thoại khẩn cấp đã cài trước.
- [ ] **La bàn số & Đo độ cao**:
  - Tích hợp cảm biến từ trường và khí áp kế phần cứng (Altimeter & Digital Compass).
- [ ] **Chế độ Siêu tiết kiệm pin (Outdoor Battery Saver)**:
  - Chuyển toàn bộ UI sang Pure Black Theme (OLED).
  - Tự động tối ưu tần số lấy mẫu GPS để kéo dài thời gian sử dụng lên 2-3 ngày.

---

## Giai Đoạn 4: Đồng Bộ, Cộng Đồng & Web Viewer (Phase 4 — Cloud & Web)
> **Mục tiêu**: Kết nối cộng đồng phượt và chia sẻ chuyến đi cho người thân trên nền tảng web.

- [ ] **Xây dựng Backend (Node.js/Go + PostgreSQL PostGIS)**:
  - Quản lý danh mục hàng ngàn địa điểm du lịch, cắm trại trên toàn quốc.
  - Tìm kiếm điểm dịch vụ quanh bán kính $R$ km (`ST_DWithin`).
- [ ] **Web Viewer (Next.js)**:
  - Render trang xem lịch trình chuyến đi gọn nhẹ, hỗ trợ xem trực tiếp trên mọi trình duyệt mà không cần cài app.
- [ ] **Cộng đồng đóng góp dữ liệu (Trail Hazards)**:
  - Người dùng cắm mốc cảnh báo nguy hiểm trên cung đường (sạt lở, nước ngập, cầu hỏng).

