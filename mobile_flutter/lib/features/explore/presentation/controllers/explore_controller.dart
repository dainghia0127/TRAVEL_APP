import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/repositories/i_explore_repository.dart';

class RegionItem {
  final String id;
  final String label;

  const RegionItem({required this.id, required this.label});
}

class ExploreController extends ChangeNotifier {
  final IExploreRepository repository;
  final String userCountryCode;

  ExploreController({
    required this.repository,
    this.userCountryCode = 'VN',
  });

  bool _isDomestic = true;
  String _selectedRegion = 'all';
  String _selectedCategory = 'all';
  int? _selectedDifficulty;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Destination> _destinations = [];
  Set<String> _favoriteIds = {};

  // Getters
  bool get isDomestic => _isDomestic;
  String get selectedRegion => _selectedRegion;
  String get selectedCategory => _selectedCategory;
  int? get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Destination> get destinations => _destinations;
  Set<String> get favoriteIds => _favoriteIds;

  bool get isFiltering =>
      _searchQuery.isNotEmpty ||
      _selectedDifficulty != null ||
      _selectedCategory != 'all' ||
      _selectedRegion != 'all';

  /// Danh sách vùng miền Việt Nam
  static const List<RegionItem> domesticRegions = [
    RegionItem(id: 'all', label: 'Tất cả miền'),
    RegionItem(id: 'vn_north', label: 'Miền Bắc'),
    RegionItem(id: 'vn_central', label: 'Miền Trung'),
    RegionItem(id: 'vn_highlands', label: 'Tây Nguyên'),
    RegionItem(id: 'vn_south', label: 'Miền Nam'),
    RegionItem(id: 'vn_mekong', label: 'Tây Nam Bộ'),
  ];

  /// Danh sách châu lục Quốc tế
  static const List<RegionItem> internationalRegions = [
    RegionItem(id: 'all', label: 'Tất cả châu lục'),
    RegionItem(id: 'intl_asia', label: 'Châu Á'),
    RegionItem(id: 'intl_europe', label: 'Châu Âu'),
    RegionItem(id: 'intl_north_america', label: 'Bắc Mỹ'),
    RegionItem(id: 'intl_south_america', label: 'Nam Mỹ'),
    RegionItem(id: 'intl_oceania', label: 'Châu Đại Dương'),
    RegionItem(id: 'intl_africa', label: 'Châu Phi'),
  ];

  List<RegionItem> get currentRegions =>
      _isDomestic ? domesticRegions : internationalRegions;

  /// Khởi tạo và nạp dữ liệu ban đầu
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadFavorites();
    await fetchDestinations();
  }

  Future<void> _loadFavorites() async {
    final favs = await StorageService.getFavorites();
    _favoriteIds = favs.toSet();
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    StorageService.toggleFavorite(id);
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Chuyển đổi giữa Trong Nước và Quốc Tế
  void switchArea(bool isDomesticArea) {
    if (_isDomestic == isDomesticArea) return;
    _isDomestic = isDomesticArea;
    _selectedRegion = 'all'; // Đặt lại bộ lọc vùng khi đổi khu vực
    fetchDestinations();
  }

  void selectRegion(String regionId) {
    if (_selectedRegion == regionId) return;
    _selectedRegion = regionId;
    fetchDestinations();
  }

  void selectCategory(String categoryId) {
    if (_selectedCategory == categoryId) return;
    _selectedCategory = categoryId;
    fetchDestinations();
  }

  void selectDifficulty(int? level) {
    if (_selectedDifficulty == level) return;
    _selectedDifficulty = level;
    fetchDestinations();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchDestinations();
  }

  void resetFilters() {
    _selectedRegion = 'all';
    _selectedCategory = 'all';
    _selectedDifficulty = null;
    _searchQuery = '';
    fetchDestinations();
  }

  /// Truy vấn danh sách điểm đến theo bộ lọc
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinations = await repository.searchAndFilterDestinations(
        isDomestic: _isDomestic,
        query: _searchQuery,
        regionId: _selectedRegion,
        categoryId: _selectedCategory,
        difficultyLevel: _selectedDifficulty,
        userCountryCode: userCountryCode,
      );
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách điểm đến: $e';
      _destinations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

