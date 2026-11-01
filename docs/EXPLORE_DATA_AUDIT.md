# BÁO CÁO KIỂM TOÁN DỮ LIỆU & MÃ NGUỒN PHÂN HỆ KHÁM PHÁ (EXPLORE DATA AUDIT - REVISED)

> **Dự án:** TRAVEL_APP — Mobile Flutter Application  
> **Phiên bản tài liệu:** 2.0 (Kiểm toán kỹ thuật có phân định mức độ xác minh)  
> **Cam kết liêm chính:** Phân định rõ ràng giữa:
> - `[VERIFIED-CODE]`: Đã xác minh trực tiếp từ mã nguồn thực tế (kèm file và line).
> - `[INFERRED-CODE]`: Suy luận kỹ thuật từ cấu trúc code hiện hữu.
> - `[NOT-VERIFIED]`: Chưa được xác minh trong code/cần kiểm tra thêm.
> - `[PROVIDER-FACT]`: Dữ liệu về bên thứ ba cần đối chiếu tài liệu chính thức của nhà cung cấp.

---

## 1. PHÂN LOẠI & XÁC MINH CẤU TRÚC HIỆN TẠI TRONG CODEBASE

### 1.1. Cấu trúc mã nguồn thực tế (`mobile_flutter/lib`)

