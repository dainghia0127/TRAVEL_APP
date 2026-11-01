# KẾ HOẠCH TÍCH HỢP DỊCH VỤ NGOÀI & CHÍNH SÁCH DỮ LIỆU (EXPLORE API INTEGRATION PLAN - REVISED)

> **Dự án:** TRAVEL_APP — Premium Global Travel Discovery Platform  
> **Phiên bản:** 2.0 (Xác minh điều khoản pháp lý, giới hạn kỹ thuật và phòng thủ an toàn sinh tồn)  
> **Cam kết:** Phân định rõ ràng giữa:
> - `[VERIFIED-DOC]`: Đã xác minh qua tài liệu chính thức của nhà cung cấp.
> - `[ASSUMPTION]`: Giả định kỹ thuật cần kiểm soát.
> - `[UNVERIFIED]`: Chưa thể xác minh độc lập, có phương án kiểm chứng đi kèm.

---

## 1. MA TRẬN NHÀ CUNG CẤP DỮ LIỆU BÊN NGOÀI

| Nhà Cung Cấp | Mục Đích Sử Dụng | Yêu Cầu Xác Thực | Giấy Phép Sử Dụng | Attribution Bắt Buộc | Rủi Ro Kỹ Thuật Chính |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Open-Meteo** | Dự báo vi khí hậu (nhiệt độ, gió giật, mưa, mã thời tiết) | Không cần key cho phi thương mại | CC-BY 4.0 (Phi thương mại) | Có (Link to Open-Meteo.com) | Giới hạn 10,000 req/ngày/IP. Mô hình lưới toán học, không phải cảm biến tại chỗ. |
| **OpenStreetMap / Overpass** | POIs dã ngoại (trạm kiểm lâm, nguồn nước, bãi cắm trại) | Không cần key cho public instance | ODbL (Open Database License) | Có (© OpenStreetMap contributors) | Rate limit 2 req đồng thời; dữ liệu cộng đồng không đồng đều ở vùng sâu. |
| **Esri ArcGIS Online** | Bản đồ nền địa hình cao độ (Topo) và vệ tinh | Không cần key với public map server | Dịch vụ công cộng ArcGIS Online | Có ("Powered by Esri", USGS, NOAA...) | Lớp Topo không có sẵn đường mòn trekking nhỏ tại VN; phải vẽ đè bằng GPX. |
| **Wikimedia Commons** | Hình ảnh thực địa kèm bản quyền mở minh bạch | Không cần key (Bắt buộc User-Agent hợp lệ) | Đa dạng: CC-BY, CC-BY-SA, Public Domain | Bắt buộc cho từng ảnh cụ thể | Cần kiểm tra license từng ảnh; không dùng contact email bịa đặt. |

---

## 2. ĐÁNH GIÁ CHI TIẾT TỪNG NHÀ CUNG CẤP

### 2.1. Open-Meteo API (Dự báo vi khí hậu dã ngoại)
- `[VERIFIED-DOC]` **Mục đích sử dụng:** Lấy dữ liệu dự báo thời tiết 3 ngày (nhiệt độ, tốc độ gió, gió giật, lượng mưa, mã thời tiết WMO) theo tọa độ GPS vĩ độ/kinh độ.
- `[VERIFIED-DOC]` **Endpoint:** `https://api.open-meteo.com/v1/forecast`
- `[VERIFIED-DOC]` **Xác thực:** Miễn phí, không cần API Key cho mục đích phi thương mại. Đối với mục đích thương mại trong tương lai, Open-Meteo yêu cầu đăng ký gói trả phí (Commercial API Key).
- `[VERIFIED-DOC]` **Điều khoản cấp phép & Attribution:**
  - Cấp phép theo giấy phép **Creative Commons Attribution 4.0 International (CC BY 4.0)**.
  - Bắt buộc hiển thị liên kết ghi công rõ ràng trên giao diện: *"Weather data by Open-Meteo.com"*.
- `[VERIFIED-DOC]` **Hạn mức sử dụng (Rate Limits):**
  - Gói phi thương mại giới hạn: **10,000 requests/ngày**, tối đa **5,000 requests/giờ** và **600 requests/phút** trên một địa chỉ IP. Vượt quá sẽ trả về mã lỗi `HTTP 429 Too Many Requests`.
- `[VERIFIED-DOC]` **Chính sách Bộ đệm & Kiểm soát tải:**
  - **TTL Cache:** 30 phút. Không gọi lại mạng nếu snapshot thời tiết của tọa độ đó chưa quá 30 phút.
  - **Ngưỡng Stale:** Sau 1 giờ. Nếu mất mạng và dữ liệu cũ hơn 1 giờ, bắt buộc hiển thị nhãn *"Bản lưu lúc [HH:mm] (Dữ liệu cũ)"*.
  - **Cấm gọi trong ListView:** Tuyệt đối không gọi API trong vòng lặp cuộn danh sách. Chỉ gọi khi mở `DestinationDetailScreen` hoặc cho thẻ Hero chính.
  - **Timeout & Retry:** Timeout 5 giây; không tự động retry liên tục khi gặp lỗi 429 hoặc 5xx.
