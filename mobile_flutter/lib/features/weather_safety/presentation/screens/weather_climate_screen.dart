import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/safety/services/local_emergency_service.dart';

class WeatherClimateScreen extends StatefulWidget {
  final String? initialDestinationId;

  const WeatherClimateScreen({super.key, this.initialDestinationId});

  @override
  State<WeatherClimateScreen> createState() => _WeatherClimateScreenState();
}

class _WeatherClimateScreenState extends State<WeatherClimateScreen> {
  // Đồng hồ thời gian thực (Real-time Clock)
  Timer? _liveClockTimer;
  DateTime _currentTime = DateTime.now();

  // Dữ liệu Vị trí & Khí hậu Hiện Tại (GPS)
  OutdoorWeather? _currentWeather;
  Position? _realPosition;
  bool _isGpsLoading = true;
  String _gpsAreaName = 'Đang dò vị trí GPS...';

  // Dữ liệu Khí hậu Điểm Đến Đích (Destination)
  OutdoorWeather? _destWeather;
  bool _isLoadingDestWeather = true;
  String _targetDestinationName = 'Đỉnh Tà Năng (Lâm Đồng)';
  double _targetDestLat = 11.6420;
  double _targetDestLng = 108.4230;

  int _selectedTargetTab = 0; // 0: Vị trí hiện tại (GPS), 1: Điểm đến đích

  double get _currentLat => _realPosition?.latitude ?? 11.9404;
  double get _currentLng => _realPosition?.longitude ?? 108.4583;

