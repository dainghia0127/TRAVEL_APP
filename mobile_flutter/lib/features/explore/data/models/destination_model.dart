import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination_media.dart';
import 'package:mobile_flutter/features/explore/domain/entities/safety_guideline.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';

class DestinationMediaModel extends DestinationMedia {
  const DestinationMediaModel({
    required super.id,
    required super.imageUrl,
    super.localAssetPath,
    required super.photographer,
    required super.sourceName,
    required super.license,
    required super.attribution,
    super.aspectRatio,
    super.isHero,
  });

  factory DestinationMediaModel.fromJson(Map<String, dynamic> json) {
    return DestinationMediaModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      localAssetPath: json['local_asset_path'] as String?,
      photographer: json['photographer'] as String? ?? 'Nhiếp ảnh gia',
      sourceName: json['source_name'] as String? ?? 'Creative Commons',
      license: json['license'] as String? ?? 'CC-BY',
      attribution: json['attribution'] as String? ?? '',
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 16 / 9,
      isHero: json['is_hero'] as bool? ?? false,
    );
  }
}

class SafetyGuidelineModel extends SafetyGuideline {
  const SafetyGuidelineModel({
    required super.waterAdvice,
    required super.mobileCoverageSummary,
    required super.primaryHazards,
    required super.requiredGear,
    required super.emergencyContactInfo,
    required super.verificationDate,
    required super.verifiedBy,
  });

  factory SafetyGuidelineModel.fromJson(Map<String, dynamic> json) {
    return SafetyGuidelineModel(
      waterAdvice: json['water_advice'] as String? ?? 'Đun sôi nước trước khi uống.',
      mobileCoverageSummary: json['mobile_coverage_summary'] as String? ?? 'Sóng di động chập chờn.',
      primaryHazards: (json['primary_hazards'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      requiredGear: (json['required_gear'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      emergencyContactInfo: json['emergency_contact_info'] as String? ?? 'Liên hệ kiểm lâm địa phương.',
      verificationDate: json['verification_date'] as String? ?? '',
      verifiedBy: json['verified_by'] as String? ?? 'Chuyên gia dã ngoại',
    );
  }
}

class RouteStageModel extends RouteStage {
  const RouteStageModel({
    required super.stageNumber,
    required super.title,
    required super.description,
    super.distanceKm,
    super.elevationGainMeters,
    super.terrainType,
  });

  factory RouteStageModel.fromJson(Map<String, dynamic> json) {
    return RouteStageModel(
      stageNumber: json['stage_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      elevationGainMeters: json['elevation_gain_meters'] as int?,
      terrainType: json['terrain_type'] as String?,
    );
  }
}

class TrekkingRouteModel extends TrekkingRoute {
  const TrekkingRouteModel({
    required super.id,
    required super.name,
    super.distanceKm,
    super.elevationGainMeters,
    super.difficultyLevel,
    super.estimatedDurationDays,
    super.isVerified,
    super.stages,
    super.safety,
  });

  factory TrekkingRouteModel.fromJson(Map<String, dynamic> json) {
    final stagesList = (json['stages'] as List<dynamic>?)
            ?.map((e) => RouteStageModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    SafetyGuideline? safety;
    if (json['safety'] != null) {
      safety = SafetyGuidelineModel.fromJson(json['safety'] as Map<String, dynamic>);
    }

    return TrekkingRouteModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Cung dã ngoại',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      elevationGainMeters: json['elevation_gain_meters'] as int?,
      difficultyLevel: json['difficulty_level'] as int?,
      estimatedDurationDays: json['estimated_duration_days'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      stages: stagesList,
      safety: safety,
    );
  }
}

class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.slug,
    required super.name,
    super.localName,
    super.province,
    super.countryName,
    required super.countryIds,
    required super.regionId,
    required super.categoryIds,
    super.centerLatitude,
    super.centerLongitude,
    super.elevationMeters,
    required super.editorialSummary,
    super.editorialContent,
    super.bestTravelSeasons,
    super.isFeatured,
    super.isPopular,
    super.isVerified,
    super.verificationDate,
    super.dataSource,
    super.media,
    super.route,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List<dynamic>?)
            ?.map((e) => DestinationMediaModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final countryList = (json['country_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['VN'];

    final categoryList = (json['category_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['trekking'];

    final seasonsList = (json['best_travel_seasons'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    TrekkingRoute? route;
    if (json['route'] != null) {
      route = TrekkingRouteModel.fromJson(json['route'] as Map<String, dynamic>);
    }

    return DestinationModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      localName: json['local_name'] as String?,
      province: json['province'] as String?,
      countryName: json['country_name'] as String?,
      countryIds: countryList,
      regionId: json['region_id'] as String? ?? 'vn_north',
      categoryIds: categoryList,
      centerLatitude: (json['center_latitude'] as num?)?.toDouble(),
      centerLongitude: (json['center_longitude'] as num?)?.toDouble(),
      elevationMeters: json['elevation_meters'] as int?,
      editorialSummary: json['editorial_summary'] as String? ?? '',
      editorialContent: json['editorial_content'] as String?,
      bestTravelSeasons: seasonsList,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationDate: json['verification_date'] as String?,
      dataSource: json['data_source'] as String?,
      media: mediaList,
      route: route,
    );
  }
}

