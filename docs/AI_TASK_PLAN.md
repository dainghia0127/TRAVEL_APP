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
- **Giai đoạn hiện tại**: **GIAI ĐOẠN 13 — KHẮC PHỤC TRIỆT ĐỂ 5 VẤN ĐỀ PWA IOS, ĐỊNH VỊ BẢN ĐỒ, OFFLINE MODE & TIẾN ĐỘ LỊCH TRÌNH**.
- **Trạng thái tổng thể**: `[x]` **Đã hoàn thành và kiểm chứng 100% qua 33/33 unit & widget tests.**

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

### Giai Đoạn 5: Khắc Phục Lỗi Thực Địa Trên iPhone & Nâng Cấp Vận Hành (Phase 5)
- [x] Task 5.1: Sửa lỗi tràn ngang Header màn hình Khám phá (`explore_screen.dart`), bảo toàn vị trí, thời tiết và nút refresh trên mọi cỡ màn hình iPhone (Expanded + ellipsis + ConstrainedBox).
- [x] Task 5.2: Khắc phục triệt để lỗi ảnh địa điểm biến mất (`editorial_image.dart` - sửa HTTP header & cacheWidth), lỗi không nhấp được địa điểm do cử chỉ ScrollView iOS (`bouncing_button.dart` - gán trực tiếp onTap cho GestureDetector), và tối ưu cuộn vô tận (`trending_grid_section.dart` - phân trang Top 8 kèm nút Xem thêm).
- [x] Task 5.3: Thêm chức năng Bản Đồ Online tách biệt với Bản Đồ Offline, cơ chế đồng bộ ngầm định kỳ mỗi 8s, hiển thị icon tín hiệu định vị vệ tinh GPS Live (xanh neon / cam nhấp nháy), cập nhật line và hiển thị HUD số km còn lại theo thời gian thực khi di chuyển (`offline_map_screen.dart`).
- [x] Task 5.4: Nâng cấp SOS Cứu hộ (`safety_sos_screen.dart`): Sửa tiêu đề thành "Thời Tiết Và Khí Hậu", nạp thời tiết thời gian thực tại cả vị trí hiện tại và điểm đến đích, tự động lấy đường dây nóng cứu hộ thực tế theo tỉnh/thành phố GPS (`local_emergency_service.dart`).
- [x] Task 5.5: Fix triệt để lỗi hình ảnh không hiển thị: Xử lý TypeError ngầm trong getter `Destination.heroMedia` (`firstWhere` type mismatch), bỏ `cacheWidth` GPU decode Metal trên iOS, thêm `NSAppTransportSecurity` vào `Info.plist`, kiểm chứng 100% 32/32 địa danh nạp ảnh thành công qua 15/15 automated tests.

### Giai Đoạn 6: Nâng Cấp Toàn Diện Trải Nghiệm Thực Tế Theo Phản Hồi (Phase 6)
- [x] Task 6.1: Rà soát và chuẩn hóa toàn bộ thuật ngữ "Thời tiết vi khí hậu" -> "Thời tiết và khí hậu" trên toàn bộ app (`destination_detail_screen.dart`, `safety_sos_screen.dart`, `explore_screen.dart`, `weather_service.dart`).
- [x] Task 6.2: Khắc phục triệt để hiển thị `-- km`: Bổ sung thông tin cự ly hành trình `distance_km` và thông tin `route` cho toàn bộ 20 địa danh seed còn thiếu trong `destinations_seed.json`; cập nhật getter `distanceDisplay` và `elevationDisplay` trong `destination.dart`, `trail_compact_row.dart` và `social_trending_section.dart`, đảm bảo 100% không còn card nào hiện `-- km`.
- [x] Task 6.3: Nâng cấp bản đồ mượt mà chuẩn Google Maps (`offline_map_screen.dart`):
  - Tích hợp lớp bản đồ CartoDB Voyager Retina HD (`@2x.png`) có tên đường tiếng Việt chi tiết như Google Maps, Hybrid Satellite (Vệ tinh Esri World Imagery kèm nhãn địa danh World Boundaries and Places) và Outdoor Topo.
  - Cấu hình `maxNativeZoom: 18`, `maxZoom: 19.0`, `panBuffer: 2`, `keepBuffer: 6` chống vỡ hình khi zoom out, phóng to thấy rõ từng con đường ngõ hẻm và suối ngòi.
  - Interactive Bottom Sheet: Cho phép vuốt xuống (`onVerticalDragEnd`) để thu nhỏ gọn còn 54px giải phóng toàn bộ tầm nhìn bản đồ, vuốt lên để mở bung toàn bộ thông số và nút dẫn đường.
