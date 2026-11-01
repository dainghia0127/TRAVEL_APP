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

    // Ưu tiên nạp từ local asset nếu có (đặc biệt là bộ ảnh thật của từng địa danh được lưu tại assets/images/destinations/)
    // Giúp ảnh hiển thị tức thì 0ms, không phụ thuộc mạng, 100% không bị lỗi CORS hay màn hình đen (blackout) khi pop route.
    final bool hasLocalAsset = image.localAsset.isNotEmpty &&
        image.localAsset.startsWith('assets/');

    if (hasLocalAsset) {
      imageContent = Image.asset(
        image.localAsset,
        key: ValueKey('asset_${image.localAsset}'),
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
        errorBuilder: (context, error, stackTrace) => _buildNetworkFallback(radius),
      );
    } else if (kIsWeb) {
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
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      // Trên Mobile Native (Android / iOS): Sử dụng CachedNetworkImage
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
        errorWidget: (context, url, error) => _buildPlaceholder(),
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

  Widget _buildNetworkFallback(BorderRadius radius) {
    if (kIsWeb) {
      return Image.network(
        image.url,
        key: ValueKey('fb_web_${image.url}'),
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return CachedNetworkImage(
      key: ValueKey('fb_native_${image.url}'),
      imageUrl: image.url,
      width: width,
      height: height,
      fit: fit,
      alignment: image.focalPoint,
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(Icons.landscape_outlined, size: 36, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
