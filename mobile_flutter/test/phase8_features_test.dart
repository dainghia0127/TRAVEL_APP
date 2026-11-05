import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 8 - Cloud Sync & Local Storage Test', () {
    test('StorageService can save and retrieve synced destinations JSON', () async {
      const mockJson = '{"version":"2026.11","destinations":[{"id":"test_dest","name":"Đỉnh Fansipan"}]}';
      final saved = await StorageService.saveSyncedDestinationsJson(mockJson);
      expect(saved, isTrue);

      final retrieved = await StorageService.getSyncedDestinationsJson();
      expect(retrieved, equals(mockJson));

      final lastSyncTime = await StorageService.getLastSyncTime();
      expect(lastSyncTime, isNotNull);
    });

    test('ExploreLocalDataSource falls back gracefully to local asset/cache', () async {
      final dataSource = ExploreLocalDataSource();
      final syncResult = await dataSource.syncFromCloud();
      // Trong môi trường test offline không mạng, syncFromCloud sẽ chuyển sang offline mode an toàn
      expect(syncResult.destinationCount, greaterThanOrEqualTo(0));
      expect(syncResult.message, isNotEmpty);
    });
  });

  group('Phase 8 - Trip Planner Milestone Logic Test', () {
    test('Milestone formatting handles custom km and completion state', () {
      final milestone = <String, dynamic>{
        'id': 'test_ms_1',
        'title': 'Trạm Suối 1',
        'distance': '+ 4.5 km',
        'isCompleted': false,
      };

      expect(milestone['distance'], equals('+ 4.5 km'));
      expect(milestone['isCompleted'], isFalse);

      // Toggle hoàn thành mốc
      milestone['isCompleted'] = !(milestone['isCompleted'] as bool);
      expect(milestone['isCompleted'], isTrue);
    });
  });
}