- `[VERIFIED-DOC]` **Hạn chế cốt lõi về bản chất dữ liệu (Data-Quality Limitations):**
  - Open-Meteo tổng hợp các mô hình dự báo số trị toàn cầu và khu vực (DWD ICON, NOAA GFS, ECMWF) với độ phân giải lưới từ 1 km đến 11 km.
  - **DỰ BÁO TOÁN HỌC KHÔNG PHẢI LÀ TRẠM QUAN TRẮC MẶT ĐẤT TẠI CHỖ:** Vi khí hậu tại các khe núi sâu, thung lũng hẹp hoặc đỉnh núi cao có thể khác biệt rất lớn so với mô hình dự báo.
  - **TUYỆT ĐỐI KHÔNG TUYÊN BỐ:** Dữ liệu Open-Meteo chứng minh an toàn tuyệt đối trước nguy cơ lũ quét, lũ ống, lở đất hay sét đánh. Luôn khuyến cáo người đi rừng quan sát bầu trời thực tế và tuân thủ cảnh báo của ban quản lý địa phương.

---

### 2.2. OpenStreetMap & Overpass API (Điểm tiện ích dã ngoại lân cận)
- `[VERIFIED-DOC]` **Mục đích sử dụng:** Truy vấn các đối tượng địa lý xung quanh điểm đến:
  - Trạm kiểm lâm (`amenity=ranger_station`)
  - Nguồn nước tự nhiên / vòi nước (`amenity=drinking_water`, `natural=spring`)
  - Bãi cắm trại (`tourism=camp_site`)
  - Cơ sở y tế (`amenity=clinic`, `amenity=hospital`)
- `[VERIFIED-DOC]` **Hỗ trợ loại đối tượng OSM:** Bắt buộc hỗ trợ cả 3 loại đối tượng trong Overpass QL:
  - `node`: Điểm tọa độ đơn (vòi nước, đỉnh núi).
  - `way`: Đường hoặc đa giác khép kín (khu vực bãi cắm trại, tòa nhà trạm kiểm lâm).
  - `relation`: Tập hợp phức tạp (khu bảo tồn thiên nhiên, mạng lưới đường mòn).
- `[VERIFIED-DOC]` **Endpoint:** `https://overpass-api.de/api/interpreter`
- `[VERIFIED-DOC]` **Điều khoản & Attribution:**
  - Cấp phép theo **Open Database License (ODbL)**.
  - Bắt buộc hiển thị attribution: *"Data © OpenStreetMap contributors"*.
- `[VERIFIED-DOC]` **Hạn mức & Giới hạn tải (Rate Limits):**
  - Public Overpass instance có hệ thống quản lý slot giới hạn (thường là 2 truy vấn đồng thời/IP). Nếu gửi quá nhiều query nặng sẽ bị khóa tạm thời (`HTTP 429`) hoặc timeout (`HTTP 504`).
- `[VERIFIED-DOC]` **Chính sách gọi & Bộ đệm:**
  - **Chỉ gọi On-Demand:** Chỉ kích hoạt khi người dùng mở tab "Tiện ích xung quanh" trong chi tiết điểm đến.
  - **Bán kính truy vấn:** Giới hạn $R \le 10\text{km}$ quanh tọa độ trung tâm.
  - **TTL Cache:** 24 giờ trên bộ nhớ thiết bị.
  - **Timeout:** 8 giây. Khi lỗi, chuyển sang danh bạ cứu hộ lưu sẵn.
- `[VERIFIED-DOC]` **Hạn chế dữ liệu an toàn dã ngoại (Critical Field Safety Limitations):**
  - Dữ liệu OSM là do cộng đồng tình nguyện đóng góp. Độ đầy đủ (completeness) rất chênh lệch: Vùng châu Âu rất chi tiết, nhưng vùng núi rừng hẻo lánh Việt Nam (Tà Năng, Kon Chư Răng, Bidoup) dữ liệu POI rất thưa thớt hoặc đã cũ.
  - **NGUỒN NƯỚC TRÊN OSM KHÔNG ĐỒNG NGHĨA VỚI NƯỚC UỐNG AN TOÀN:** Thẻ `amenity=drinking_water` hoặc `natural=spring` có thể đã cạn khô vào mùa khô hoặc nhiễm ký sinh trùng / vi khuẩn đường ruột. Ứng dụng bắt buộc hiển thị: *"Nguồn nước tự nhiên chưa kiểm định. Phải đun sôi 3 phút hoặc dùng thiết bị lọc chuyên dụng trước khi uống."*
  - **TRẠM KIỂM LÂM TRÊN OSM CHƯA CHẮC CÓ NGƯỜI TRỰC:** Có thể là chòi quan sát theo mùa không có nhân viên thường trực 24/7. Không được coi là cơ sở cấp cứu mặc định.

