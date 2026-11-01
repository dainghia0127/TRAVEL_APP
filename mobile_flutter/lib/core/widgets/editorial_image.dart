import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/widgets/skeleton_shimmer.dart';

class EditorialImage extends StatelessWidget {
  final OutdoorImage image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showAttribution;
  final Widget? overlay;

  const EditorialImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showAttribution = false,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    Widget imageContent;

    // Trên Web: Sử dụng Image.network native của trình duyệt để tận dụng HTTP cache,
    // tránh triệt để lỗi XHR CORS của flutter_cache_manager và canvas texture blackout khi route pop.
    if (kIsWeb) {
      imageContent = Image.network(
        image.url,
        key: ValueKey('web_img_${image.url}'),
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return SkeletonShimmer(
            width: width ?? double.infinity,
            height: height ?? 200,
            borderRadius: radius,
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildLocalFallback(),
      );
    } else {
      // Trên Mobile Native (Android / iOS): Sử dụng CachedNetworkImage cho Disk Storage Cache
      imageContent = CachedNetworkImage(
        key: ValueKey('native_img_${image.url}'),
        imageUrl: image.url,
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => SkeletonShimmer(
          width: width ?? double.infinity,
          height: height ?? 200,
          borderRadius: radius,
        ),
        errorWidget: (context, url, error) => _buildLocalFallback(),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFE2E8F0),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            imageContent,
            if (overlay != null) Positioned.fill(child: overlay!),
            if (showAttribution && image.photographer != null)
              Positioned(
                bottom: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Ảnh: ${image.photographer}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalFallback() {
    return Image.asset(
      image.localAsset,
      key: ValueKey('asset_${image.localAsset}'),
      width: width,
      height: height,
      fit: fit,
      alignment: image.focalPoint,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(Icons.landscape_outlined, size: 36, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
