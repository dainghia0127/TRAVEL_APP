import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/destination_detail_screen.dart';

/// Danh mục Địa điểm Check-in Hot Trend trên TikTok, Facebook & MXH
class SocialTrendingSection extends StatelessWidget {
  final List<Destination> destinations;
  final String locationName;
  final LatLng userLocation;
  final Set<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const SocialTrendingSection({
    super.key,
    required this.destinations,
    required this.locationName,
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

  String _computeDistance(Destination dest) {
    if (dest.centerLatitude != null && dest.centerLongitude != null) {
      final destPos = LatLng(dest.centerLatitude!, dest.centerLongitude!);
      final dist = const Distance().as(LengthUnit.Kilometer, userLocation, destPos);
      if (dist < 1) return '< 1 km';
      if (dist >= 1000) {
        return '${(dist / 1000).toStringAsFixed(1)}k km';
      }
      return '${dist.round()} km';
    }
    return '-- km';
  }

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    // Rút trích tên thành phố hiển thị ngắn gọn (ví dụ: TP. Hồ Chí Minh)
    String cleanCity = 'TP. Hồ Chí Minh';
    if (locationName.contains('Hồ Chí Minh')) {
      cleanCity = 'TP. Hồ Chí Minh';
    } else if (locationName.contains('Tây Nguyên') || locationName.contains('Lâm Đồng')) {
      cleanCity = 'Đà Lạt & Tây Nguyên';
    } else if (locationName.contains('Fansipan') || locationName.contains('Sa Pa')) {
      cleanCity = 'Sa Pa & Tây Bắc';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Hot Trend Check-in • $cleanCity',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialInk,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE2C55).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFE2C55).withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'TikTok / FB',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFE2C55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tọa độ sống ảo triệu view & điểm hẹn chill đình đám nhất',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.editorialMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal Carousel Cards
        SizedBox(
          height: 275,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final dest = destinations[index];
              final isFav = favoriteIds.contains(dest.id);
              final distStr = _computeDistance(dest);

              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: BouncingButton(
                  onTap: () => _openDetail(context, dest, isFav),
                  child: Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: AppColors.editorialSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.editorialBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Stack
                        Stack(
                          children: [
                            EditorialImage(
                              image: OutdoorImage.fromMedia(dest.heroMedia, caption: dest.name),
                              height: 145,
                              width: 250,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            ),

                            // Top Trend Badge
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFF9500).withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 13,
                                      color: Color(0xFFFF9500),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dest.socialViews ?? 'Hot Trend',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Favorite Button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black.withValues(alpha: 0.45),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: isFav ? AppColors.emergencyRed : Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    onToggleFavorite(dest.id);
                                  },
                                ),
                              ),
                            ),

                            // Distance Pill
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me_outlined, size: 11, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cách $distStr',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Info Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dest.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.editorialInk,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      dest.localName ?? dest.provinceOrCountry,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.editorialMuted,
                                      ),
                                    ),
                                  ],
                                ),

                                // Photo Spot Tip
                                if (dest.photoSpotTip != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.summitGold.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.summitGold.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 12,
                                          color: AppColors.editorialTerracotta,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            dest.photoSpotTip!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: AppColors.editorialTerracotta,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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

