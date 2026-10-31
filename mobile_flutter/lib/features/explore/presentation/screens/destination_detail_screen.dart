import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DestinationDetailScreen({
    super.key,
    required this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late bool _fav;
  int _selectedTab = 0; // 0: Tổng quan, 1: Lộ trình, 2: An toàn

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
  }

  void _handleToggleFav() {
    setState(() => _fav = !_fav);
    widget.onToggleFavorite();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final highlights = (spot['highlights'] as List<dynamic>?)?.cast<String>() ?? [];
    final imageUrl = spot['imageUrl'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: AppColors.bgDark,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: Icon(
                          _fav ? Icons.favorite : Icons.favorite_border,
                          color: _fav ? AppColors.emergencyRed : Colors.white,
                          size: 20,
                        ),
                        onPressed: _handleToggleFav,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Real Nature Photo
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      else
                        _buildPlaceholder(),

                      // Gradient Scrim
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroOverlayGradient,
                        ),
                      ),

                      // Floating Category & Rating Badge on bottom of image
                      Positioned(
                        left: AppSpacing.space16,
                        bottom: AppSpacing.space20,
                        right: AppSpacing.space16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TacticalPill(
                              text: spot['category'] as String? ?? 'Dã ngoại',
                              color: Colors.white,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: AppRadius.roundedPill,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.summitGold),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${spot['rating']} (${spot['reviews']} đánh giá)',
                                    style: AppTypography.captionBadge,
                                  ),
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

              // Title & Location Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.space16, AppSpacing.space16, AppSpacing.space16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot['title'] as String? ?? '',
                        style: AppTypography.displayHero.copyWith(fontSize: 26),
                      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 15, color: AppColors.emerald),
                          const SizedBox(width: 4),
                          Text(
                            spot['location'] as String? ?? '',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      // 4-Column Tactical Bar
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBase,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TacticalBadge(
                              icon: Icons.straighten,
                              label: 'Cự ly',
                              value: spot['distance'] as String? ?? '--',
                            ),
                            _buildDivider(),
                            TacticalBadge(
                              icon: Icons.terrain,
                              label: 'Độ cao',
                              value: spot['elevation'] as String? ?? '--',
                            ),
                            _buildDivider(),
                            TacticalBadge(
                              icon: Icons.water_drop,
                              label: 'Nguồn nước',
                              value: spot['water'] as String? ?? '--',
                            ),
                            _buildDivider(),
                            TacticalBadge(
                              icon: Icons.signal_cellular_alt,
                              label: 'Sóng 4G',
                              value: spot['signal'] as String? ?? '--',
                              iconColor: (spot['signal'] as String? ?? '').contains('0%')
                                  ? AppColors.emergencyRed
                                  : AppColors.emerald,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: AppSpacing.space20),

                      // Tab selector
                      Row(
                        children: [
                          _buildTabButton(0, 'Tổng quan'),
                          const SizedBox(width: 8),
                          _buildTabButton(1, 'Lộ trình'),
                          const SizedBox(width: 8),
                          _buildTabButton(2, 'Lưu ý an toàn'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),

                      // Tab Content
                      if (_selectedTab == 0) ...[
                        Text(
                          'Giới thiệu cung đường',
                          style: AppTypography.headlineMedium.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          spot['description'] as String? ?? '',
                          style: AppTypography.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        Text(
                          'Điểm nổi bật nhất',
                          style: AppTypography.headlineMedium.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: highlights.map((h) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: AppRadius.roundedMd,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: AppColors.emerald),
                                const SizedBox(width: 6),
                                Text(h, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ] else if (_selectedTab == 1) ...[
                        _buildTrailStep('1', 'Điểm tập kết xuất phát', 'Chuẩn bị trang bị cá nhân và kiểm tra tín hiệu GPS lần cuối.', '0.0 km'),
                        _buildTrailStep('2', 'Vượt dốc sống lưng khủng long', 'Cung đường gió mạnh trên độ cao 1,100m, cảnh quan đồi cỏ bao la.', '+ 18.5 km'),
                        _buildTrailStep('3', 'Bãi hạ trại ven suối rừng', 'Nơi có nguồn nước ngọt tự nhiên dồi dào để dựng lều qua đêm.', '+ 12.0 km'),
                        _buildTrailStep('4', 'Cung rừng khộp hạ sơn', 'Rừng rụng lá mùa khô, dốc thoải dẫn ra bìa rừng đón xe trung chuyển.', '+ 24.5 km'),
                      ] else ...[
                        _buildSafetyNotice(
                          Icons.warning_amber_rounded,
                          AppColors.tacticalOrange,
                          'Mất sóng di động dài ngày',
                          'Tải sẵn bản đồ ngoại tuyến vector (.mbtiles) và pin sạc dự phòng 20,000mAh trước khi vào rừng.',
                        ),
                        const SizedBox(height: 10),
                        _buildSafetyNotice(
                          Icons.water,
                          AppColors.alpineCyan,
                          'Tránh lũ quét đầu nguồn',
                          'Nếu thấy nước suối chuyển màu đục ngầu kèm cành cây trôi, phải sơ tán lên sườn đồi cao ngay lập tức.',
                        ),
                      ],

                      // Bottom Clearance
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pinned Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 12, AppSpacing.space16, 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceBase,
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Bookmark Offline Pill
                  BouncingButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceElevated,
                          content: Row(
                            children: [
                              const Icon(Icons.cloud_download, color: AppColors.emerald, size: 18),
                              const SizedBox(width: 8),
                              Text('Đã tải gói dữ liệu offline cho ${spot['title']}', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Icon(Icons.download_for_offline_outlined, color: AppColors.emerald, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Main Start Button
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.emeraldGradient,
                          borderRadius: AppRadius.roundedMd,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.navigation, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Bắt Đầu Khám Phá',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceHigh,
      child: const Center(
        child: Icon(Icons.terrain, size: 60, color: Colors.white12),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 26, color: AppColors.borderSubtle);
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: BouncingButton(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : AppColors.surfaceHigh,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailStep(String step, String title, String desc, String dist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.surfaceHigh,
            child: Text(step, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                    Text(dist, style: AppTypography.captionBadge.copyWith(color: AppColors.emerald)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(desc, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14, color: Colors.white)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

