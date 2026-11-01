# CÁC QUYẾT ĐỊNH THIẾT KẾ & ĐÁNH ĐỔI KỸ THUẬT (EXPLORE DESIGN DECISIONS)

> **Dự án:** TRAVEL_APP — Premium Global Travel Discovery Platform  
> **Tài liệu:** Nhật ký Quyết định Thiết kế (Architecture Decision Records - ADR)  
> **Mục đích:** Ghi nhận các quyết định kiến trúc then chốt, các phương án thay thế, các đánh đổi kỹ thuật và giải đáp dứt khoát 3 câu hỏi trọng tâm của dự án.

---

## 1. GIẢI ĐÁP DỨT KHOÁT 3 CÂU HỎI QUAN TRỌNG TỪ NGƯỜI DÙNG

### Câu hỏi 1: Mô hình dữ liệu có thực sự hỗ trợ toàn cầu không? Đặc biệt là địa điểm, vùng miền và cung đường xuyên nhiều quốc gia?

**Trả lời: CÓ, mô hình phiên bản 2.0 đã hỗ trợ toàn cầu thực tế và xuyên biên giới.**

- **Sửa sai triệt để mô hình cũ:** Phiên bản cũ đã sai lầm khi mô hình hóa "châu lục là vùng miền của một quốc gia". Phiên bản 2.0 thiết lập cấu trúc phân cấp chuẩn mực: `continents` $\to$ `countries` $\to$ `regions`.
- **Hỗ trợ Xuyên Biên Giới (Cross-border / Multi-country):**
  - Thực tế địa lý: Các điểm đến và cung đường dã ngoại nổi tiếng trên thế giới thường nằm trên biên giới (ví dụ: *Tour du Mont Blanc* đi qua Pháp, Ý, Thụy Sĩ; *Đỉnh Everest* nằm trên biên giới Nepal - Trung Quốc; *Thác Iguazu* nằm giữa Brazil và Argentina; *Dãy Andes* trải dài 7 quốc gia).
  - Giải pháp cơ sở dữ liệu: Loại bỏ cột khóa ngoại đơn `country_id` trong `destinations` và `trekking_routes`. Thay thế bằng hai bảng liên kết quan hệ nhiều - nhiều:
    - `destination_countries (destination_id, country_id, is_primary)`
    - `route_countries (route_id, country_id)`
- **Loại bỏ trường dư thừa `is_domestic` trong Database:**
  - Không lưu cứng boolean `is_domestic` trong bảng vì "trong nước" phụ thuộc vào người dùng. Đối với người dùng Việt Nam, Việt Nam là trong nước; đối với người dùng Nhật Bản, Nhật Bản là trong nước.
  - Trên ứng dụng Flutter, `isDomestic` là một thuộc tính phái sinh (computed getter): Một điểm đến thuộc tab "Trong Nước" nếu `destination.countryIds.contains(currentAppCountryCode)`.

---

### Câu hỏi 2: Dữ liệu có đủ đáng tin để người dùng đi thực tế không? Đặc biệt là thông tin nước uống, cứu hộ, thời tiết và cảnh báo an toàn?

**Trả lời: DỮ LIỆU ĐƯỢC THIẾT KẾ THEO CHÍNH SÁCH PHÒNG THỦ AN TOÀN SINH TỒN THỰC ĐỊA, KHÔNG MƠ HỒ, KHÔNG BỊA ĐẶT.**

- **Về Nguồn Nước:**
  - Tuyệt đối không dán nhãn POI nguồn nước trên OpenStreetMap (`natural=spring`, `amenity=drinking_water`) là "nước sạch uống ngay".
  - Mọi hiển thị về nguồn nước tự nhiên trên thực địa đều bắt buộc đi kèm cảnh báo: *"Chưa qua kiểm nghiệm vệ sinh. Bắt buộc đun sôi 3 phút hoặc dùng viên lọc Aquatabs / thiết bị lọc chuyên dụng trước khi uống"*.
  - Đối với các cung đường trekking như Tà Năng - Phan Dũng: Ghi rõ dữ liệu đo đạc thực tế: *"Đoạn sống lưng 12km từ đồi Lính đến dốc Dầu không có nguồn nước; suối có thể cạn vào mùa khô tháng 3 – tháng 5; khuyến cáo mang tối thiểu 2.5L nước/người/ngày"*.