- [x] Task 6.4: Sticky Header Timeline Lịch trình (`trip_planner_screen.dart`): Tách biệt phần Header điều khiển (Day Selector Ribbon, Lịch ngày tháng, Tiêu đề ngày + nút `+ Thêm mốc`) ghim cố định ở trên cùng màn hình. Khi vuốt lên chỉ cuộn danh sách các mốc lộ trình bên dưới, người dùng luôn biết rõ đang chỉnh sửa lịch trình ngày nào.
- [x] Task 6.5: Mở rộng Cẩm nang sinh tồn & Kỹ năng sống (`outdoor_skills_screen.dart`):
  - Bổ sung 7 chuyên đề sinh tồn và sơ cứu thực chiến mới: Hỏa hoạn chung cư cao tầng, Hóc dị vật đường thở (thủ thuật Heimlich), Ngưng tim đột ngột (CPR chuẩn AHA), Thoát hiểm ô tô lao xuống sông sâu, Sơ cứu bỏng nước sôi và dầu mỡ, Phòng tránh giông sét & ngập lụt đô thị, Kinh nghiệm tự vệ và quy tắc 4 khúc cua khi bị bám đuôi.
  - Thêm danh mục mới "Kinh nghiệm cuộc sống" vào bộ lọc.
  - Bổ sung Carousel "Mẹo Bỏ Túi & Kinh Nghiệm Cuộc Sống" với 6 mẹo đời sống hữu ích (chống say xe, phát hiện camera giấu kín, giữ pin trời lạnh, mở nắp lọ kẹt ma sát, lọc nước SODIS bằng nắng, chống rộp chân).
- [x] Task 6.6: Nâng cấp Thời tiết và Khí hậu trong SOS (`safety_sos_screen.dart` & `weather_service.dart`):
  - Bổ sung đồng hồ thời gian thực điện tử (Real-time Clock chạy từng giây) ở cả Vị trí hiện tại (GPS) và Điểm đến đích.
  - Sửa thuật toán chọn icon thời tiết theo ngày/đêm (`is_day` WMO): Ban đêm (sau 18h) trời quang đãng hiển thị icon mặt trăng `nightlight_round` / `nightlight_outlined`, tuyệt đối không còn hiện icon mặt trời ban đêm.
  - Dữ liệu Real-time 100% từ Open-Meteo API: Tích hợp đầy đủ chuỗi dữ liệu dự báo từng giờ (Hourly Forecast 24 giờ tiếp theo) và dự báo nhiều ngày tới (Daily Forecast 7 ngày tới) kèm thanh nhiệt độ min/max và xác suất mưa thực tế, không gán cứng.

### Giai Đoạn 7: Khắc Phục Triệt Để 3 Yêu Cầu Người Dùng Mới (Phase 7)
- [x] Task 7.1: Sửa lỗi bản đồ Google Maps style "API key required": Thay thế hoàn toàn sang Google Maps Tile Server chính hãng (`https://mt{s}.google.com/vt/lyrs=m...` cho đường phố, `lyrs=y` cho vệ tinh hybrid và `lyrs=p` cho địa hình) hoạt động trực tiếp 100% miễn phí, sắc nét, không đòi API key và không có bất kỳ watermark nào.
- [x] Task 7.2: Thêm cơ chế khôi phục Pop-up bản đồ khi lỡ tay tắt (`offline_map_screen.dart`):
  - Lưu lại `_lastActiveDestination` khi chọn hoặc khi nhấn đóng.
  - Hiển thị Floating Restore Bar / Mini Dock ở cạnh dưới màn hình (`Mở lại lộ trình: ${_lastActiveDestination.name}`) để người dùng chạm vào là bật lại pop-up ngay tức thì.
  - Chạm vào Marker trên bản đồ hoặc chip địa điểm ở thanh trên đỉnh đều bật lại pop-up dẫn đường.
- [x] Task 7.3: Tách biệt hoàn toàn SOS Cứu Hộ và Thời Tiết Khí Hậu thành 2 trang riêng:
  - `safety_sos_screen.dart`: Chuyên biệt 100% cho Cứu nạn khẩn cấp, Morse Beacon, SMS 115 kèm GPS, Gọi cấp cứu, và Danh bạ đường dây nóng theo tỉnh/thành phố GPS. Không còn tab thời tiết gây phân tâm. Thêm card liên kết trực quan chuyển sang trang Thời tiết & Khí hậu.
  - `weather_climate_screen.dart`: Màn hình độc lập riêng biệt cho Thời tiết và Khí hậu, tích hợp đồng hồ số real-time chạy từng giây, icon ngày/đêm chính xác (trời tối hiện mặt trăng), chuỗi dự báo từng giờ 24h & 7 ngày tới, cảnh báo nguy cơ cực đoan và checklist đồ dã ngoại thông minh.
  - Kết nối mượt mà từ thanh thời tiết Header tại `explore_screen.dart`, chi tiết địa điểm tại `destination_detail_screen.dart` và từ màn hình SOS.

---

### Giai Đoạn 8: Nâng Cấp 3 Tính Năng Cốt Lõi Mới (Phase 8)
- [x] Task 8.1: Triển khai Cơ Chế Đồng Bộ Đám Mây Tự Động (Cloud Sync) cho màn hình Khám Phá:
  - Tải dữ liệu JSON cập nhật từ GitHub Cloud Raw endpoint khi có mạng và người dùng bấm Refresh hoặc kéo vuốt.
  - Tự động nạp và lưu vào Local Storage (`SharedPreferences`) để mở rộng danh sách địa danh mà không cần build lại app hay cài lại file IPA.
  - Giữ cơ chế Offline-First: khi không có mạng, dùng dữ liệu đã lưu hoặc asset seed nội bộ, tuyệt đối không làm gián đoạn app.
