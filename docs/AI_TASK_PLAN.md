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
- **Giai đoạn hiện tại**: **GIAI ĐOẠN 9 — HOÀN THIỆN ĐỒNG BỘ HAI CHIỀU BẢN ĐỒ - LỊCH TRÌNH, TÌM KIẾM ĐỊA CHỈ GOOGLE MAPS GEOCODING & KHẮC PHỤC THÔNG BÁO CLOUD SYNC REPO PRIVATE**.
- **Trạng thái tổng thể**: `[x]` **Đã hoàn thành và kiểm chứng 100% qua 22/22 unit & widget tests.**

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

---

## 4. Công Việc Đang Thực Hiện
- Hoàn thành toàn bộ các yêu cầu của Giai Đoạn 8 bao gồm Cloud Sync, Live Trekking, Bản đồ A-B Custom Routing và Quy trình Tự động nạp địa danh mới (Data Pipeline).
- Sẵn sàng bàn giao và hướng dẫn người dùng vận hành.

---

## 5. Kết Quả Kiểm Thử Thực Tế
- **`flutter analyze`**: **`No issues found!`** (0 lỗi, 0 cảnh báo - 100% clean).
- **`flutter test`**: **`All tests passed!`** (22/22 unit & widget test pass 100%).
- **`flutter build web`**: Sẵn sàng biên dịch khi cần.

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
