import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';
import 'package:mobile_flutter/features/explore/domain/entities/safety_guideline.dart';
import 'package:mobile_flutter/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/overpass_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination? destination;
  final Map<String, dynamic>? spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final LatLng? userLocation;

  const DestinationDetailScreen({
    super.key,
    this.destination,
    this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.userLocation,
  }) : assert(destination != null || spot != null, 'Either destination or spot must be provided');

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late bool _fav;
  int _selectedTab = 0; // 0: Tổng quan, 1: Lộ trình, 2: An toàn
  bool _isInTrip = false;

  OutdoorWeather? _liveWeather;
  bool _isLoadingWeather = true;
  List<Map<String, dynamic>> _nearbyPois = [];
  bool _isLoadingPois = false;

  String get _destId => widget.destination?.id ?? (widget.spot?['id'] as String? ?? 'vn_ta_nang_phan_dung');
  double? get _lat => widget.destination?.centerLatitude ?? (widget.spot?['lat'] as num?)?.toDouble();
  double? get _lng => widget.destination?.centerLongitude ?? (widget.spot?['lng'] as num?)?.toDouble();

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
    _checkTripStatus();
    _fetchLiveWeather();
    _fetchNearbyPois();
  }

  Future<void> _fetchLiveWeather() async {
    final lat = _lat;
    final lng = _lng;
    if (lat != null && lng != null) {
      try {
        final w = await WeatherService.getForecast(lat, lng);
        if (mounted) {
          setState(() {
            _liveWeather = w;
            _isLoadingWeather = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingWeather = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  Future<void> _fetchNearbyPois() async {
    final lat = _lat;
    final lng = _lng;
    if (lat != null && lng != null) {
      setState(() => _isLoadingPois = true);
      try {
        final pois = await OverpassService.getOutdoorPoisNearby(
          center: LatLng(lat, lng),
          radiusMeters: 10000,
        );
        if (mounted) {
          setState(() {
            _nearbyPois = pois;
            _isLoadingPois = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingPois = false);
      }
    }
  }

  Future<void> _checkTripStatus() async {
    final trips = await StorageService.getTripDestinations();
    if (mounted) {
      setState(() {
        _isInTrip = trips.contains(_destId);
      });
    }
  }

  void _handleToggleFav() {
    setState(() => _fav = !_fav);
    widget.onToggleFavorite();
    HapticFeedback.mediumImpact();
  }

  Future<void> _handleAddToTrip() async {
    HapticFeedback.mediumImpact();
    await StorageService.addTripDestination(_destId);
    await StorageService.setSelectedTripDestination(_destId);
    if (mounted) {
      setState(() => _isInTrip = true);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
          elevation: 12,
          backgroundColor: const Color(0xFF141916),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E4537), width: 1.5),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.summitGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.summitGold.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.summitGold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đã thêm vào Chuyến đi!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_title • Sẵn sàng tạo lộ trình & bản đồ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB0C4B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'XEM LỊCH TRÌNH',
            textColor: AppColors.summitGold,
            onPressed: () {
              Navigator.of(context).pop();
              MainNavigationScreen.switchToTab(2);
            },
          ),
        ),
      );
    }
  }

  void _navigateToMap() {
    StorageService.setSelectedTripDestination(_destId);
    Navigator.of(context).pop();
    MainNavigationScreen.switchToTab(1);
  }

  void _navigateToTripPlanner() {
    StorageService.setSelectedTripDestination(_destId);
    Navigator.of(context).pop();
    MainNavigationScreen.switchToTab(2);
  }

  OutdoorImage _resolveImage() {
    if (widget.destination != null) {
      final hero = widget.destination!.heroMedia;
      return OutdoorImage.fromMedia(hero, caption: widget.destination!.name);
    }
    final spot = widget.spot!;
    if (spot['outdoorImage'] is OutdoorImage) {
      return spot['outdoorImage'] as OutdoorImage;
    }
    final url = spot['imageUrl'] as String? ?? '';
    return OutdoorImage(
      url: url.isNotEmpty ? url : OutdoorImage.defaultNature.url,
      localAsset: 'assets/images/default_nature.jpg',
      photographer: 'Tác giả dã ngoại',
    );
  }

  String get _title => widget.destination?.name ?? widget.spot?['title'] as String? ?? '';
  String? get _localName => widget.destination?.localName;
  String get _summary => widget.destination?.editorialSummary ?? widget.spot?['description'] as String? ?? '';
  String? get _content => widget.destination?.editorialContent;
  String get _elevation => widget.destination?.elevationDisplay ?? widget.spot?['elevation'] as String? ?? '--';
  List<String> get _seasons => widget.destination?.bestTravelSeasons ?? [];
  bool get _isVerified => widget.destination?.isVerified ?? false;
  TrekkingRoute? get _route => widget.destination?.route;
  SafetyGuideline? get _safety => _route?.safety;
  List<String> get _localSpecialties => widget.destination?.localSpecialties ?? [];
  List<String> get _mustTryActivities => widget.destination?.mustTryActivities ?? [];
  List<String> get _culturalHighlights => widget.destination?.culturalHighlights ?? [];
  String? get _gettingThereAdvice => widget.destination?.gettingThereAdvice;
  String? get _photoSpotTip => widget.destination?.photoSpotTip ?? widget.spot?['photoSpotTip'] as String?;

  /// Tính toán khoảng cách thực tế từ vị trí người dùng đến địa điểm
  String get _computedDistance {
    if (widget.destination != null &&
        widget.destination!.centerLatitude != null &&
        widget.destination!.centerLongitude != null) {
      final userPos = widget.userLocation ?? const LatLng(10.8231, 106.6297);
      final destPos = LatLng(
        widget.destination!.centerLatitude!,
        widget.destination!.centerLongitude!,
      );
      final dist = const Distance().as(LengthUnit.Kilometer, userPos, destPos);
      if (dist >= 1000) {
        final formatted = (dist / 1000).toStringAsFixed(1);
        return '${formatted.replaceAll('.0', '')}k km';
      }
      return '${dist.round()} km';
    }
    if (widget.destination?.route?.distanceKm != null) {
      return '${widget.destination!.route!.distanceKm} km';
    }
    final spotDist = widget.spot?['distance'] as String?;
    if (spotDist != null && spotDist.isNotEmpty && spotDist != '--') {
      return spotDist;
    }
    return '94 km';
  }

  void _openImagePreview(BuildContext context, OutdoorImage img) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: EditorialImage(
                  image: img,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (img.photographer != null || img.source != null) ...[
              const SizedBox(height: 10),
              Text(
                'Nguồn: ${img.source ?? 'Wikimedia Commons'} • Tác giả: ${img.photographer ?? 'Nhiếp ảnh thực địa'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = _resolveImage();

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.editorialBg,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: Icon(
                          _fav ? Icons.favorite : Icons.favorite_border,
                          color: _fav ? AppColors.emergencyRed : Colors.white,
                          size: 20,
                        ),
                        onPressed: _handleToggleFav,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      EditorialImage(
                        image: img,
                        showAttribution: true,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x30000000),
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
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _route != null ? Icons.hiking : Icons.landscape_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _route?.difficultyLabel ?? 'Điểm dã ngoại',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            if (_isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialPine.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: AppColors.summitGold),
                                    SizedBox(width: 4),
                                    Text(
                                      'Đã kiểm chứng',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title & Location Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.editorialInk,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0),
                      if (_localName != null && _localName != _title) ...[
                        const SizedBox(height: 2),
                        Text(
                          _localName!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.editorialMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 4-Column Restrained Facts Bar
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFact(Icons.near_me_outlined, 'Khoảng cách', _computedDistance),
                            _buildDivider(),
                            _buildFact(Icons.landscape, 'Độ cao', _elevation),
                            _buildDivider(),
                            _buildFact(
                              _route?.distanceKm != null ? Icons.straighten : Icons.schedule,
                              _route?.distanceKm != null ? 'Cung đường' : 'Thời gian',
                              _route?.distanceKm != null
                                  ? '${_route!.distanceKm} km'
                                  : (_route?.estimatedDurationDays != null
                                      ? '${_route!.estimatedDurationDays} ngày'
                                      : '1 ngày'),
                            ),
                            _buildDivider(),
                            _buildFact(
                              Icons.verified_user_outlined,
                              'Kiểm định',
                              _isVerified ? 'Chuyên gia' : 'Cộng đồng',
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 20),

                      // Tab selector
                      Row(
                        children: [
                          _buildTabButton(0, 'Tổng quan'),
                          const SizedBox(width: 8),
                          _buildTabButton(1, 'Lộ trình'),
                          const SizedBox(width: 8),
                          _buildTabButton(2, 'Lưu ý an toàn'),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Tab Content
                      if (_selectedTab == 0) ...[
                        const Text(
                          'Giới thiệu địa danh',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _content ?? _summary,
                          style: const TextStyle(fontSize: 14, color: AppColors.editorialInk, height: 1.6),
                        ),

                        // Hình ảnh thực tế địa danh & Điểm check-in
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.photo_library_outlined, size: 18, color: AppColors.editorialPine),
                                SizedBox(width: 8),
                                Text(
                                  'Hình ảnh thực tế địa danh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.editorialInk,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.editorialPine.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, size: 12, color: AppColors.editorialPine),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ảnh thực tế 100%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.editorialPine,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _openImagePreview(context, img),
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
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
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                EditorialImage(
                                  image: img,
                                  fit: BoxFit.cover,
                                  showAttribution: true,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_photoSpotTip != null && _photoSpotTip!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Góc chụp đẹp: $_photoSpotTip',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF92400E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Chỉ dẫn di chuyển & Phương tiện
                        if (_gettingThereAdvice != null && _gettingThereAdvice!.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Icon(Icons.directions_bus_filled_outlined, size: 18, color: AppColors.editorialPine),
                              SizedBox(width: 8),
                              Text(
                                'Chỉ dẫn di chuyển & Phương tiện',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.editorialBorder),
                            ),
                            child: Text(
                              _gettingThereAdvice!,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.editorialInk, height: 1.55),
                            ),
                          ),
                        ],

                        // Đặc sản & Ẩm thực địa phương
                        if (_localSpecialties.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Icon(Icons.restaurant_menu, size: 18, color: AppColors.editorialTerracotta),
                              SizedBox(width: 8),
                              Text(
                                'Đặc sản & Ẩm thực địa phương',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._localSpecialties.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.editorialTerracotta.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.lunch_dining_outlined, size: 16, color: AppColors.editorialTerracotta),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.editorialInk),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],

                        // Trải nghiệm nhất định phải thử
                        if (_mustTryActivities.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Icon(Icons.explore_outlined, size: 18, color: AppColors.editorialPine),
                              SizedBox(width: 8),
                              Text(
                                'Trải nghiệm dã ngoại không thể bỏ lỡ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._mustTryActivities.map((act) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.check_circle_outline, size: 16, color: AppColors.editorialPine),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      act,
                                      style: const TextStyle(fontSize: 13, color: AppColors.editorialInk, height: 1.45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],

                        // Nét đẹp văn hóa & Lịch sử bản địa
                        if (_culturalHighlights.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Icon(Icons.auto_stories_outlined, size: 18, color: AppColors.summitGold),
                              SizedBox(width: 8),
                              Text(
                                'Nét đẹp văn hóa & Lịch sử bản địa',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._culturalHighlights.map((cul) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.bookmark_outline, size: 16, color: AppColors.summitGold),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cul,
                                      style: const TextStyle(fontSize: 13, color: AppColors.editorialInk, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],

                        // THỜI TIẾT VÀ KHÍ HẬU THỜI GIAN THỰC TẠI ĐIỂM ĐẾN
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.cloud_outlined, size: 18, color: AppColors.editorialTerracotta),
                                SizedBox(width: 8),
                                Text(
                                  'Thời tiết và khí hậu thời gian thực',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, size: 12, color: AppColors.summitGold),
                                  SizedBox(width: 4),
                                  Text(
                                    'OPEN-METEO LIVE',
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.editorialPine),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_isLoadingWeather)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.editorialBorder),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.editorialPine),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Đang kết nối trạm khí tượng vệ tinh...',
                                  style: TextStyle(fontSize: 12, color: AppColors.editorialMuted),
                                ),
                              ],
                            ),
                          )
                        else if (_liveWeather != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.editorialBorder),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_liveWeather!.temperature.round()}°C',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.editorialInk,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          _liveWeather!.weatherDescription,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.editorialPine,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        _buildWeatherMiniStat(
                                          icon: Icons.air,
                                          label: 'Gió',
                                          value: '${_liveWeather!.windSpeed.round()} km/h',
                                        ),
                                        const SizedBox(width: 14),
                                        _buildWeatherMiniStat(
                                          icon: Icons.water_drop_outlined,
                                          label: 'Mưa',
                                          value: '${_liveWeather!.precipitationProb}%',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (_liveWeather!.hasFlashFloodRisk ||
                                    _liveWeather!.hasHypothermiaRisk ||
                                    _liveWeather!.hasThunderstormRisk) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.editorialTerracotta.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.editorialTerracotta.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.editorialTerracotta),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _liveWeather!.hasThunderstormRisk
                                                ? 'Cảnh báo: Có nguy cơ giông sét cực đoan!'
                                                : (_liveWeather!.hasFlashFloodRisk
                                                    ? 'Cảnh báo: Nguy cơ lũ quét suối lớn!'
                                                    : 'Lưu ý: Nguy cơ hạ thân nhiệt về đêm do gió lạnh!'),
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.editorialTerracotta),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        // THỜI ĐIỂM LÝ TƯỞNG NHẤT (CHUẨN HÓA THỜI GIAN THỰC)
                        if (_seasons.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Thời điểm lý tưởng nhất',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              final nowMonth = DateTime.now().month;
                              final isCurrentIdeal = _seasons.any((s) => int.tryParse(s) == nowMonth);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isCurrentIdeal)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.summitGold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.summitGold),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.stars_rounded, size: 16, color: AppColors.summitGold),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Thời điểm vàng: Tháng $nowMonth này đang là mùa đẹp nhất để trải nghiệm!',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _seasons.map((s) {
                                      final monthNum = int.tryParse(s);
                                      final isNow = monthNum == nowMonth;
                                      final label = monthNum != null ? 'Tháng $monthNum' : s;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isNow
                                              ? AppColors.summitGold.withValues(alpha: 0.15)
                                              : AppColors.editorialSurface,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isNow ? AppColors.summitGold : AppColors.editorialBorder,
                                            width: isNow ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isNow ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                                              size: 14,
                                              color: isNow ? AppColors.summitGold : AppColors.editorialTerracotta,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isNow ? AppColors.editorialInk : AppColors.editorialInk,
                                                fontWeight: isNow ? FontWeight.w800 : FontWeight.w500,
                                              ),
                                            ),
                                            if (isNow) ...[
                                              const SizedBox(width: 4),
                                              const Text(
                                                '(Hiện tại)',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.summitGold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],

                        // TIỆN ÍCH DÃ NGOẠI XUNG QUANH TỪ OPENSTREETMAP (LIVE POI)
                        if (_nearbyPois.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tiện ích thực địa lân cận (OSM)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                              ),
                              Text(
                                _isLoadingPois
                                    ? 'Đang quét bản đồ...'
                                    : '${_nearbyPois.length} điểm trong 10km',
                                style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _nearbyPois.take(8).length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final poi = _nearbyPois[i];
                                return Container(
                                  width: 160,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.editorialSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.editorialBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        poi['name'] as String? ?? 'Điểm dã ngoại',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        poi['type'] as String? ?? 'Tiện ích',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10.5, color: AppColors.editorialMuted),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ] else if (_selectedTab == 1) ...[
                        const Text(
                          'Lộ trình các chặng thực tế',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 12),
                        if (_route != null && _route!.stages.isNotEmpty)
                          ..._route!.stages.map((stage) => _buildTrailStep(
                                '${stage.stageNumber}',
                                stage.title,
                                stage.description,
                                stage.distanceKm != null ? '${stage.distanceKm} km' : '--',
                                stage.terrainType,
                              ))
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.editorialSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.editorialBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.editorialPine, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Điểm đến này không có cung đường trekking cố định. Bạn có thể tự do dã ngoại, chèo SUP hoặc cắm trại.',
                                    style: TextStyle(fontSize: 13, color: AppColors.editorialInk),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else ...[
                        const Text(
                          'Quy tắc an toàn sinh tồn thực địa',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                        const SizedBox(height: 12),
                        if (_safety != null) ...[
                          _buildSafetyNotice(
                            Icons.water_drop,
                            AppColors.editorialPine,
                            'Khuyến cáo nguồn nước',
                            _safety!.waterAdvice,
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyNotice(
                            Icons.signal_cellular_alt,
                            AppColors.editorialTerracotta,
                            'Tình trạng sóng di động',
                            _safety!.mobileCoverageSummary,
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyNotice(
                            Icons.warning_amber_rounded,
                            AppColors.emergencyRed,
                            'Hiểm họa cần đề phòng',
                            _safety!.primaryHazards.join(' • '),
                          ),
                          const SizedBox(height: 10),
                          _buildSafetyNotice(
                            Icons.phone_in_talk,
                            AppColors.editorialPine,
                            'Liên hệ cứu hộ khẩn cấp',
                            _safety!.emergencyContactInfo,
                          ),
                        ] else
                          _buildSafetyNotice(
                            Icons.shield_outlined,
                            AppColors.editorialPine,
                            'An toàn chung',
                            'Luôn thông báo cho người thân trước khi khởi hành và mang theo bản đồ ngoại tuyến.',
                          ),
                      ],

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.editorialSurface,
                border: const Border(top: BorderSide(color: AppColors.editorialBorder)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  BouncingButton(
                    onTap: _handleToggleFav,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _fav ? AppColors.emergencyRed.withValues(alpha: 0.1) : AppColors.editorialSurfaceSubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _fav ? AppColors.emergencyRed : AppColors.editorialBorder,
                        ),
                      ),
                      child: Icon(
                        _fav ? Icons.favorite : Icons.favorite_border,
                        color: _fav ? AppColors.emergencyRed : AppColors.editorialInk,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_isInTrip)
                    Expanded(
                      child: BouncingButton(
                        onTap: _handleAddToTrip,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.editorialPine,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.editorialPine.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Thêm Vào Chuyến Đi',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      flex: 6,
                      child: BouncingButton(
                        onTap: _navigateToMap,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.editorialPine,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.editorialPine.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.navigation_outlined, color: Colors.white, size: 19),
                              SizedBox(width: 6),
                              Text(
                                'Chỉ Đường Bản Đồ',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: BouncingButton(
                        onTap: _navigateToTripPlanner,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.editorialPine, width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, color: AppColors.editorialPine, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Xem Lịch Trình',
                                style: TextStyle(color: AppColors.editorialPine, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFact(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.editorialPine),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.editorialInk)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.editorialMuted)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: AppColors.editorialBorderSubtle);
  }

  Widget _buildTabButton(int index, String title) {
    final isSel = _selectedTab == index;
    return Expanded(
      child: BouncingButton(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.editorialPine : AppColors.editorialSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? AppColors.editorialPine : AppColors.editorialBorder),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                color: isSel ? Colors.white : AppColors.editorialInk,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailStep(String stepNumber, String title, String desc, String distance, [String? terrain]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.editorialSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.editorialBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.editorialPine,
              child: Text(
                stepNumber,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.editorialSurfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          distance,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.editorialPine),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.editorialMuted, height: 1.4)),
                  if (terrain != null && terrain.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.terrain_outlined, size: 12, color: AppColors.editorialTerracotta),
                        const SizedBox(width: 4),
                        Text(
                          terrain,
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.editorialTerracotta),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyNotice(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.editorialSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.editorialBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppColors.editorialMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.editorialPine),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.editorialInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.editorialMuted),
        ),
      ],
    );
  }
}