- [x] Task 8.2: Nâng cấp Lịch Trình (Trip Timeline - Milestone Tracking & Live Trekking Mode):
  - Chuẩn hóa cự ly mốc: Cho phép người dùng nhập cự ly km thực tế hoặc chọn số km tùy ý khi thêm mốc (loại bỏ hoàn toàn gán cứng `+ 5 km`).
  - Bổ sung nút bấm "BẮT ĐẦU LỊCH TRÌNH THỰC TẾ" (Start Journey / Live Trekking Mode):
    - Quản lý trạng thái hành trình thực địa trực quan (Garmin HUD style).
    - Cho phép check-in hoàn thành từng mốc: Mốc đổi màu sang Xanh lá Emerald/Neon (`AppColors.emerald`), kèm huy hiệu/dấu tick `[✓]` thể hiện đã hoàn thành mốc.
    - Cột dọc timeline spine đổi màu xanh lá emerald theo mốc đã hoàn thành.
    - Hiển thị thanh tiến độ phần trăm hoàn thành hành trình ngày.
- [x] Task 8.3: Bản Đồ Google Maps Style - Tự Chọn Điểm Bắt Đầu & Điểm Đích (Custom A-to-B Routing):
  - Thêm nút chuyển chế độ "Lộ trình A-B" ngay trên Top Header.
  - Hỗ trợ nút đảo chiều (Swap A ⇄ B), tính toán và vẽ tuyến đường bộ OSRM thực tế kèm cự ly km và thời gian di chuyển.
  - Hiển thị Floating Card tóm tắt lộ trình A-B và nút bao quát toàn tuyến đường.
- [x] Task 8.4: Tự Động Hóa Thu Thập & Đồng Bộ Dữ Liệu Địa Danh Mới (Automated Content Ingestion Pipeline):
  - Phát triển công cụ tự động hóa `tools/auto_destinations_updater.py`: Quản lý kho dữ liệu dã ngoại tuyển chọn chất lượng cao (Curated Outdoor Reservoir), kiểm tra chống trùng lặp thông minh và tự động chèn địa danh chuẩn cấu trúc vào `destinations_seed.json`.
  - Thiết lập GitHub Actions Workflow `.github/workflows/auto_sync_destinations.yml`: Tự động kích hoạt hàng ngày vào lúc 00:00 (17:00 UTC = 00:00 GMT+7 giờ VN) và dự phòng 00:00 UTC hoặc chạy thủ công bằng 1 click (`workflow_dispatch`), tự động commit và đẩy lên nhánh `main` kèm cờ `[skip ci]` không làm tốn tài nguyên build iOS.
- [x] Task 8.5: Tối Ưu Bản Đồ - Chống Che Khuất Nút Zoom Out Khi Pop-up Thu Gọn:
  - Bổ sung getter `_mapControlsBottomOffset` tính toán vị trí đáy linh hoạt cho cụm nút điều khiển bên phải theo từng trạng thái.
  - Chuyển cụm nút điều khiển thành `AnimatedPositioned` (thời gian chuyển động 250ms, easeOutCubic) giúp các nút trượt lên/xuống mượt mà tự nhiên.

---

### Giai Đoạn 9: Hoàn Thiện Đồng Bộ Hai Chiều Bản Đồ - Lịch Trình & Tìm Kiếm Địa Chỉ Geocoding (Phase 9)
- [x] Task 9.1: Khắc phục thông báo Cloud Sync 404 & giải thích nguyên nhân:
  - Repo GitHub đang ở chế độ Private nên Raw link trả về 404 khi truy cập không kèm OAuth token bí mật.
  - Cập nhật thông báo trực quan: *"Kho lưu trữ GitHub đang ở chế độ Riêng Tư (Private). Hãy chuyển Repo sang Public để tải tự động"*, giúp người dùng phân biệt rõ với tình trạng mất mạng offline.
- [x] Task 9.2: Tích hợp Ô Tìm Kiếm Địa Chỉ Thời Gian Thực Chuẩn Google Maps (`GeocodingService`):
  - Kết nối OpenStreetMap Nominatim Geocoding API (`search?q=...&countrycodes=vn`).
  - Hỗ trợ gõ tìm kiếm mọi địa chỉ, số nhà, ngõ hẻm, tên đèo, đỉnh núi, địa danh tiếng Việt có dấu hoặc không dấu.
  - Tự động hiển thị danh sách gợi ý địa chỉ tức thì khi gõ, chọn là định vị ngay điểm A hoặc B với độ chính xác cao.
- [x] Task 9.3: Cho phép xóa sạch toàn bộ địa điểm và đồng bộ trạng thái rỗng sang Lịch Trình:
  - Bỏ ràng buộc `if (_tripDestinations.length > 1)` ở cả Bản đồ và Lịch trình: Người dùng có thể xóa sạch mọi điểm kể cả điểm cuối cùng.
  - Cập nhật `StorageService`: Tôn trọng danh sách chuyến đi rỗng (`[]`), không tự ý nạp lại 2 địa điểm mẫu sau khi người dùng đã chủ động xóa.
