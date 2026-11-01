import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/skeleton_shimmer.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:mobile_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/area_hero_banner.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/category_selector.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/empty_filter_state.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/explore_tab_bar.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/featured_carousel.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/nearby_section.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/region_chip_filter.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/search_filter_bar.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/seasonal_section.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trail_compact_row.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trending_grid_section.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ExploreController _controller;

  String _currentLocationName = 'Quận 9, TP. Hồ Chí Minh • 14m';
  String _currentWeatherBrief = '31°C Nắng ráo';
  bool _isDetectingGps = false;
  LatLng _currentUserLocation = const LatLng(10.8231, 106.6297);

  final List<Map<String, dynamic>> _presetLocations = const [
    {
      'name': 'Quận 9, TP. Hồ Chí Minh • 14m',
      'weather': '31°C Nắng ráo',
      'desc': 'Vị trí hiện tại (TP. Thủ Đức, TP.HCM)',
      'isGps': true,
      'lat': 10.8231,
      'lon': 106.6297,
    },
    {
      'name': 'Tây Nguyên (Tà Năng) • 1,485m',
      'weather': '18°C Ít mây',
      'desc': 'Cao nguyên Lâm Đồng',
      'isGps': false,
      'lat': 11.6420,
      'lon': 108.4230,
    },
    {
      'name': 'Đỉnh Fansipan • 3,143m',
      'weather': '9°C Sương mù lạnh',
      'desc': 'Nóc nhà Đông Dương (Sa Pa, Lào Cai)',
      'isGps': false,
      'lat': 22.3551,
      'lon': 103.7745,
    },
    {
      'name': 'Rừng Nam Cát Tiên • 120m',
      'weather': '28°C Râm mát',
      'desc': 'Rừng nhiệt đới Đồng Nai',
      'isGps': false,
      'lat': 11.4239,
      'lon': 107.4294,
    },
  ];

  final List<CategoryItem> _categories = const [
    CategoryItem(title: 'Tất cả', icon: Icons.explore),
    CategoryItem(title: 'Trekking / Leo núi', icon: Icons.hiking),
    CategoryItem(title: 'Camping / Cắm trại', icon: Icons.holiday_village),
    CategoryItem(title: 'Hiking / Đi bộ', icon: Icons.directions_walk),
    CategoryItem(title: 'Biển đảo', icon: Icons.beach_access),
    CategoryItem(title: 'Vườn quốc gia', icon: Icons.forest),
    CategoryItem(title: 'Cung đường đèo', icon: Icons.two_wheeler),
    CategoryItem(title: 'Di sản UNESCO', icon: Icons.account_balance),
  ];

  @override
  void initState() {
    super.initState();
    final localDataSource = ExploreLocalDataSource();
    final repository = ExploreRepositoryImpl(localDataSource: localDataSource);
    _controller = ExploreController(repository: repository);
    _controller.addListener(_onControllerUpdate);
    _controller.initialize();

    _autoDetectGpsLocation();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectGpsLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        setState(() {
          _currentUserLocation = LatLng(pos.latitude, pos.longitude);
        });

        // Lấy thời tiết vi khí hậu thời gian thực từ Open-Meteo
        try {
          final forecast = await WeatherService.getForecast(pos.latitude, pos.longitude);
          if (mounted) {
            setState(() {
              _currentWeatherBrief = '${forecast.temperature.round()}°C ${forecast.weatherDescription}';
            });
          }
        } catch (_) {}

        if (pos.latitude >= 10.3 && pos.latitude <= 11.2 && pos.longitude >= 106.3 && pos.longitude <= 107.1) {
          setState(() {
            _currentLocationName = 'Quận 9, TP. Hồ Chí Minh • 14m';
          });
        } else {
          setState(() {
            _currentLocationName = '${pos.latitude.toStringAsFixed(2)}°N, ${pos.longitude.toStringAsFixed(2)}°E';
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isDetectingGps = false);
    }
  }

  void _showLocationSelectorSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.editorialSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.editorialBorder,
                    borderRadius: AppRadius.roundedPill,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vị Trí & Tọa Độ Dã Ngoại',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                  ),
                  if (_isDetectingGps)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.editorialPine),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              ..._presetLocations.map((loc) {
                final isSelected = _currentLocationName == loc['name'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BouncingButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _currentLocationName = loc['name'] as String;
                        _currentWeatherBrief = loc['weather'] as String;
                        _currentUserLocation = LatLng(loc['lat'] as double, loc['lon'] as double);
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.editorialSurfaceSubtle : AppColors.editorialSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            loc['isGps'] == true ? Icons.near_me : Icons.landscape_outlined,
                            color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc['name'] as String,
                                  style: TextStyle(
                                    color: AppColors.editorialInk,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${loc['desc']} • ${loc['weather']}',
                                  style: const TextStyle(color: AppColors.editorialMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.editorialPine, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _mapCategoryToId(String title) {
    switch (title) {
      case 'Trekking / Leo núi':
        return 'trekking';
      case 'Camping / Cắm trại':
        return 'camping';
      case 'Hiking / Đi bộ':
        return 'hiking';
      case 'Biển đảo':
        return 'beach';
      case 'Vườn quốc gia':
        return 'nature';
      case 'Cung đường đèo':
        return 'road_trip';
      case 'Di sản UNESCO':
        return 'unesco';
      default:
        return 'all';
    }
  }

  String _mapIdToCategoryTitle(String id) {
    switch (id) {
      case 'trekking':
        return 'Trekking / Leo núi';
      case 'camping':
        return 'Camping / Cắm trại';
      case 'hiking':
        return 'Hiking / Đi bộ';
      case 'beach':
        return 'Biển đảo';
      case 'nature':
        return 'Vườn quốc gia';
      case 'road_trip':
        return 'Cung đường đèo';
      case 'unesco':
        return 'Di sản UNESCO';
      default:
        return 'Tất cả';
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _controller.destinations;
    final isFiltering = _controller.isFiltering;
    final currentMonth = DateTime.now().month;

    // Phân loại danh mục chuyên đề
    final featuredSpots = destinations.where((d) => d.isFeatured).toList();
    final seasonalSpots = destinations.where((d) => d.isIdealSeason(currentMonth)).toList();
    final trendingSpots = destinations.where((d) => d.isPopular || !d.isFeatured).toList();

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top App Bar & Live Status Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Weather Live Pill Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BouncingButton(
                          onTap: _showLocationSelectorSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: AppColors.editorialBorder),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.near_me, size: 13, color: AppColors.editorialPine),
                                const SizedBox(width: 6),
                                Text(
                                  _currentLocationName,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialInk),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.editorialMuted),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurface,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(color: AppColors.editorialBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.editorialTerracotta),
                              const SizedBox(width: 5),
                              Text(
                                _currentWeatherBrief,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Editorial Headline
                    const Text(
                      'Khám Phá & Dã Ngoại',
                      style: AppTypography.editorialHero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.isDomestic
                          ? 'Dải đất gấm hoa - Di sản UNESCO, cung đèo hùng vĩ & biển đảo nguyên sơ'
                          : 'Kỳ quan thế giới - Những nóc nhà địa cầu và vườn quốc gia tráng lệ 6 châu lục',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.editorialMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Segmented Navigation Bar: TRONG NƯỚC / QUỐC TẾ
                    ExploreTabBar(
                      isDomestic: _controller.isDomestic,
                      onTabChanged: (val) => _controller.switchArea(val),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Hero Area Banner
            SliverToBoxAdapter(
              child: AreaHeroBanner(
                isDomestic: _controller.isDomestic,
                totalCount: destinations.length,
              ),
            ),

            // 4. Region Filter Chips (5 Miền VN hoặc 6 Châu Lục)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RegionChipFilter(
                  regions: _controller.currentRegions,
                  selectedRegion: _controller.selectedRegion,
                  onSelectRegion: (reg) => _controller.selectRegion(reg),
                ),
              ),
            ),

            // 5. Search & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchFilterBar(
                  controller: _searchController,
                  selectedDifficulty: _controller.selectedDifficulty,
                  onChanged: (val) => _controller.setSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                  },
                  onSelectDifficulty: (lvl) => _controller.selectDifficulty(lvl),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 6. Categories Selector (Trekking, Camping, Hiking, Beach, Nature, Road Trip, UNESCO)
            SliverToBoxAdapter(
              child: CategorySelector(
                categories: _categories,
                selectedCategory: _mapIdToCategoryTitle(_controller.selectedCategory),
                onSelectCategory: (catTitle) {
                  _controller.selectCategory(_mapCategoryToId(catTitle));
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // =================================================================
            // NỘI DUNG 1: KHI ĐANG TÌM KIẾM HOẶC LỌC NÂNG CAO
            // =================================================================
            if (isFiltering) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kết Quả Tìm Kiếm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.editorialInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${destinations.length} địa điểm phù hợp',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.editorialPine,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (_controller.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonShimmer(
                          width: double.infinity,
                          height: 90,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (destinations.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyFilterState(
                    onReset: () {
                      _searchController.clear();
                      _controller.resetFilters();
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dest = destinations[index];
                        final isFav = _controller.isFavorite(dest.id);
                        return TrailCompactRow(
                          destination: dest,
                          isFavorite: isFav,
                          onToggleFavorite: () => _controller.toggleFavorite(dest.id),
                        );
                      },
                      childCount: destinations.length,
                    ),
                  ),
                ),
            ] else ...[
              // =================================================================
              // NỘI DUNG 2: KHÁM PHÁ THEO CÁC CHUYÊN ĐỀ PHÂN TẦNG (DISCOVERY FEED)
              // =================================================================
              if (_controller.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonShimmer(
                          width: double.infinity,
                          height: 140,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      childCount: 3,
                    ),
                  ),
                )
              else ...[
                // SECTION 1: ĐIỂM ĐẾN NỔI BẬT (FEATURED CAROUSEL)
                if (featuredSpots.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FeaturedCarousel(
                      destinations: featuredSpots,
                      favoriteIds: _controller.favoriteIds,
                      onToggleFavorite: (id) => _controller.toggleFavorite(id),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // SECTION 2: GỢI Ý THEO MÙA & THỜI TIẾT
                if (seasonalSpots.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SeasonalSection(
                      destinations: seasonalSpots,
                      currentMonth: currentMonth,
                      favoriteIds: _controller.favoriteIds,
                      onToggleFavorite: (id) => _controller.toggleFavorite(id),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // SECTION 3: ĐỊA ĐIỂM GẦN BẠN NHẤT
                if (destinations.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: NearbySection(
                      destinations: destinations,
                      userLocation: _currentUserLocation,
                      favoriteIds: _controller.favoriteIds,
                      onToggleFavorite: (id) => _controller.toggleFavorite(id),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // SECTION 4: ĐỊA ĐIỂM ĐƯỢC KHÁM PHÁ NHIỀU NHẤT
                if (trendingSpots.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: TrendingGridSection(
                      destinations: trendingSpots,
                      favoriteIds: _controller.favoriteIds,
                      onToggleFavorite: (id) => _controller.toggleFavorite(id),
                    ),
                  ),
                ],
              ],
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }
}