---

### 2.3. Esri ArcGIS Online Tile Server (Bản đồ GIS)
- `[VERIFIED-DOC]` **Mục đích sử dụng:** Hiển thị lớp bản đồ địa hình cao độ (Topo Map) và lớp ảnh vệ tinh (World Imagery) trong màn hình Bản đồ và xem nhanh (preview) trong Explore.
- `[VERIFIED-DOC]` **Endpoints:**
  - Topo Map: `https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}`
  - Imagery: `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}`
  - Street Map: `https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}`
- `[VERIFIED-DOC]` **Xác thực:** Không yêu cầu API Key cho việc truy cập tile công khai trực tiếp.
- `[VERIFIED-DOC]` **Điều khoản & Attribution:**
  - Bắt buộc hiển thị nhãn bản quyền ở góc bản đồ: *"Powered by Esri — Sources: Esri, USGS, NOAA"*.
- `[UNVERIFIED]` **Hạn chế về dữ liệu đường mòn dã ngoại (Trail Data Coverage):**
  - *Thực tế kiểm tra:* Lớp `World_Topo_Map` của Esri cung cấp địa hình cao độ (contour lines) và địa vật toàn cầu rất tốt, nhưng **KHÔNG CHỨA DỮ LIỆU ĐƯỜNG MÒN TREKKING CHI TIẾT TẠI VIỆT NAM** (như lối mòn Tà Năng - Phan Dũng hay cung rừng K50).
  - *Phương án kỹ thuật:* Ứng dụng phải tự vẽ đè (overlay) các cung đường dã ngoại bằng file GPX / Polyline vector của riêng dự án lên trên nền bản đồ Esri Topo, không thể phụ thuộc vào tile map của Esri để hiển thị đường mòn.

---

### 2.4. Wikimedia Commons API (Bản quyền hình ảnh dã ngoại)
- `[VERIFIED-DOC]` **Mục đích sử dụng:** Tra cứu hình ảnh thực tế chất lượng cao đại diện đúng cho điểm đến, kèm metadata bản quyền và tác giả.
- `[VERIFIED-DOC]` **Endpoint:** `https://commons.wikimedia.org/w/api.php`
- `[VERIFIED-DOC]` **Chính sách User-Agent:**
  - Wikimedia cấm các User-Agent mặc định hoặc không định danh.
  - Bắt buộc gửi User-Agent theo định dạng chuẩn: `User-Agent: TravelAppOutdoor/<version> (Flutter Client; contact: <link_repo_or_verified_contact>)`.
  - **TUYỆT ĐỐI KHÔNG DÙNG EMAIL GIẢ ĐỊNH** (ví dụ `info@travelapp.vn` không tồn tại). Phải dùng link GitHub repository hoặc địa chỉ liên lạc thật của dự án.
- `[VERIFIED-DOC]` **Xác minh giấy phép từng ảnh:**
  - Mỗi ảnh tải về phải lưu trữ cụ thể: Tên tác giả (`Artist`), Giấy phép (`LicenseShortName`: CC-BY-4.0, CC-BY-SA-3.0, Public Domain), và Link điều khoản gốc (`LicenseUrl`).
  - Nếu ảnh không có giấy phép thương mại hoặc giấy phép mở tương thích, không được đưa vào catalog chính thức.

---

## 3. NGUYÊN TẮC TRUNG THỰC DỮ LIỆU TUYỆT ĐỐI (TRUTH IN DATA PRINCIPLES)

1. **Tuyệt đối không bịa đặt chỉ số xã hội:**
   - Không tạo số sao giả (4.9★), không bịa số lượt đánh giá (284 reviews), không tạo số lượng người đang leo núi giả.
   - Thay vào đó, hiển thị trạng thái kiểm chứng: *"Dữ liệu kiểm chứng thực địa bởi [Tên chuyên gia/Đội dã ngoại]"* hoặc *"Chưa có đánh giá thực tế"*.
2. **Tuyệt đối không bịa đặt giá vé & giờ mở cửa:**
   - Nếu không có nguồn văn bản từ Ban quản lý VQG, ghi rõ *"Liên hệ trạm kiểm lâm"* hoặc ẩn trường.
3. **Số điện thoại khẩn cấp theo từng quốc gia:**
   - Khi xem điểm đến tại Thụy Sĩ: Hiển thị 1414 (REGA Mountain Rescue) và 112.
   - Khi xem điểm đến tại Mỹ: Hiển thị 911.
   - Khi xem điểm đến tại Nhật: Hiển thị 110 (Cảnh sát) và 119 (Cứu thương/Cứu hỏa).
   - Khi xem điểm đến tại Việt Nam: Hiển thị 114 (Cứu nạn) và số trạm kiểm lâm VQG sở tại.
   - **Tuyệt đối không tái sử dụng số hotline 114/115 của Việt Nam cho điểm đến quốc tế.**
