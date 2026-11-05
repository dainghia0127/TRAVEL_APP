import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Kết quả tìm kiếm địa chỉ từ dịch vụ Geocoding
class GeocodingResult {
  final String displayName;
  final String title;
  final String subtitle;
  final LatLng position;

  const GeocodingResult({
    required this.displayName,
    required this.title,
    required this.subtitle,
    required this.position,
  });

  /// Parse dữ liệu từ OpenStreetMap Nominatim
  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;
    final displayName = json['display_name'] as String? ?? 'Vị trí không xác định';

    final parts = displayName.split(',');
    final title = parts.isNotEmpty ? parts.first.trim() : displayName;
    final subtitle = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return GeocodingResult(
      displayName: displayName,
      title: title,
      subtitle: subtitle,
      position: LatLng(lat, lon),
    );
  }

  /// Parse dữ liệu từ Photon Komoot GeoJSON Feature
  factory GeocodingResult.fromPhoton(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final geom = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coords = geom['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final lon = coords.isNotEmpty ? (double.tryParse(coords[0].toString()) ?? 0.0) : 0.0;
    final lat = coords.length > 1 ? (double.tryParse(coords[1].toString()) ?? 0.0) : 0.0;

    final name = props['name']?.toString() ?? '';
    final street = props['street']?.toString() ?? '';
    final locality = props['locality']?.toString() ?? '';
    final district = props['district']?.toString() ?? '';
    final city = props['city']?.toString() ?? '';
    final country = props['country']?.toString() ?? 'Việt Nam';

    final title = name.isNotEmpty
        ? name
        : (street.isNotEmpty ? street : (locality.isNotEmpty ? locality : 'Vị trí đã chọn'));

    final addressParts = <String>[];
    if (street.isNotEmpty && street != title) addressParts.add(street);
    if (locality.isNotEmpty && locality != title) addressParts.add(locality);
    if (district.isNotEmpty) addressParts.add(district);
    if (city.isNotEmpty) addressParts.add(city);
    if (country.isNotEmpty && country != 'Việt Nam') addressParts.add(country);

    final subtitle = addressParts.join(', ');
    final displayName = subtitle.isNotEmpty ? '$title, $subtitle' : title;

    return GeocodingResult(
      displayName: displayName,
      title: title,
      subtitle: subtitle,
      position: LatLng(lat, lon),
    );
  }
}

/// Dịch vụ tìm kiếm địa chỉ đa tầng thông minh Google Maps Style
/// Kết hợp Photon Komoot (chống chặn ISP Việt Nam + chịu lỗi chính tả) và Nominatim
class GeocodingService {
  static final http.Client _client = http.Client();

  /// Chuẩn hóa từ khóa thông minh, tự động sửa các lỗi gõ nhanh tiếng Việt/tiếng Anh
  static String normalizeQuery(String raw) {
    var q = raw.trim();
    // granpark, gran park -> grand park
    q = q.replaceAll(RegExp(r'\bgranpark\b', caseSensitive: false), 'grand park');
    q = q.replaceAll(RegExp(r'\bgran\s+park\b', caseSensitive: false), 'grand park');
    // vinhome -> vinhomes
    q = q.replaceAll(RegExp(r'\bvinhome\b', caseSensitive: false), 'vinhomes');
    // Tách các từ viết dính phổ biến
    q = q.replaceAll(RegExp(r'\bvinhomegrandpark\b', caseSensitive: false), 'vinhomes grand park');
    q = q.replaceAll(RegExp(r'\bvinhomesgrandpark\b', caseSensitive: false), 'vinhomes grand park');
    return q;
  }

  /// Tìm kiếm địa chỉ theo chuỗi nhập liệu
  static Future<List<GeocodingResult>> searchAddress(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    final normalized = normalizeQuery(cleanQuery);
    final queriesToTry = <String>[cleanQuery];
    if (normalized.toLowerCase() != cleanQuery.toLowerCase()) {
      queriesToTry.add(normalized);
    }

    // 1. Thử tìm qua Photon Komoot API (Nhanh, không bị chặn tại VN, hỗ trợ typo)
    for (final q in queriesToTry) {
      try {
        final uri = Uri.parse(
          'https://photon.komoot.io/api/?'
          'q=${Uri.encodeComponent(q)}'
          '&lat=14.0583&lon=108.2772' // Tâm Việt Nam ưu tiên địa điểm lân cận
          '&limit=8',
        );

        final response = await _client.get(
          uri,
          headers: {
            'User-Agent': 'TravelOutdoorApp/1.0',
            'Accept-Language': 'vi,en;q=0.9',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final features = data['features'] as List<dynamic>? ?? [];
          final results = features
              .map((f) => GeocodingResult.fromPhoton(f as Map<String, dynamic>))
              .where((r) => r.position.latitude != 0.0 && r.position.longitude != 0.0)
              .toList();

          if (results.isNotEmpty) {
            return results;
          }
        }
      } catch (_) {
        // Tiếp tục thử query kế tiếp hoặc fallback
      }
    }

    // 2. Fallback sang OpenStreetMap Nominatim nếu Photon không có kết quả
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(normalized)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=8'
        '&countrycodes=vn',
      );

      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'TravelOutdoorApp/1.0 (traveloutdoor.app@vietnam.local)',
          'Accept-Language': 'vi,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map((item) => GeocodingResult.fromJson(item as Map<String, dynamic>))
            .where((r) => r.position.latitude != 0.0 && r.position.longitude != 0.0)
            .toList();
      }
    } catch (_) {
      // Khi mất kết nối hoặc bị chặn
    }

    return [];
  }
}
