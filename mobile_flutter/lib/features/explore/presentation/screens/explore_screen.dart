import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/bento_destination_grid.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/category_selector.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trail_compact_row.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/search_filter_bar.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/empty_filter_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  int? _selectedDifficulty;
  Set<String> _favoriteSpots = {};

  String _currentLocationName = 'Quận 9, TP. Hồ Chí Minh • 14m';
  String _currentWeatherBrief = '31°C Nắng ráo';
  bool _isDetectingGps = false;

  final List<Map<String, String>> _presetLocations = const [
    {
      'name': 'Quận 9, TP. Hồ Chí Minh • 14m',
      'weather': '31°C Nắng ráo',
      'desc': 'Vị trí hiện tại của bạn (TP. Thủ Đức, TP.HCM)',
      'isGps': 'true',
    },
    {
      'name': 'Tây Nguyên (Tà Năng) • 1,485m',
      'weather': '18°C Ít mây',
      'desc': 'Khu vực dã ngoại cao nguyên Lâm Đồng',
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
      'desc': 'Rừng mưa nhiệt đới Đồng Nai',
      'isGps': 'false',
    },
  ];

  final List<CategoryItem> _categories = const [
    CategoryItem(title: 'Tất cả', icon: Icons.explore),
    CategoryItem(title: 'Trekking / Leo núi', icon: Icons.hiking),
    CategoryItem(title: 'Camping / Cắm trại', icon: Icons.holiday_village),
    CategoryItem(title: 'Suối / Thác nước', icon: Icons.water),
    CategoryItem(title: 'Cung đường đèo', icon: Icons.two_wheeler),
    CategoryItem(title: 'Bãi biển hoang sơ', icon: Icons.beach_access),
  ];

  final List<Map<String, dynamic>> _spots = [
    {
      'id': 'spot_1',
      'title': 'Cung Tà Năng - Phan Dũng',
      'category': 'Trekking / Leo núi',
      'difficulty': 'Khó (55km)',
      'difficultyLevel': 3,
      'elevation': '1,100 m',
      'distance': '55 km',
      'water': 'Suối cạn theo mùa',
      'signal': 'Mất sóng 70%',
      'location': 'Lâm Đồng - Bình Thuận',
      'rating': '4.9',
      'reviews': '284',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=900&q=80',
      'outdoorImage': const OutdoorImage(
        url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=900&q=80',
        localAsset: 'assets/images/hero_ta_nang.jpg',
        photographer: 'Bailey Zindel',
        caption: 'Đỉnh Tà Năng - Phan Dũng',
      ),
      'description': 'Cung trekking đẹp nhất miền Nam qua sống lưng khủng long, đồi cỏ bạt ngàn và rừng khộp hoang dã.',
      'highlights': ['Đồi cỏ mênh mông', 'Ngắm bình minh sống lưng', 'Off-grid 100%'],
      'isFeatured': true,
    },
    {
      'id': 'spot_2',
      'title': 'Hồ Tuyền Lâm & Rừng Thông',
      'category': 'Camping / Cắm trại',
      'difficulty': 'Dễ',
      'difficultyLevel': 1,
      'elevation': '1,500 m',
      'distance': '12 km',
      'water': 'Có nguồn nước sạch',
      'signal': '4G ổn định',
      'location': 'Đà Lạt, Lâm Đồng',
      'rating': '4.8',
      'reviews': '512',
      'imageUrl': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=80',
      'outdoorImage': const OutdoorImage(
        url: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=80',
        localAsset: 'assets/images/lake_tuyen_lam.jpg',
        photographer: 'Kalina Sak',
        caption: 'Hồ Tuyền Lâm & Rừng Thông',
      ),
      'description': 'Bãi cắm trại ven hồ yên bình, sương mây lãng đãng quanh rừng thông, cực kỳ thích hợp chèo SUP dã ngoại.',
      'highlights': ['Chèo SUP mặt hồ', 'Nước ngọt dồi dào', 'Phù hợp người mới'],
      'isFeatured': true,
    },
    {
      'id': 'spot_3',
      'title': 'Đại Thác K50 (Hang Én)',
      'category': 'Suối / Thác nước',
      'difficulty': 'Khó (Vượt rừng)',
      'difficultyLevel': 3,
      'elevation': '820 m',
      'distance': '24 km',
      'water': 'Nước suối dồi dào',
      'signal': 'Không có sóng (0%)',
      'location': 'Khu BTTN Kon Chư Răng, Gia Lai',
      'rating': '5.0',
      'reviews': '142',
      'imageUrl': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=900&q=80',
      'outdoorImage': const OutdoorImage(
        url: 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=900&q=80',
        localAsset: 'assets/images/fall_k50.jpg',
        photographer: 'Adam K.',
        caption: 'Thác K50 - Hang Én',
      ),
      'description': 'Dải lụa bạc hùng vĩ ẩn sâu giữa rừng nguyên sinh Tây Nguyên, tiếng nước ầm vang cả một góc thung lũng.',
      'highlights': ['Thác nước tráng lệ', 'Tổ chim én tự nhiên', 'Rừng nguyên sinh'],
      'isFeatured': true,
    },
    {
      'id': 'spot_4',
      'title': 'Đỉnh Bidoup Núi Bà',
      'category': 'Trekking / Leo núi',
      'difficulty': 'Thách thức (2,287m)',
      'difficultyLevel': 3,
      'elevation': '2,287 m',
      'distance': '28 km',
      'water': 'Có trạm kiểm lâm',
      'signal': 'Sóng chập chờn',
      'location': 'Vườn Quốc Gia Bidoup Núi Bà',
      'rating': '4.9',
      'reviews': '189',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&q=80',
      'outdoorImage': const OutdoorImage(
        url: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&q=80',
        localAsset: 'assets/images/mang_den.jpg',
        photographer: 'Nguyên Vũ',
        caption: 'Rừng Rêu Bidoup Núi Bà',
      ),
      'description': 'Nóc nhà tỉnh Lâm Đồng với thảm rừng rêu ma mị, cây thông 2 lá dẹt ngàn năm tuổi và không khí lạnh 10°C.',
      'highlights': ['Rừng rêu ma thuật', 'Nóc nhà Lâm Đồng', 'Hệ sinh vật đa dạng'],
      'isFeatured': false,
    },
    {
      'id': 'spot_5',
      'title': 'Cung Đèo Ô Quy Hồ — Cổng Trời',
      'category': 'Cung đường đèo',
      'difficulty': 'Trung bình (Đèo dốc)',
      'difficultyLevel': 2,
      'elevation': '2,003 m',
      'distance': '50 km',
      'water': 'Có điểm dừng chân',
      'signal': '4G tốt',
      'location': 'Lào Cai - Lai Châu',
      'rating': '4.9',
      'reviews': '680',
      'imageUrl': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=900&q=80',
      'outdoorImage': const OutdoorImage(
        url: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=900&q=80',
        localAsset: 'assets/images/pass_o_quy_ho.jpg',
        photographer: 'Lê Hoàng',
        caption: 'Đèo Ô Quy Hồ',
      ),
      'description': 'Một trong tứ đại đỉnh đèo hiểm trở và ngoạn mục nhất Tây Bắc, nơi săn mây bồng bềnh và hoàng hôn tráng lệ.',
      'highlights': ['Săn biển mây cuồn cuộn', 'Cung đường uốn lượn', 'Hoàng hôn rực rỡ'],
      'isFeatured': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _autoDetectGpsLocation();
  }

  Future<void> _autoDetectGpsLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        if (pos.latitude >= 10.3 && pos.latitude <= 11.2 && pos.longitude >= 106.3 && pos.longitude <= 107.1) {
          setState(() {
            _currentLocationName = 'Quận 9, TP. Hồ Chí Minh • 14m';
            _currentWeatherBrief = '31°C Nắng ráo';
          });
        } else {
          setState(() {
            _currentLocationName = '${pos.latitude.toStringAsFixed(2)}°N, ${pos.longitude.toStringAsFixed(2)}°E';
          });
        }
      }
    } catch (_) {
      // Default stays: Quận 9, TP. Hồ Chí Minh
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
                    'Vị Trí & Điểm Dã Ngoại',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favs = await StorageService.getFavorites();
    if (mounted) {
      setState(() => _favoriteSpots = favs.toSet());
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteSpots.contains(id)) {
        _favoriteSpots.remove(id);
      } else {
        _favoriteSpots.add(id);
      }
    });
    StorageService.toggleFavorite(id);
  }

  List<Map<String, dynamic>> get _filteredSpots {
    return _spots.where((spot) {
      final matchesCategory = _selectedCategory == 'Tất cả' || spot['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (spot['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (spot['location'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (spot['description'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDifficulty = _selectedDifficulty == null || spot['difficultyLevel'] == _selectedDifficulty;

      return matchesCategory && matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSpots;
    final isFiltering = _searchQuery.isNotEmpty || _selectedDifficulty != null || _selectedCategory != 'Tất cả';
    final heroSpot = _spots[0];

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar & Editorial Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Weather Pill Header
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
                    const SizedBox(height: 18),

                    // Editorial Headline
                    const Text(
                      'Khám Phá & Dã Ngoại',
                      style: AppTypography.editorialHero,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Những cung đường trekking hùng vĩ và bãi cắm trại hoang sơ nhất Việt Nam',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.editorialMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Destination-Led Inspirational Hero (Shown when not actively searching)
            if (!isFiltering)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: _buildHeroInspirationalCard(heroSpot),
                ),
              ),

            // Search & Filter Interface
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchFilterBar(
                  controller: _searchController,
                  selectedDifficulty: _selectedDifficulty,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onClear: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                  onSelectDifficulty: (lvl) => setState(() => _selectedDifficulty = lvl),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Horizontal Categories Selector
            SliverToBoxAdapter(
              child: CategorySelector(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 1. Bento Grid Spotlight (When in Discovery mode)
            if (!isFiltering) ...[
              SliverToBoxAdapter(
                child: BentoDestinationGrid(
                  spots: _spots,
                  favoriteSpots: _favoriteSpots,
                  onToggleFavorite: _toggleFavorite,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // Section 2: Header for curated lists
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isFiltering ? 'Kết Quả Tìm Kiếm' : 'Gợi Ý Cho Bạn',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.editorialInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${filtered.length} cung đường',
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

            // Empty State
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: EmptyFilterState(
                  onReset: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedDifficulty = null;
                      _selectedCategory = 'Tất cả';
                    });
                  },
                ),
              )
            else
              // Compact Editorial Rows
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final spot = filtered[index];
                      final isFav = _favoriteSpots.contains(spot['id']);
                      return TrailCompactRow(
                        spot: spot,
                        isFavorite: isFav,
                        onToggleFavorite: () => _toggleFavorite(spot['id'] as String),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroInspirationalCard(Map<String, dynamic> spot) {
    final isFav = _favoriteSpots.contains(spot['id']);
    final OutdoorImage img = spot['outdoorImage'] as OutdoorImage;

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 360),
      openBuilder: (context, action) => DestinationDetailScreen(
        spot: spot,
        isFavorite: isFav,
        onToggleFavorite: () => _toggleFavorite(spot['id'] as String),
      ),
      closedBuilder: (context, action) => Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full photograph with local bundled fallback & caching
            EditorialImage(
              image: img,
              borderRadius: BorderRadius.circular(20),
              showAttribution: true,
            ),

            // Gradient scrim for editorial readability
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

            // Top Badge
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
                      'ĐIỂM ĐẾN NỔI BẬT THÁNG NÀY',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Content
            Positioned(
              bottom: 18,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spot['description'] as String,
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
                          '${spot['distance']} • ${spot['elevation']}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Text(
                            'Chi tiết',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
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
