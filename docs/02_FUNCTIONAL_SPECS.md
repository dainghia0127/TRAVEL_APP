# 02. ĐẶC TẢ TÍNH NĂNG (FUNCTIONAL SPECIFICATIONS)

---

## I. 5 PHÂN HỆ CỐT LÕI

### 01. Explore — Khám Phá Địa Điểm
* **Dữ liệu địa điểm ngoài trời**:
  - Phân loại: Đỉnh núi trekking, bãi cắm trại (Camping / Glamping), suối/thác, hồ nước, bãi biển hoang sơ, cung đường đèo.
  - Thông số kỹ thuật của từng địa điểm: Độ cao (m), độ khó (Dễ / Trung bình / Khắc nghiệt), thời gian di chuyển dự kiến, nguồn nước ngọt, vùng phủ sóng di động (Viettel/Vina/Mobi).
* **Bộ lọc thông minh**:
  - Lọc theo bán kính vị trí hiện tại ($R = 5\text{km}, 20\text{km}, 50\text{km}, 100\text{km}$).
  - Lọc theo mức chi phí dự kiến & độ khó.
* **Điểm dịch vụ thiết yếu trên đường (Amenities)**:
  - Tự động hiển thị các trạm xăng gần nhất, tiệm sửa xe máy, tiệm tạp hóa/nước uống, trạm y tế / bệnh viện huyện, đồn biên phòng / trạm kiểm lâm.

---

### 02. Trip Planner — Lập Kế Hoạch Chuyến Đi
* **Lên lịch trình theo ngày**:
  - Sắp xếp các điểm dừng theo mốc thời gian (Sáng - Trưa - Chiều - Tối).
  - Thuật toán định tuyến (Routing TSP): Tự động sắp xếp các điểm tham quan để không bị chạy xe vòng vèo ngược đường.
* **Dự toán chi phí thực tế**:
  - Chọn phương tiện: Đi bộ trekking / Xe máy số / Xe côn tay / Xe bán tải 4x4.
  - Tự động tính toán lượng xăng dự kiến dựa trên cung đường (đường đèo dốc nhân hệ số x1.4).
  - Chi phí ăn uống, lều trại, vé vào cổng bảo tồn thiên nhiên.
* **Chia sẻ & Đồng bộ**:
  - Xuất link web chuyến đi (ví dụ `travelapp.vn/t/ta-nang-phan-dung-3n2d`) gửi cho bạn bè, gia đình.
  - Xuất file `.GPX` hoặc `.KML` để nạp vào đồng hồ thông minh (Garmin, Apple Watch, Suunto).

---

### 03. Weather & Safety — Thời Tiết & Cảnh Báo An Toàn
* **Dự báo vi khí hậu theo cao độ (Microclimate)**:
  - Khác với thời tiết đồng bằng, dự báo thời tiết tại đỉnh núi cần thông số: Tốc độ gió giật (Wind Gusts), khả năng mưa rào tức thời, chỉ số UV và nhiệt độ cảm nhận (RealFeel).
* **Cảnh báo nguy cơ cao**:
  - Cảnh báo giông sét (Lightning risk): Đưa ra khuyến cáo tránh trú trên đỉnh trơ trọi.
  - Gợi ý khung giờ xuất phát lý tưởng (ví dụ: *"Nên vượt đèo trước 14:00 vì sau 15:00 có sương mù dày và mưa giông"*).
* **Checklist đồ dùng thông minh**:
  - Tự động thêm trang bị dựa vào thời tiết và loại hình: Nếu mưa -> thêm áo mưa bộ, bọc balo chống nước, ủng đi mưa; nếu cắm trại qua đêm trên núi -> thêm túi ngủ chịu nhiệt $5^\circ\text{C}$, miếng dán giữ nhiệt.

---

