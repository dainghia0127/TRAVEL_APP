import 'package:mobile_flutter/features/explore/domain/entities/destination_media.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';

/// Entity Điểm đến du lịch dã ngoại toàn cầu
class Destination {
  final String id;
  final String slug;
  final String name;
  final String? localName;
  final List<String> countryIds;
  final String regionId;
  final List<String> categoryIds;
  final double? centerLatitude;
  final double? centerLongitude;
  final int? elevationMeters;
  final String editorialSummary;
  final String? editorialContent;
  final List<String> bestTravelSeasons;
  final bool isFeatured;
  final bool isVerified;
  final String? verificationDate;
  final List<DestinationMedia> media;
  final TrekkingRoute? route;

  const Destination({
    required this.id,
    required this.slug,
    required this.name,
    this.localName,
    required this.countryIds,
    required this.regionId,
    required this.categoryIds,
    this.centerLatitude,
    this.centerLongitude,
    this.elevationMeters,
    required this.editorialSummary,
    this.editorialContent,
    this.bestTravelSeasons = const [],
    this.isFeatured = false,
    this.isVerified = false,
    this.verificationDate,
    this.media = const [],
    this.route,
  });

  /// Kiểm tra xem điểm đến có thuộc quốc gia ngữ cảnh của người dùng hay không
  bool isDomestic(String userCountryCode) => countryIds.contains(userCountryCode);

  /// Lấy ảnh Hero đại diện
  DestinationMedia? get heroMedia {
    if (media.isEmpty) return null;
    return media.firstWhere(
      (m) => m.isHero,
      orElse: () => media.first,
    );
  }

  /// Chuỗi hiển thị cự ly (nếu có cung đường đi kèm)
  String get distanceDisplay {
    if (route?.distanceKm != null) {
      return '${route!.distanceKm!.toStringAsFixed(route!.distanceKm! % 1 == 0 ? 0 : 1)} km';
    }
    return '-- km';
  }

  /// Chuỗi hiển thị độ cao
  String get elevationDisplay {
    if (elevationMeters != null) {
      return '$elevationMeters m';
    }
    return '-- m';
  }
}
