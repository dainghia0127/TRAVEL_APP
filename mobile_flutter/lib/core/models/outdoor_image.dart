import 'package:flutter/material.dart';

/// Data model representing a curated outdoor photograph with local fallback and attribution
class OutdoorImage {
  final String url;
  final String localAsset;
  final double aspectRatio;
  final Alignment focalPoint;
  final String? photographer;
  final String? source;
  final String? caption;

  const OutdoorImage({
    required this.url,
    required this.localAsset,
    this.aspectRatio = 16 / 9,
    this.focalPoint = Alignment.center,
    this.photographer,
    this.source = 'Unsplash',
    this.caption,
  });

  /// Factory helper for fallback nature photo
  static const OutdoorImage defaultNature = OutdoorImage(
    url: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=900&q=80',
    localAsset: 'assets/images/default_nature.jpg',
    aspectRatio: 16 / 9,
    photographer: 'Sasha Freemind',
    caption: 'Vùng đồi hoang sơ dã ngoại',
  );
}

