import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';
import 'package:mobile_flutter/features/trip_planner/services/itinerary_engine.dart';

void main() {
  group('ItineraryEngine Dynamic Breakdown Tests', () {
    test('calculateSuggestedDays proposes realistic days based on distance', () {
      // 1. Cự ly cực xa (~2,000 km: TP.HCM <-> Hà Giang, Sa Pa, Tây Bắc)
      final farDays1 = ItineraryEngine.calculateSuggestedDays(2050.0, 1);
      expect(farDays1, equals(3), reason: 'Điểm 2000km có thời lượng 1 ngày cần tối thiểu 3 ngày (tiếp cận + chơi + về)');

      final farDays3 = ItineraryEngine.calculateSuggestedDays(2050.0, 3);
      expect(farDays3, equals(5), reason: 'Điểm 2000km có cung trekking 3 ngày cần 5 ngày tổng thể');

      // 2. Cự ly quốc tế (> 3500 km: Everest, Phú Sĩ)
      final intlDays = ItineraryEngine.calculateSuggestedDays(4200.0, 2);
      expect(intlDays, equals(5));

      // 3. Cự ly liên vùng (450km - 1200km: TP.HCM <-> Đà Lạt, Phú Yên)
      final midDays = ItineraryEngine.calculateSuggestedDays(650.0, 2);
      expect(midDays, equals(3));

      // 4. Cự ly gần (< 120km: TP.HCM <-> Núi Bà Đen)
      final shortDays = ItineraryEngine.calculateSuggestedDays(95.0, 1);
      expect(shortDays, equals(1));
    });

    test('generateDynamicItinerary provides complete stops for ALL days without any blank day for 2000km distance', () {
      final mockDestination = Destination(
        id: 'dest_test_hagiang',
        slug: 'deo-ma-pi-leng',
        name: 'Đèo Mã Pí Lèng',
        countryIds: const ['VN'],
        regionId: 'northern_vn',
        categoryIds: const ['mountain_pass'],
        editorialSummary: 'Cung đèo hiểm trở bậc nhất tứ đại đỉnh đèo',
        centerLatitude: 23.2389,
        centerLongitude: 105.4180,
        elevationMeters: 1400,
        route: const TrekkingRoute(
          id: 'route_mapileng',
          name: 'Đường mòn Mã Pí Lèng',
          distanceKm: 22.0,
          elevationGainMeters: 650,
          estimatedDurationDays: 2,
          stages: [
            RouteStage(
              stageNumber: 1,
              title: 'Vượt đèo hiểm trở ngắm sông Nho Quế',
              description: 'Đi bộ theo đường mòn vách đá trắng',
              distanceKm: 12.0,
              elevationGainMeters: 400,
            ),
            RouteStage(
              stageNumber: 2,
              title: 'Xuống hẻm Tu Sản & Thuyền trên dòng Nho Quế',
              description: 'Chiêm ngưỡng hẻm vực sâu nhất Đông Nam Á',
              distanceKm: 10.0,
              elevationGainMeters: 250,
            ),
          ],
        ),
      );

      const double distanceKm = 2050.0; // Khoảng cách thực tế TP.HCM -> Hà Giang
      final totalDays = ItineraryEngine.calculateSuggestedDays(distanceKm, mockDestination.route?.estimatedDurationDays);

      expect(totalDays, equals(4), reason: '2000km với cung 2 ngày phải được phân bổ thành 4 ngày');

      final itinerary = ItineraryEngine.generateDynamicItinerary(
        dest: mockDestination,
        distKm: distanceKm,
        totalDays: totalDays,
      );

      // Đảm bảo kết quả chứa đầy đủ số ngày từ 1 đến 4
      expect(itinerary.keys.length, equals(4));

      for (int day = 1; day <= totalDays; day++) {
        final dayStops = itinerary[day];
        expect(dayStops, isNotNull, reason: 'Ngày $day không được null');
        expect(dayStops!.isNotEmpty, isTrue, reason: 'Ngày $day bắt buộc phải có mốc lịch trình chi tiết, không được để trống!');
      }

      // Kiểm tra tính chất Ngày 1 (Tiếp cận đường dài)
      final day1Stops = itinerary[1]!;
      expect(day1Stops.any((s) => (s['title'] as String).contains('hàng không') || (s['title'] as String).contains('đường dài')), isTrue);

      // Kiểm tra tính chất Ngày 4 (Hồi hương)
      final day4Stops = itinerary[4]!;
      expect(day4Stops.any((s) => (s['title'] as String).contains('hồi hương') || (s['type'] == 'finish')), isTrue);
    });
  });
}

