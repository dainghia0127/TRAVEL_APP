import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/services/geocoding_service.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeocodingResult Model Tests', () {
    test('GeocodingResult parses JSON accurately', () {
      final json = {
        'place_id': 123456,
        'lat': '21.0285',
        'lon': '105.8542',
        'display_name': 'Hồ Hoàn Kiếm, Quận Hoàn Kiếm, Hà Nội, Việt Nam',
      };

      final result = GeocodingResult.fromJson(json);

      expect(result.displayName, equals('Hồ Hoàn Kiếm, Quận Hoàn Kiếm, Hà Nội, Việt Nam'));
      expect(result.title, equals('Hồ Hoàn Kiếm'));
      expect(result.subtitle, equals('Quận Hoàn Kiếm, Hà Nội, Việt Nam'));
      expect(result.position.latitude, closeTo(21.0285, 0.0001));
      expect(result.position.longitude, closeTo(105.8542, 0.0001));
    });

    test('GeocodingResult handles single part display_name', () {
      final json = {
        'place_id': 999,
        'lat': '10.7769',
        'lon': '106.7009',
        'display_name': 'Bến Nhà Rồng',
      };

      final result = GeocodingResult.fromJson(json);

      expect(result.title, equals('Bến Nhà Rồng'));
      expect(result.subtitle, isEmpty);
      expect(result.position.latitude, closeTo(10.7769, 0.0001));
      expect(result.position.longitude, closeTo(106.7009, 0.0001));
    });

    test('GeocodingResult parses Photon Komoot GeoJSON accurately', () {
      final feature = {
        'type': 'Feature',
        'properties': {
          'name': 'Tòa S2.05 Vinhome Grand Park',
          'street': 'Đường Nguyễn Xiển',
          'locality': 'Vinhomes Grand Park',
          'district': 'Long Bình',
          'city': 'Thành phố Thủ Đức',
          'country': 'Việt Nam',
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [106.832719, 10.8376756],
        },
      };

      final result = GeocodingResult.fromPhoton(feature);

      expect(result.title, equals('Tòa S2.05 Vinhome Grand Park'));
      expect(result.subtitle, contains('Long Bình'));
      expect(result.subtitle, contains('Thủ Đức'));
      expect(result.position.latitude, closeTo(10.8376, 0.0001));
      expect(result.position.longitude, closeTo(106.8327, 0.0001));
    });

    test('GeocodingService normalizes typo in queries like vinhome granpark', () {
      expect(
        GeocodingService.normalizeQuery('vinhome granpark'),
        equals('vinhomes grand park'),
      );
      expect(
        GeocodingService.normalizeQuery('vinhomes gran park'),
        equals('vinhomes grand park'),
      );
    });
  });

  group('StorageService Custom Route Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('StorageService saves and retrieves custom routes correctly', () async {
      final testRouteMap = {
        'id': 'route_custom_1',
        'name': 'Hà Nội đến Sa Pa',
        'startName': 'Hà Nội',
        'destName': 'Sa Pa',
        'startLat': 21.0285,
        'startLng': 105.8542,
        'destLat': 22.3364,
        'destLng': 103.8438,
        'distanceKm': 315.5,
      };
      final testRouteJson = jsonEncode(testRouteMap);

      await StorageService.saveCustomRouteJson('route_custom_1', testRouteJson);

      final retrievedStr = await StorageService.getCustomRouteJson('route_custom_1');
      expect(retrievedStr, isNotNull);
      final retrieved = jsonDecode(retrievedStr!) as Map<String, dynamic>;
      expect(retrieved['name'], equals('Hà Nội đến Sa Pa'));
      expect(retrieved['distanceKm'], equals(315.5));

      final allRoutesStr = await StorageService.getAllCustomRoutesJson();
      expect(allRoutesStr.length, equals(1));
      final firstRoute = jsonDecode(allRoutesStr.first) as Map<String, dynamic>;
      expect(firstRoute['id'], equals('route_custom_1'));

      await StorageService.removeCustomRouteJson('route_custom_1');
      final afterRemove = await StorageService.getCustomRouteJson('route_custom_1');
      expect(afterRemove, isNull);
    });

    test('Trip destinations can be completely emptied and respected', () async {
      // Lưu danh sách rỗng (người dùng đã xóa hết điểm)
      await StorageService.saveTripDestinations([]);

      // Việc đọc danh sách phải tôn trọng danh sách rỗng, không tự ý nạp 2 điểm mẫu
      final trips = await StorageService.getTripDestinations();
      expect(trips, isEmpty);
    });
  });
}
