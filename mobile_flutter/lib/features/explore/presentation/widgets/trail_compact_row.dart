import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

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

  OutdoorImage _resolveImage() {
    if (spot['outdoorImage'] is OutdoorImage) {
      return spot['outdoorImage'] as OutdoorImage;
    }
    final url = spot['imageUrl'] as String? ?? '';
    return OutdoorImage(
      url: url.isNotEmpty ? url : OutdoorImage.defaultNature.url,
      localAsset: 'assets/images/default_nature.jpg',
    );
  }

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
              // Image Thumbnail with caching and local fallback
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
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.emergencyRed : AppColors.editorialMuted,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spot['location'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.editorialMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          spot['rating'] as String,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${spot['distance']} • ${spot['elevation']}',
                          style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            spot['difficulty'] as String,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.editorialPine),
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
