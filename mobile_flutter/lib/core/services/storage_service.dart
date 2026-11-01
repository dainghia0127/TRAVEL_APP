import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyFavorites = 'travel_favorites';
  static const String _keyChecklist = 'travel_checklist';

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