  String get _liveTimeString {
    final h = _currentTime.hour.toString().padLeft(2, '0');
    final m = _currentTime.minute.toString().padLeft(2, '0');
    final s = _currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _liveDateString {
    final weekdays = ['CN', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    final weekday = weekdays[_currentTime.weekday % 7];
    final day = _currentTime.day.toString().padLeft(2, '0');
    final month = _currentTime.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month';
  }

  @override
  void initState() {
    super.initState();
    _startLiveClock();
    _detectLiveGpsAndWeather();
    _loadDestinationWeather();
  }

  void _startLiveClock() {
    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _liveClockTimer?.cancel();
    super.dispose();
  }

  Future<void> _detectLiveGpsAndWeather() async {
    setState(() => _isGpsLoading = true);
    try {
      final pos = await LocationService.getDetailedPosition();
      if (pos != null && mounted) {
        setState(() {
          _realPosition = pos;
          _isGpsLoading = false;
        });

        final weather = await WeatherService.getForecast(pos.latitude, pos.longitude);
        final area = await LocalEmergencyService.resolveEmergencyContacts(pos.latitude, pos.longitude);

        if (mounted) {
          setState(() {
            _currentWeather = weather;
            _gpsAreaName = area.areaName;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      final weather = await WeatherService.getForecast(_currentLat, _currentLng);
      final area = await LocalEmergencyService.resolveEmergencyContacts(_currentLat, _currentLng);
      setState(() {
        _isGpsLoading = false;
        _currentWeather = weather;
        _gpsAreaName = area.areaName;
      });
    }
  }

  Future<void> _loadDestinationWeather() async {
    setState(() => _isLoadingDestWeather = true);
    try {
      final tripIds = await StorageService.getTripDestinations();
      final allDest = await ExploreLocalDataSource().getSeedDestinations();
      final selectedId = widget.initialDestinationId ?? await StorageService.getSelectedTripDestination();

      var target = allDest.firstWhere(
        (d) => d.id == selectedId,
        orElse: () => (tripIds.isNotEmpty
            ? allDest.firstWhere((d) => d.id == tripIds.first, orElse: () => allDest.first)
            : allDest.first),
      );

      _targetDestinationName = target.name;
      _targetDestLat = target.centerLatitude ?? 11.6420;
      _targetDestLng = target.centerLongitude ?? 108.4230;

      final w = await WeatherService.getForecast(_targetDestLat, _targetDestLng);
      if (mounted) {
        setState(() {
          _destWeather = w;
          _isLoadingDestWeather = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDestWeather = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViewingCurrent = _selectedTargetTab == 0;
    final activeWeather = isViewingCurrent ? _currentWeather : _destWeather;
    final isLoading = isViewingCurrent ? _isGpsLoading : _isLoadingDestWeather;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Thời Tiết Và Khí Hậu',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.emerald, size: 20),
            tooltip: 'Làm mới thời tiết',
            onPressed: isViewingCurrent ? _detectLiveGpsAndWeather : _loadDestinationWeather,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 12),
          children: [
            // Thanh chuyển đổi: Vị Trí Của Bạn (GPS) vs Điểm Đến Trekking
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceBase,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTargetTab = 0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isViewingCurrent ? AppColors.emerald : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 14,
                              color: isViewingCurrent ? Colors.black : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Vị Trí Hiện Tại',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isViewingCurrent ? FontWeight.w800 : FontWeight.w600,
                                color: isViewingCurrent ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTargetTab = 1);
                        if (_destWeather == null) _loadDestinationWeather();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: !isViewingCurrent ? AppColors.summitGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag,
                              size: 14,
                              color: !isViewingCurrent ? Colors.black : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Đích: $_targetDestinationName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: !isViewingCurrent ? FontWeight.w800 : FontWeight.w600,
                                  color: !isViewingCurrent ? Colors.black : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card Khí Hậu Lớn (Hero Card)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceBase,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isViewingCurrent
                      ? AppColors.emerald.withValues(alpha: 0.5)
                      : AppColors.summitGold.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isViewingCurrent ? AppColors.neonGreen : AppColors.summitGold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isViewingCurrent ? 'KHÍ HẬU VỊ TRÍ BẠN (GPS)' : 'KHÍ HẬU TẠI ĐÍCH ĐẾN TREKKING',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.satellite_alt,
                              size: 12,
                              color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Open-Meteo Vệ Tinh',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tên địa điểm
                  Text(
                    isViewingCurrent
                        ? '$_gpsAreaName (${_currentLat.toStringAsFixed(3)}, ${_currentLng.toStringAsFixed(3)})'
                        : _targetDestinationName,
                    style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // ĐỒNG HỒ SỐ THỜI GIAN THỰC (Real-time Clock Badge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 13, color: AppColors.alpineCyan),
                            const SizedBox(width: 5),
                            Text(
                              isViewingCurrent ? 'Đồng hồ GPS hiện tại' : 'Đồng hồ điểm đến',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_liveTimeString  •  $_liveDateString',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.summitGold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.emerald),
                      ),
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${activeWeather?.temperature.round() ?? 18}°C',
                              style: AppTypography.displayHero.copyWith(fontSize: 42),
                            ),
                            Text(
                              activeWeather?.weatherDescription ?? 'Ít mây / Mát mẻ',
                              style: AppTypography.titleMedium.copyWith(
                                color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cảm giác như ${activeWeather?.apparentTemperature.round() ?? 18}°C',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        // Icon ngày/đêm chính xác (đêm hiện trăng)
                        Icon(
                          activeWeather?.iconInfo.icon ?? Icons.nightlight_round,
                          size: 54,
                          color: activeWeather?.iconInfo.color ?? AppColors.tacticalOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 14),

                    // 4 Weather Gauges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TacticalBadge(
                          icon: Icons.air,
                          label: 'Tốc độ gió',
                          value: '${activeWeather?.windSpeed.round() ?? 15} km/h',
                        ),
                        Container(width: 1, height: 24, color: AppColors.borderSubtle),
                        TacticalBadge(
                          icon: Icons.speed,
                          label: 'Gió giật',
                          value: '${activeWeather?.windGusts.round() ?? 28} km/h',
                          iconColor: AppColors.tacticalOrange,
                        ),
                        Container(width: 1, height: 24, color: AppColors.borderSubtle),
                        TacticalBadge(
                          icon: Icons.water_drop,
                          label: 'Khả năng mưa',
                          value: '${activeWeather?.precipitationProb ?? 30}%',
                          iconColor: AppColors.alpineCyan,
                        ),
                        Container(width: 1, height: 24, color: AppColors.borderSubtle),
                        TacticalBadge(
                          icon: Icons.opacity,
                          label: 'Độ ẩm',
                          value: '${activeWeather?.humidity ?? 65}%',
                          iconColor: AppColors.emerald,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bảng So Sánh Khí Hậu: Hiện Tại vs Đích Đến
            if (_currentWeather != null && _destWeather != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.compare_arrows, size: 16, color: AppColors.alpineCyan),
                        SizedBox(width: 6),
                        Text(
                          'SO SÁNH THỜI TIẾT VÀ KHÍ HẬU (HIỆN TẠI VS ĐÍCH ĐẾN)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.alpineCyan,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vị trí của bạn', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(_currentWeather!.iconInfo.icon, size: 14, color: _currentWeather!.iconInfo.color),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${_currentWeather!.temperature.round()}°C • ${_currentWeather!.weatherDescription}',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: AppColors.borderSubtle),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đích: $_targetDestinationName', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(_destWeather!.iconInfo.icon, size: 14, color: _destWeather!.iconInfo.color),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${_destWeather!.temperature.round()}°C • ${_destWeather!.weatherDescription}',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.summitGold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Severe Weather Warnings Box
            if (activeWeather?.hasHypothermiaRisk == true) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange.withValues(alpha: 0.1),
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.tacticalOrange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.ac_unit, color: AppColors.tacticalOrange, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isViewingCurrent ? 'CẢNH BÁO NGUY CƠ HẠ THÂN NHIỆT TẠI CHỖ' : 'CẢNH BÁO LẠNH & GIÓ GIẬT TẠI ĐÍCH ĐẾN',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Nhiệt độ vùng cao hạ dưới 14°C kèm gió mạnh. Hãy mang theo áo khoác cản gió, túi ngủ chuyên dụng và bổ sung đủ calo.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // DỰ BÁO TỪNG GIỜ (24H TỚI - REAL-TIME)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isViewingCurrent ? 'Dự Báo Từng Giờ (24h Tới)' : 'Dự Báo Từng Giờ Tại Đích (24h Tới)',
                  style: AppTypography.headlineMedium.copyWith(fontSize: 15),
                ),
                const Text(
                  'Chuỗi giờ thực',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (activeWeather != null && activeWeather.hourly.isNotEmpty)
              SizedBox(
                height: 118,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeWeather.hourly.length,
                  itemBuilder: (context, index) {
                    final item = activeWeather.hourly[index];
                    return _buildHourlyForecastCard(item);
                  },
                ),
              )
            else
              Container(
                height: 80,
                alignment: Alignment.center,
                child: const Text('Đang cập nhật chuỗi dữ liệu dự báo theo giờ...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),

            const SizedBox(height: 20),

            // DỰ BÁO 7 NGÀY SẮP TỚI (DAILY FORECAST)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isViewingCurrent ? 'Dự Báo 7 Ngày Tới (Vị Trí Bạn)' : 'Dự Báo 7 Ngày Tới (Điểm Đến)',
                  style: AppTypography.headlineMedium.copyWith(fontSize: 15),
                ),
                const Text(
                  'Hàng ngày',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (activeWeather != null && activeWeather.daily.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    for (int i = 0; i < activeWeather.daily.length; i++) ...[
                      _buildDailyForecastRow(activeWeather.daily[i]),
                      if (i < activeWeather.daily.length - 1)
                        const Divider(height: 14, color: AppColors.borderSubtle),
                    ],
                  ],
                ),
              )
            else
              Container(
                height: 80,
                alignment: Alignment.center,
                child: const Text('Đang tải dữ liệu dự báo 7 ngày tới...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),

            const SizedBox(height: 20),

            // GỢI Ý CHUẨN BỊ ĐỒ DÃ NGOẠI THÔNG MINH
            if (activeWeather != null) ...[
              Text(
                'Checklist Đồ Dã Ngoại Đề Xuất Theo Khí Hậu',
                style: AppTypography.headlineMedium.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: WeatherService.generateSmartChecklist(activeWeather).map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.emerald),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item, style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastCard(HourlyWeather item) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(item.hourLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Icon(item.iconInfo.icon, size: 22, color: item.iconInfo.color),
          Text('${item.temperature.round()}°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 9, color: AppColors.alpineCyan),
              const SizedBox(width: 2),
              Text('${item.precipitationProb}%', style: const TextStyle(fontSize: 10, color: AppColors.alpineCyan, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastRow(DailyWeather item) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            item.dayLabel,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        Icon(item.iconInfo.icon, size: 18, color: item.iconInfo.color),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop, size: 10, color: AppColors.alpineCyan),
            const SizedBox(width: 2),
            Text('${item.precipitationProbMax}%', style: const TextStyle(fontSize: 11, color: AppColors.alpineCyan, fontWeight: FontWeight.w600)),
          ],
        ),
        const Spacer(),
        Text(
          '${item.tempMin.round()}°',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.alpineCyan, AppColors.summitGold],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${item.tempMax.round()}°C',
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
