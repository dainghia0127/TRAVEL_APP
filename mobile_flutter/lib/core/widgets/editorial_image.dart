import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/widgets/skeleton_shimmer.dart';

/// Widget hiển thị hình ảnh biên tập thông minh với kiến trúc 3 lớp:
/// 1. Dynamic Network + Disk Cache (Trên Mobile Native: nạp động từ API/mạng, tự cache vào máy, KHÔNG CẦN build lại app khi có địa điểm mới)
/// 2. Bundled Pre-packaged Assets (Ảnh hạt giống có sẵn trong bộ cài app: mở app lần đầu tức thì 0ms, hỗ trợ offline khi đi rừng núi)
/// 3. Resilient Error Fallback (Tự động fallback an toàn, không bao giờ bị vỡ layout hay màn hình đen)
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

    // Kiểm tra xem có asset cục bộ riêng biệt của địa danh này hay không (Bundled Seeds)
    final bool hasSpecificLocalAsset = image.localAsset.isNotEmpty &&
        image.localAsset.startsWith('assets/images/destinations/');

    // Kiểm tra xem có URL mạng hợp lệ để nạp động hay không
    final bool hasValidNetworkUrl = image.url.isNotEmpty &&
        (image.url.startsWith('http://') || image.url.startsWith('https://')) &&
        image.url != OutdoorImage.defaultNature.url;

    // Tính toán giới hạn kích thước giải mã GPU (GPU Decode Bounds) để tối ưu triệt để RAM
    final int targetMemWidth = (width != null && width!.isFinite && width! > 0)
        ? (width! * 2.0).round().clamp(200, 900)
        : 800;

    Widget imageContent;

    if (hasSpecificLocalAsset) {
      // =========================================================================
      // [1] ƯU TIÊN BUNDLED SEEDS (Bộ ảnh đóng gói sẵn trong App):
      // - Nạp tức thì 0ms, không tốn data 4G/5G, hoạt động 100% offline trong rừng.
      // - Giới hạn cacheWidth để giải mã GPU siêu nhanh, mượt mà 60-120fps.
      // =========================================================================
      imageContent = Image.asset(
        image.localAsset,
        key: ValueKey('asset_${image.localAsset}'),
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        cacheWidth: targetMemWidth,
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
    } else if (!kIsWeb && hasValidNetworkUrl) {
      // =========================================================================
      // [2] ĐỊA ĐIỂM ĐỘNG MỚI TRÊN MOBILE NATIVE (iOS / Android):
      // - Tự động tải từ server/API và lưu Disk Cache.
      // - memCacheWidth: Giới hạn giải mã vào RAM GPU, ngăn chặn triệt để giật lag/OOM.
      // =========================================================================
      imageContent = CachedNetworkImage(
        key: ValueKey('native_img_${image.url}'),
        imageUrl: image.url,
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        fadeInDuration: const Duration(milliseconds: 150),
        memCacheWidth: targetMemWidth,
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        placeholder: (context, url) => SkeletonShimmer(
          width: width ?? double.infinity,
          height: height ?? 200,
          borderRadius: radius,
        ),
        errorWidget: (context, url, error) => _buildAssetOrPlaceholder(hasSpecificLocalAsset),
      );
    } else if (hasValidNetworkUrl) {
      // =========================================================================
      // [3] ĐỊA ĐIỂM ĐỘNG MỚI TRÊN WEB:
      // =========================================================================
      imageContent = Image.network(
        image.url,
        key: ValueKey('web_img_${image.url}'),
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        cacheWidth: targetMemWidth,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return SkeletonShimmer(
            width: width ?? double.infinity,
            height: height ?? 200,
            borderRadius: radius,
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildAssetOrPlaceholder(hasSpecificLocalAsset),
      );
    } else {
      // [4] FALLBACK AN TOÀN
      imageContent = _buildAssetOrPlaceholder(hasSpecificLocalAsset);
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

  Widget _buildAssetOrPlaceholder(bool hasSpecificLocalAsset) {
    if (hasSpecificLocalAsset) {
      return Image.asset(
        image.localAsset,
        key: ValueKey('fb_asset_${image.localAsset}'),
        width: width,
        height: height,
        fit: fit,
        alignment: image.focalPoint,
        cacheWidth: 800,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
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
