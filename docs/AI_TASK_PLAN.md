# BẢNG THEO DÕI TIẾN ĐỘ DỰ ÁN (AI_TASK_PLAN.md)

> **Quy ước trạng thái**:
> - `[ ]` Chưa bắt đầu.
> - `[~]` Đang thực hiện.
> - `[x]` Đã hoàn thành và kiểm chứng (Chỉ đánh dấu khi tiêu chí nghiệm thu đã được kiểm tra).
> - `[!]` Bị chặn hoặc cần người dùng quyết định.

---

## 1. Mục Tiêu & Phạm Vi Công Việc
- **Dự án**: TRAVEL_APP — Ứng dụng khám phá, phượt và sinh tồn ngoài trời thời gian thực (Offline-First).
- **Phạm vi hoàn thành**:
  - ✅ **Giai đoạn 0**: Bộ tài liệu kiến trúc, đặc tả tính năng, lộ trình và bộ quy tắc lập trình AI riêng biệt.
  - ✅ **Giai đoạn 1**: Ứng dụng di động Flutter Core, Bản đồ ngoại tuyến (`flutter_map` + `latlong2`), Định vị GPS phần cứng (`geolocator`), Cẩm nang sinh tồn offline.
  - ✅ **Giai đoạn 2**: Lập lịch trình chuyến đi (Trip Planner), Dự toán chi phí thực tế (tính hệ số dốc đèo), Dự báo thời tiết vi khí hậu (Open-Meteo), Checklist chuẩn bị đồ thông minh tự động sinh.
  - ✅ **Giai đoạn 3**: Bộ công cụ an toàn & cứu hộ SOS (Chớp đèn mã Morse SOS, Tự động soạn SMS cứu hộ kèm tọa độ GPS, Gọi khẩn cấp 114/115/113, Cảnh báo lũ quét & hạ thân nhiệt, La bàn & Altimeter, Chế độ siêu tiết kiệm pin OLED).
  - ✅ **Giai đoạn 4**: Bản Web Viewer đã biên dịch sẵn sàng (`build/web`), Bản dự phòng song hành React Native (Expo) sẵn sàng.

---

## 2. Giai Đoạn Hiện Tại & Trạng Thái Tổng Thể
- **Giai đoạn hiện tại**: **HOÀN THÀNH TOÀN BỘ CÁC GIAI ĐOẠN DỰ ÁN (ALL PHASES COMPLETED)**.
- **Trạng thái tổng thể**: `[x]` **Toàn bộ tính năng đã triển khai, kiểm thử tự động 100% Passed (0 lỗi, 0 cảnh báo), đã biên dịch thành công bản Web Viewer.**

---

## 3. Danh Sách Giai Đoạn & Checklist Thực Hiện

### Giai Đoạn 0: Khởi Tạo Tài Liệu & Quy Chuẩn (Foundation)
- [x] Tạo cấu trúc thư mục dự án `TRAVEL_APP`.
- [x] Hoàn thiện tài liệu tổng quan `README.md`.
- [x] Hoàn thiện đặc tả kiến trúc kỹ thuật `docs/01_ARCHITECTURE.md`.
- [x] Hoàn thiện đặc tả tính năng 5 phân hệ + 5 tính năng sinh tồn `docs/02_FUNCTIONAL_SPECS.md`.
- [x] Thiết lập lộ trình triển khai chi tiết `docs/03_ROADMAP.md`.
- [x] Ban hành quy tắc lập trình dự án `GEMINI.md` & `AGENTS.md`.
- [x] Khởi tạo file theo dõi tiến độ duy nhất `docs/AI_TASK_PLAN.md`.

### Giai Đoạn 1: MVP Cốt Lõi & Bản Đồ Ngoại Tuyến (Phase 1)
- [x] Chuẩn bị sẵn nền tảng dự phòng React Native Expo tại `TRAVEL_APP/mobile_react_native`.
- [x] Tải và cấu hình Flutter SDK 3.47.9 (Dart 3.13.7) vào `E:\flutter` và User PATH.
- [x] Khởi tạo dự án Flutter chính tại `TRAVEL_APP/mobile_flutter`.
- [x] Xây dựng kiến trúc thư mục Feature-first & Theme ngoài trời Pure Dark OLED (`AppTheme.outdoorDarkTheme`).
- [x] Xây dựng màn hình điều hướng chính (`MainNavigationScreen`) kết nối 5 phân hệ cốt lõi.
- [x] Tích hợp thư viện Bản đồ Dã ngoại (`flutter_map`, `latlong2`) và dịch vụ định vị vệ tinh (`LocationService` qua `geolocator`).
- [x] Vẽ cung đường trekking mẫu (Polyline Tà Năng - Phan Dũng) và các mốc sinh tồn (cửa rừng, nguồn nước suối, điểm cắm trại).
- [x] Cấu hình Local Storage (`StorageService` qua `SharedPreferences`) lưu trữ danh sách yêu thích và checklist offline.

