import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Danh mục Địa điểm Được Khám Phá Nhiều / Tiêu biểu (Trending & Popular Discovery)
class TrendingGridSection extends StatefulWidget {
  final List<Destination> destinations;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final VoidCallback? onScrollToTop;

  const TrendingGridSection({
    super.key,
    required this.destinations,
    required this.favoriteIds,
    required this.onToggleFavorite,
    this.onScrollToTop,
  });

  @override
  State<TrendingGridSection> createState() => _TrendingGridSectionState();
}

class _TrendingGridSectionState extends State<TrendingGridSection> {
  bool _isExpanded = false;
  static const int _initialLimit = 8;

  void _openDetail(BuildContext context, Destination dest, bool isFav) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DestinationDetailScreen(
          destination: dest,
          isFavorite: isFav,
          onToggleFavorite: () => widget.onToggleFavorite(dest.id),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.destinations.isEmpty) return const SizedBox.shrink();

    final totalCount = widget.destinations.length;
    final displayList = _isExpanded
        ? widget.destinations
        : widget.destinations.take(_initialLimit).toList();
    final remainingCount = totalCount - displayList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore_outlined, size: 20, color: AppColors.editorialPine),
                  SizedBox(width: 6),
                  Text(
                    'Khám Phá Nhiều Nhất',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Text(
                '$totalCount địa danh',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: displayList.map((dest) {
              final isFav = widget.favoriteIds.contains(dest.id);
              final isUnesco = dest.categoryIds.contains('unesco');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BouncingButton(
                  onTap: () => _openDetail(context, dest, isFav),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.editorialSurface,
                      borderRadius: BorderRadius.circular(16),
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
                      children: [
                        // Ảnh thumbnail bên trái
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                          child: SizedBox(
                            width: 105,
                            height: 105,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                EditorialImage(
                                  image: OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name),
                                  fit: BoxFit.cover,
                                ),
                                if (isUnesco)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.account_balance, color: Colors.white, size: 11),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Nội dung chi tiết bên phải
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dest.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.editorialInk,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => widget.onToggleFavorite(dest.id),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          size: 18,
                                          color: isFav ? AppColors.editorialTerracotta : AppColors.editorialMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  dest.editorialSummary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.editorialMuted,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      dest.provinceOrCountry,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.editorialPine),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${dest.elevationDisplay}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                                    ),
                                    if (dest.dataSource != null) ...[
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.editorialSurfaceSubtle,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          dest.dataSource!.split(' ')[0], // e.g. UNESCO, Wikidata
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.editorialMuted),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Nút Xem thêm / Thu gọn để tránh tình trạng cuộn vô tận
        if (totalCount > _initialLimit) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BouncingButton(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isExpanded = !_isExpanded);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.editorialSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.editorialBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x04000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.editorialPine,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isExpanded ? 'Thu Gọn Danh Sách' : 'Xem Thêm ($remainingCount địa danh nữa)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.editorialPine,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Footer Trang Trọng: Điểm dừng kết thúc Feed rõ ràng
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.editorialBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '✦ BẠN ĐÃ KHÁM PHÁ HẾT DANH MỤC TIÊU BIỂU ✦',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.editorialMuted,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sử dụng thanh tìm kiếm ở đầu trang để tra cứu thêm hàng trăm tọa độ dã ngoại khác',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.editorialMuted,
                ),
              ),
              if (widget.onScrollToTop != null) ...[
                const SizedBox(height: 12),
                BouncingButton(
                  onTap: widget.onScrollToTop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.editorialSurface,
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(color: AppColors.editorialBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.editorialPine),
                        SizedBox(width: 4),
                        Text(
                          'Lên đầu trang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.editorialPine,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
