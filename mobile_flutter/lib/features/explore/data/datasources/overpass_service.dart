import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Dịch vụ kết nối trực tiếp OpenStreetMap Overpass API
/// Dùng để truy vấn các điểm tiện ích dã ngoại (POI) thực tế quanh tọa độ
/// Tuân thủ nguyên tắc: Không tạo rating, review hay số liệu đánh giá ảo
class OverpassService {
  static const String _overpassEndpoint = 'https://overpass-api.de/api/interpreter';
  static final Map<String, List<Map<String, dynamic>>> _memoryCache = {};

  /// Truy vấn các tiện ích dã ngoại trong bán kính [radiusMeters] quanh tọa độ [center]
  /// Các loại POI: Bãi cắm trại (camp_site), Điểm ngắm cảnh (viewpoint), Đỉnh núi (peak), Nguồn nước (drinking_water)
  static Future<List<Map<String, dynamic>>> getOutdoorPoisNearby({
    required LatLng center,
    int radiusMeters = 5000,
  }) async {
    final cacheKey = '${center.latitude.toStringAsFixed(2)}_${center.longitude.toStringAsFixed(2)}_$radiusMeters';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    final query = '''
[out:json][timeout:10];
(
  node["tourism"="camp_site"](around:$radiusMeters,${center.latitude},${center.longitude});
  node["tourism"="viewpoint"](around:$radiusMeters,${center.latitude},${center.longitude});
  node["natural"="peak"](around:$radiusMeters,${center.latitude},${center.longitude});
  node["amenity"="drinking_water"](around:$radiusMeters,${center.latitude},${center.longitude});
  node["tourism"="wilderness_hut"](around:$radiusMeters,${center.latitude},${center.longitude});
);
out body 20;
''';

    try {
      final response = await http
          .post(
            Uri.parse(_overpassEndpoint),
            body: {'data': query},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final elements = (decoded['elements'] as List<dynamic>?) ?? [];

        final List<Map<String, dynamic>> results = [];
        for (final el in elements) {
          final tags = el['tags'] as Map<String, dynamic>? ?? {};
          final name = tags['name'] as String? ?? tags['name:en'] as String? ?? 'Tiện ích dã ngoại OSM';
          final lat = (el['lat'] as num?)?.toDouble() ?? 0.0;
          final lon = (el['lon'] as num?)?.toDouble() ?? 0.0;
          
          String type = 'checkpoint';
          if (tags['tourism'] == 'camp_site') type = 'camp';
          if (tags['tourism'] == 'viewpoint') type = 'highlight';
          if (tags['natural'] == 'peak') type = 'peak';
          if (tags['amenity'] == 'drinking_water') type = 'water';

          results.add({
            'id': 'osm_${el['id']}',
            'name': name,
            'latitude': lat,
            'longitude': lon,
            'type': type,
            'elevation': tags['ele'] as String?,
            'source': 'OpenStreetMap (OSM Node #${el['id']})',
          });
        }

        _memoryCache[cacheKey] = results;
        return results;
      }
    } catch (_) {
      // Khi mất mạng hoặc Overpass bị quá tải, trả về danh sách rỗng an toàn
    }

    return [];
  }
}

