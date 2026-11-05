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

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0;
    final displayName = json['display_name'] as String? ?? 'Vị trí không xác định';

    // Tách tên ngắn gọn và địa chỉ phụ
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
}

/// Dịch vụ tìm kiếm địa chỉ chính xác Google Maps Style thông qua OpenStreetMap Nominatim
class GeocodingService {
  static final http.Client _client = http.Client();

  /// Tìm kiếm địa chỉ theo chuỗi nhập liệu tiếng Việt
  static Future<List<GeocodingResult>> searchAddress(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(cleanQuery)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=7'
        '&countrycodes=vn',
      );

      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'TravelOutdoorApp/1.0 (traveloutdoor.app@vietnam.local)',
          'Accept-Language': 'vi,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map((item) => GeocodingResult.fromJson(item as Map<String, dynamic>))
            .where((r) => r.position.latitude != 0.0 && r.position.longitude != 0.0)
            .toList();
      }
    } catch (_) {
      // Khi mất kết nối hoặc timeout
    }
    return [];
  }
}

