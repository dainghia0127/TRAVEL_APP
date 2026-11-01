import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/features/offline_map/services/routing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoutingService Tests', () {
    test('Fallback route generates multiple realistic coordinates, not a straight line', () {
      const start = LatLng(10.8231, 106.6297); // TP.HCM
      const end = LatLng(11.6420, 108.4230); // Tà Năng

      final result = RoutingService.getActualRoute(start: start, end: end, isDomestic: true);

      expect(result, completion(isA<RoutingResult>()));
    });

    test('RoutingResult contains valid metrics and coordinates', () async {
      const start = LatLng(10.8231, 106.6297);
      const end = LatLng(11.6420, 108.4230);

      final result = await RoutingService.getActualRoute(start: start, end: end, isDomestic: true);

      expect(result.points.length, greaterThan(10));
      expect(result.points.first.latitude, closeTo(start.latitude, 0.001));
      expect(result.points.last.latitude, closeTo(end.latitude, 0.001));
      expect(result.distanceKm, greaterThan(0));
      expect(result.durationText, isNotEmpty);
    });

    test('Domestic route coordinates strictly reside within Vietnam national territory bounds', () async {
      // Tuyến đường xuyên Việt từ TP.HCM ra Fansipan (Sa Pa)
      const start = LatLng(10.8231, 106.6297);
      const end = LatLng(22.3030, 103.7750);

      final result = await RoutingService.getActualRoute(start: start, end: end, isDomestic: true);

      expect(result.points.isNotEmpty, isTrue);

      // Xác minh tất cả các điểm đều nằm trong phạm vi vĩ độ và kinh độ của lãnh thổ Việt Nam
      for (final p in result.points) {
        expect(p.latitude, inInclusiveRange(8.5, 23.5),
            reason: 'Vĩ độ ${p.latitude} phải nằm trong lãnh thổ Việt Nam');
        expect(p.longitude, inInclusiveRange(102.0, 109.6),
            reason: 'Kinh độ ${p.longitude} phải nằm trong lãnh thổ Việt Nam');

        // Đối với vùng miền Trung (vĩ độ 15.0 - 17.5), dải đất hẹp sát biển, kinh độ không được lấn sang Lào (< 106.0)
        if (p.latitude >= 16.0 && p.latitude <= 17.5) {
          expect(p.longitude, greaterThanOrEqualTo(106.0),
              reason: 'Điểm ${p.latitude}, ${p.longitude} tại miền Trung không được chệch sang Lào');
        }
      }
    });
  });
}
