import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/skeleton_shimmer.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/weather_safety/presentation/screens/weather_climate_screen.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
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
import 'package:mobile_flutter/features/explore/presentation/widgets/social_trending_section.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trail_compact_row.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trending_grid_section.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
    CategoryItem(title: 'Hot Trend TikTok', icon: Icons.local_fire_department_rounded),
    CategoryItem(title: 'Trekking / Leo núi', icon: Icons.hiking),
    CategoryItem(title: 'Camping / Cắm trại', icon: Icons.holiday_village),
    CategoryItem(title: 'Hiking / Đi bộ', icon: Icons.directions_walk),
    CategoryItem(title: 'Biển đảo', icon: Icons.beach_access),
    CategoryItem(title: 'Vườn quốc gia', icon: Icons.forest),
    CategoryItem(title: 'Cung đường đèo', icon: Icons.two_wheeler),
    CategoryItem(title: 'Di sản UNESCO', icon: Icons.account_balance),
  ];

  /// Làm mới lại dữ liệu từ nguồn thực tế và cập nhật lại cự ly
  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await _controller.refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
          backgroundColor: const Color(0xFF141916),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF2E4537), width: 1.5),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.summitGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã làm mới dữ liệu thực tế (${_controller.destinations.length} địa điểm)',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          420.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<String> _resolveGpsLocationName(double lat, double lon) async {
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=vi');
      final res = await http.get(uri, headers: {'User-Agent': 'TravelApp/1.0'}).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final district = address['quarter'] ?? address['suburb'] ?? address['district'] ?? address['city_district'] ?? address['town'];
        final city = address['city'] ?? address['state'] ?? address['county'];
        if (district != null && city != null) {
          return '$district, $city';
        } else if (city != null) {
          return '$city';
        }
      }
    } catch (_) {}

    // Fallback thông minh theo vùng địa lý nếu không có mạng
    if (lat >= 10.5 && lat <= 11.1 && lon >= 106.4 && lon <= 107.0) {
      return 'TP. Hồ Chí Minh';
    } else if (lat >= 20.8 && lat <= 21.3 && lon >= 105.6 && lon <= 106.1) {
      return 'Thủ đô Hà Nội';
    } else if (lat >= 15.9 && lat <= 16.2 && lon >= 108.0 && lon <= 108.4) {
      return 'TP. Đà Nẵng';
    } else if (lat >= 11.8 && lat <= 12.1 && lon >= 108.3 && lon <= 108.6) {
      return 'TP. Đà Lạt, Lâm Đồng';
    }
    return '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E';
  }

  Future<void> _autoDetectGpsLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        setState(() {
          _currentUserLocation = LatLng(pos.latitude, pos.longitude);
        });

        // 1. Lấy tên địa danh thực tế từ GPS
        final locName = await _resolveGpsLocationName(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _currentLocationName = locName;
          });
        }

        // 2. Lấy thời tiết và khí hậu thời gian thực từ Open-Meteo
        try {
          final forecast = await WeatherService.getForecast(pos.latitude, pos.longitude);
          if (mounted) {
            setState(() {
              _currentWeatherBrief = '${forecast.temperature.round()}°C ${forecast.weatherDescription}';
            });
          }
        } catch (_) {}
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
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final lat = loc['lat'] as double;
                      final lon = loc['lon'] as double;
                      Navigator.pop(context);
                      setState(() {
                        _currentLocationName = loc['name'] as String;
                        _currentUserLocation = LatLng(lat, lon);
                        _currentWeatherBrief = 'Đang tải thời tiết...';
                      });
                      _handleRefresh();
                      try {
                        final fc = await WeatherService.getForecast(lat, lon);
                        if (mounted) {
                          setState(() {
                            _currentWeatherBrief = '${fc.temperature.round()}°C ${fc.weatherDescription}';
                          });
                        }
                      } catch (_) {}
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
      case 'Hot Trend TikTok':
        return 'social_trend';
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
      case 'social_trend':
        return 'Hot Trend TikTok';
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

    // Sử dụng danh sách đã được pre-computed trong controller (O(1) access, tối ưu 60/120fps)
    final featuredSpots = _controller.featuredSpots;
    final seasonalSpots = _controller.seasonalSpots;
    final trendingSpots = _controller.trendingSpots;

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.editorialPine,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
            // 1. Top App Bar & Live Status Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Weather Live Pill Header (Bảo vệ tràn màn hình trên mọi iPhone)
                    Row(
                      children: [
                        // Cụm Vị trí bên trái: Tự động co giãn linh hoạt, không bao giờ đẩy văng nút
                        Expanded(
                          child: BouncingButton(
                            onTap: _showLocationSelectorSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  Expanded(
                                    child: Text(
                                      _currentLocationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.editorialInk,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.editorialMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Cụm Thời tiết & Nút Làm Mới bên phải: Luôn cố định, hiển thị trọn vẹn 100%
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingButton(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WeatherClimateScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialSurface,
                                  borderRadius: AppRadius.roundedPill,
                                  border: Border.all(color: AppColors.editorialBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.editorialTerracotta),
                                    const SizedBox(width: 4),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 100),
                                      child: Text(
                                        _currentWeatherBrief,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.editorialInk,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.editorialMuted),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            BouncingButton(
                              onTap: _handleRefresh,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.editorialBorder),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x06000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: _controller.isLoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.editorialPine),
                                      )
                                    : const Icon(Icons.refresh_rounded, size: 16, color: AppColors.editorialPine),
                              ),
                            ),
                          ],
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
                  onChanged: (val) {
                    _controller.setSearchQuery(val);
                    if (val.trim().isNotEmpty) _scrollToResults();
                  },
                  onClear: () {
                    _searchController.clear();
                    _controller.setSearchQuery('');
                  },
                  onSelectDifficulty: (lvl) {
                    _controller.selectDifficulty(lvl);
                    if (lvl != null) _scrollToResults();
                  },
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
                  if (catTitle != 'Tất cả') _scrollToResults();
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

                // SECTION HOT TREND TIKTOK & FACEBOOK (Nổi bật tại địa phương hoặc toàn quốc)
                () {
                  final cityTrends = _controller.isDomestic
                      ? _controller.getHotTrendsByProvince(_currentLocationName)
                      : <Destination>[];
                  final displayTrends = cityTrends.isNotEmpty
                      ? cityTrends
                      : (_controller.isDomestic ? _controller.socialTrendingSpots : <Destination>[]);

                  if (displayTrends.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SocialTrendingSection(
                          destinations: displayTrends,
                          locationName: _currentLocationName,
                          userLocation: _currentUserLocation,
                          favoriteIds: _controller.favoriteIds,
                          onToggleFavorite: (id) => _controller.toggleFavorite(id),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }(),

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
                      onScrollToTop: () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    ),
  );
  }
}