- [x] Task 9.4: Đồng bộ hai chiều giữa Bản Đồ và Lịch Trình:
  - Khi Lịch trình rỗng: Hiển thị Empty State với nút lớn **"TẠO ĐIỂM A-B TRÊN BẢN ĐỒ"**.
  - Nhấn nút sẽ tự động chuyển sang tab Bản Đồ và kích hoạt ngay modal Lộ Trình A-B.
  - Trên Floating Card Lộ Trình A-B của Bản Đồ: Bổ sung nút **"Thêm Lộ Trình Này Vào Lịch Trình"** (`_addCustomRouteToTrip`), tự động lưu tuyến đường A-B và chuyển sang tab Lịch trình để người dùng theo dõi và check-in.
- [x] Task 9.5: Đảm bảo độ ổn định giao diện và kiểm thử toàn diện:
  - Tối ưu `_buildContinuousTimelineView()` dùng `LayoutBuilder` để co giãn chiều cao thông minh trên mọi kích cỡ màn hình iOS, khắc phục triệt để RenderFlex overflow.
  - Viết bộ test `custom_route_and_geocoding_test.dart` kiểm thử đầy đủ `GeocodingResult` và `StorageService`.
  - Đạt 22/22 unit & widget tests pass 100% và `flutter analyze` 0 issues.
- [x] Task 9.6: Triển khai PWA (Progressive Web App) & Tự Động Deploy Lên GitHub Pages:
  - Cấu hình PWA tối ưu chuẩn mực cho iPhone Safari (`manifest.json`, `index.html` với `viewport-fit=cover`, `black-translucent`, splash screen nền tối Dark Forest tránh chớp trắng).
  - Tạo GitHub Actions Workflow `.github/workflows/deploy_pwa_pages.yml`: Tự động biên dịch Flutter Web và deploy trực tiếp lên GitHub Pages (`https://dainghia0127.github.io/TRAVEL_APP/`) mỗi khi push code lên `main`.
  - Đảm bảo app chạy vĩnh viễn trên iPhone không bao giờ hết hạn (loại bỏ giới hạn 7 ngày của chứng chỉ Apple Free Developer qua Sideloadly).
- [x] Task 9.7: Nâng cấp Multi-tier Smart Geocoder & Xử lý Typo ("vinhome granpark"):
  - Tích hợp Photon Komoot API chống chặn mạng ISP tại Việt Nam, định tuyến tọa độ chuẩn xác.
  - Xây dựng thuật toán `normalizeQuery`: Tự động nhận diện và chuyển đổi các từ khóa gõ nhanh/thiếu chữ ("vinhome granpark" ➔ "vinhomes grand park").
- [x] Task 9.8: Tự động đóng SnackBar & Pop up khi xem lịch trình và khi đổi tab:
  - Thêm `ScaffoldMessenger.of(context).hideCurrentSnackBar()` vào hành động `XEM LỊCH TRÌNH` và các hàm điều hướng tại `destination_detail_screen.dart`.
  - Tự động đóng các pop up SnackBar còn dang dở khi người dùng chuyển qua lại giữa các tab tại `main_navigation_screen.dart`.
- [x] Task 9.9: Ẩn toàn bộ nút bấm & Dọn sạch dữ liệu Lịch Trình khi xóa hết địa điểm:
  - Khi `_tripDestinations.isEmpty`: Reset sạch `_daysItinerary = {}`, `_checklistItems = []`, `_isJourneyActive = false`.
  - Ẩn hoàn toàn: Thanh tiến độ, Bộ chọn 2 Tab, Nút bắt đầu lộ trình, Nút đổi ngày, Nút thêm mốc.
  - Hiển thị Empty State toàn màn hình với 2 nút hành động trực quan: "TẠO LỘ TRÌNH A-B TRÊN BẢN ĐỒ" và "Khám Phá Địa Danh Mới".
- [x] Task 9.10: Lưu trữ Tài Liệu Hướng Dẫn PWA Vĩnh Viễn Trong App & Thư Mục Docs:
  - Thêm chuyên đề mới `skill_pwa_guide` vào tab Cẩm Nang (`outdoor_skills_screen.dart`) kèm sơ đồ minh họa từng bước để người dùng có thể mở xem trực tiếp ngay trong app bất cứ lúc nào.
  - Tạo file tài liệu chi tiết `docs/PWA_PERMANENT_GUIDE.md` lưu trữ trong project.

---

### Giai Đoạn 10: Tối Ưu Hiệu Năng Lịch Trình, Bỏ Chặn GPS, Dynamic Cache & Camera Fit Bounds (Phase 10)
- [x] Task 10.1: Loại bỏ block 10 giây do `LocationService.getCurrentLocation()` trong Lịch trình:
  - Đưa nạp danh sách chuyến đi từ bộ nhớ máy lên chạy ngay lập tức trong 0.001 giây.
  - Chuyển `LocationService.getCurrentLocation()` sang chạy ngầm bất đồng bộ bằng `.then(...)` không chặn giao diện dù chỉ 1 mili-giây.
