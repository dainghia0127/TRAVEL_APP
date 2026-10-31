import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Bento Grid Layout: 1 Thẻ Tiêu Điểm Lớn + 2 Thẻ Vệ Tinh Nhỏ Đa Dạng
class BentoDestinationGrid extends StatelessWidget {
  final List<Map<String, dynamic>> spots;
  final Set<String> favoriteSpots;
  final Function(String) onToggleFavorite;

  const BentoDestinationGrid({
    super.key,
    required this.spots,
    required this.favoriteSpots,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final spotlight = spots[0];
    final sub1 = spots.length > 1 ? spots[1] : null;
    final sub2 = spots.length > 2 ? spots[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tâm Điểm Dã Ngoại (Spotlight)', style: AppTypography.headlineMedium.copyWith(fontSize: 18)),
              TacticalPill(
                icon: Icons.star,
                text: 'BẢN SẮC OUTDOOR',
                color: AppColors.summitGold,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),

          // 1. Large Hero Spotlight Card
          _buildSpotlightCard(spotlight),

          const SizedBox(height: AppSpacing.space12),

          // 2. Two Side-by-Side Compact Satellite Cards
          if (sub1 != null && sub2 != null)
            Row(
              children: [
                Expanded(child: _buildSatelliteCard(sub1)),
                const SizedBox(width: AppSpacing.space12),
                Expanded(child: _buildSatelliteCard(sub2)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(Map<String, dynamic> spot) {
    final isFav = favoriteSpots.contains(spot['id']);
    final imageUrl = spot['imageUrl'] as String? ?? '';

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.bgDark,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 360),
      openBuilder: (context, action) => DestinationDetailScreen(
        spot: spot,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(spot['id'] as String),
      ),
      closedBuilder: (context, action) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceHigh),
              )
            else
              Container(color: AppColors.surfaceHigh),

            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.imageOverlayGradient,
              ),
            ),

            // Top Badges
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TacticalPill(
                    icon: Icons.local_fire_department,
                    text: 'TIÊU ĐIỂM TUẦN',
                    color: AppColors.tacticalOrange,
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                  ),
                  BouncingButton(
                    onTap: () => onToggleFavorite(spot['id'] as String),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.emergencyRed : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Information
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    spot['title'] as String,
                    style: AppTypography.headlineLarge.copyWith(fontSize: 19, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.emerald),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spot['location'] as String,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TacticalPill(
                        text: spot['distance'] as String,
                        color: AppColors.emerald,
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
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

  Widget _buildSatelliteCard(Map<String, dynamic> spot) {
    final isFav = favoriteSpots.contains(spot['id']);
    final imageUrl = spot['imageUrl'] as String? ?? '';

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.bgDark,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 360),
      openBuilder: (context, action) => DestinationDetailScreen(
        spot: spot,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(spot['id'] as String),
      ),
      closedBuilder: (context, action) => Container(
        height: 155,
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceHigh),
              )
            else
              Container(color: AppColors.surfaceHigh),

            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.imageOverlayGradient,
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TacticalPill(
                    text: spot['category'] as String,
                    color: Colors.white,
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spot['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    spot['elevation'] as String,
                    style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.bold),
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

