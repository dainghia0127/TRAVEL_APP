import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Danh mục Gợi ý theo Mùa & Thời tiết lý tưởng (Seasonal & Weather Highlights)
class SeasonalSection extends StatelessWidget {
  final List<Destination> destinations;
  final int currentMonth;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const SeasonalSection({
    super.key,
    required this.destinations,
    required this.currentMonth,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    final monthStr = currentMonth < 10 ? '0$currentMonth' : '$currentMonth';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 20, color: AppColors.editorialTerracotta),
                  const SizedBox(width: 6),
                  Text(
                    'Mùa Đẹp Nhất Hiện Tại (Tháng $monthStr)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.editorialSurface,
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(color: AppColors.editorialBorder),
                ),
                child: const Text(
                  'KHÍ HẬU VÀNG',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.editorialPine),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final dest = destinations[index];
              final isFav = favoriteIds.contains(dest.id);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 200,
                  child: OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    closedColor: Colors.transparent,
                    openColor: AppColors.editorialBg,
                    transitionDuration: const Duration(milliseconds: 360),
                    openBuilder: (context, action) => DestinationDetailScreen(
                      destination: dest,
                      isFavorite: isFav,
                      onToggleFavorite: () => onToggleFavorite(dest.id),
                    ),
                    closedBuilder: (context, action) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.editorialBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh địa danh
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  EditorialImage(
                                    image: OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: BouncingButton(
                                      onTap: () => onToggleFavorite(dest.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? AppColors.editorialTerracotta : Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Thông tin tóm tắt
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.editorialInk,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dest.provinceOrCountry,
                                      style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                                    ),
                                    Text(
                                      dest.elevationDisplay,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.editorialPine,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