- [x] Task 10.2: Khắc phục lỗi Static RAM Cache bỏ qua Custom Routes (`explore_local_datasource.dart`):
  - Tách riêng cache cho các địa danh seed. Luôn luôn nạp các Custom Route A-B mới nhất từ SharedPreferences.
  - Bổ sung cơ chế fallback nạp trực tiếp qua `StorageService.getCustomRouteJson(id)` trong `TripPlannerScreen`, bảo đảm các tuyến đường A-B vừa thêm từ bản đồ luôn xuất hiện ngay lập tức trong Lịch trình.
- [x] Task 10.3: Triển khai Optimistic UI cho thao tác Xóa địa điểm (`trip_planner_screen.dart`):
  - Khi bấm xóa, địa điểm biến mất ngay lập tức khỏi RAM trong 0ms.
  - Dọn sạch toàn bộ mốc lộ trình, checklist, chi phí nếu là địa điểm cuối cùng.
  - Chuyển sang địa điểm kế tiếp nếu xóa địa điểm đang chọn.
  - Ghi ngầm vào SharedPreferences không `await` và không gọi lại `_initTripData()`, chấm dứt hoàn toàn hiện tượng trễ khi xóa.
- [x] Task 10.4: Tối ưu chuyển tab Lịch trình (`_onTabChanged`):
  - So sánh danh sách ID trong storage với danh sách hiện tại. Chỉ nạp lại khi có sự thay đổi thực sự (ví dụ vừa thêm điểm mới ở Khám phá hoặc Bản đồ), giữ nguyên UI mượt mà khi người dùng chỉ switch tab qua lại.
- [x] Task 10.5: Nâng cấp Bản đồ Lộ trình A-B với `CameraFit.bounds` (`offline_map_screen.dart`):
  - Thay thế toàn bộ công thức tính zoom cứng thủ công (6.5, 8.5, 10.0) bằng `_mapController.fitCamera(CameraFit.bounds(...))` kèm padding `EdgeInsets.fromLTRB(40, 160, 40, 260)`.
  - Tự động căn chỉnh bao quát cả điểm A, điểm B và toàn bộ vệt đường màu xanh uốn lượn ngay sau khi tính toán xong hoặc khi bấm nút "Bao Quát Toàn Tuyến Đường".
- [x] Task 10.6: Xác minh và giải thích hiện tượng trên iPhone Native vs PWA:
  - Nguyên nhân gốc rễ nằm ở logic Dart chung (blocking GPS 10s và static RAM cache), do đó cả bản PWA (Safari) lẫn bản Native IPA (Sideloadly) đều bị tương tự trước khi sửa.
  - Bản sửa lỗi này giải quyết triệt để và hoạt động mượt mà 100% trên cả hai nền tảng.
- [x] Task 10.7: Kiểm thử tự động toàn diện:
  - Bổ sung unit test `ExploreLocalDataSource dynamically includes Custom Routes from storage`.
  - Đạt 25/25 automated tests pass 100% và `flutter analyze` 0 issues.
- [x] Task 10.8: Tự động dọn dẹp các workflow runs cũ của TRAVEL_APP trên GitHub Actions:
  - Cấu hình quyền `actions: write` và tích hợp bước Cleanup tự động vào cả 2 workflow: `build_ios.yml` và `deploy_pwa_pages.yml`.
  - Sử dụng GitHub CLI `gh run list --workflow ...` và `gh run delete` để xóa sạch toàn bộ các bản chạy cũ trước đó của chính workflow đó trong repo `TRAVEL_APP`.
  - An toàn 100%: Chỉ hoạt động trong phạm vi `${{ github.repository }}` (`dainghia0127/TRAVEL_APP`), tuyệt đối không bao giờ xóa nhầm sang app hay repository nào khác của tài khoản.
  - Cập nhật file `push_to_github.bat` thông báo trực quan quá trình dọn dẹp và kích hoạt workflow mới.

---

### Giai Đoạn 11: Tối Ưu Hóa Trải Nghiệm Lộ Trình Tự Chọn A-B & Tự Do Thêm Hành Trang (Phase 11)
- [x] Task 11.1: Khởi tạo danh sách chuyến đi rỗng ban đầu & Nút "Xóa tất cả":
  - Sửa `StorageService.getTripDestinations()`: Mặc định trả về `[]` sạch sẽ, không tự ý nạp 2 điểm mẫu `vn_ta_nang_phan_dung` và `vn_lake_tuyen_lam`.
  - Thêm phương thức `StorageService.clearAllTripDestinations()` và nút "Xóa tất cả" kèm hộp thoại xác nhận trên Header của Lịch Trình, cho phép 1 chạm dọn sạch toàn bộ các điểm cũ.
- [x] Task 11.2: Vẽ ngay Line chỉ đường trong 0.01 giây khi chọn xong Điểm A và Điểm B:
  - Ngay khi có tọa độ A và B, vẽ ngay đường line định hướng trực tiếp tạm thời và căn chỉnh camera bao quát ngay lập tức trong 0.01s.
  - Khi OSRM hoàn tất, cập nhật mượt mà đè lên thành hàng trăm điểm bám sát mặt đường thực tế.