- **Về Cứu Hộ & Số Điện Thoại Khẩn Cấp:**
  - Bảng `countries` lưu trữ số khẩn cấp theo từng quốc gia (`emergency_police`, `emergency_ambulance`, `emergency_fire`, `emergency_mountain_rescue`).
  - Khi xem điểm đến tại Việt Nam: Hiển thị 114 (Cứu nạn) và số trạm kiểm lâm vườn quốc gia.
  - Khi xem điểm đến tại Thụy Sĩ: Hiển thị 1414 (REGA Cứu hộ đường không trên núi) và 112.
  - Khi xem điểm đến tại Mỹ: Hiển thị 911.
  - Khi xem điểm đến tại Nhật Bản: Hiển thị 110/119.
  - Tuyệt đối không dùng số hotline Việt Nam cho điểm đến ở nước ngoài.
  - Trạm kiểm lâm (`ranger_station`) trên bản đồ được dán nhãn trạng thái: *"Trạm thực địa (Chưa xác minh có người trực 24/7)"*.
- **Về Thời Tiết:**
  - Dán nhãn minh bạch: *"Dự báo mô hình toán học (Open-Meteo) • Cập nhật lúc [HH:mm]"*.
  - Khuyến cáo rõ: Dự báo số trị lưới rộng không phải cảm biến tại chỗ, không loại trừ được rủi ro lũ quét bất ngờ ở khe suối hẹp hoặc lở đất cục bộ.
- **Loại bỏ hoàn toàn dữ liệu giả lập (No Fabricated Data):**
  - Không bịa số sao (4.9★), không bịa số review (284 reviews), không bịa giá vé, không bịa giờ mở cửa. Nếu chưa có dữ liệu, hiển thị trung thực *"Chưa có dữ liệu kiểm chứng"*.

---

### Câu hỏi 3: Kiến trúc có vừa đủ cho giai đoạn hiện tại không? Tránh xây dựng một hệ thống backend quá phức tạp khi catalog ban đầu vẫn còn nhỏ?

**Trả lời: CÓ, KIẾN TRÚC ĐƯỢC THIẾT KẾ THEO NGUYÊN TẮC "PRAGMATIC & PROGRESSIVE" (VỪA ĐỦ HIỆN TẠI, DỄ DÀNG MỞ RỘNG).**

- **Tránh bẫy Over-Engineering:**
  - Hiện tại catalog hạt nhân chỉ cần khoảng 16 điểm đến chất lượng cao (10 điểm Việt Nam, 6 điểm Quốc tế).
  - Chưa cần triển khai ngay hệ thống cụm Microservices, Kubernetes, Redis cluster hay triển khai Supabase Production ngay lập tức.
- **Giải pháp vừa đủ (Pragmatic Architecture) cho giai đoạn này:**
  - **Tầng Client-First bền vững:** Đóng gói toàn bộ catalog hạt nhân vào file `assets/data/destinations_seed.json` chuẩn hóa đầy đủ theo Schema mới.
  - **Không cần Internet vẫn chạy 100%:** Khi tải app về máy, ứng dụng đọc trực tiếp từ Seed JSON L0 và đưa vào In-Memory Cache L1. Không cần backend vẫn chạy mượt mà, đầy đủ tính năng.
  - **Tách biệt tầng dữ liệu theo Clean Architecture:** Tầng UI không đọc JSON trực tiếp mà gọi qua `ExploreRepository` và `ExploreLocalDataSource`. Khi sau này người dùng muốn kết nối với Supabase Cloud thật, chúng ta chỉ cần cài đặt `ExploreRemoteDataSource` mà không cần viết lại dù chỉ 1 dòng code ở tầng Giao diện (UI) hay Tầng nghiệp vụ (Domain).
  - **Quản lý dữ liệu cục bộ:** Dùng `SharedPreferences` cho Key-Value đơn giản (bookmarks, app settings, country code). Thiết kế sẵn hợp đồng Repository để khi catalog vượt quá 50–100 điểm có thể cắm SQLite (`sqflite`) vào tầng LocalDataSource một cách trong suốt.

---

## 2. NHẬT KÝ CÁC QUYẾT ĐỊNH THIẾT KẾ CỐT LÕI (ADRs)

