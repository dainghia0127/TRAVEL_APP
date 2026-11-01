import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Danh mục Địa điểm Gần Vị trí Hiện Tại Nhất (Nearby from Current GPS)
class NearbySection extends StatelessWidget {
  final List<Destination> destinations;
  final LatLng userLocation;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const NearbySection({
    super.key,
    required this.destinations,
    required this.userLocation,
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  void _openDetail(BuildContext context, Destination dest, bool isFav) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DestinationDetailScreen(
          destination: dest,
          isFavorite: isFav,
          onToggleFavorite: () => onToggleFavorite(dest.id),
          userLocation: userLocation,
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
    if (destinations.isEmpty) return const SizedBox.shrink();

    // Sắp xếp các địa điểm theo cự ly từ gần đến xa
    final distanceCalc = const Distance();
    final sortedList = List<Destination>.from(destinations);
    sortedList.sort((a, b) {
      final posA = LatLng(a.centerLatitude ?? 10.8231, a.centerLongitude ?? 106.6297);
      final posB = LatLng(b.centerLatitude ?? 10.8231, b.centerLongitude ?? 106.6297);
      final distA = distanceCalc.as(LengthUnit.Kilometer, userLocation, posA);
      final distB = distanceCalc.as(LengthUnit.Kilometer, userLocation, posB);
      return distA.compareTo(distB);
    });

    final topNearby = sortedList.take(6).toList();

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
                  Icon(Icons.near_me_rounded, size: 20, color: AppColors.editorialPine),
                  SizedBox(width: 6),
                  Text(
                    'Gần Vị Trí Của Bạn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const Text(
                'Theo cự ly GPS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.editorialMuted),
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
            itemCount: topNearby.length,
            itemBuilder: (context, index) {
              final dest = topNearby[index];
              final isFav = favoriteIds.contains(dest.id);
              final destPos = LatLng(dest.centerLatitude ?? 10.8231, dest.centerLongitude ?? 106.6297);
              final distKm = distanceCalc.as(LengthUnit.Kilometer, userLocation, destPos);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 200,
                  child: BouncingButton(
                    onTap: () => _openDetail(context, dest, isFav),
                    child: Container(
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
                          // Ảnh địa danh kèm Badge khoảng cách
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
                                  // Badge khoảng cách
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.72),
                                        borderRadius: AppRadius.roundedPill,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.navigation, size: 10, color: Color(0xFF68D391)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${distKm.toStringAsFixed(0)} km',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Nút yêu thích
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
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
