import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

class BentoDestinationGrid extends StatelessWidget {
  final List<Destination> destinations;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const BentoDestinationGrid({
    super.key,
    required this.destinations,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  OutdoorImage _resolveImage(Destination dest) {
    return OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name);
  }

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    final spotlight = destinations[0];
    final sub1 = destinations.length > 1 ? destinations[1] : null;
    final sub2 = destinations.length > 2 ? destinations[2] : null;

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
                'Điểm Đến Tiêu Biểu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.editorialInk,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Tất cả (${destinations.length})',
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

  Widget _buildSpotlightCard(Destination dest) {
    final isFav = favoriteIds.contains(dest.id);
    final img = _resolveImage(dest);

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 320),
      openBuilder: (context, action) => DestinationDetailScreen(
        destination: dest,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(dest.id),
      ),
      closedBuilder: (context, action) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 14,
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
              borderRadius: BorderRadius.circular(20),
              showAttribution: true,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x20000000),
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
            Positioned(
              top: 12,
              right: 12,
              child: BouncingButton(
                onTap: () => onToggleFavorite(dest.id),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.emergencyRed : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dest.editorialSummary,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${dest.distanceDisplay} • ${dest.elevationDisplay}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Text('Khám phá', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          SizedBox(width: 3),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                        ],
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

  Widget _buildSatelliteCard(Destination dest) {
    final isFav = favoriteIds.contains(dest.id);
    final img = _resolveImage(dest);

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: AppColors.editorialBg,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 320),
      openBuilder: (context, action) => DestinationDetailScreen(
        destination: dest,
        isFavorite: isFav,
        onToggleFavorite: () => onToggleFavorite(dest.id),
      ),
      closedBuilder: (context, action) => Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
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
              showAttribution: false,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0x60000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.3, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: BouncingButton(
                onTap: () => onToggleFavorite(dest.id),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
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
                    dest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dest.distanceDisplay,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
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
