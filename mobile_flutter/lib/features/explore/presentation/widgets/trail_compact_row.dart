import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Hàng danh sách cung đường tinh gọn (Compact Row List) - Phá vỡ sự rập khuôn dạng thẻ hộp
class TrailCompactRow extends StatelessWidget {
  final Map<String, dynamic> spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const TrailCompactRow({
    super.key,
    required this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = spot['imageUrl'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: AppColors.bgDark,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 320),
        openBuilder: (context, action) => DestinationDetailScreen(
          spot: spot,
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        ),
        closedBuilder: (context, action) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              // Circular Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceHigh,
                            child: const Icon(Icons.terrain, size: 24, color: Colors.white24),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.terrain, size: 24, color: Colors.white24),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            spot['title'] as String,
                            style: AppTypography.titleMedium.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        BouncingButton(
                          onTap: onToggleFavorite,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.emergencyRed : AppColors.textMuted,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spot['location'] as String,
                      style: AppTypography.bodyMedium.copyWith(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        TacticalPill(
                          text: spot['distance'] as String,
                          color: AppColors.emerald,
                          backgroundColor: AppColors.surfaceHigh,
                        ),
                        const SizedBox(width: 6),
                        TacticalPill(
                          text: spot['elevation'] as String,
                          color: AppColors.alpineCyan,
                          backgroundColor: AppColors.surfaceHigh,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

