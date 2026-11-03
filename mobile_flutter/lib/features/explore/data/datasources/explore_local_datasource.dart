import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/features/explore/data/models/destination_model.dart';

abstract class IExploreLocalDataSource {
  Future<List<DestinationModel>> getSeedDestinations();
  void invalidateCache();
}

class ExploreLocalDataSource implements IExploreLocalDataSource {
  static const String _assetPath = 'assets/data/destinations_seed.json';
  // Static RAM Cache: Toàn bộ app chỉ parse JSON đúng 1 lần duy nhất trong toàn vòng đời
  static List<DestinationModel>? _cachedDestinations;

  @override
  Future<List<DestinationModel>> getSeedDestinations() async {
    // 1. Kiểm tra RAM cache
    if (_cachedDestinations != null && _cachedDestinations!.isNotEmpty) {
      return _cachedDestinations!;
    }

    try {
      // 2. Đọc file JSON từ asset bundle
      final jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = (decoded['destinations'] as List<dynamic>?)
              ?.map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      _cachedDestinations = list;
      return list;
    } catch (e) {
      // Fallback an toàn nếu có lỗi giải mã
      return [];
    }
  }

  /// Cho phép làm mới cache khi cần thiết
  @override
  void invalidateCache() {
    _cachedDestinations = null;
  }
}

