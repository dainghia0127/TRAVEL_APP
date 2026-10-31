import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/bento_destination_grid.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/category_selector.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/trail_compact_row.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/destination_card.dart';
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
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&q=80',
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
      'imageUrl': 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=800&q=80',
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
      'imageUrl': 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&q=80',
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
      'imageUrl': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
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
      'imageUrl': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80',
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
      // Default to Quận 9, TP. Hồ Chí Minh
    } finally {
      if (mounted) setState(() => _isDetectingGps = false);
    }
  }

  void _showLocationSelectorSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: AppRadius.roundedPill),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('VỊ TRÍ & ĐỊA ĐIỂM DÃ NGOẠI', style: AppTypography.captionBadge.copyWith(color: AppColors.emerald)),
                  if (_isDetectingGps)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
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
                        color: isSelected ? AppColors.surfaceHigh : AppColors.surfaceBase,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(
                          color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            loc['isGps'] == 'true' ? Icons.my_location : Icons.landscape_outlined,
                            color: isSelected ? AppColors.emerald : AppColors.textSecondary,
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
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${loc['desc']!} • ${loc['weather']!}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.emerald, size: 20),
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
    StorageService.saveFavorites(_favoriteSpots.toList());
  }

  List<Map<String, dynamic>> get _filteredSpots {
    return _spots.where((spot) {
      final matchCat = _selectedCategory == 'Tất cả' || spot['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          (spot['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (spot['location'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchDiff = _selectedDifficulty == null || spot['difficultyLevel'] == _selectedDifficulty;
      return matchCat && matchSearch && matchDiff;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'Tất cả';
      _selectedDifficulty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSpots;
    final isFiltering = _searchQuery.isNotEmpty || _selectedCategory != 'Tất cả' || _selectedDifficulty != null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar & Weather Scrim
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space12,
                  AppSpacing.space16,
                  AppSpacing.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ambient Location & Weather (Interactive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BouncingButton(
                          onTap: _showLocationSelectorSheet,
                          child: TacticalPill(
                            icon: Icons.my_location,
                            text: _currentLocationName,
                            color: AppColors.emerald,
                            backgroundColor: AppColors.surfaceHigh,
                          ),
                        ),
                        TacticalPill(
                          icon: Icons.wb_sunny_outlined,
                          text: _currentWeatherBrief,
                          color: AppColors.tacticalOrange,
                          backgroundColor: AppColors.surfaceHigh,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space16),

                    // Editorial Headline
                    Text(
                      'Khám Phá Cung Đường',
                      style: AppTypography.displayHero,
                    ).animate().fadeIn(duration: 260.ms).slideX(begin: -0.05, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Bản đồ địa hình & cẩm nang sinh tồn ngoại tuyến 100%',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.space16),

                    // Search & Filter Interface
                    SearchFilterBar(
                      controller: _searchController,
                      selectedDifficulty: _selectedDifficulty,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                      onSelectDifficulty: (lvl) => setState(() => _selectedDifficulty = lvl),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories Selector
            SliverToBoxAdapter(
              child: CategorySelector(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space20)),

            // 1. Bento Grid Spotlight (Only show when not actively searching to avoid clutter)
            if (!isFiltering) ...[
              SliverToBoxAdapter(
                child: BentoDestinationGrid(
                  spots: _spots,
                  favoriteSpots: _favoriteSpots,
                  onToggleFavorite: _toggleFavorite,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space24)),
            ],

            // Section 2: Diverse Trail Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFiltering ? 'Kết Quả Bộ Lọc' : 'Tất Cả Cung Đường (Danh Mục)',
                      style: AppTypography.headlineMedium.copyWith(fontSize: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        '${filtered.length} địa điểm',
                        style: AppTypography.captionBadge.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space12)),

            // Cards vs Rows based on context to BREAK CARD MONOTONY:
            // When filtering: show rich detailed destination cards
            // When general browsing: show clean compact editorial rows!
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: EmptyFilterState(onReset: _resetFilters),
              )
            else if (isFiltering)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final spot = filtered[index];
                      return DestinationCard(
                        spot: spot,
                        isFavorite: _favoriteSpots.contains(spot['id']),
                        onToggleFavorite: () => _toggleFavorite(spot['id'] as String),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final spot = filtered[index];
                      return TrailCompactRow(
                        spot: spot,
                        isFavorite: _favoriteSpots.contains(spot['id']),
                        onToggleFavorite: () => _toggleFavorite(spot['id'] as String),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            // Bottom Safe Inset Clearance
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space32)),
          ],
        ),
      ),
    );
  }
}
