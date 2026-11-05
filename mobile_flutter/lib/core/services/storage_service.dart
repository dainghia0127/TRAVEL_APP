import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyFavorites = 'travel_favorites';
  static const String _keyChecklist = 'travel_checklist';
  static const String _keyTripDestinations = 'travel_trip_destinations';
  static const String _keyTripInitialized = 'travel_trip_initialized';
  static const String _keySelectedTripDestId = 'travel_selected_trip_dest_id';
  static const String _keySyncedDestinationsJson = 'travel_synced_destinations_json';
  static const String _keyLastSyncTimestamp = 'travel_last_sync_timestamp';
  static const String _keyCustomRoutesPrefix = 'travel_custom_route_';
  static const String _keyCustomRouteIds = 'travel_custom_route_ids';
  static const String _keyCustomRouteDetailPrefix = 'travel_custom_route_detail_';

  /// Lưu chuỗi JSON địa danh đồng bộ từ Cloud về máy
  static Future<bool> saveSyncedDestinationsJson(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSyncTimestamp, DateTime.now().toIso8601String());
    return prefs.setString(_keySyncedDestinationsJson, jsonString);
  }

  /// Lấy chuỗi JSON địa danh đã đồng bộ từ Cloud lưu trong máy
  static Future<String?> getSyncedDestinationsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySyncedDestinationsJson);
  }

  /// Lấy thời điểm đồng bộ đám mây gần nhất
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyLastSyncTimestamp);
    if (str != null) {
      try {
        return DateTime.parse(str);
      } catch (_) {}
    }
    return null;
  }

  /// Lưu danh sách yêu thích
  static Future<bool> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_keyFavorites, favorites);
  }

  /// Lấy danh sách yêu thích
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  /// Đảo trạng thái yêu thích của 1 địa điểm
  static Future<List<String>> toggleFavorite(String id) async {
    final list = await getFavorites();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await saveFavorites(list);
    return list;
  }

  /// Lưu danh sách địa điểm đã thêm vào chuyến đi (hỗ trợ danh sách rỗng khi người dùng xóa hết)
  static Future<bool> saveTripDestinations(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTripInitialized, true);
    return prefs.setStringList(_keyTripDestinations, ids);
  }

  /// Lấy danh sách địa điểm đã thêm vào chuyến đi
  /// Mặc định trả về danh sách rỗng [] để người dùng tự do khám phá và tạo chuyến đi sạch sẽ
  static Future<List<String>> getTripDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_keyTripInitialized) ?? false;
    if (!isInitialized) {
      await prefs.setBool(_keyTripInitialized, true);
      await prefs.setStringList(_keyTripDestinations, []);
      return [];
    }
    return prefs.getStringList(_keyTripDestinations) ?? [];
  }

  /// Xóa sạch toàn bộ địa điểm trong chuyến đi
  static Future<void> clearAllTripDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTripInitialized, true);
    await prefs.setStringList(_keyTripDestinations, []);
    await prefs.remove(_keySelectedTripDestId);
  }

  /// Thêm 1 địa điểm vào chuyến đi và tự động chọn nó
  static Future<List<String>> addTripDestination(String id) async {
    final list = await getTripDestinations();
    if (!list.contains(id)) {
      list.add(id);
      await saveTripDestinations(list);
    }
    await setSelectedTripDestination(id);
    return list;
  }

  /// Xóa 1 địa điểm khỏi chuyến đi (cho phép xóa sạch hoàn toàn)
  static Future<List<String>> removeTripDestination(String id) async {
    final list = await getTripDestinations();
    list.remove(id);
    await saveTripDestinations(list);
    final selected = await getSelectedTripDestination();
    if (list.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySelectedTripDestId);
    } else if (selected == id) {
      await setSelectedTripDestination(list.first);
    }
    // Dọn dẹp custom route nếu id là custom route
    if (id.startsWith('custom_route_')) {
      await removeCustomRouteJson(id);
    }
    return list;
  }

  /// Lưu địa điểm đang được chọn để xem trên bản đồ & lịch trình
  static Future<bool> setSelectedTripDestination(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keySelectedTripDestId, id);
  }

  /// Lấy ID địa điểm đang được chọn (trả về null nếu chuyến đi rỗng)
  static Future<String?> getSelectedTripDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getTripDestinations();
    if (list.isEmpty) return null;

    final selected = prefs.getString(_keySelectedTripDestId);
    if (selected != null && list.contains(selected)) {
      return selected;
    }
    return list.first;
  }

  /// Lưu trữ thông tin Tuyến đường tự chọn A-B dạng JSON
  static Future<void> saveCustomRouteJson(String id, String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyCustomRoutesPrefix$id', jsonString);
    final ids = prefs.getStringList(_keyCustomRouteIds) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_keyCustomRouteIds, ids);
    }
  }

  /// Lấy thông tin 1 Tuyến đường tự chọn A-B
  static Future<String?> getCustomRouteJson(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyCustomRoutesPrefix$id');
  }

  /// Lấy tất cả chuỗi JSON của các tuyến tự chọn A-B đã lưu
  static Future<List<String>> getAllCustomRoutesJson() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_keyCustomRouteIds) ?? [];
    final List<String> result = [];
    for (final id in ids) {
      final str = prefs.getString('$_keyCustomRoutesPrefix$id');
      if (str != null && str.isNotEmpty) {
        result.add(str);
      }
    }
    return result;
  }

  /// Lưu metadata chi tiết của Lộ trình A-B (tọa độ A, B, tên A, B, và line points)
  static Future<void> saveCustomRouteDetail(String id, String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyCustomRouteDetailPrefix$id', jsonString);
  }

  /// Lấy metadata chi tiết của Lộ trình A-B
  static Future<String?> getCustomRouteDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyCustomRouteDetailPrefix$id');
  }

  /// Xóa tuyến đường tự chọn A-B
  static Future<void> removeCustomRouteJson(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyCustomRoutesPrefix$id');
    await prefs.remove('$_keyCustomRouteDetailPrefix$id');
    final ids = prefs.getStringList(_keyCustomRouteIds) ?? [];
    ids.remove(id);
    await prefs.setStringList(_keyCustomRouteIds, ids);
  }

  /// Lưu trạng thái checklist chuẩn bị đồ
  static Future<bool> saveChecklist(List<String> checkedItems) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_keyChecklist, checkedItems);
  }

  /// Lấy danh sách checklist đã tích chọn
  static Future<List<String>> getChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyChecklist) ?? [];
  }
}