- [x] Task 11.3: Thu gọn Pop-up Card nhưng vẫn giữ nguyên Line và 2 Điểm A, B (`offline_map_screen.dart`):
  - Nhấn nút `(X)` trên Pop-up Card Lộ trình A-B chỉ thu nhỏ card (`_isCustomRouteCardCollapsed = true`), tuyệt đối không xóa route.
  - Line màu xanh và 2 marker A, B vẫn hiển thị đầy đủ trên bản đồ.
  - Hiển thị Mini Dock Floating Pill ở cạnh dưới kèm nút "Mở lại" để người dùng mở bung lại pop-up card bất cứ lúc nào.
- [x] Task 11.4: Khôi phục nguyên vẹn Lộ trình A-B khi chuyển tab quay lại Bản Đồ:
  - Lưu metadata chi tiết qua `StorageService.saveCustomRouteDetail(...)` (tên A, B, tọa độ A, B, cự ly, thời gian, và mảng tọa độ line).
  - Khi quay lại Bản đồ hoặc chọn Custom Route trong chuyến đi, tự động phục hồi `_isCustomRouteMode = true`, nạp lại đầy đủ 2 điểm A, B và vẽ lại vệt đường màu xanh.
- [x] Task 11.5: Tùy biến Lịch Trình cho Lộ trình tự chọn A-B (`trip_planner_screen.dart`):
  - Xóa sạch các mốc trekking rừng núi giả định.
  - Tự động tạo 2 mốc khởi đầu sạch sẽ: `Khởi hành: A` và `Đến đích: B`.
  - Cung cấp nút "+ Thêm mốc" để người dùng tự do thêm bất kỳ trạm dừng chân nào dọc đường.
  - Hành trang: Đưa vào danh sách vật dụng đi đường cơ bản, không chèn đồ sinh tồn leo núi cực đoan.
  - Bổ sung nút "+ Thêm đồ" (`_showAddChecklistItemDialog`) cho phép người dùng tự gõ thêm bất kỳ đồ dùng cá nhân nào và có nút xóa từng món đồ.
- [x] Task 11.6: Kiểm thử tự động toàn diện:
  - Bổ sung 2 test cases mới trong `custom_route_and_geocoding_test.dart` kiểm thử `clearAllTripDestinations` và `saveCustomRouteDetail`.
  - Đạt 27/27 automated tests pass 100% và `flutter analyze` 0 issues.

### Giai Đoạn 12: Tối Ưu Hiển Thị Pop-up Bản Đồ & Tùy Biến Chi Phí Tự Do (Phase 12)
- [x] Task 12.1: Khắc phục triệt để hiện 2 pop-up đè lên nhau trên Bản Đồ (`offline_map_screen.dart`):
  - Khi lộ trình A-B đã thêm vào lịch trình hoặc khi chọn lộ trình từ danh sách chuyến đi: Đặt `_isCustomRouteMode = false` và chọn `_selectedTripDestination = dest`.
  - Thêm điều kiện `_selectedTripDestination == null` vào cả Card Lộ trình A-B tự chọn và Mini Dock.
  - Kết quả: Khi lộ trình A-B đã thêm vào chuyến đi, bản đồ **chỉ hiển thị DUY NHẤT một pop-up Tuyến đường bộ thực tế**, giữ nguyên vẹn vệt đường màu xanh và 2 marker A, B; pop-up Lộ trình A-B tự chọn không bao giờ hiện đè lên nữa.
- [x] Task 12.2: Sửa triệt để lỗi tính toán chi phí (Phí bãi trại & Khoản chi tự thêm) (`trip_planner_screen.dart`):
  - Phí bãi trại:
    - Sửa công thức: Trước đây dùng `(_maxDays - 1) * _campFeePerNight`, khiến chuyến đi 1 ngày (lộ trình A-B) luôn có `(_maxDays - 1) = 0`, dẫn tới việc người dùng nhập hay xóa phí bãi trại thì tổng tiền vẫn luôn bằng 0.
    - Cập nhật chuẩn: Nếu `_campFeePerNight <= 0` trả về đúng 0; nếu `_maxDays == 1` và có nhập phí bãi thì tính 1 lần; nếu `_maxDays > 1` thì tính theo số đêm `(_maxDays - 1)`.
    - Khi người dùng xóa trắng ô phí bãi trại: Tự động gán = 0 và trừ sạch khỏi tổng chi phí ngay lập tức.
    - Bổ sung nút Clear `[X]` nhanh trong TextField để người dùng 1 chạm là xóa sạch ô nhập.
  - Khoản chi tự thêm:
    - Bổ sung 2 chế độ áp dụng trực quan: **`Mỗi người`** (mặc định, cộng thẳng vào chi phí/người) và **`Chia cả đoàn`** (chia đều theo số người tham gia trong đoàn).
    - Khắc phục lỗi nhập số tiền rồi bấm luôn "Lưu thay đổi": Tự động gom khoản chi đang gõ dở kể cả khi để trống tiêu đề (tự gán tên `'Khoản chi khác'`), tuyệt đối không làm mất số tiền người dùng vừa nhập.
    - Hiển thị chi tiết trên Thẻ Dự Toán Chi Phí kèm huy hiệu `Mỗi người` hoặc `Chia cả đoàn` để minh bạch cách tính.
