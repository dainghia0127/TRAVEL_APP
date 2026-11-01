import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/data/repositories/explore_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExploreLocalDataSource dataSource;
  late ExploreRepositoryImpl repository;

  setUp(() {
    dataSource = ExploreLocalDataSource();
    repository = ExploreRepositoryImpl(localDataSource: dataSource);
  });

  test('ExploreRepository reads seed JSON and separates Domestic & International correctly', () async {
    // 1. Lấy toàn bộ danh sách điểm đến
    final allDestinations = await repository.getAllDestinations();
    expect(allDestinations.length, 16);

    // 2. Điểm đến trong nước (Việt Nam)
    final domestic = await repository.getDomesticDestinations(userCountryCode: 'VN');
    expect(domestic.length, 10);
    for (final d in domestic) {
      expect(d.countryIds.contains('VN'), isTrue);
    }

    // 3. Điểm đến quốc tế
    final international = await repository.getInternationalDestinations(userCountryCode: 'VN');
    expect(international.length, 6);
    for (final d in international) {
      expect(d.countryIds.contains('VN'), isFalse);
    }

    // 4. Lọc theo vùng Tây Nguyên
    final highlands = await repository.searchAndFilterDestinations(
      isDomestic: true,
      regionId: 'vn_highlands',
      userCountryCode: 'VN',
    );
    expect(highlands.isNotEmpty, isTrue);
    for (final d in highlands) {
      expect(d.regionId, 'vn_highlands');
    }

    // 5. Tìm kiếm từ khóa quốc tế 'Fuji'
    final fujiResults = await repository.searchAndFilterDestinations(
      isDomestic: false,
      query: 'Fuji',
      userCountryCode: 'VN',
    );
    expect(fujiResults.length, 1);
    expect(fujiResults.first.id, 'intl_mount_fuji');

    // 6. Kiểm tra cung đường xuyên quốc gia Tour du Mont Blanc
    final montBlanc = await repository.getDestinationById('intl_tour_du_mont_blanc');
    expect(montBlanc, isNotNull);
    expect(montBlanc!.countryIds, containsAll(['FR', 'IT', 'CH']));
    expect(montBlanc.route, isNotNull);
    expect(montBlanc.route!.stages.length, 3);
    expect(montBlanc.route!.safety, isNotNull);
    expect(montBlanc.route!.safety!.emergencyContactInfo, contains('1414'));
  });
}

