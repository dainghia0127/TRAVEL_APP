import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyFavorites = 'travel_favorites';
  static const String _keyChecklist = 'travel_checklist';
  static const String _keyTripDestinations = 'travel_trip_destinations';
  static const String _keySelectedTripDestId = 'travel_selected_trip_dest_id';
  static const String _keySyncedDestinationsJson = 'travel_synced_destinations_json';
  static const String _keyLastSyncTimestamp = 'travel_last_sync_timestamp';

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

  /// Lưu danh sách địa điểm đã thêm vào chuyến đi
  static Future<bool> saveTripDestinations(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_keyTripDestinations, ids);
  }

  /// Lấy danh sách địa điểm đã thêm vào chuyến đi
  static Future<List<String>> getTripDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTripDestinations);
    if (list == null || list.isEmpty) {
      // Mặc định cung cấp 2 điểm đến khởi đầu
      return ['vn_ta_nang_phan_dung', 'vn_lake_tuyen_lam'];
    }
    return list;
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

  /// Xóa 1 địa điểm khỏi chuyến đi
  static Future<List<String>> removeTripDestination(String id) async {
    final list = await getTripDestinations();
    list.remove(id);
    await saveTripDestinations(list);
    final selected = await getSelectedTripDestination();
    if (selected == id && list.isNotEmpty) {
      await setSelectedTripDestination(list.first);
    }
    return list;
  }

  /// Lưu địa điểm đang được chọn để xem trên bản đồ & lịch trình
  static Future<bool> setSelectedTripDestination(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keySelectedTripDestId, id);
  }

  /// Lấy ID địa điểm đang được chọn
  static Future<String?> getSelectedTripDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final selected = prefs.getString(_keySelectedTripDestId);
    if (selected != null && selected.isNotEmpty) {
      return selected;
    }
    final list = await getTripDestinations();
    return list.isNotEmpty ? list.first : 'vn_ta_nang_phan_dung';
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
