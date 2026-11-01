/// Entity đại diện cho tài nguyên hình ảnh với bản quyền và attribution rõ ràng
class DestinationMedia {
  final String id;
  final String imageUrl;
  final String? localAssetPath;
  final String photographer;
  final String sourceName;
  final String license;
  final String attribution;
  final double aspectRatio;
  final bool isHero;

  const DestinationMedia({
    required this.id,
    required this.imageUrl,
    this.localAssetPath,
    required this.photographer,
    required this.sourceName,
    required this.license,
    required this.attribution,
    this.aspectRatio = 16 / 9,
    this.isHero = false,
  });
}

