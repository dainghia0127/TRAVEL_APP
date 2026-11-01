import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/core/widgets/skeleton_shimmer.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/controllers/explore_controller.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/bento_destination_grid.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/category_selector.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trail_compact_row.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/search_filter_bar.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/empty_filter_state.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/explore_tab_bar.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/region_chip_filter.dart';

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

  final List<Map<String, String>> _presetLocations = const [
    {
      'name': 'Quận 9, TP. Hồ Chí Minh • 14m',
      'weather': '31°C Nắng ráo',
      'desc': 'Vị trí hiện tại (TP. Thủ Đức, TP.HCM)',
      'isGps': 'true',
    },
    {
      'name': 'Tây Nguyên (Tà Năng) • 1,485m',
      'weather': '18°C Ít mây',
      'desc': 'Cao nguyên Lâm Đồng',
      'isGps': 'false',
    },
    {
      'name': 'Đỉnh Fansipan • 3,143m',
      'weather': '9°C Sương mù lạnh',
      'desc': 'Nóc nhà Đông Dương (Sa Pa, Lào Cai)',
      'isGps': 'false',
    },
    {
      'name': 'Rừng Nam Cát Tiên • 120m',
      'weather': '28°C Râm mát',
      'desc': 'Rừng nhiệt đới Đồng Nai',
      'isGps': 'false',
    },
  ];

  final List<CategoryItem> _categories = const [
    CategoryItem(title: 'Tất cả', icon: Icons.explore),
    CategoryItem(title: 'Trekking / Leo núi', icon: Icons.hiking),
    CategoryItem(title: 'Camping / Cắm trại', icon: Icons.holiday_village),
    CategoryItem(title: 'Suối / Thác nước', icon: Icons.water),
    CategoryItem(title: 'Cung đường đèo', icon: Icons.two_wheeler),
    CategoryItem(title: 'Vườn quốc gia', icon: Icons.forest),
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
                        _currentLocationName = loc['name']!;
                        _currentWeatherBrief = loc['weather']!;
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
                            loc['isGps'] == 'true' ? Icons.near_me : Icons.landscape_outlined,
                            color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc['name']!,
                                  style: TextStyle(
                                    color: AppColors.editorialInk,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${loc['desc']!} • ${loc['weather']!}',
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
      case 'Suối / Thác nước':
        return 'waterfalls';
      case 'Cung đường đèo':
        return 'passes';
      case 'Vườn quốc gia':
        return 'national_parks';
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
      case 'waterfalls':
        return 'Suối / Thác nước';
      case 'passes':
        return 'Cung đường đèo';
      case 'national_parks':
        return 'Vườn quốc gia';
      default:
        return 'Tất cả';
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _controller.destinations;
    final isFiltering = _controller.isFiltering;
    final heroDest = destinations.isNotEmpty ? destinations[0] : null;

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top App Bar & Editorial Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
                    const SizedBox(height: 16),

                    // Editorial Headline
                    const Text(
                      'Khám Phá & Dã Ngoại',
                      style: AppTypography.editorialHero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.isDomestic
                          ? 'Những cung đường trekking hùng vĩ và bãi cắm trại hoang sơ nhất Việt Nam'
                          : 'Các cung đường dã ngoại và vườn quốc gia tráng lệ khắp 6 châu lục',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.editorialMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Segmented Navigation Bar: TRONG NƯỚC / QUỐC TẾ
                    ExploreTabBar(
                      isDomestic: _controller.isDomestic,
                      onTabChanged: (val) => _controller.switchArea(val),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Region Filter Chips (5 Miền VN hoặc 6 Châu Lục)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: RegionChipFilter(
                  regions: _controller.currentRegions,
                  selectedRegion: _controller.selectedRegion,
                  onSelectRegion: (reg) => _controller.selectRegion(reg),
                ),
              ),
            ),

            // 4. Hero Card (Shown when not actively filtering)
            if (!isFiltering && heroDest != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildHeroCard(heroDest),
                ),
              ),

            // 5. Search & Filter Interface
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

            // 6. Categories Selector
            SliverToBoxAdapter(
              child: CategorySelector(
                categories: _categories,
                selectedCategory: _mapIdToCategoryTitle(_controller.selectedCategory),
                onSelectCategory: (catTitle) {
                  _controller.selectCategory(_mapCategoryToId(catTitle));
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 7. Bento Grid Spotlight (When in Discovery mode)
            if (!isFiltering && destinations.length >= 3) ...[
              SliverToBoxAdapter(
                child: BentoDestinationGrid(
                  destinations: destinations,
                  favoriteIds: _controller.favoriteIds,
                  onToggleFavorite: (id) => _controller.toggleFavorite(id),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // 8. Section Header for destination list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isFiltering ? 'Kết Quả Tìm Kiếm' : 'Gợi Ý Khám Phá',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.editorialInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${destinations.length} điểm đến',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.editorialMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 9. Loading State / Empty State / Destination List
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

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Destination dest) {
    final isFav = _controller.isFavorite(dest.id);
    final img = OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name);

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 360),
      openBuilder: (context, action) => DestinationDetailScreen(
        destination: dest,
        isFavorite: isFav,
        onToggleFavorite: () => _controller.toggleFavorite(dest.id),
      ),
      closedBuilder: (context, action) => Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EditorialImage(
              image: img,
              borderRadius: BorderRadius.circular(20),
              showAttribution: true,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x20000000),
                    Colors.transparent,
                    Color(0x90000000),
                    Color(0xEA000000),
                  ],
                  stops: [0.0, 0.3, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 12),
                    SizedBox(width: 5),
                    Text(
                      'ĐIỂM ĐẾN NỔI BẬT',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dest.editorialSummary,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${dest.distanceDisplay} • ${dest.elevationDisplay}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Text('Chi tiết', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
