import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalEmergencyContact {
  final String title;
  final String phone;
  final String role;
  final String iconType; // 'ranger', 'rescue', 'hospital', 'police', 'national'

  const LocalEmergencyContact({
    required this.title,
    required this.phone,
    required this.role,
    this.iconType = 'rescue',
  });
}

class LocalEmergencyArea {
  final String areaName;
  final String provinceName;
  final List<LocalEmergencyContact> contacts;

  const LocalEmergencyArea({
    required this.areaName,
    required this.provinceName,
    required this.contacts,
  });
}

class LocalEmergencyService {
  /// Xác định danh bạ cứu hộ thực tế theo tọa độ GPS
  static Future<LocalEmergencyArea> resolveEmergencyContacts(double lat, double lon) async {
    String provinceName = '';

    // 1. Cố gắng lấy Tỉnh/Thành phố từ OpenStreetMap Reverse Geocoding
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=vi');
      final res = await http.get(uri, headers: {'User-Agent': 'TravelApp/1.0'}).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        provinceName = (address['state'] ?? address['city'] ?? address['county'] ?? '').toString();
      }
    } catch (_) {}

    // 2. Fallback theo bounding box địa lý nếu mất kết nối mạng
    if (provinceName.isEmpty) {
      provinceName = _detectProvinceByCoordinates(lat, lon);
    }

    return _buildAreaContacts(provinceName, lat, lon);
  }

  static String _detectProvinceByCoordinates(double lat, double lon) {
    if (lat >= 11.4 && lat <= 12.4 && lon >= 107.7 && lon <= 108.9) {
      return 'Lâm Đồng';
    } else if (lat >= 22.1 && lat <= 22.7 && lon >= 103.5 && lon <= 104.5) {
      return 'Lào Cai';
    } else if (lat >= 22.4 && lat <= 23.4 && lon >= 104.5 && lon <= 105.8) {
      return 'Hà Giang';
    } else if (lat >= 10.4 && lat <= 11.2 && lon >= 106.3 && lon <= 107.1) {
      return 'TP. Hồ Chí Minh';
    } else if (lat >= 20.7 && lat <= 21.4 && lon >= 105.4 && lon <= 106.2) {
      return 'Hà Nội';
    } else if (lat >= 15.9 && lat <= 16.3 && lon >= 108.0 && lon <= 108.5) {
      return 'Đà Nẵng';
    } else if (lat >= 17.0 && lat <= 17.8 && lon >= 105.8 && lon <= 106.7) {
      return 'Quảng Bình';
    } else if (lat >= 22.3 && lat <= 23.1 && lon >= 105.8 && lon <= 106.8) {
      return 'Cao Bằng';
    } else if (lat >= 10.9 && lat <= 11.6 && lon >= 106.7 && lon <= 107.6) {
      return 'Đồng Nai';
    } else if (lat >= 11.1 && lat <= 11.8 && lon >= 105.8 && lon <= 106.5) {
      return 'Tây Ninh';
    } else if (lat >= 9.8 && lat <= 10.5 && lon >= 103.8 && lon <= 104.5) {
      return 'Kiên Giang';
    }
    return 'Việt Nam';
  }

  static LocalEmergencyArea _buildAreaContacts(String province, double lat, double lon) {
    final pNorm = province.toLowerCase();

    if (pNorm.contains('lâm đồng') || pNorm.contains('đà lạt') || pNorm.contains('đức trọng')) {
      return const LocalEmergencyArea(
        areaName: 'Lâm Đồng (Đà Lạt & Tà Năng)',
        provinceName: 'Lâm Đồng',
        contacts: [
          LocalEmergencyContact(
            title: 'Ban Chỉ huy PCTT & TKCN Lâm Đồng',
            phone: '02633822243',
            role: 'Cứu hộ cứu nạn thiên tai toàn tỉnh',
            iconType: 'rescue',
          ),
          LocalEmergencyContact(
            title: 'Chi cục Kiểm lâm Lâm Đồng (Tà Năng)',
            phone: '02633843115',
            role: 'Đội tuần tra rừng & cứu hộ lạc lối',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Công an Cứu nạn Cứu hộ Lâm Đồng',
            phone: '114',
            role: 'Cứu nạn sự cố dốc đèo & sông suối',
            iconType: 'police',
          ),
          LocalEmergencyContact(
            title: 'Trung tâm Cấp cứu Y tế 115 Lâm Đồng',
            phone: '115',
            role: 'Sơ cấp cứu y tế dã ngoại',
            iconType: 'hospital',
          ),
        ],
      );
    }

    if (pNorm.contains('lào cai') || pNorm.contains('sa pa') || pNorm.contains('fansipan')) {
      return const LocalEmergencyArea(
        areaName: 'Lào Cai (Sa Pa & Fansipan)',
        provinceName: 'Lào Cai',
        contacts: [
          LocalEmergencyContact(
            title: 'BQL Vườn Quốc Gia Hoàng Liên (Sa Pa)',
            phone: '02143871146',
            role: 'Cứu nạn leo núi Fansipan & Lảo Thẩn',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Ban Chỉ huy PCTT & TKCN Sa Pa',
            phone: '02143871223',
            role: 'Cứu hộ sạt lở đèo & lũ quét vùng cao',
            iconType: 'rescue',
          ),
          LocalEmergencyContact(
            title: 'Công an Cứu hộ Cứu nạn Lào Cai',
            phone: '114',
            role: 'Ứng trực cứu hộ 24/7',
            iconType: 'police',
          ),
          LocalEmergencyContact(
            title: 'Bệnh viện Đa khoa Sa Pa (Cấp cứu)',
            phone: '02143871233',
            role: 'Cấp cứu hạ thân nhiệt & chấn thương núi',
            iconType: 'hospital',
          ),
        ],
      );
    }

    if (pNorm.contains('hà giang') || pNorm.contains('đồng văn') || pNorm.contains('mã pí lèng')) {
      return const LocalEmergencyArea(
        areaName: 'Hà Giang (Đồng Văn & Mã Pí Lèng)',
        provinceName: 'Hà Giang',
        contacts: [
          LocalEmergencyContact(
            title: 'Ban Chỉ huy PCTT & TKCN Hà Giang',
            phone: '02193866380',
            role: 'Tìm kiếm cứu nạn cao nguyên đá',
            iconType: 'rescue',
          ),
          LocalEmergencyContact(
            title: 'Hạt Kiểm lâm Đồng Văn - Mèo Vạc',
            phone: '02193871115',
            role: 'Cứu hộ vách đá trắng & hẻm Tu Sản',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Công an Huyện Mèo Vạc (Cứu nạn)',
            phone: '02193871113',
            role: 'Cứu hộ sự cố xe đèo Mã Pí Lèng',
            iconType: 'police',
          ),
        ],
      );
    }

    if (pNorm.contains('quảng bình') || pNorm.contains('phong nha')) {
      return const LocalEmergencyArea(
        areaName: 'Quảng Bình (Phong Nha - Kẻ Bàng)',
        provinceName: 'Quảng Bình',
        contacts: [
          LocalEmergencyContact(
            title: 'Trung tâm Cứu nạn VQG Phong Nha',
            phone: '02323677018',
            role: 'Cứu hộ thám hiểm hang động & rừng sâu',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Ban Chỉ huy PCTT & TKCN Quảng Bình',
            phone: '02323822340',
            role: 'Cứu hộ lũ lụt & thiên tai',
            iconType: 'rescue',
          ),
        ],
      );
    }

    if (pNorm.contains('đà nẵng') || pNorm.contains('hải vân') || pNorm.contains('sơn trà')) {
      return const LocalEmergencyArea(
        areaName: 'TP. Đà Nẵng (Đèo Hải Vân & Sơn Trà)',
        provinceName: 'TP. Đà Nẵng',
        contacts: [
          LocalEmergencyContact(
            title: 'Đội Cứu nạn Bán đảo Sơn Trà & Hải Vân',
            phone: '02363920115',
            role: 'Cứu hộ lạc rừng & sự cố cung đèo',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Cảnh sát PCCC & CNCH Đà Nẵng',
            phone: '114',
            role: 'Cứu hộ khẩn cấp 24/7',
            iconType: 'police',
          ),
          LocalEmergencyContact(
            title: 'Trung tâm Cấp cứu 115 Đà Nẵng',
            phone: '115',
            role: 'Cấp cứu y tế lưu động',
            iconType: 'hospital',
          ),
        ],
      );
    }

    if (pNorm.contains('hồ chí minh') || pNorm.contains('sài gòn') || pNorm.contains('thủ đức') || pNorm.contains('cần giờ')) {
      return const LocalEmergencyArea(
        areaName: 'TP. Hồ Chí Minh (Cần Giờ & Ven Đô)',
        provinceName: 'TP. Hồ Chí Minh',
        contacts: [
          LocalEmergencyContact(
            title: 'Cảnh sát Cứu nạn Cứu hộ TP.HCM',
            phone: '114',
            role: 'Tổng đài phản ứng nhanh sự cố 24/7',
            iconType: 'police',
          ),
          LocalEmergencyContact(
            title: 'Ban Chỉ huy PCTT & TKCN TP.HCM',
            phone: '02838297598',
            role: 'Điều phối cứu nạn thủy bộ',
            iconType: 'rescue',
          ),
          LocalEmergencyContact(
            title: 'Hạt Kiểm lâm Rừng Cần Giờ',
            phone: '02838740248',
            role: 'Cứu hộ rừng ngập mặn & luồng lạch',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Trung tâm Cấp cứu 115 TP.HCM',
            phone: '115',
            role: 'Mạng lưới cấp cứu ngoại viện 115',
            iconType: 'hospital',
          ),
        ],
      );
    }

    if (pNorm.contains('hà nội') || pNorm.contains('ba vì') || pNorm.contains('sóc sơn')) {
      return const LocalEmergencyArea(
        areaName: 'Thủ đô Hà Nội (Ba Vì & Sóc Sơn)',
        provinceName: 'Hà Nội',
        contacts: [
          LocalEmergencyContact(
            title: 'Hạt Kiểm lâm VQG Ba Vì',
            phone: '02433881205',
            role: 'Cứu hộ dã ngoại đỉnh Ba Vì',
            iconType: 'ranger',
          ),
          LocalEmergencyContact(
            title: 'Cảnh sát Cứu hộ Cứu nạn Hà Nội',
            phone: '114',
            role: 'Ứng trực sự cố khẩn cấp 24/7',
            iconType: 'police',
          ),
          LocalEmergencyContact(
            title: 'Trung tâm Cấp cứu 115 Hà Nội',
            phone: '115',
            role: 'Cấp cứu chấn thương y tế',
            iconType: 'hospital',
          ),
        ],
      );
    }

    // Mặc định quốc gia theo lãnh thổ Việt Nam
    return LocalEmergencyArea(
      areaName: province.isNotEmpty ? 'Khu Vực $province' : 'Địa Bàn Hiện Tại (Toàn Quốc)',
      provinceName: province.isNotEmpty ? province : 'Việt Nam',
      contacts: const [
        LocalEmergencyContact(
          title: 'Tổng đài Cứu nạn Quốc Gia',
          phone: '112',
          role: 'Tìm kiếm cứu nạn trên biển, rừng & vùng sâu',
          iconType: 'national',
        ),
        LocalEmergencyContact(
          title: 'Cứu nạn Cứu hộ Khẩn cấp Bộ Công An',
          phone: '114',
          role: 'Ứng trực ứng cứu tai nạn & thiên tai 24/7',
          iconType: 'police',
        ),
        LocalEmergencyContact(
          title: 'Cấp cứu Y tế Ngoại Viện Quốc Gia',
          phone: '115',
          role: 'Điều phối xe cấp cứu y tế gần nhất',
          iconType: 'hospital',
        ),
      ],
    );
  }
}