### ADR-01: Tách bạch 3 thực thể `Destination`, `TrekkingRoute` và `PointOfInterest`
- **Ngữ cảnh:** Thiết kế ban đầu coi mọi điểm đến đều là một cung đường đi bộ, ép buộc các địa danh văn hóa/nghỉ dưỡng (như Sa Pa, Hallstatt) phải có cự ly đi bộ và độ khó.
- **Quyết định:** Tách thành 3 thực thể riêng biệt:
  - `Destination`: Vùng địa danh / khu vực du lịch.
  - `TrekkingRoute`: Tuyến đường dã ngoại cụ thể có GPX, cự ly và các chặng.
  - `PointOfInterest`: Điểm tọa độ cụ thể (đỉnh, nguồn nước, trạm kiểm lâm, bãi cắm trại).
- **Đánh đổi:** Cần nhiều bảng và class model hơn, nhưng đổi lại dữ liệu chính xác 100% với thực tế thế giới dã ngoại.

### ADR-02: Chuẩn hóa bảng quan hệ cho Lộ trình và An toàn thay vì dùng JSONB thô
- **Ngữ cảnh:** Bản thiết kế trước dùng cột `route_stages JSONB` và `safety_guidelines JSONB` trong bảng `destinations`.
- **Quyết định:** Chuẩn hóa thành các bảng quan hệ riêng `route_stages` và `safety_guidelines` có khóa ngoại trỏ tới `trekking_routes(id)`.
- **Lý do:** Cho phép ràng buộc tính toàn vẹn (ví dụ: `stage_number > 0`), có thể truy vấn tìm kiếm các cung đường theo loại địa hình hiểm trở, và mỗi hướng dẫn an toàn có trường `verification_date`, `verified_by` cụ thể.

### ADR-03: Sử dụng Bundled Seed Data (`destinations_seed.json`) cho phân hệ Explore
- **Ngữ cảnh:** Cần một nguồn dữ liệu ban đầu phong phú, chuẩn xác, chạy ngoại tuyến được ngay mà không bắt buộc người dùng phải có kết nối mạng và chưa cần cấu hình Supabase Cloud.
- **Quyết định:** Xây dựng catalog hạt nhân chuẩn hóa thành tệp JSON đóng gói trong asset của app.
- **Lý do:** Đảm bảo trải nghiệm tức thì (Zero-latency startup), an toàn tuyệt đối khi đi dã ngoại mất mạng, và dễ dàng kiểm thử tự động.

---

## 3. CÁC RỦI RO KỸ THUẬT & QUYẾT ĐỊNH CẦN NGƯỜI DÙNG PHÊ DUYỆT

### 3.1. Các rủi ro kỹ thuật còn tồn đọng (Unresolved Risks)
1. **Dữ liệu đường mòn của Esri Topo:** Lớp bản đồ Esri Topo không có sẵn các vệt mòn trekking chi tiết tại Việt Nam. *Giải pháp đề xuất:* Ứng dụng sẽ vẽ đè đường đi (Polyline overlay) từ tọa độ hoặc file GPX có sẵn trong catalog.
2. **Bản quyền ảnh Creative Commons:** Khi mở rộng lên hàng trăm điểm đến quốc tế, cần quy trình tự động hóa kiểm tra API Wikimedia Commons để đảm bảo link ảnh không bị tác giả xóa hoặc đổi giấy phép.

### 3.2. Danh sách các quyết định cần người dùng phê duyệt (Decisions Requiring Approval)
- [ ] **Phê duyệt 1:** Đồng ý với mô hình thực thể chuẩn hóa (Destination, TrekkingRoute, POI, Multi-country) và DDL PostgreSQL trong `docs/EXPLORE_DATABASE_SCHEMA.md`.
- [ ] **Phê duyệt 2:** Đồng ý với chiến lược triển khai Client-First (Sử dụng `destinations_seed.json` chuẩn hóa trong asset trước, giữ nguyên vẹn các module Map/SOS/Planner/Skills, chưa dựng backend cloud Supabase thật ở bước này).
- [ ] **Phê duyệt 3:** Đồng ý với ước tính nỗ lực thực tế (36 – 45 giờ chia làm 6 deliverables độc lập) và cho phép bắt đầu bước tiếp theo: **Phase C (Design Spec) & Phase D (Seed Catalog & Domain Data Layer)**.

