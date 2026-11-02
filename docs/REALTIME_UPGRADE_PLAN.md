# KẾ HOẠCH NÂNG CẤP DỮ LIỆU REAL-TIME TOÀN BỘ ỨNG DỤNG TRAVEL_APP

> **Ngày bắt đầu**: 02/11/2026 17:10  
> **Hoàn tất nâng cấp**: 02/11/2026 17:20  
> **Mục tiêu**: Loại bỏ toàn bộ dữ liệu gán cứng (hardcoded mock/dummy), tích hợp GPS phần cứng, Open-Meteo thời tiết thực, Reverse Geocoding, Waypoint động và thời gian thực tế `DateTime.now()`.  

---

## 🎯 CHECKLIST CÁC HẠNG MỤC THỰC HIỆN

- [x] **Task 1: Cứu hộ & Báo động SOS (`safety_sos_screen.dart` & `location_service.dart`)**
  - [x] Nâng cấp `LocationService.getDetailedPosition()` trả về đầy đủ tọa độ, cao độ (`altitude`), sai số (`accuracy`).
  - [x] `safety_sos_screen.dart`: Tự động quét GPS thực tế khi mở màn hình, có đèn trạng thái sóng vệ tinh và nút refresh GPS.
  - [x] SMS Cứu hộ 115: Gửi tin nhắn chứa tọa độ vệ tinh & cao độ thực tế.
  - [x] Nút sao chép tọa độ: Copy tọa độ thực tế kèm cao độ chuẩn xác.
  - [x] Tab Thời tiết vi khí hậu: Dự báo thời tiết tại tọa độ thực tế của người dùng.
  - [x] Kiểm thử: Tất cả các bài test đạt 100%.

- [x] **Task 2: Chi tiết Điểm đến (`destination_detail_screen.dart`)**
  - [x] Chuẩn hóa hiển thị "Thời điểm lý tưởng nhất": Hiển thị `Tháng 9, Tháng 10...` rõ ràng thay vì `09, 10, 11`.
  - [x] Tự động đối chiếu `DateTime.now().month`: Nếu trùng tháng hiện tại, gắn thẻ vàng nổi bật: `"Thời điểm vàng: Tháng X này đang là mùa đẹp nhất để trải nghiệm!"`.
  - [x] Tích hợp Thời tiết vi khí hậu thời gian thực: Tự động gọi `WeatherService.getForecast(lat, lng)` theo tọa độ điểm đến.
  - [x] Hiển thị cảnh báo thời tiết xấu thực tế: Lũ quét, hạ thân nhiệt về đêm, giông sét cực đoan.
  - [x] Tích hợp Tiện ích dã ngoại xung quanh (Overpass API): Hiển thị danh sách nguồn nước, bãi cắm trại thực tế từ OpenStreetMap.
  - [x] Kiểm thử: Tất cả các bài test đạt 100%.

- [x] **Task 3: Màn hình Khám phá (`explore_screen.dart`)**
  - [x] Thay thế chuỗi gán cứng "Quận 9" bằng Reverse Geocoding động (OpenStreetMap Nominatim) xác định quận/huyện, tỉnh/thành phố thực tế theo GPS người dùng.
  - [x] Nạp thời tiết thời gian thực khi chuyển đổi các địa điểm preset qua `WeatherService.getForecast`.
  - [x] Kiểm thử: Tất cả các bài test đạt 100%.

- [x] **Task 4: Bản đồ Ngoại tuyến (`offline_map_screen.dart`)**
  - [x] Định vị người dùng từ GPS thực tế thiết bị.
  - [x] Thay thế cung đường và waypoint Tà Năng cố định bằng Waypoint & Cung đường động lấy từ các chặng thực tế (`stages`) của địa điểm đang được chọn (`selectedTripDestination`).
  - [x] Kiểm thử: Tất cả các bài test đạt 100%.

- [x] **Task 5: Kế hoạch Chuyến đi (`trip_planner_screen.dart`)**
  - [x] Thêm bộ chọn Ngày khởi hành (`DatePicker` khởi tạo từ `DateTime.now()`), hiển thị thứ và ngày tháng thực tế cho từng chặng của hành trình.
  - [x] Cho phép người dùng tùy chỉnh định mức chi phí thực tế: Đơn giá xăng RON95, chi phí ăn uống/ngày, phí bãi trại/đêm thông qua popup điều chỉnh.
  - [x] Kiểm thử: Tất cả các bài test đạt 100%.

---

## 🕒 NHẬT KÝ TIẾN ĐỘ & BÀN GIAO
- **17:10 (02/11/2026)**: Bắt đầu rà soát và lập kế hoạch nâng cấp.
- **17:12 (02/11/2026)**: Hoàn thành Task 1 (Cứu hộ SOS GPS thực tế). Test passed.
- **17:14 (02/11/2026)**: Hoàn thành Task 2 (Mùa lý tưởng & Thời tiết thực tế tại điểm đến). Test passed.
- **17:16 (02/11/2026)**: Hoàn thành Task 3 (Reverse Geocoding khám phá). Test passed.
- **17:18 (02/11/2026)**: Hoàn thành Task 4 (Bản đồ động theo điểm đến). Test passed.
- **17:20 (02/11/2026)**: Hoàn thành Task 5 (Ngày khởi hành thực tế & chi phí linh hoạt). Test passed.
- **17:22 (02/11/2026)**: Biên dịch hoàn tất bản Web mới (`flutter build web`). Toàn bộ ứng dụng sẵn sàng.