### Giai Đoạn 2: Lập Kế Hoạch & Thời Tiết Vi Khí Hậu (Phase 2)
- [x] Phân hệ Trip Planner: Tính toán chi phí thực tế tự động theo 4 loại phương tiện, áp dụng hệ số đèo dốc x1.35.
- [x] Tích hợp dịch vụ dự báo thời tiết vi khí hậu Open-Meteo (`WeatherService`).
- [x] Thuật toán tự động sinh Checklist chuẩn bị đồ dã ngoại thông minh dựa trên nguy cơ thời tiết (mưa, bão, gió giật, nhiệt độ).

### Giai Đoạn 3: Bộ Công Cụ An Toàn Sinh Tồn (Phase 3)
- [x] Chế độ SOS khẩn cấp: Chớp đèn màn hình / flash theo chu kỳ mã Morse quốc tế (`··· --- ···`).
- [x] Tự động soạn tin nhắn SMS khẩn cấp chứa tọa độ GPS chính xác mở ứng dụng SMS mặc định (hoạt động khi chỉ có sóng 2G).
- [x] Tích hợp các nút gọi khẩn cấp 115 (Cấp cứu), 114 (Cứu nạn cứu hộ), 113 (Công an).
- [x] Phân tích và đưa ra cảnh báo sớm Lũ quét & Nguy cơ Hạ thân nhiệt thời gian thực.
- [x] La bàn số & Đo độ cao (Altimeter) so với mực nước biển.
- [x] Chế độ Siêu tiết kiệm pin ngoài trời (Pure Black OLED).
- [x] Cẩm nang sinh tồn ngoại tuyến 100%: Quy tắc xử lý rắn cắn, hạ thân nhiệt, nút dây, nước sạch, quy tắc STOP khi lạc rừng.

### Giai Đoạn 4: Web Viewer & Sẵn Sàng Vận Hành (Phase 4)
- [x] Biên dịch thành công bản Web Viewer tĩnh (`build/web`) để xem lịch trình, bản đồ và kỹ năng trực tiếp trên mọi trình duyệt web không cần cài app.
- [x] Tái thiết kế toàn diện UI/UX (Design System Obsidian Forest, AllTrails & Garmin HUD style, Hero Cards, Morse Beacon SOS).
- [x] Bản dự phòng song hành React Native (Expo) đã sẵn sàng.
- [x] Tạo file khởi chạy nhanh `run_app.bat` (chạy dạng App Desktop) và `run_web.bat` (mở trên tab trình duyệt).
- [x] Đã khởi chạy máy chủ web nền và mở trực tiếp tab trình duyệt tại `http://localhost:8080`.
- [x] Kết nối Git và đẩy toàn bộ mã nguồn lên GitHub tại: https://github.com/dainghia0127/TRAVEL_APP (branch: main).

---

## 4. Công Việc Đang Thực Hiện
- Toàn bộ các công việc trong phạm vi dự án đã hoàn thành và kiểm chứng thành công.

---

## 5. Kết Quả Kiểm Thử Thực Tế
- **`flutter analyze`**: **`No issues found!`** (0 lỗi, 0 cảnh báo).
- **`flutter test`**: **`All tests passed!`** (100% test pass).
- **`flutter build web`**: **Biên dịch thành công** thư mục phân phối web tại `TRAVEL_APP/mobile_flutter/build/web`.

---

## 6. Các File Dự Án Chính
```text
TRAVEL_APP/
├── GEMINI.md                                 # 10 quy tắc lập trình AI riêng cho TRAVEL_APP
├── AGENTS.md                                 # Bản chuẩn hóa quy tắc cho coding agents
├── README.md                                 # Tổng quan dự án & sứ mệnh
├── TRAVEL_APP_PLAN.md                        # Kế hoạch ban đầu
├── docs/
│   ├── 01_ARCHITECTURE.md                    # Kiến trúc kỹ thuật & chiến lược bản đồ offline
│   ├── 02_FUNCTIONAL_SPECS.md                # Đặc tả 5 phân hệ cốt lõi & 5 tính năng an toàn
│   ├── 03_ROADMAP.md                         # Lộ trình 4 giai đoạn
│   └── AI_TASK_PLAN.md                       # File theo dõi tiến độ duy nhất
├── mobile_react_native/                      # Bản dự phòng React Native Expo
└── mobile_flutter/                           # Ứng dụng di động chính Flutter
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── theme/app_theme.dart          # Pure Dark OLED Theme ngoài trời
    │   │   ├── constants/app_constants.dart  # Hằng số, danh mục, số khẩn cấp
    │   │   └── services/storage_service.dart # Local storage SharedPreferences
    │   └── features/
    │       ├── home/screens/main_navigation_screen.dart
    │       ├── explore/screens/explore_screen.dart
    │       ├── offline_map/
    │       │   ├── screens/offline_map_screen.dart
    │       │   └── services/location_service.dart
    │       ├── trip_planner/screens/trip_planner_screen.dart
    │       ├── outdoor_skills/screens/outdoor_skills_screen.dart
    │       ├── safety/screens/safety_sos_screen.dart
    │       └── weather_safety/services/weather_service.dart
    └── build/web/                            # Bản Web Viewer hoàn chỉnh
```

---

## 7. Bước Tiếp Theo
- Bàn giao sản phẩm hoàn chỉnh cho người dùng nghiệm thu. Hướng dẫn cách chạy trên máy tính (Windows desktop / Web) hoặc điện thoại thật.
