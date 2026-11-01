import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';

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

  OutdoorImage _resolveImage() {
    final spot = widget.spot;
    if (spot['outdoorImage'] is OutdoorImage) {
      return spot['outdoorImage'] as OutdoorImage;
    }
    final url = spot['imageUrl'] as String? ?? '';
    return OutdoorImage(
      url: url.isNotEmpty ? url : OutdoorImage.defaultNature.url,
      localAsset: 'assets/images/default_nature.jpg',
      photographer: 'Tác giả dã ngoại',
    );
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final highlights = (spot['highlights'] as List<dynamic>?)?.cast<String>() ?? [];
    final img = _resolveImage();

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.editorialBg,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
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
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
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
                      // Editorial Image with cache and local fallback
                      EditorialImage(
                        image: img,
                        showAttribution: true,
                      ),

                      // Gradient Scrim
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x30000000),
                              Colors.transparent,
                              Color(0x80000000),
                              Color(0xD0000000),
                            ],
                            stops: [0.0, 0.35, 0.7, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Floating Category & Rating Badge on bottom of image
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                spot['category'] as String? ?? 'Dã ngoại',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${spot['rating']} (${spot['reviews']} đánh giá)',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot['title'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.editorialInk,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 15, color: AppColors.editorialPine),
                          const SizedBox(width: 4),
                          Text(
                            spot['location'] as String? ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.editorialMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4-Column Restrained Facts Bar
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.editorialSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.editorialBorder),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFact(Icons.straighten, 'Cự ly', spot['distance'] as String? ?? '--'),
                            _buildDivider(),
                            _buildFact(Icons.landscape, 'Độ cao', spot['elevation'] as String? ?? '--'),
                            _buildDivider(),
                            _buildFact(Icons.water_drop_outlined, 'Nguồn nước', spot['water'] as String? ?? '--'),
                            _buildDivider(),
                            _buildFact(Icons.signal_cellular_alt, 'Sóng 4G', spot['signal'] as String? ?? '--'),
                          ],
                        ),
                      ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 20),

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
                      const SizedBox(height: 18),

                      // Tab Content
                      if (_selectedTab == 0) ...[
                        const Text(
                          'Giới thiệu cung đường',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          spot['description'] as String? ?? '',
                          style: const TextStyle(fontSize: 14, color: AppColors.editorialInk, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Điểm nổi bật nhất',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: highlights.map((h) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.editorialBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 14, color: AppColors.editorialPine),
                                const SizedBox(width: 6),
                                Text(h, style: const TextStyle(fontSize: 12, color: AppColors.editorialInk, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ] else if (_selectedTab == 1) ...[
                        const Text(
                          'Lộ trình tham khảo',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 12),
                        _buildTrailStep('1', 'Khởi hành tại Cửa rừng', 'Chuẩn bị thể lực, kiểm tra balo và bắt đầu tiến vào bìa rừng.', '0 km'),
                        _buildTrailStep('2', 'Vượt dốc và sống lưng', 'Cung đường mở ra khung cảnh thung lũng cỏ bạt ngàn tuyệt đẹp.', '15 km'),
                        _buildTrailStep('3', 'Bãi hạ trại ven suối', 'Nghỉ đêm, dựng lều kín gió, nấu ăn và ngắm bầu trời sao.', '28 km'),
                        _buildTrailStep('4', 'Đích đến trạm kết thúc', 'Hoàn tất cung đường và tập kết đón xe trung chuyển.', '${spot['distance']}'),
                      ] else ...[
                        const Text(
                          'Quy tắc an toàn sinh tồn',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 12),
                        _buildSafetyNotice(
                          Icons.water_drop,
                          AppColors.editorialPine,
                          'Mang tối thiểu 2.5 Lít nước',
                          'Đoạn sống lưng rất nắng gió và không có nguồn nước trong suốt 12km.',
                        ),
                        const SizedBox(height: 10),
                        _buildSafetyNotice(
                          Icons.warning_amber_rounded,
                          AppColors.editorialTerracotta,
                          'Cảnh báo mất sóng di động',
                          'Khu vực này mất sóng 70%. Luôn tải bản đồ và cẩm nang sơ cứu về máy trước khi đi.',
                        ),
                        const SizedBox(height: 10),
                        _buildSafetyNotice(
                          Icons.nights_stay,
                          AppColors.editorialPine,
                          'Dựng lều trước 16:30',
                          'Nhiệt độ đêm vùng núi có thể hạ dưới 12°C kèm gió giật mạnh.',
                        ),
                      ],

                      const SizedBox(height: 110), // Bottom padding for sticky button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.editorialSurface,
                border: const Border(top: BorderSide(color: AppColors.editorialBorder)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  BouncingButton(
                    onTap: _handleToggleFav,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.editorialBorder),
                      ),
                      child: Icon(
                        _fav ? Icons.favorite : Icons.favorite_border,
                        color: _fav ? AppColors.emergencyRed : AppColors.editorialInk,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.editorialPine,
                            content: Text(
                              'Đã lưu cung đường vào kế hoạch dã ngoại của bạn!',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.editorialPine,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_task, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Thêm Vào Lịch Trình',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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

  Widget _buildFact(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.editorialPine),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.editorialMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.editorialInk)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 26, color: AppColors.editorialBorder);
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: BouncingButton(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.editorialInk,
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
            radius: 13,
            backgroundColor: AppColors.editorialPine,
            child: Text(step, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.editorialInk)),
                    Text(dist, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.editorialPine)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.editorialMuted, height: 1.4)),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
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
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.editorialInk, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
