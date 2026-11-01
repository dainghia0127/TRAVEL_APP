import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';

/// Interface hợp đồng dữ liệu của Phân hệ Khám phá
abstract class IExploreRepository {
  /// Lấy toàn bộ danh sách điểm đến đã được kiểm duyệt
  Future<List<Destination>> getAllDestinations();

  /// Lấy danh sách điểm đến trong nước (Việt Nam)
  Future<List<Destination>> getDomesticDestinations({String userCountryCode = 'VN'});

  /// Lấy danh sách điểm đến quốc tế
  Future<List<Destination>> getInternationalDestinations({String userCountryCode = 'VN'});

  /// Lấy chi tiết một điểm đến theo ID
  Future<Destination?> getDestinationById(String id);

  /// Tìm kiếm và lọc điểm đến
  Future<List<Destination>> searchAndFilterDestinations({
    required bool isDomestic,
    String query = '',
    String? regionId,
    String? categoryId,
    int? difficultyLevel,
    String userCountryCode = 'VN',
  });
}

