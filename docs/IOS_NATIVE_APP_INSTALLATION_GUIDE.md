# Hướng Dẫn Cài Đặt Bản Native App iOS (.ipa) Lên iPhone Từ Máy Tính Windows

Tài liệu này hướng dẫn chi tiết quy trình tải file cài đặt **`TravelOutdoorApp.ipa`** (được biên dịch tự động bởi GitHub Actions trên máy ảo macOS) và cài đặt trực tiếp vào iPhone (ví dụ: iPhone 12 Pro Max) từ máy tính Windows thông qua công cụ **Sideloadly** mà **không cần tài khoản Apple Developer trả phí ($99/năm)**.

---

## 📌 Tổng Quan Kiến Trúc Tự Động Hóa (CI/CD)

```mermaid
flowchart LR
    A[Mã nguồn Flutter] -->|Git Push| B[GitHub Actions]
    B -->|macOS-14 Runner| C[flutter build ios --release]
    C -->|Đóng gói Payload| D[TravelOutdoorApp.ipa]
    D -->|Upload Artifact| E[GitHub Artifacts]
    E -->|Tải về máy tính| F[Sideloadly trên Windows]
    F -->|Cáp USB + Apple ID| G[iPhone 12 Pro Max]
```

---

## 🛠️ Yêu Cầu Chuẩn Bị

1. **Máy tính chạy Windows 10/11** có kết nối mạng Internet.
2. **iPhone** chạy iOS 15, 16, 17 hoặc 18 (ví dụ: iPhone 12 Pro Max).
3. **Cáp sạc USB** kết nối iPhone với máy tính.
4. **Một tài khoản Apple ID cá nhân thông thường** (tài khoản iCloud bạn đang dùng để tải app trên App Store).

---

## 📥 BƯỚC 1: Tải File `.ipa` Từ GitHub Actions

