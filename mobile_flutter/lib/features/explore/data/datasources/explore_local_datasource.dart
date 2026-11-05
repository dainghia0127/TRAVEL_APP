import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/data/models/destination_model.dart';

class CloudSyncResult {
  final bool isSuccess;
  final bool isOffline;
  final int destinationCount;
  final String message;

  const CloudSyncResult({
    required this.isSuccess,
    this.isOffline = false,
    required this.destinationCount,
    required this.message,
  });
}

abstract class IExploreLocalDataSource {
  Future<List<DestinationModel>> getSeedDestinations();
  Future<CloudSyncResult> syncFromCloud();
  void invalidateCache();
}

class ExploreLocalDataSource implements IExploreLocalDataSource {
  static const String _assetPath = 'assets/data/destinations_seed.json';
  static const String _cloudSeedUrl =
      'https://raw.githubusercontent.com/dainghia0127/TRAVEL_APP/main/mobile_flutter/assets/data/destinations_seed.json';

  // Static RAM Cache: Toàn bộ app chỉ parse JSON đúng 1 lần duy nhất trong toàn vòng đời
  static List<DestinationModel>? _cachedDestinations;

  @override
  Future<List<DestinationModel>> getSeedDestinations() async {
    // 1. Kiểm tra RAM cache
    if (_cachedDestinations != null && _cachedDestinations!.isNotEmpty) {
      return _cachedDestinations!;
    }

    List<DestinationModel> list = [];

    // 2. Kiểm tra bộ nhớ máy (SharedPreferences) đã từng đồng bộ từ Cloud chưa
    try {
      final savedCloudJson = await StorageService.getSyncedDestinationsJson();
      if (savedCloudJson != null && savedCloudJson.trim().isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(savedCloudJson) as Map<String, dynamic>;
        list = (decoded['destinations'] as List<dynamic>?)
                ?.map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (_) {}

    // 3. Fallback đọc file JSON từ asset bundle nội bộ trong máy nếu chưa có cloud cache
    if (list.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString(_assetPath);
        final Map<String, dynamic> decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        list = (decoded['destinations'] as List<dynamic>?)
                ?.map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      } catch (e) {
        // Fallback an toàn nếu có lỗi giải mã
        list = [];
      }
    }

    // 4. Nạp thêm các Lộ trình tự chọn A-B do người dùng tạo (Custom Routes)
    try {
      final customJsonList = await StorageService.getAllCustomRoutesJson();
      for (final cJson in customJsonList) {
        final decoded = jsonDecode(cJson) as Map<String, dynamic>;
        final model = DestinationModel.fromJson(decoded);
        if (!list.any((d) => d.id == model.id)) {
          list.add(model);
        }
      }
    } catch (_) {}

    _cachedDestinations = list;
    return list;
  }

  /// Đồng bộ dữ liệu địa danh mới nhất từ Cloud (GitHub Raw endpoint)
  @override
  Future<CloudSyncResult> syncFromCloud() async {
    String? failureReason;
    try {
      final response = await http
          .get(Uri.parse(_cloudSeedUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (decoded['destinations'] as List<dynamic>?)
                ?.map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        if (list.isNotEmpty) {
          // Lưu vào bộ nhớ máy SharedPreferences để dùng lâu dài kể cả khi offline
          await StorageService.saveSyncedDestinationsJson(response.body);
          invalidateCache();
          final refreshedList = await getSeedDestinations();
          return CloudSyncResult(
            isSuccess: true,
            isOffline: false,
            destinationCount: refreshedList.length,
            message: 'Đã đồng bộ thành công ${refreshedList.length} địa điểm mới nhất từ Đám Mây (Cloud)!',
          );
        }
      } else if (response.statusCode == 404) {
        failureReason = 'Kho lưu trữ GitHub đang ở chế độ Riêng Tư (Private). Hãy chuyển Repo sang Public để tải tự động.';
      } else {
        failureReason = 'Máy chủ trả về mã HTTP ${response.statusCode}.';
      }
    } catch (_) {
      failureReason = 'Không thể kết nối đến máy chủ Cloud (Kiểm tra kết nối mạng).';
    }

    // Đọc dữ liệu local hiện có trong máy
    invalidateCache();
    final currentList = await getSeedDestinations();
    return CloudSyncResult(
      isSuccess: false,
      isOffline: true,
      destinationCount: currentList.length,
      message: failureReason != null
          ? '$failureReason\nĐang sử dụng ${currentList.length} địa điểm lưu trong máy.'
          : 'Chế độ Ngoại Tuyến (Offline). Đang sử dụng ${currentList.length} địa điểm lưu trong máy.',
    );
  }

  /// Cho phép làm mới cache khi cần thiết
  @override
  void invalidateCache() {
    _cachedDestinations = null;
  }
}