- `[VERIFIED-CODE]` **Entry Point & Navigation:**
  - File [`mobile_flutter/lib/main.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/main.dart): Khởi chạy `TravelOutdoorApp`, bọc trong `MaterialApp`, trỏ vào `MainNavigationScreen`.
  - File [`mobile_flutter/lib/features/home/presentation/screens/main_navigation_screen.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/home/presentation/screens/main_navigation_screen.dart#L22-L57): Quản lý 5 tab thông qua `PageTransitionSwitcher` và `FadeThroughTransition`: Khám phá (`ExploreScreen`), Bản đồ (`OfflineMapScreen`), Lịch trình (`TripPlannerScreen`), Cẩm nang (`OutdoorSkillsScreen`), SOS Cứu hộ (`SafetySosScreen`).
- `[VERIFIED-CODE]` **Cấu trúc thư mục phân hệ Explore:**
  - Trong `mobile_flutter/lib/features/explore/`, **chỉ tồn tại thư mục `presentation/`**.
  - Hoàn toàn **không có** thư mục `domain/` hay `data/`.
  - Không có repository, datasource hay usecase.
- `[VERIFIED-CODE]` **Thư viện bên ngoài trong `pubspec.yaml`:**
  - Các dependency đã cài đặt: `flutter_map: ^8.3.2`, `latlong2: ^0.10.1`, `geolocator: ^14.1.2`, `shared_preferences: ^2.5.6`, `url_launcher: ^6.3.3`, `http: ^1.6.0`, `flutter_animate: ^4.5.2`, `animations: ^2.0.11`, `lottie: ^3.3.1`, `cached_network_image: ^3.4.1`.
  - Không có `sqflite`, `drift`, hay `isar`. Local database có cấu trúc chưa được cài đặt.

---

## 2. KIỂM TOÁN CHI TIẾT DỮ LIỆU ĐANG BỊ GÁN CỨNG (HARDCODED AUDIT)

### 2.1. Danh mục điểm đến trong `explore_screen.dart`
- `[VERIFIED-CODE]` Dòng 71–192 của [`explore_screen.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/explore/presentation/screens/explore_screen.dart#L71-L192): Mảng `List<Map<String, dynamic>> _spots` chứa 5 điểm đến được gán cứng hoàn toàn:
  1. `spot_1`: Cung Tà Năng - Phan Dũng (`rating: '4.9'`, `reviews: '284'`, `elevation: '1,100 m'`, `distance: '55 km'`)
  2. `spot_2`: Hồ Tuyền Lâm & Rừng Thông (`rating: '4.8'`, `reviews: '512'`, `elevation: '1,500 m'`, `distance: '12 km'`)
  3. `spot_3`: Đại Thác K50 (`rating: '5.0'`, `reviews: '142'`, `elevation: '820 m'`, `distance: '24 km'`)
  4. `spot_4`: Đỉnh Bidoup Núi Bà (`rating: '4.9'`, `reviews: '189'`, `elevation: '2,287 m'`, `distance: '28 km'`)
  5. `spot_5`: Cung Đèo Ô Quy Hồ (`rating: '4.9'`, `reviews: '680'`, `elevation: '2,003 m'`, `distance: '50 km'`)
- `[INFERRED-CODE]` Đánh giá: Cả 5 điểm đến đều nằm tại Việt Nam (Lâm Đồng, Bình Thuận, Gia Lai, Lào Cai). Hoàn toàn không có bất kỳ điểm đến quốc tế nào trong mã nguồn.
- `[VERIFIED-CODE]` Đánh giá về chỉ số mạng xã hội: Không có API hay bảng lưu trữ đánh giá. Toàn bộ `rating` và `reviews` là chuỗi văn bản gán cứng, không có nguồn gốc từ người dùng thực.

### 2.2. Vị trí & Thời tiết chọn sẵn (`_presetLocations`)
- `[VERIFIED-CODE]` Dòng 35–60 của `explore_screen.dart`: Chứa 4 vị trí tĩnh kèm mô tả thời tiết gán cứng:
  - 'Quận 9, TP. Hồ Chí Minh • 14m' — '31°C Nắng ráo'
  - 'Tây Nguyên (Tà Năng) • 1,485m' — '18°C Ít mây'
  - 'Đỉnh Fansipan • 3,143m' — '9°C Sương mù lạnh'
  - 'Rừng Nam Cát Tiên • 120m' — '28°C Râm mát'
- `[INFERRED-CODE]` Các thông số thời tiết trên không được lấy từ API thời tiết mà là chuỗi tĩnh gán sẵn.

### 2.3. Lộ trình mẫu & Lưu ý an toàn trong `destination_detail_screen.dart`
- `[VERIFIED-CODE]` Dòng 286–289 của [`destination_detail_screen.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/explore/presentation/screens/destination_detail_screen.dart#L286-L289): Bốn bước lộ trình gán cứng cho mọi điểm đến:
  - Chặng 1: 'Khởi hành tại Cửa rừng' (0 km)
  - Chặng 2: 'Vượt dốc và sống lưng' (15 km)
  - Chặng 3: 'Bãi hạ trại ven suối' (28 km)
  - Chặng 4: 'Đích đến trạm kết thúc' (`${spot['distance']}`)
- `[VERIFIED-CODE]` Dòng 296–315 của `destination_detail_screen.dart`: Ba lưu ý an toàn sinh tồn gán cứng cho mọi điểm đến:
  - 'Mang tối thiểu 2.5 Lít nước'
  - 'Cảnh báo mất sóng di động (70%)'
  - 'Dựng lều trước 16:30'
- `[INFERRED-CODE]` Hậu quả an toàn: Khi người dùng xem chi tiết Hồ Tuyền Lâm (khu cắm trại xe hơi vào tận nơi), ứng dụng vẫn hiển thị cảnh báo "vượt dốc sống lưng 15km" và "mất sóng 70%". Đây là thông tin sai lệch thực tế, nguy hiểm nếu áp dụng cho trekking.

---

## 3. KIỂM TOÁN TÍCH HỢP DỊCH VỤ & API NGOÀI TRÊN TOÀN APP

| Tên Dịch Vụ / Thư Viện | Vị Trí Triển Khai | Xác Minh Thực Tế Trong Code | Hiện Trạng Tích Hợp |
| :--- | :--- | :--- | :--- |
| **Open-Meteo API** | [`mobile_flutter/lib/features/weather_safety/services/weather_service.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/weather_safety/services/weather_service.dart#L37-L79) | `[VERIFIED-CODE]` URL: `https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng...`<br>Timeout: `Duration(seconds: 5)`. Trả về `OutdoorWeather`. | Tích hợp thành công trong `WeatherService`. **Chưa** được gọi từ màn hình Explore hoặc Destination Detail. |
| **ESRI ArcGIS Tiles** | [`mobile_flutter/lib/features/offline_map/presentation/screens/offline_map_screen.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/offline_map/presentation/screens/offline_map_screen.dart#L44-L64) | `[VERIFIED-CODE]` Sử dụng `server.arcgisonline.com` cho Topo, Satellite, Street Map trên FlutterMap `TileLayer`. | Đang chạy tốt trong tab Bản đồ, không cần key. **Chưa** có preview trong Explore. |
| **Geolocator GPS** | [`mobile_flutter/lib/features/offline_map/services/location_service.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/features/offline_map/services/location_service.dart#L6-L40) | `[VERIFIED-CODE]` Gọi `Geolocator.getCurrentPosition()`. | Đã tích hợp, được dùng để xác định vị trí hiện tại trên header của Explore. |
| **SharedPreferences** | [`mobile_flutter/lib/core/services/storage_service.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/core/services/storage_service.dart) | `[VERIFIED-CODE]` Lưu 2 key: `travel_favorites` (List<String>) và `travel_checklist` (List<String>). | Đã tích hợp lưu ID danh sách yêu thích và checklist. |
| **Overpass API / OSM** | Không có file nào | `[VERIFIED-CODE]` Không tìm thấy bất kỳ chuỗi `overpass` hay query OSM nào trong toàn bộ thư mục `lib/`. | **Chưa tích hợp trong codebase.** |
| **Wikimedia API** | Không có file nào | `[VERIFIED-CODE]` Không có HTTP client nào gọi Wikimedia Commons API. | **Chưa tích hợp trong codebase.** |
| **Supabase / Cloud DB**| Không có file nào | `[VERIFIED-CODE]` Không có dependency `supabase_flutter` hay kết nối database nào. | **Chưa tích hợp trong codebase.** |

---

## 4. KIỂM TOÁN QUẢN LÝ HÌNH ẢNH & BẢN QUYỀN HIỆN TẠI

- `[VERIFIED-CODE]` **Tài nguyên ảnh cục bộ:**
  - Thư mục [`mobile_flutter/assets/images/`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/assets/images) chứa đúng 6 tệp:
    1. `default_nature.jpg` (94 KB)
    2. `fall_k50.jpg` (189 KB)
    3. `hero_ta_nang.jpg` (94 KB)
    4. `lake_tuyen_lam.jpg` (137 KB)
    5. `mang_den.jpg` (121 KB)
    6. `pass_o_quy_ho.jpg` (159 KB)
- `[VERIFIED-CODE]` **Cấu trúc Class `OutdoorImage`:**
  - File [`mobile_flutter/lib/core/models/outdoor_image.dart`](file:///c:/Users/DELL/Downloads/AI%20Coding/Gemini%20Code/TRAVEL_APP/mobile_flutter/lib/core/models/outdoor_image.dart):
    - Các trường có sẵn: `url`, `localAsset`, `aspectRatio`, `focalPoint`, `photographer`, `source`, `caption`.
    - Giá trị mặc định của `source`: `'Unsplash'`.
    - **Thiếu:** `license` (CC-BY, CC-BY-SA, Public Domain...), `sourceUrl`, `imageId`, `verificationDate`.
- `[INFERRED-CODE]` **Độ chính xác của ảnh gán cho điểm đến:**
  - `spot_3` (Đại Thác K50): Sử dụng ảnh `photo-1432405972618-c60b0225b8f9` của tác giả Adam K. trên Unsplash. Đây là ảnh thác nước chụp ở nước ngoài, không phải thác K50 thực tế tại Khu BTTN Kon Chư Răng, Gia Lai.
  - `spot_4` (Đỉnh Bidoup Núi Bà): Gán asset cục bộ `mang_den.jpg` (ảnh Măng Đen - Kon Tum) thay vì rừng thông rêu Bidoup (Lâm Đồng).

---

## 5. TỔNG HỢP NỢ KỸ THUẬT VÀ PHẠM VI CẦN SỬA ĐỔI

1. `[VERIFIED-CODE]` **Thiếu mô hình Domain & Data:** Toàn bộ dữ liệu đang nằm trong View (`ExploreScreen`). Cần xây dựng tầng Domain và Data theo Clean Architecture.
2. `[VERIFIED-CODE]` **Không có cơ chế lưu trữ có cấu trúc ngoại tuyến:** `SharedPreferences` chỉ lưu mảng String ID yêu thích. Cần có file seed JSON đóng gói sẵn (`destinations_seed.json`) và bộ nhớ đệm cục bộ bền vững khi mở rộng.
3. `[VERIFIED-CODE]` **Thiếu dữ liệu an toàn thực tế:** Cần tách bạch `safety_guidelines` và `route_stages` cho từng điểm đến riêng biệt, có cờ trạng thái kiểm chứng và nguồn gốc dữ liệu.
4. `[INFERRED-CODE]` **Rủi ro quốc tế hóa:** Không thể hỗ trợ các điểm đến quốc tế nếu tiếp tục sử dụng logic và dữ liệu hiện tại. Cần thiết kế cấu trúc đa quốc gia và xuyên biên giới ngay từ mô hình dữ liệu lõi.
