import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

class TrailCompactRow extends StatelessWidget {
  final Destination? destination;
  final Map<String, dynamic>? spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const TrailCompactRow({
    super.key,
    this.destination,
    this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : assert(destination != null || spot != null);

  OutdoorImage _resolveImage() {
    if (destination != null) {
      final hero = destination!.heroMedia;
      return OutdoorImage.fromMedia(hero, caption: destination!.name);
    }
    if (spot?['outdoorImage'] is OutdoorImage) {
      return spot!['outdoorImage'] as OutdoorImage;
    }
    final url = spot?['imageUrl'] as String? ?? '';
    return OutdoorImage(
      url: url.isNotEmpty ? url : OutdoorImage.defaultNature.url,
      localAsset: 'assets/images/default_nature.jpg',
    );
  }

  String get _title => destination?.name ?? spot?['title'] as String? ?? '';
  String get _summary => destination?.editorialSummary ?? spot?['description'] as String? ?? '';
  String get _distance => destination?.distanceDisplay ?? spot?['distance'] as String? ?? '--';
  String get _elevation => destination?.elevationDisplay ?? spot?['elevation'] as String? ?? '--';
  String get _difficultyLabel => destination?.route?.difficultyLabel ?? spot?['difficulty'] as String? ?? 'Dã ngoại';

  @override
  Widget build(BuildContext context) {
    final img = _resolveImage();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: AppColors.editorialBg,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 320),
        openBuilder: (context, action) => DestinationDetailScreen(
          destination: destination,
          spot: spot,
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        ),
        closedBuilder: (context, action) => Container(
          padding: const EdgeInsets.all(12),
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 66,
                  height: 66,
                  child: EditorialImage(
                    image: img,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editorialInk,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        BouncingButton(
                          onTap: onToggleFavorite,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.emergencyRed : AppColors.editorialMuted,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _summary,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.editorialMuted,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _difficultyLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editorialPine,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_distance • $_elevation',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.editorialInk,
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
  }
}
