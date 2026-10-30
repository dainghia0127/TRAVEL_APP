import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  Set<String> _favoriteSpots = {};

  final List<Map<String, String>> _categories = const [
    {'title': 'Tất cả', 'icon': '🌲'},
    {'title': 'Trekking / Leo núi', 'icon': '🥾'},
    {'title': 'Camping / Cắm trại', 'icon': '⛺'},
    {'title': 'Suối / Thác nước', 'icon': '🌊'},
    {'title': 'Cung đường đèo', 'icon': '🏍️'},
    {'title': 'Bãi biển hoang sơ', 'icon': '🏖️'},
  ];

  final List<Map<String, dynamic>> _spots = [
    {
      'id': 'spot_1',
      'title': 'Cung Tà Năng - Phan Dũng',
      'category': 'Trekking / Leo núi',
      'difficulty': 'Khó (55km)',
      'difficultyLevel': 3, // 1: Dễ, 2: Vừa, 3: Khó
      'elevation': '1,100 m',
      'distance': '55 km',
      'water': 'Suối cạn theo mùa',
      'signal': 'Mất sóng 70%',
      'location': 'Lâm Đồng - Bình Thuận',
      'rating': '4.9',
      'reviews': '284',
      'accentColor': const Color(0xFF10B981),
      'description': 'Cung trekking đẹp nhất miền Nam qua sống lưng khủng long, đồi cỏ bạt ngàn và rừng khộp hoang dã.',
      'highlights': ['Đồi cỏ mênh mông', 'Ngắm bình minh sống lưng', 'Off-grid 100%'],
    },
    {
      'id': 'spot_2',
      'title': 'Hồ Tuyền Lâm & Rừng Thông Cổ',
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
      'accentColor': const Color(0xFF06B6D4),
      'description': 'Bãi cắm trại ven hồ yên bình, sương mây lãng đãng quanh rừng thông, cực kỳ thích hợp chèo SUP dã ngoại.',
      'highlights': ['Chèo SUP mặt hồ', 'Nước ngọt dồi dào', 'Phù hợp người mới'],
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
      'accentColor': const Color(0xFF3B82F6),
      'description': 'Dải lụa bạc hùng vĩ ẩn sâu giữa rừng nguyên sinh Tây Nguyên, tiếng nước ầm vang cả một góc thung lũng.',
      'highlights': ['Thác nước tráng lệ', 'Tổ chim én tự nhiên', 'Rừng nguyên sinh'],
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
      'accentColor': const Color(0xFF8B5CF6),
      'description': 'Nóc nhà tỉnh Lâm Đồng với thảm rừng rêu ma mị, cây thông 2 lá dẹt ngàn năm tuổi và không khí lạnh 10°C.',
      'highlights': ['Rừng rêu ma thuật', 'Nóc nhà Lâm Đồng', 'Hệ sinh vật đa dạng'],
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
      'accentColor': const Color(0xFFF59E0B),
      'description': 'Một trong tứ đại đỉnh đèo hiểm trở và ngoạn mục nhất Tây Bắc, nơi săn mây bồng bềnh và hoàng hôn tráng lệ.',
      'highlights': ['Săn biển mây cuồn cuộn', 'Cung đường uốn lượn', 'Hoàng hôn rực rỡ'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
          spot['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spot['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar & Hero Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Weather Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, size: 14, color: AppTheme.emerald),
                              SizedBox(width: 4),
                              Text(
                                'Tây Nguyên • 1,485m',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wb_sunny_outlined, size: 14, color: AppTheme.tacticalOrange),
                              SizedBox(width: 4),
                              Text(
                                '18°C Ít mây',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Main App Heading
                    const Text(
                      'Khám Phá Địa Điểm Dã Ngoại',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cung đường hoang dã & cẩm nang sinh tồn ngoại tuyến',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSub),
                    ),
                    const SizedBox(height: 16),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBase,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tìm núi, thác, bãi cắm trại, đèo...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.emerald, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : const Icon(Icons.tune, color: AppTheme.textMuted, size: 18),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories Selector
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat['title'] == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat['title']!),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.emerald : AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.emerald : AppTheme.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat['title']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.black : AppTheme.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Outdoor Spot Cards List
            _filteredSpots.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Không tìm thấy địa điểm phù hợp',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final spot = _filteredSpots[index];
                          return _buildSpotCard(spot);
                        },
                        childCount: _filteredSpots.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotCard(Map<String, dynamic> spot) {
    final isFav = _favoriteSpots.contains(spot['id']);
    final Color accent = spot['accentColor'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBase,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSpotDetails(spot),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Header with Visual Pattern
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.7), AppTheme.surfaceBase],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            spot['category'] as String,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        // Favorite Heart
                        InkWell(
                          onTap: () => _toggleFavorite(spot['id'] as String),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? AppTheme.emergencyRed : Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Rating & Difficulty Pills
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: AppTheme.tacticalOrange),
                              const SizedBox(width: 3),
                              Text(
                                '${spot['rating']} (${spot['reviews']})',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(spot['difficultyLevel'] as int).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _getDifficultyColor(spot['difficultyLevel'] as int).withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            spot['difficulty'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getDifficultyColor(spot['difficultyLevel'] as int),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          spot['location'] as String,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSub),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      spot['description'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSub),
                    ),
                    const SizedBox(height: 14),

                    // 4 Outdoor Badges in Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge(Icons.straighten, spot['distance'] as String, 'Cự ly'),
                          _buildStatDivider(),
                          _buildStatBadge(Icons.terrain, spot['elevation'] as String, 'Cao độ'),
                          _buildStatDivider(),
                          _buildStatBadge(Icons.water_drop, spot['water'] as String, 'Nước ngọt'),
                          _buildStatDivider(),
                          _buildStatBadge(Icons.signal_cellular_alt, spot['signal'] as String, 'Sóng 4G'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    if (level == 1) return AppTheme.emerald;
    if (level == 2) return AppTheme.tacticalOrange;
    return AppTheme.emergencyRed;
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.emerald),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMain),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: Colors.white12);
  }

  void _showSpotDetails(Map<String, dynamic> spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final highlights = spot['highlights'] as List<String>;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                spot['title'] as String,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textMain),
              ),
              const SizedBox(height: 4),
              Text(spot['location'] as String, style: const TextStyle(color: AppTheme.emerald, fontSize: 13)),
              const Divider(height: 24, color: AppTheme.borderLight),
              Text(
                spot['description'] as String,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textSub),
              ),
              const SizedBox(height: 16),
              const Text('Điểm nổi bật của cung đường:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMain)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: highlights.map((h) => Chip(
                  backgroundColor: AppTheme.surfaceHigh,
                  label: Text(h, style: const TextStyle(fontSize: 11, color: AppTheme.textMain)),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Bắt đầu dẫn đường ngoại tuyến', style: TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
