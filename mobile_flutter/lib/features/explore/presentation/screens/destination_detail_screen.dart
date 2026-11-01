import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/models/outdoor_image.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/editorial_image.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';
import 'package:mobile_flutter/features/explore/domain/entities/safety_guideline.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination? destination;
  final Map<String, dynamic>? spot;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const DestinationDetailScreen({
    super.key,
    this.destination,
    this.spot,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : assert(destination != null || spot != null, 'Either destination or spot must be provided');

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late bool _fav;
  int _selectedTab = 0; // 0: Tổng quan, 1: Lộ trình, 2: An toàn

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
  }

  void _handleToggleFav() {
    setState(() => _fav = !_fav);
    widget.onToggleFavorite();
    HapticFeedback.mediumImpact();
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
  String get _distance => widget.destination?.distanceDisplay ?? widget.spot?['distance'] as String? ?? '--';
  String get _elevation => widget.destination?.elevationDisplay ?? widget.spot?['elevation'] as String? ?? '--';
  List<String> get _seasons => widget.destination?.bestTravelSeasons ?? [];
  bool get _isVerified => widget.destination?.isVerified ?? false;
  TrekkingRoute? get _route => widget.destination?.route;
  SafetyGuideline? get _safety => _route?.safety;

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
                            _buildFact(Icons.straighten, 'Cự ly', _distance),
                            _buildDivider(),
                            _buildFact(Icons.landscape, 'Độ cao', _elevation),
                            _buildDivider(),
                            _buildFact(
                              Icons.schedule,
                              'Thời gian',
                              _route?.estimatedDurationDays != null
                                  ? '${_route!.estimatedDurationDays} ngày'
                                  : '1 ngày',
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
                          style: const TextStyle(fontSize: 14, color: AppColors.editorialInk, height: 1.5),
                        ),
                        if (_seasons.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Thời điểm lý tưởng nhất',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _seasons.map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.editorialTerracotta),
                                  const SizedBox(width: 6),
                                  Text(s, style: const TextStyle(fontSize: 12, color: AppColors.editorialInk, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )).toList(),
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
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm $_title vào Kế hoạch Chuyến đi!'),
                            backgroundColor: AppColors.editorialPine,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
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
                            Icon(Icons.route, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Lập Kế Hoạch Chuyến Đi',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
}
