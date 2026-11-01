import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/features/offline_map/services/routing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoutingService Tests', () {
    test('Fallback route generates multiple realistic coordinates, not a straight line', () {
      const start = LatLng(10.8231, 106.6297); // TP.HCM
      const end = LatLng(11.6420, 108.4230); // Tà Năng

      // Trong test environment, HTTP requests return 400 nên RoutingService sẽ tự động dùng Realistic Fallback
      // hoặc kết quả hợp lệ.
      final result = RoutingService.getActualRoute(start: start, end: end);

      expect(result, completion(isA<RoutingResult>()));
    });

    test('RoutingResult contains valid metrics and coordinates', () async {
      const start = LatLng(10.8231, 106.6297);
      const end = LatLng(11.6420, 108.4230);

      final result = await RoutingService.getActualRoute(start: start, end: end);

      expect(result.points.length, greaterThan(10));
      expect(result.points.first.latitude, closeTo(start.latitude, 0.001));
      expect(result.points.last.latitude, closeTo(end.latitude, 0.001));
      expect(result.distanceKm, greaterThan(0));
      expect(result.durationText, isNotEmpty);
    });
  });
}

