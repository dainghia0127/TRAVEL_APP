# HƯỚNG DẪN KÍCH HOẠT PWA & CÀI ĐẶT LÊN IPHONE DÙNG VĨNH VIỄN KHÔNG HẾT HẠN

> **Mục đích**: Giải quyết triệt để vấn đề chứng chỉ dùng thử 7 ngày của Apple khi cài file `.ipa` qua Sideloadly / AltStore, cho phép bạn sử dụng TRAVEL_APP độc lập, mượt mà trên iPhone **MÃI MÃI KHÔNG BAO GIỜ HẾT HẠN**.

---

## 1. So Sánh: Cài Qua Sideloadly vs Cài Qua PWA (GitHub Pages)

| Tiêu Chí | Cài file .ipa qua Sideloadly | Cài PWA qua Safari (Khuyên dùng) |
| :--- | :--- | :--- |
| **Hạn sử dụng** | **7 ngày** (Apple thu hồi chứng chỉ miễn phí) | **VĨNH VIỄN (Không bao giờ hết hạn)** |
| **Yêu cầu máy tính** | Cần máy tính + Cáp nối mỗi 7 ngày để ký lại | **Không cần máy tính**, chỉ cần iPhone |
| **Giao diện & Cảm giác** | App Native toàn màn hình | **App Standalone toàn màn hình (y hệt Native)** |
| **Cập nhật tính năng** | Phải tải lại IPA và cài đặt lại | **Tự động cập nhật ngầm** mỗi khi push code lên GitHub |
| **GPS & Bản đồ ngoài trời** | Hoạt động bình thường | **Hoạt động bình thường** qua Geolocation API |
| **Dữ liệu ngoại tuyến** | Lưu trên máy | Lưu trong Cache Storage & LocalStorage của máy |

---

## 2. Bước 1: Kích Hoạt GitHub Pages Trên GitHub (Chỉ cần làm 1 lần duy nhất)

1. Mở trình duyệt trên máy tính hoặc điện thoại, truy cập kho lưu trữ GitHub của bạn:
   👉 **`https://github.com/dainghia0127/TRAVEL_APP`**
2. Bấm vào tab **Settings** (Cài đặt trên thanh menu ngang).
3. **Chuyển Repo sang Public** (để kích hoạt tính năng Pages miễn phí & tải dữ liệu Cloud Sync):
   - Cuộn xuống dưới cùng của trang Settings đến khung viền đỏ **Danger Zone**.
   - Tại mục **Change repository visibility**, bấm nút **Change to public**.
   - Bấm xác nhận chuyển sang Public.
4. **Bật GitHub Pages Source**:
   - Ở cột menu bên trái trang Settings, bấm chọn mục **Pages**.
   - Tại phần **Build and deployment** $\rightarrow$ Mục **Source**, đổi từ *"Deploy from a branch"* thành:
     👉 **`GitHub Actions`**
5. Chạy file `push_to_github.bat` trong thư mục máy tính để kích hoạt lượt deploy đầu tiên. Chỉ sau khoảng 1-2 phút, đường link web app của bạn sẽ sẵn sàng tại:
   👉 **`https://dainghia0127.github.io/TRAVEL_APP/`**

---

## 3. Bước 2: Cài Đặt Lên Màn Hình Chính iPhone (Add to Home Screen)

> [!IMPORTANT]
> **Bắt buộc sử dụng trình duyệt SAFARI của iPhone** (Không dùng Google Chrome, Cốc Cốc hay Facebook App vì Apple chỉ cấp quyền PWA toàn màn hình cho Safari).

1. Mở trình duyệt **Safari** trên iPhone, nhập địa chỉ:
   ```text
   https://dainghia0127.github.io/TRAVEL_APP/
   ```
2. Chờ 2-3 giây để app tải các tài nguyên dã ngoại ban đầu vào bộ nhớ máy.
3. Ở thanh công cụ cạnh dưới màn hình Safari, bấm vào biểu tượng **Chia sẻ (Share)** (hình vuông có mũi tên chỉ lên $\uparrow$).
4. Cuộn xuống danh sách hành động và chọn dòng:
   👉 **"Thêm vào Màn hình chính" (Add to Home Screen)**.
5. Kiểm tra tên ứng dụng hiển thị là **TRAVEL APP**, sau đó bấm nút **Thêm (Add)** ở góc trên bên phải màn hình.

---

## 4. Trải Nghiệm Ứng Dụng Sau Khi Cài Đặt

* Biểu tượng **TRAVEL APP** sẽ xuất hiện trên màn hình chính iPhone của bạn cùng với các ứng dụng khác.
* Khi chạm mở:
  * Ứng dụng khởi chạy độc lập toàn màn hình (Standalone) — hoàn toàn không có thanh địa chỉ URL hay các nút tiến/lùi của Safari.
  * Tối ưu hiển thị tràn viền cho iPhone có Tai thỏ (Notch) và Dynamic Island.
  * Tích hợp Splash Screen nền đen dã ngoại chống chớp trắng khi khởi động.
  * Sử dụng vĩnh viễn, không lo bị khóa sau 7 ngày!
