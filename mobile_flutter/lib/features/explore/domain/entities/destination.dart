import 'package:mobile_flutter/features/explore/domain/entities/destination_media.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';

/// Entity Điểm đến du lịch dã ngoại toàn cầu
class Destination {
  final String id;
  final String slug;
  final String name;
  final String? localName;
  final String? province; // Tỉnh / Thành phố / Bang
  final String? countryName; // Tên quốc gia hiển thị
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
  final bool isPopular; // Địa điểm được khám phá nhiều / thịnh hành
  final bool isVerified;
  final String? verificationDate;
  final String? dataSource; // Nguồn dữ liệu thực tế (UNESCO, Wikidata, OSM, Cục Du lịch)
  final List<DestinationMedia> media;
  final TrekkingRoute? route;
  final List<String> localSpecialties; // Đặc sản ẩm thực địa phương
  final List<String> mustTryActivities; // Trải nghiệm nhất định phải thử
  final List<String> culturalHighlights; // Nét đẹp văn hóa & lịch sử bản địa
  final String? gettingThereAdvice; // Hướng dẫn di chuyển & phương tiện đến
  final bool isSocialTrend; // Địa điểm check-in viral / hot trend trên TikTok & Facebook
  final String? socialPlatform; // Nền tảng trend (ví dụ: TikTok & Facebook, Instagram)
  final String? socialViews; // Lượng tương tác / lượt xem (ví dụ: 3.5M lượt xem)
  final String? photoSpotTip; // Mẹo góc chụp ảnh sống ảo triệu view

  const Destination({
    required this.id,
    required this.slug,
    required this.name,
    this.localName,
    this.province,
    this.countryName,
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
    this.isPopular = false,
    this.isVerified = false,
    this.verificationDate,
    this.dataSource,
    this.media = const [],
    this.route,
    this.localSpecialties = const [],
    this.mustTryActivities = const [],
    this.culturalHighlights = const [],
    this.gettingThereAdvice,
    this.isSocialTrend = false,
    this.socialPlatform,
    this.socialViews,
    this.photoSpotTip,
  });

  /// Kiểm tra xem điểm đến có thuộc quốc gia ngữ cảnh của người dùng hay không
  bool isDomestic(String userCountryCode) => countryIds.contains(userCountryCode);

  /// Kiểm tra xem tháng hiện tại có phải mùa du lịch lý tưởng nhất không
  bool isIdealSeason(int currentMonth) {
    if (bestTravelSeasons.isEmpty) return true;
    final mStr = currentMonth < 10 ? '0$currentMonth' : '$currentMonth';
    final mNum = currentMonth.toString();
    return bestTravelSeasons.any((s) =>
        s.contains(mStr) ||
        s.contains(mNum) ||
        s.toLowerCase().contains('quanh năm') ||
        s.toLowerCase().contains('all'));
  }

  /// Hiển thị địa chỉ tỉnh/thành hoặc quốc gia
  String get provinceOrCountry => province ?? countryName ?? (isDomestic('VN') ? 'Việt Nam' : 'Quốc tế');

  /// Lấy ảnh Hero đại diện
  DestinationMedia? get heroMedia {
    if (media.isEmpty) return null;
    for (final m in media) {
      if (m.isHero) return m;
    }
    return media.first;
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

  /// Nhãn danh mục chính hiển thị
  String get categoryLabel => categoryIds.isNotEmpty ? categoryIds.first : 'Dã ngoại';

  /// Vị trí hiển thị (Tỉnh/Thành phố hoặc Quốc gia)
  String get regionDisplay => province ?? countryName ?? '';
}
