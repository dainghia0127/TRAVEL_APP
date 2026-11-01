import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

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

  OutdoorImage _resolveImage(Map<String, dynamic> spot) {
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Cung Đường Nổi Bật',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.editorialInk,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Xem thêm (${spots.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.editorialPine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Large Hero Spotlight Card
          _buildSpotlightCard(spotlight),

          const SizedBox(height: 12),

          // 2. Two Side-by-Side Satellite Cards
          if (sub1 != null && sub2 != null)
            Row(
              children: [
                Expanded(child: _buildSatelliteCard(sub1)),
                const SizedBox(width: 12),
                Expanded(child: _buildSatelliteCard(sub2)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(Map<String, dynamic> spot) {
    final isFav = favoriteSpots.contains(spot['id']);
    final img = _resolveImage(spot);

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 340),
      openBuilder: (context, action) => DestinationDetailScreen(
        spot: spot,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(spot['id'] as String),
      ),
      closedBuilder: (context, action) => Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EditorialImage(
              image: img,
              borderRadius: BorderRadius.circular(18),
              showAttribution: true,
            ),

            // Subtle gradient overlay for editorial readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x30000000),
                    Colors.transparent,
                    Color(0x90000000),
                    Color(0xDF000000),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${spot['rating']} (${spot['reviews']})',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  BouncingButton(
                    onTap: () => onToggleFavorite(spot['id'] as String),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
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

            // Bottom Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, color: Colors.white70, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        spot['location'] as String,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spot['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildMiniBadge(Icons.straighten, spot['distance'] as String),
                      const SizedBox(width: 8),
                      _buildMiniBadge(Icons.landscape, spot['elevation'] as String),
                      const SizedBox(width: 8),
                      _buildMiniBadge(Icons.hiking, spot['difficulty'] as String),
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
    final img = _resolveImage(spot);

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 320),
      openBuilder: (context, action) => DestinationDetailScreen(
        spot: spot,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(spot['id'] as String),
      ),
      closedBuilder: (context, action) => Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EditorialImage(
              image: img,
              borderRadius: BorderRadius.circular(16),
            ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xB5000000), Color(0xEB000000)],
                  stops: [0.3, 0.7, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: BouncingButton(
                onTap: () => onToggleFavorite(spot['id'] as String),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.emergencyRed : Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot['category'] as String,
                    style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spot['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${spot['distance']} • ${spot['elevation']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white70),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
