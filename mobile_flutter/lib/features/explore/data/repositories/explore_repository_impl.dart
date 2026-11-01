import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/repositories/i_explore_repository.dart';

class ExploreRepositoryImpl implements IExploreRepository {
  final IExploreLocalDataSource localDataSource;

  ExploreRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Destination>> getAllDestinations() async {
    return await localDataSource.getSeedDestinations();
  }

  @override
  Future<List<Destination>> getDomesticDestinations({String userCountryCode = 'VN'}) async {
    final all = await getAllDestinations();
    return all.where((d) => d.isDomestic(userCountryCode)).toList();
  }

  @override
  Future<List<Destination>> getInternationalDestinations({String userCountryCode = 'VN'}) async {
    final all = await getAllDestinations();
    return all.where((d) => !d.isDomestic(userCountryCode)).toList();
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final all = await getAllDestinations();
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Destination>> searchAndFilterDestinations({
    required bool isDomestic,
    String query = '',
    String? regionId,
    String? categoryId,
    int? difficultyLevel,
    String userCountryCode = 'VN',
  }) async {
    final all = await (isDomestic
        ? getDomesticDestinations(userCountryCode: userCountryCode)
        : getInternationalDestinations(userCountryCode: userCountryCode));

    return all.where((d) {
      // Lọc theo từ khóa tìm kiếm (Tên, địa danh bản địa, tóm tắt)
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = d.name.toLowerCase().contains(q);
        final matchLocal = (d.localName ?? '').toLowerCase().contains(q);
        final matchSummary = d.editorialSummary.toLowerCase().contains(q);
        if (!matchName && !matchLocal && !matchSummary) return false;
      }

      // Lọc theo vùng miền / châu lục
      if (regionId != null && regionId.isNotEmpty && regionId != 'all') {
        if (d.regionId != regionId) return false;
      }

      // Lọc theo danh mục
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        if (!d.categoryIds.contains(categoryId)) return false;
      }

      // Lọc theo độ khó của cung đường
      if (difficultyLevel != null) {
        if (d.route == null || d.route!.difficultyLevel != difficultyLevel) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

