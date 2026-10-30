# KẾ HOẠCH & KIẾN TRÚC ỨNG DỤNG TRAVEL OUTDOOR THỜI GIAN THỰC

> **Lưu ý**: Tài liệu này là bản tổng hợp kế hoạch và phân tích kỹ thuật ban đầu cho dự án **TRAVEL_APP**.

---

## 1. Giải Đáp: Nên Chọn Web App, iOS Hay Android?

* **Web App (PWA)**: KHÔNG NÊN làm app chính vì vào rừng, leo núi mất mạng 4G sẽ không đọc được bản đồ offline dung lượng lớn, iOS Safari giới hạn dung lượng cache và không bắt được GPS khi khóa màn hình.
* **Native riêng biệt (Swift + Kotlin)**: KHÔNG NÊN ở giai đoạn đầu vì tốn gấp đôi chi phí và nhân lực code 2 lần.
* 🌟 **LỰA CHỌN TỐI ƯU NHẤT**: **Cross-Platform Mobile App (Flutter hoặc React Native)** kèm theo **1 trang Web Viewer gọn nhẹ**:
  - **App Mobile**: Dùng cho cả iPhone & Android, truy cập thẳng chip vệ tinh GPS phần cứng, tải bản đồ offline, cẩm nang sinh tồn, cảnh báo khẩn cấp.
  - **Trang Web Viewer**: Người dùng gửi link chuyến đi (ví dụ `travelapp.vn/trip/da-lat-3n2d`), bạn bè mở trình duyệt xem ngay không bắt buộc phải cài app.

### Flutter có xem thử nghiệm tức thì trên máy thật được không?
👉 **HOÀN TOÀN ĐƯỢC VÀ RẤT NHANH**:
- Flutter có tính năng **Hot Reload**: Cắm cáp USB (hoặc cùng Wi-Fi) vào điện thoại thật (cả iPhone lẫn Android). Khi bạn sửa code và bấm Lưu (`Ctrl + S`), chỉ sau **chưa đầy 1 giây** màn hình điện thoại thật tự động cập nhật mà không mất dữ liệu đang nhập.

---

## 2. Đánh Giá 5 Phân Hệ Ý Tưởng & Giải Pháp Kỹ Thuật

### 01. Explore — Khám Phá
- **Ý tưởng gốc**: Bản đồ địa điểm du lịch, núi, biển, hồ, camping; lọc vị trí/ngân sách/độ khó; lưu yêu thích; điểm dịch vụ (trạm xăng, bệnh viện, tạp hóa, điểm nghỉ).
- **Đánh giá**: **Hoàn toàn khả thi**.
- **Giải pháp**:
  - Cơ sở dữ liệu không gian **PostgreSQL + PostGIS** tính bán kính $R$ km quanh vị trí người dùng (`ST_DWithin`).
  - Dữ liệu trạm xăng, bệnh viện, tạp hóa lấy từ **OpenStreetMap (OSM) / Overpass API** (miễn phí, phong phú ở VN).

### 02. Trip Planner — Lập Kế Hoạch Chuyến Đi
- **Ý tưởng gốc**: Gợi ý theo ngày/ngân sách/sở thích; lịch trình từng ngày & thứ tự điểm đến; ước tính chi phí di chuyển/ăn uống/lưu trú; lưu & chia sẻ.
- **Đánh giá**: **Hoàn toàn khả thi**.
- **Giải pháp**:
  - Thuật toán tối ưu cung đường (Routing / TSP) sắp xếp thứ tự điểm đến không bị đi lòng vòng.
  - Dự toán chi phí: Cần cho chọn loại phương tiện (Xe máy / Ô tô / Đi bộ trekking) để tính đúng mức tiêu hao nhiên liệu.

### 03. Weather & Safety — Thời Tiết & An Toàn
- **Ý tưởng gốc**: Dự báo thời tiết tại điểm đến; cảnh báo mưa lớn, giông, gió giật; gợi ý giờ xuất phát; checklist đồ dùng thông minh.
- **Đánh giá**: **Hoàn toàn khả thi**.
- **Giải pháp**: Tích hợp API **Open-Meteo** (miễn phí, hỗ trợ dữ liệu gió, giông bão, lượng mưa chi tiết theo từng tọa độ đỉnh núi). Tự động sinh checklist đồ (ví dụ: mưa -> thêm áo mưa bộ, túi chống nước).

### 04. Outdoor Skills — Cẩm Nang Ngoài Trời
- **Ý tưởng gốc**: Hướng dẫn nút dây, dựng lều, nhóm lửa an toàn, xử lý khi bị lạc, sơ cứu, nước uống sinh tồn; tải trước nội dung offline.
- **Đánh giá**: **Hoàn toàn khả thi**.
- **Giải pháp**: Toàn bộ bài học, ảnh minh họa vector SVG hoặc GIF động được nén sẵn trong app (Offline-first), mở xem không cần mạng.

### 05. Offline Mode — Chế Độ Ngoại Tuyến (Trọng Tâm Sống Còn)
- **Ý tưởng gốc**: Lưu lịch trình, cẩm nang trên máy; lưu bản đồ khu vực; GPS không có mạng; danh bạ khẩn cấp offline.
- **Đánh giá**: **Khả thi nhưng có bẫy cần tránh**.
- **Bẫy kỹ thuật**: **Không được dùng Google Maps** để tải bản đồ offline (vi phạm chính sách của Google, sẽ bị khóa API).
- **Giải pháp chuẩn**: Dùng **MapLibre Native** kết hợp nguồn bản đồ **OpenStreetMap / MapTiler**. Tải bản đồ offline dạng vector tile `.mbtiles` (1 khu vực/tỉnh chỉ khoảng 25MB - 40MB). Chip GPS bắt sóng vệ tinh độc lập 100% không phụ thuộc vào 4G/Wi-Fi.

---

## 3. 5 Ý Tưởng Phát Triển Thêm (Biến App Thành Sản Phẩm Đột Phá)

1. **Chế độ SOS khẩn cấp bằng Mã Morse & Âm thanh**:
   - Bấm 1 nút: Đèn flash điện thoại chớp mã SOS quốc tế (`... --- ...`), còi hú tần số cao định vị ban đêm.
   - Tự động soạn tin nhắn SMS chứa tọa độ GPS gửi người thân (SMS vẫn gửi được ở nơi sóng yếu không có 4G).
2. **Cảnh báo Lũ quét & Hạ thân nhiệt (Flash Flood / Hypothermia)**: Cảnh báo tự động nếu mưa lớn ở thượng nguồn suối hoặc nhiệt độ đêm trên núi giảm sâu kèm gió to.
3. **La bàn số & Đo độ cao thời gian thực (Altimeter & Compass)**: Khai báo cảm biến từ trường & khí áp kế đo độ cao so với mực nước biển.
4. **Cảnh báo chướng ngại vật cộng đồng (Crowdsourced Trail Hazards)**: Người đi trước cắm cờ: *"Đoạn này sạt lở"*, *"Cầu gãy"*, *"Nước sâu không qua được"*.
5. **Chế độ Siêu tiết kiệm pin ngoài trời (Outdoor Battery Saver)**: Chỉ quét GPS khi mở màn hình, ngắt định vị liên tục khi khóa máy để pin trụ được 2-3 ngày đi rừng.