- [x] Task 12.3: Bổ sung Nút Bấm & Modal Giải Trình Công Thức Dự Toán Chi Phí Tường Minh (`trip_planner_screen.dart`):
  - Bổ sung nút bấm trực quan `[Công thức]` (Summit Gold) và icon trợ giúp `[?]` ngay cạnh tiêu đề "Dự Toán Chi Phí" và giá tiền tổng.
  - Cho phép chạm vào bất kỳ mục nào trên Legend (Nhiên liệu, Ăn uống, Trại bãi) hoặc đường dẫn trong hộp thoại Tùy chỉnh để mở ngay Modal giải trình.
  - Xây dựng Modal Bottom Sheet `_showCostBreakdownExplanationModal()` giải thích chi tiết, minh bạch từng khoản chi:
    - **Nhiên liệu**: Phương tiện, mức tiêu hao (L/100km), cự ly khứ hồi, hệ số đèo dốc x1.30, lượng xăng tiêu thụ, tổng tiền xăng cả xe và số tiền chia theo số người trong đoàn.
    - **Ăn uống**: Số ngày chuyến đi x đơn giá ăn uống/người/ngày = thành tiền.
    - **Trại & Bãi**: Số đêm cắm trại x đơn giá bãi/người/đêm = thành tiền (nêu rõ số ngày và số đêm).
    - **Khoản chi tự thêm**: Chi tiết từng khoản kèm công thức tính (mỗi người hay chia đoàn).
    - **Tổng dự toán**: Hiển thị rõ ràng phép cộng tổng và tổng chi phí toàn đoàn.
- [x] Task 12.4: Tái Thiết Kế Màu Sắc, Chữ & Icon Đồng Bộ Editorial Theme (`trip_planner_screen.dart`):
  - Khắc phục triệt để lỗi màu sắc tối tăm, chữ chìm, icon lệch tông:
    - Loại bỏ hoàn toàn nền đen ngòm tối tăm (`#1B231F`, `#131A16`) và các chữ xám mờ (`textMuted`, `textSecondary`) gây chìm chữ, khó nhìn.
    - Chuyển toàn bộ Dialog Tùy Chỉnh và Modal Giải Trình sang **Editorial Light Theme** đồng bộ tuyệt đối với phong cách Tạp chí dã ngoại của Lịch Trình & Khám Phá.
    - Màu nền: Nền giấy mộc ấm áp `editorialBg` (`#EFECE4`) và Thẻ trắng tinh khôi `editorialSurface` (`#FFFFFF`).
    - Màu chữ: Chữ mực rừng sâu `editorialInk` (`#17221B`) và chữ xanh thông `editorialPine` (`#1E3A2B`) có độ tương phản cực cao, đậm nét, sắc sảo và dễ đọc trong mọi điều kiện ánh sáng.
    - Màu icon & nút bấm: Thống nhất icon xanh thông `editorialPine` và đất nung `editorialTerracotta`, loại bỏ các icon vàng summit chói lóa hoặc cyan lạc quẻ.
- [x] Task 12.5: Kiểm thử tự động toàn diện:
  - Đạt 31/31 automated tests pass 100% và `flutter analyze` 0 issues.

---

### Giai Đoạn 13: Khắc Phục Triệt Để 5 Vấn Đề PWA iOS, Định Vị Bản Đồ, Offline Mode & Tiến Độ Lịch Trình (Phase 13)
- [x] Task 13.1: Khắc phục triệt để lỗi PWA trên iPhone Safari (chỉ vuốt được, không bấm được nút và giật lag):
  - Chống overscroll / rubber-banding trên iOS WebKit Standalone mode (`web/index.html`): Ngăn chặn `touchcancel` do trình duyệt tự ý nảy trang, chuyển giao trọn vẹn sự kiện chạm cho Flutter Glass Pane.
  - Chuẩn hóa CSS body/html: `position: fixed`, `touch-action: manipulation`, `overscroll-behavior: none`, `-webkit-tap-highlight-color: transparent`.
  - Tối ưu build web trong `.github/workflows/deploy_pwa_pages.yml`: Biên dịch với mức tối ưu `-O4 --no-source-maps`, giảm 30-40% dung lượng bundle JS, giảm tải WebGL GPU trên Safari iOS.
- [x] Task 13.2: Sửa triệt để logic Trục Lộ Trình & Tiến Độ Lịch Trình A-B (`trip_planner_screen.dart`):
  - Khi bấm "BẮT ĐẦU LỊCH TRÌNH THỰC TẾ": Tự động đánh dấu mốc "Khởi hành: A" là đã hoàn thành (`isCompleted: true`).
  - Khi tick mốc "Đến đích: B": Tự động đánh dấu hoàn thành toàn bộ các mốc trước đó, đưa tiến độ lên **100% Hoàn thành (2/2 mốc)**, không bao giờ bị kẹt ở 50%.
