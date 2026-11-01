# TRAVEL_APP — Ứng Dụng Khám Phá & Sinh Tồn Outdoor Thời Gian Thực

> **Sứ mệnh**: Đồng hành cùng người đi phượt, trekking, cắm trại và khám phá thiên nhiên với khả năng hoạt động ngoại tuyến (Offline-First) 100%, tích hợp bản đồ địa hình độc lập và các công cụ an toàn sinh tồn chuyên nghiệp.

---

## 📂 Cấu Trúc Dự Án & Tài Liệu

```text
TRAVEL_APP/
├── README.md                     # Tài liệu tổng quan dự án
├── TRAVEL_APP_PLAN.md            # Bản ghi kế hoạch & tư vấn chi tiết ban đầu
└── docs/
    ├── 01_ARCHITECTURE.md        # Kiến trúc hệ thống, Tech Stack & Offline Maps
    ├── 02_FUNCTIONAL_SPECS.md    # Đặc tả chi tiết 5 phân hệ cốt lõi & 5 tính năng an toàn
    └── 03_ROADMAP.md             # Kế hoạch lộ trình triển khai (Phase 1 -> 4)
```

---

## 🎯 Điểm Nhấn Công Nghệ Cốt Lõi

1. **Kiến trúc Offline-First (Trọng tâm sống còn)**:
   - Bản đồ offline vector tile (`.mbtiles`) sử dụng **MapLibre Native + OpenStreetMap**. Không phụ thuộc mạng 4G khi ở trong rừng hay trên đỉnh núi.
   - Định vị trực tiếp từ chip vệ tinh GPS phần cứng của điện thoại (kể cả khi bật Airplane Mode).
2. **Nền tảng phát triển**:
   - **Cross-Platform Mobile (Flutter)**: Một codebase duy nhất cho cả iOS & Android, hỗ trợ Hot Reload thử nghiệm tức thì trên máy thật.
   - **Lightweight Web Viewer**: Cho phép bạn bè, gia đình mở liên kết web để theo dõi lộ trình chuyến đi mà không cần cài app.
3. **An toàn & Sinh tồn thời gian thực**:
   - Cảnh báo thời tiết chuyên sâu (Open-Meteo API): Lũ quét đầu nguồn, hạ thân nhiệt do gió/rét, giông lốc.
   - Còi hú & đèn flash chớp mã Morse SOS tự động.
   - Gửi tọa độ cứu hộ tự động qua tin nhắn SMS truyền thống (hoạt động được khi sóng 2G chập chờn không có data 4G).
   - La bàn số & đo độ cao theo thời gian thực (Barometer / Altimeter).

---

## 📚 Hướng Dẫn Truy Cập Tài Liệu Chi Tiết

- [**01. Kiến Trúc Kỹ Thuật (Architecture & Tech Stack)**](file:///e:/AI%20Code/Gemini%20Code/TRAVEL_APP/docs/01_ARCHITECTURE.md)
- [**02. Đặc Tả Tính Năng (Functional Specifications)**](file:///e:/AI%20Code/Gemini%20Code/TRAVEL_APP/docs/02_FUNCTIONAL_SPECS.md)
- [**03. Lộ Trình Triển Khai (Roadmap)**](file:///e:/AI%20Code/Gemini%20Code/TRAVEL_APP/docs/03_ROADMAP.md)
- [**04. Hướng Dẫn Cài Đặt Native App iOS (.ipa) Lên iPhone**](docs/IOS_NATIVE_APP_INSTALLATION_GUIDE.md)
- [**Kế Hoạch Ban Đầu Gốc (Original Plan)**](file:///e:/AI%20Code/Gemini%20Code/TRAVEL_APP/TRAVEL_APP_PLAN.md)