1. Truy cập vào mục **Actions** của kho lưu trữ dự án:
   👉 **[https://github.com/dainghia0127/TRAVEL_APP/actions](https://github.com/dainghia0127/TRAVEL_APP/actions)**
2. Nhấp vào workflow có tên **"Build iOS IPA"** mới nhất.
3. Chờ cho đến khi lượt build hoàn thành (có dấu tích xanh `√ Built Native iOS IPA`).
4. Cuộn xuống phần **Artifacts** ở cuối trang:
   - Nhấp vào **`TravelOutdoorApp-iOS-Native`** để tải về máy tính file nén `.zip`.
5. Giải nén file `.zip` vừa tải về, bạn sẽ nhận được file:
   ```text
   TravelOutdoorApp.ipa
   ```

---

## 💻 BƯỚC 2: Cài Đặt Sideloadly Trên Máy Tính Windows

**Sideloadly** là công cụ an toàn, phổ biến hàng đầu hiện nay giúp người dùng Windows cài đặt trực tiếp file `.ipa` vào iPhone thông qua cơ chế tự ký chứng chỉ phát triển cá nhân (Personal Development Certificate) hoàn toàn miễn phí của Apple.

1. Truy cập trang web chính thức: 👉 **[https://sideloadly.io](https://sideloadly.io)**
2. Tải bản **Sideloadly for Windows (64-bit)** và tiến hành cài đặt.
3. **Cài đặt Apple WebServices / iTunes Standalone (nếu được yêu cầu):**
   - Để Sideloadly giao tiếp được với iPhone qua cổng USB, máy tính cần driver của Apple.
   - Sideloadly có sẵn nút tự động tải và cài đặt driver Apple độc lập (Standalone iTunes/iCloud) chỉ trong 1 cú click.

---

## 📱 BƯỚC 3: Cài Đặt Ứng Dụng Vào iPhone

1. **Kết nối iPhone với máy tính:**
   - Dùng cáp USB cắm iPhone vào máy tính.
   - Mở khóa màn hình iPhone. Nếu màn hình hiện thông báo *"Tin cậy máy tính này?"*, bấm **Tin cậy (Trust)** và nhập mật mã iPhone của bạn.
2. **Mở phần mềm Sideloadly trên máy tính:**
   - **Connected Device**: Đảm bảo hiển thị đúng tên iPhone của bạn (ví dụ: *iPhone 12 Pro Max*).
   - **IPA**: Kéo và thả file **`TravelOutdoorApp.ipa`** vào ô icon IPA lớn bên trái.
   - **Apple account**: Nhập địa chỉ email Apple ID cá nhân của bạn.
3. **Bắt đầu cài đặt:**
   - Bấm nút **Start** ở dưới cùng.
   - Khi Sideloadly yêu cầu, nhập mật khẩu Apple ID của bạn (dữ liệu được mã hóa và gửi trực tiếp đến máy chủ Apple để xin chứng chỉ chứng thực cá nhân).
   - Chờ khoảng 1–2 phút cho tiến trình ký và cài đặt.
4. Khi thanh tiến trình báo **`100% - Done!`**, ứng dụng **Travel Outdoor** đã được cài đặt thành công và xuất hiện icon trên màn hình chính của iPhone!

---

## 🔐 BƯỚC 4: Kích Hoạt Quyền Mở Ứng Dụng Trên iPhone

Do ứng dụng được cài đặt trực tiếp (Sideload) bằng chứng chỉ cá nhân, Apple yêu cầu bạn xác nhận độ tin cậy lần đầu tiên trước khi mở:

### 1. Tin cậy chứng chỉ nhà phát triển:
1. Mở **Cài đặt (Settings)** trên iPhone.
2. Vào **Cài đặt chung (General)** ➔ **Quản lý VPN & Thiết bị (VPN & Device Management)**.
3. Dưới mục **Ứng dụng nhà phát triển (Developer App)**, chọn email Apple ID của bạn.
4. Bấm **Tin cậy "[Apple ID của bạn]"** ➔ Chọn tiếp **Tin cậy (Trust)**.

### 2. Bật Chế độ Nhà phát triển (Bắt buộc nếu iPhone chạy iOS 16, 17, 18):
1. Vào **Cài đặt (Settings)** ➔ **Quyền riêng tư & Bảo mật (Privacy & Security)**.
2. Cuộn xuống dưới cùng tìm mục **Chế độ nhà phát triển (Developer Mode)**.
3. Gạt công tắc sang **Bật (On)**.
4. iPhone sẽ hiện thông báo yêu cầu khởi động lại máy, bấm **Khởi động lại (Restart)**.
5. Sau khi máy mở lại, nhập mật mã màn hình và bấm **Bật (Turn On)** để hoàn tất.

🎉 **Chúc mừng!** Bây giờ bạn có thể chạm vào icon **Travel Outdoor** trên màn hình chính để mở và trải nghiệm ứng dụng Native 100% với tốc độ 60–120fps mượt mà, định vị GPS vệ tinh ngoại tuyến và hiệu ứng đồ họa chân thực nhất.

---

## ❓ Câu Hỏi & Lưu Ý Thường Gặp (FAQ)

### 1. Chứng chỉ cá nhân miễn phí dùng được bao lâu?
- Theo chính sách của Apple, các app được cài bằng Apple ID miễn phí có thời hạn sử dụng là **7 ngày**.
- Sau 7 ngày, nếu muốn tiếp tục mở app: Bạn chỉ cần cắm cáp vào máy tính và mở Sideloadly bấm **Start** lại (mất ~30 giây) để gia hạn thêm 7 ngày mà không bị mất dữ liệu chuyến đi trong app.
- Nếu bạn có tài khoản Apple Developer trả phí ($99/năm), thời hạn sẽ là **365 ngày (1 năm)**.

### 2. Có thể cài đặt tối đa bao nhiêu app sideload?
- Apple cho phép mỗi Apple ID miễn phí cài đặt đồng thời tối đa **3 ứng dụng tự phát triển** trên 1 thiết bị.

### 3. Sideloadly báo lỗi "Anisette Data Error" thì xử lý thế nào?
- Trong Sideloadly, bấm vào mục **Advanced Settings** ➔ Tại phần **Anisette Authentication**, chuyển sang chọn **Local Anisette** hoặc **Remote Anisette** rồi bấm Start lại.