### 04. Outdoor Skills — Cẩm Nang Ngoài Trời (Offline-First)
* **Toàn bộ nội dung tích hợp sẵn trong app (Không cần mạng)**:
  - Kỹ thuật nút dây: Nút thòng lọng, nút dẹt, nút néo cọc lều (kèm ảnh GIF/vector minh họa từng bước).
  - Kỹ thuật dựng lều & cố định chống gió bão, đào rãnh thoát nước quanh lều.
  - Nhóm lửa sinh tồn an toàn: Chọn củi khô, kỹ thuật bùi nhùi, nguyên tắc dập tắt lửa triệt để bảo vệ rừng.
  - Xử lý khi bị lạc trong rừng: Nguyên tắc STOP, tìm nguồn nước, đánh dấu đường đi.
  - Sơ cứu ngoài trời: Xử lý rắn cắn (nhận diện vết cắn & nẹp cố định, tuyệt đối không rạch vết thương), hạ thân nhiệt, bong gân, đuối nước.

---

### 05. Offline Mode — Chế Độ Ngoại Tuyến
* **Quản lý vùng bản đồ ngoại tuyến**:
  - Cho phép người dùng chọn vùng bản đồ (theo tỉnh hoặc khu vực vườn quốc gia) và bấm "Tải xuống".
  - Hiển thị dung lượng lưu trữ trên máy và ngày cập nhật.
* **Định vị & Theo dõi vị trí độc lập**:
  - Sử dụng chip vệ tinh GPS của thiết bị hiển thị tọa độ (WGS84 Lat/Lng và UTM).
  - Lưu trữ vết đường đi (Track recording) cục bộ vào bộ nhớ điện thoại.
* **Danh bạ khẩn cấp ngoại tuyến**:
  - Lưu sẵn số điện thoại trung tâm cứu nạn cứu hộ 114, cứu thương 115, kiểm lâm vườn quốc gia, công an khu vực lân cận.

---

## II. 5 TÍNH NĂNG ĐỘT PHÁ AN TOÀN

1. **Chế độ SOS khẩn cấp bằng Mã Morse & Âm thanh**:
   - **Bấm 1 nút**: Đèn flash điện thoại phát sáng tín hiệu mã Morse quốc tế SOS (`··· --- ···`), đồng thời phát còi hú âm tần cao chu kỳ để người cứu hộ định vị trong bóng tối.
   - **Tự động soạn tin nhắn SMS cứu hộ**: Chứa tọa độ GPS chính xác (`Tôi đang cần cứu hộ tại: 11.9404, 108.4583`). SMS hoạt động được ở cả những nơi sóng 2G chập chờn mà mạng 4G không vào được.
2. **Cảnh báo Lũ quét & Hạ thân nhiệt (Flash Flood / Hypothermia Alert)**:
   - Tự động phân tích nếu thượng nguồn có mưa to dồn dập -> Cảnh báo người cắm trại cạnh suối di dời lên vị trí cao ngay lập tức.
   - Cảnh báo hạ thân nhiệt khi nhiệt độ dưới $12^\circ\text{C}$ kèm độ ẩm cao và gió giật trên cấp 5.
3. **La bàn số & Đo độ cao thời gian thực (Altimeter & Compass)**:
   - Tận dụng cảm biến con quay hồi chuyển và khí áp kế phần cứng để đo độ cao so với mực nước biển thời gian thực.
4. **Cảnh báo chướng ngại vật cộng đồng (Crowdsourced Trail Hazards)**:
   - Người đi trước cắm cờ đánh dấu: *"Cầu treo bị gãy"*, *"Sạt lở đất đứt đường"*, *"Có đàn ong rừng"*. Dữ liệu được đồng bộ khi có kết nối mạng trở lại.
5. **Chế độ Siêu tiết kiệm pin ngoài trời (Outdoor Battery Saver)**:
   - Tối ưu hóa chu kỳ đánh thức CPU, nền đen OLED, ngắt định vị ngầm khi khóa màn hình, giúp điện thoại hoạt động được 2 - 3 ngày hành quân.

