import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Băng chuyền hiển thị Điểm Đến Nổi Bật (Featured Destinations Carousel)
class FeaturedCarousel extends StatefulWidget {
  final List<Destination> destinations;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const FeaturedCarousel({
    super.key,
    required this.destinations,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                  Icon(Icons.stars_rounded, size: 20, color: AppColors.editorialTerracotta),
                  SizedBox(width: 6),
                  Text(
                    'Điểm Đến Nổi Bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              // Dots indicator
              Row(
                children: List.generate(widget.destinations.length, (idx) {
                  final isCurrent = _currentPage == idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 4),
                    width: isCurrent ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.editorialPine : AppColors.editorialBorder,
                      borderRadius: AppRadius.roundedPill,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 245,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.destinations.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final dest = widget.destinations[index];
              final isFav = widget.favoriteIds.contains(dest.id);
              final isUnesco = dest.categoryIds.contains('unesco');

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BouncingButton(
                  onTap: () => _openDetail(context, dest, isFav),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          EditorialImage(
                            image: OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name),
                            fit: BoxFit.cover,
                          ),

                          // Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Top Badges: UNESCO / Category & Favorite
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (isUnesco)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.88),
                                      borderRadius: AppRadius.roundedPill,
                                      border: Border.all(color: Colors.white24, width: 0.8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.account_balance, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'DI SẢN UNESCO',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: AppRadius.roundedPill,
                                    ),
                                    child: Text(
                                      dest.provinceOrCountry,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () => widget.onToggleFavorite(dest.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? AppColors.editorialTerracotta : Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Content Info
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dest.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  dest.editorialSummary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.terrain_outlined, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      dest.elevationDisplay,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.location_on_outlined, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        dest.provinceOrCountry,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
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
