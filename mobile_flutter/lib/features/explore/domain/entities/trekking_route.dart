import 'package:mobile_flutter/features/explore/domain/entities/safety_guideline.dart';

/// Entity chặng lộ trình cụ thể
class RouteStage {
  final int stageNumber;
  final String title;
  final String description;
  final double? distanceKm;
  final int? elevationGainMeters;
  final String? terrainType;

  const RouteStage({
    required this.stageNumber,
    required this.title,
    required this.description,
    this.distanceKm,
    this.elevationGainMeters,
    this.terrainType,
  });
}

/// Entity cung đường dã ngoại / trekking
class TrekkingRoute {
  final String id;
  final String name;
  final double? distanceKm;
  final int? elevationGainMeters;
  final int? difficultyLevel; // 1: Dễ, 2: Vừa, 3: Khó, 4: Thách thức
  final int? estimatedDurationDays;
  final bool isVerified;
  final List<RouteStage> stages;
  final SafetyGuideline? safety;

  const TrekkingRoute({
    required this.id,
    required this.name,
    this.distanceKm,
    this.elevationGainMeters,
    this.difficultyLevel,
    this.estimatedDurationDays,
    this.isVerified = false,
    this.stages = const [],
    this.safety,
  });

  String get difficultyLabel {
    switch (difficultyLevel) {
      case 1:
        return 'Dễ';
      case 2:
        return 'Vừa sức';
      case 3:
        return 'Khó';
      case 4:
        return 'Thách thức';
      default:
        return 'Dã ngoại';
    }
  }
}