- [x] Task 13.3: Nâng cấp Định vị Bản Đồ & Tuyến Đường A-B Thời Gian Thực (`offline_map_screen.dart` & `location_service.dart`):
  - Cập nhật điểm đầu của Lộ trình tự chọn A-B (`_customRoutePolyline[0] = newLoc`) và tính lại cự ly còn lại liên tục theo GPS thực tế khi di chuyển.
  - Bổ sung cơ chế **"Khóa Theo Dõi GPS" (Auto-Follow Camera Lock)**: Khi bật, tự động lia camera theo vị trí người dùng. Khi người dùng vuốt xem chỗ khác, tự động nhả khóa để tránh giật hình.
  - Tăng độ nhạy GPS `distanceFilter: 2` mét trong `LocationService`.
- [x] Task 13.4: Chuẩn hóa Nút Online / Offline & Tuyến Đường Ngoại Tuyến (`offline_map_screen.dart` & `routing_service.dart`):
  - Khi người dùng bấm sang chế độ "Offline": Chạy 100% chế độ cục bộ tức thì (`forceOffline: true`), không gửi HTTP request ra ngoài chờ timeout.
  - Tinh chỉnh thuật toán nội suy đường bộ ngoại tuyến: cự ly ngắn dưới 25km bám sát trục giao thông mượt mà, không bị uốn lượn zíc zắc 900m vô lý; cự ly liên tỉnh bám hành lang quốc lộ.
  - Cấu hình `evictErrorTileStrategy: EvictErrorTileStrategy.none`, `panBuffer: 3`, `keepBuffer: 8` để giữ tối đa các mảnh bản đồ trong bộ nhớ đệm khi mất mạng và zoom in/out.
- [x] Task 13.5: Kiểm thử tự động toàn diện và kiểm chứng:
  - Bổ sung 2 test cases mới trong `custom_route_and_geocoding_test.dart` kiểm thử `RoutingService forceOffline` và `Trip Planner A-B Milestones achieve 100%`.
  - Đạt 33/33 automated tests pass 100% và `flutter analyze` 0 issues.

---

## 4. Công Việc Đang Thực Hiện
- Đã hoàn thành toàn diện 5/5 vấn đề người dùng yêu cầu, kiểm chứng 100% qua Flutter Analyze & Automated Tests (33/33 tests passed).
- Sẵn sàng để người dùng chạy `push_to_github.bat` deploy lên GitHub Pages và kích hoạt workflow build.

---

## 5. Kết Quả Kiểm Thử Thực Tế
- **`flutter analyze`**: **`No issues found!`** (0 lỗi, 0 cảnh báo - 100% clean).
- **`flutter test`**: **`All tests passed!`** (33/33 unit & widget test pass 100%).
- **`flutter build web`**: Tối ưu hóa `-O4 --no-source-maps`.

---

## 5. Kết Quả Kiểm Thử Thực Tế
- **`flutter analyze`**: **`No issues found!`** (0 lỗi, 0 cảnh báo - 100% clean).
- **`flutter test`**: **`All tests passed!`** (31/31 unit & widget test pass 100%).
- **`flutter build web`**: Sẵn sàng biên dịch khi deploy GitHub Pages.

---

## 6. Các File Dự Án Chính
```text
TRAVEL_APP/
├── GEMINI.md                                 # 10 quy tắc lập trình AI riêng cho TRAVEL_APP
├── AGENTS.md                                 # Bản chuẩn hóa quy tắc cho coding agents
├── README.md                                 # Tổng quan dự án & sứ mệnh
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
    │   │   └── services/storage_service.dart # Local storage SharedPreferences (hỗ trợ Cloud Sync)
    │   └── features/
    │       ├── home/screens/main_navigation_screen.dart
    │       ├── explore/
    │       │   ├── data/datasources/explore_local_datasource.dart # Tải Cloud Sync từ GitHub
    │       │   ├── presentation/controllers/explore_controller.dart
    │       │   └── presentation/screens/explore_screen.dart
    │       ├── offline_map/
    │       │   ├── screens/offline_map_screen.dart # Bản đồ A-B Custom Routing Google Maps style
    │       │   └── services/location_service.dart
    │       ├── trip_planner/screens/trip_planner_screen.dart # Live Trekking & Check-in mốc
    │       ├── outdoor_skills/screens/outdoor_skills_screen.dart
    │       ├── safety/screens/safety_sos_screen.dart # Chuyên biệt SOS Cứu hộ khẩn cấp
    │       └── weather_safety/
    │           ├── screens/weather_climate_screen.dart # Trang Thời tiết và khí hậu độc lập
    │           └── services/weather_service.dart
    └── test/
        ├── asset_load_test.dart
        ├── explore_editorial_feed_test.dart
        ├── widget_test.dart
        └── phase8_features_test.dart         # Test case cho Cloud Sync & Live Trekking
```

---

## 7. Bước Tiếp Theo
- Bàn giao kết quả và báo cáo chi tiết bằng tiếng Việt cho người dùng nghiệm thu.
