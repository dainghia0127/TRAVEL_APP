import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

class DestinationCard extends StatelessWidget {
  final Map<String, dynamic> spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DestinationCard({
    super.key,
    required this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  Color _getDifficultyColor(int level) {
    if (level == 1) return AppColors.emerald;
    if (level == 2) return AppColors.tacticalOrange;
    return AppColors.emergencyRed;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = spot['imageUrl'] as String? ?? '';
    final difficultyLevel = (spot['difficultyLevel'] as num?)?.toInt() ?? 2;
    final diffColor = _getDifficultyColor(difficultyLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space20),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: AppColors.bgDark,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 360),
        openBuilder: (context, action) => DestinationDetailScreen(
          spot: spot,
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        ),
        closedBuilder: (context, action) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image with Aspect Ratio & Badges
              SizedBox(
                height: 185,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Real Photography
                    if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.terrain, size: 48, color: Colors.white24),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.surfaceHigh,
                        child: const Icon(Icons.terrain, size: 48, color: Colors.white24),
                      ),

                    // Gradient Scrim for Top & Bottom readability
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.imageOverlayGradient,
                      ),
                    ),

                    // Top Bar: Category Pill & Favorite Button
                    Positioned(
                      top: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TacticalPill(
                            text: spot['category'] as String? ?? 'Dã ngoại',
                            color: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: 0.65),
                          ),
                          // 44x44 Touch Target for Favorite
                          BouncingButton(
                            onTap: onToggleFavorite,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Center(
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? AppColors.emergencyRed : Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom of Image: Difficulty & Rating Badge
                    Positioned(
                      left: 14,
                      bottom: 12,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TacticalPill(
                            text: spot['difficulty'] as String? ?? 'Vừa phải',
                            color: diffColor,
                            backgroundColor: diffColor.withValues(alpha: 0.2),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 13, color: AppColors.summitGold),
                                const SizedBox(width: 4),
                                Text(
                                  '${spot['rating']} (${spot['reviews']})',
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

              // Content Body
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      spot['title'] as String? ?? '',
                      style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            spot['location'] as String? ?? '',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      spot['description'] as String? ?? '',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.space16),

                    // 4-Column Tactical Stat Bar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: AppRadius.roundedMd,
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
                            label: 'Cao độ',
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

  Widget _buildDivider() {
    return Container(width: 1, height: 22, color: AppColors.borderSubtle);
  }
}

