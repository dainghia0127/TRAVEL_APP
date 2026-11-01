import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

class HeroDestinationCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> featuredSpots;
  final Set<String> favoriteSpots;
  final Function(String) onToggleFavorite;

  const HeroDestinationCarousel({
    super.key,
    required this.featuredSpots,
    required this.favoriteSpots,
    required this.onToggleFavorite,
  });

  @override
  State<HeroDestinationCarousel> createState() => _HeroDestinationCarouselState();
}

class _HeroDestinationCarouselState extends State<HeroDestinationCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredSpots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Điểm Đến Nổi Bật',
                style: AppTypography.headlineMedium.copyWith(fontSize: 18),
              ),
              // Page Indicator Dots
              Row(
                children: List.generate(widget.featuredSpots.length, (index) {
                  final isCurrent = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 4),
                    width: isCurrent ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.emerald : AppColors.borderMedium,
                      borderRadius: AppRadius.roundedPill,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space12),

        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.featuredSpots.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final spot = widget.featuredSpots[index];
              final isFav = widget.favoriteSpots.contains(spot['id']);
              final imageUrl = spot['imageUrl'] as String? ?? '';

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BouncingButton(
                  scaleLower: 0.98,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 280),
                        reverseTransitionDuration: const Duration(milliseconds: 240),
                        pageBuilder: (context, animation, secondaryAnimation) => DestinationDetailScreen(
                          spot: spot,
                          isFavorite: isFav,
                          onToggleFavorite: () => widget.onToggleFavorite(spot['id'] as String),
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.roundedXl,
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Photo
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.landscape, size: 50, color: Color(0xFF94A3B8)),
                            ),
                          )
                        else
                          Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(Icons.landscape, size: 50, color: Color(0xFF94A3B8)),
                          ),

                        // Gradient Scrim
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.imageOverlayGradient,
                          ),
                        ),

                        // Top Badges Row
                        Positioned(
                          top: 14,
                          left: 14,
                          right: 14,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TacticalPill(
                                icon: Icons.local_fire_department,
                                text: 'HOT NHẤT MÙA',
                                color: AppColors.tacticalOrange,
                                backgroundColor: Colors.black.withValues(alpha: 0.65),
                              ),
                              BouncingButton(
                                onTap: () => widget.onToggleFavorite(spot['id'] as String),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
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

                        // Bottom Title & Outdoor Metrics
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                spot['title'] as String? ?? '',
                                style: AppTypography.headlineMedium.copyWith(
                                  fontSize: 19,
                                  color: Colors.white,
                                ),
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
                                      spot['location'] as String? ?? '',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: AppRadius.roundedPill,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: AppColors.summitGold),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${spot['rating']}',
                                          style: AppTypography.captionBadge.copyWith(fontSize: 11),
                                        ),
                                      ],
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
              );
            },
          ),
        ),
      ],
    );
  }
}

