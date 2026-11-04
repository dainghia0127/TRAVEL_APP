import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check all destinations have valid heroMedia and localAssetPath', () async {
    final ds = ExploreLocalDataSource();
    final list = await ds.getSeedDestinations();
    expect(list.length, 32);

    for (final d in list) {
      final hero = d.heroMedia;
      expect(hero, isNotNull, reason: 'Destination ${d.id} has null heroMedia');
      expect(hero!.imageUrl.isNotEmpty, isTrue);
      expect(hero.localAssetPath, isNotNull, reason: 'Destination ${d.id} has null localAssetPath');
      expect(hero.localAssetPath!.startsWith('assets/images/destinations/'), isTrue);
    }
  });
}
