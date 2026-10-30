# 01. KIẾN TRÚC KỸ THUẬT & TECH STACK (ARCHITECTURE)

## 1. Sơ Đồ Kiến Trúc Tổng Thể

```
+---------------------------------------------------------------------------------+
|                               CLIENT LAYER                                      |
|                                                                                 |
|  +------------------------------------+   +----------------------------------+  |
|  |     FLUTTER MOBILE APP (iOS/Android)|   |       WEB VIEWER (Next.js/HTML5) |  |
|  |  - MapLibre Native (.mbtiles)      |   |  - Read-only trip sharing view   |  |
|  |  - Local DB (Isar / SQLite)        |   |  - Mobile & desktop responsive   |  |
|  |  - GPS / Sensors / Flash / Morse   |   |  - Không bắt buộc đăng nhập      |  |
|  +-----------------+------------------+   +----------------+-----------------+  |
+--------------------|---------------------------------------|--------------------+
                     |                                       |
                     | HTTPS / WebSockets                    | HTTPS
                     v                                       v
+---------------------------------------------------------------------------------+
|                               BACKEND LAYER (REST / GraphQL API)                |
|  - Node.js (NestJS) hoặc Go / Python FastAPI                                    |
|  - Auth: JWT + Firebase / OAuth2                                                |
|  - Trip Routing Optimization (TSP / OSRM)                                       |
|  - Background Weather Poller (Open-Meteo Alert Worker)                          |
+--------------------+---------------------------------------+--------------------+
                     |                                       |
                     v                                       v
+------------------------------------+     +------------------------------------+
|          DATABASE LAYER            |     |        EXTERNAL SERVICES           |
|  - PostgreSQL 16 + PostGIS 3       |     |  - Open-Meteo (Thời tiết, gió, mưa)|
|  - Spatial Index (GIST)            |     |  - OpenStreetMap / Overpass API    |
|  - Redis Cache (Session & Leader)  |     |  - MapTiler / Proj Planet (Tiles)  |
+------------------------------------+     +------------------------------------+
```

---

## 2. Công Nghệ Đề Xuất (Recommended Tech Stack)

| Thành phần | Công nghệ đề xuất | Lý do lựa chọn |
| :--- | :--- | :--- |
| **Mobile App** | **Flutter (Dart)** | - 1 codebase cho cả iOS và Android.<br>- Tốc độ rendering đồ họa 60/120fps mượt mà.<br>- **Hot Reload** kiểm thử trên điện thoại thật dưới 1 giây.<br>- Hệ sinh thái plugin phần cứng mạnh mẽ (GPS, Compass, Flashlight, SMS). |
| **Bản đồ Ngoại tuyến** | **MapLibre Native** + **OpenStreetMap** | - Hoàn toàn miễn phí bản quyền, không bị khóa như Google Maps.<br>- Hỗ trợ vector tiles `.mbtiles` nhẹ (20-40MB cho 1 tỉnh/vùng trekking). |
| **Local Database** | **Isar Database** hoặc **SQLite (drift)** | - Tốc độ truy vấn siêu tốc trên thiết bị di động.<br>- Hoạt động độc lập không cần Internet (Offline-First). |
| **Web Viewer** | **Next.js** / **SvelteKit** | - Render SSR/SSG nhanh, hiển thị link chuyến đi (`preview trip`) kèm metadata OpenGraph khi chia sẻ Facebook, Zalo. |
| **Backend API** | **Node.js (NestJS)** hoặc **Go** | - Nhẹ, xử lý I/O non-blocking tốt, dễ maintain. |
| **Database Không gian** | **PostgreSQL 16 + PostGIS** | - Tiêu chuẩn vàng để xử lý tọa độ địa lý, tìm kiếm điểm du lịch lân cận theo bán kính `ST_DWithin`. |
| **Dịch vụ Thời tiết** | **Open-Meteo API** | - Miễn phí phi thương mại, cung cấp chi tiết độ ẩm, áp suất, giông bão, gió giật theo tọa độ chính xác. |

---

## 3. Chiến Lược Bản Đồ Ngoại Tuyến (Offline Map Strategy)

### Tại sao không dùng Google Maps?
- **Điều khoản Google Maps**: Cấm lưu trữ/cache dữ liệu bản đồ để dùng offline cho app tùy biến. Vi phạm sẽ dẫn đến việc khóa API Key và đình chỉ ứng dụng.
- **Chi phí**: Chi phí gọi API của Google Maps rất cao khi người dùng zoom/pan liên tục.

### Giải pháp chuẩn với MapLibre + MBTiles
1. **Dữ liệu nguồn**: Trích xuất bản đồ địa hình (Contour lines + Hillshade + Trails) từ **OpenStreetMap** & **SRTM Elevation data**.
2. **Đóng gói Tile**: Đóng gói vùng địa lý thành file vector `.mbtiles` (ví dụ: `dalat_lamvien.mbtiles` dung lượng ~35MB).
3. **Quá trình tải về máy**:
   - Khi ở nhà có Wi-Fi: Người dùng bấm **"Tải bản đồ khu vực Đà Lạt & Lạc Dương"**.
   - Ứng dụng tải file `.mbtiles` về thư mục ứng dụng (`ApplicationDocumentsDirectory`).
4. **Hiển thị khi mất mạng hoàn toàn**:
   - MapLibre đọc trực tiếp từ file local SQLite `.mbtiles`.
   - Chip GPS của điện thoại bắt sóng trực tiếp từ các chòm sao vệ tinh (GPS, GLONASS, Galileo) để ghim chấm xanh vị trí tức thời mà không cần 1 byte mạng 4G nào.

---

## 4. Quản Lý Năng Lượng (Outdoor Battery Saver Strategy)

Đi rừng, phượt dài ngày pin là yếu tố sống còn:
- **Normal Mode**: Quản lý tần số quét GPS theo vận tốc di chuyển (đi bộ: 15-30 giây/lần; dừng nghỉ: tạm dừng quét).
- **Extreme Outdoor Saver**:
  - Tắt toàn bộ background fetch/sync qua mạng.
  - Chỉ kích hoạt chip GPS khi người dùng bật sáng màn hình điện thoại.
  - Giao diện Dark Mode OLED 100% nền đen tuyệt đối giúp tiết kiệm 40% pin màn hình.

