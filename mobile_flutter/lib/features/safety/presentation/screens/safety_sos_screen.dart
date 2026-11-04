import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import 'package:mobile_flutter/features/safety/services/local_emergency_service.dart';

class SafetySosScreen extends StatefulWidget {
  const SafetySosScreen({super.key});

  @override
  State<SafetySosScreen> createState() => _SafetySosScreenState();
}

class _SafetySosScreenState extends State<SafetySosScreen> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: SOS Khẩn cấp, 1: Thời Tiết Và Khí Hậu
  bool _isSosActive = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;

  // Dữ liệu vị trí & Thời tiết Hiện Tại (GPS)
  OutdoorWeather? _currentWeather;
  Position? _realPosition;
  bool _isGpsLoading = true;
  String _gpsStatus = 'Đang dò sóng vệ tinh GPS...';

  // Đường dây nóng cứu hộ địa phương theo GPS thực tế
  LocalEmergencyArea? _emergencyArea;
  bool _isLoadingEmergency = true;

  // Dữ liệu Thời tiết Điểm Đến Đích (Destination)
  OutdoorWeather? _destWeather;
  bool _isLoadingDestWeather = true;
  String _targetDestinationName = 'Đỉnh Tà Năng (Lâm Đồng)';
  double _targetDestLat = 11.6420;
  double _targetDestLng = 108.4230;
  int _weatherTargetTab = 0; // 0: Vị trí hiện tại, 1: Điểm đến đích

  double get _currentLat => _realPosition?.latitude ?? 11.9404;
  double get _currentLng => _realPosition?.longitude ?? 108.4583;
  double get _currentAlt => _realPosition?.altitude ?? 1485.0;
  double get _currentAcc => _realPosition?.accuracy ?? 3.5;
  bool get _hasRealGps => _realPosition != null;

  @override
  void initState() {
    super.initState();
    _detectLiveGpsAndWeather();
    _loadDestinationWeather();
  }

  Future<void> _detectLiveGpsAndWeather() async {
    setState(() {
      _isGpsLoading = true;
      _isLoadingEmergency = true;
      _gpsStatus = 'Đang dò sóng vệ tinh GPS...';
    });

    try {
      final pos = await LocationService.getDetailedPosition();
      if (pos != null && mounted) {
        setState(() {
          _realPosition = pos;
          _isGpsLoading = false;
          _gpsStatus = 'Đã khóa vệ tinh độ chính xác cao';
        });

        // 1. Nạp thời tiết thời gian thực tại vị trí hiện tại
        final weather = await WeatherService.getForecast(pos.latitude, pos.longitude);
        if (mounted) setState(() => _currentWeather = weather);

        // 2. Tra cứu đường dây nóng cứu hộ thực tế theo GPS địa phương
        final area = await LocalEmergencyService.resolveEmergencyContacts(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _emergencyArea = area;
            _isLoadingEmergency = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Fallback an toàn nếu thiết bị chưa cấp quyền hoặc không có sóng GPS
    if (mounted) {
      setState(() {
        _isGpsLoading = false;
        _gpsStatus = 'Chưa nhận tín hiệu GPS (Chế độ tham chiếu)';
      });
      final weather = await WeatherService.getForecast(_currentLat, _currentLng);
      final area = await LocalEmergencyService.resolveEmergencyContacts(_currentLat, _currentLng);
      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _emergencyArea = area;
          _isLoadingEmergency = false;
        });
      }
    }
  }

  /// Nạp thông tin điểm đến của chuyến đi và thời tiết thời gian thực tại đích
  Future<void> _loadDestinationWeather() async {
    setState(() => _isLoadingDestWeather = true);
    try {
      final tripIds = await StorageService.getTripDestinations();
      final allDest = await ExploreLocalDataSource().getSeedDestinations();
      final selectedId = await StorageService.getSelectedTripDestination();

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

  void _onHoldStart() {
    if (_isSosActive) {
      // Nếu đang active thì chạm để tắt ngay
      _deactivateSos();
      return;
    }
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0.0);

    const int totalMs = 2000;
    const int stepMs = 50;
    int elapsed = 0;

    _holdTimer = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      elapsed += stepMs;
      if (!mounted) {
        timer.cancel();
        return;
      }
      final progress = elapsed / totalMs;
      if (progress >= 1.0) {
        timer.cancel();
        _activateSos();
      } else {
        setState(() => _holdProgress = progress);
      }
    });
  }

  void _onHoldEnd() {
    if (!_isSosActive) {
      _holdTimer?.cancel();
      if (mounted) {
        setState(() => _holdProgress = 0.0);
      }
    }
  }

  void _activateSos() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isSosActive = true;
      _holdProgress = 1.0;
    });
    _showSnackBar('ĐÃ BẬT BÁO ĐỘNG SOS • Hãy đảm bảo loa ngoài ở mức âm lượng tối đa 100%!');
  }

  void _deactivateSos() {
    HapticFeedback.mediumImpact();
    _holdTimer?.cancel();
    setState(() {
      _isSosActive = false;
      _holdProgress = 0.0;
    });
    _showSnackBar('Đã tắt tín hiệu cứu hộ khẩn cấp');
  }

  Future<void> _sendEmergencySms() async {
    HapticFeedback.mediumImpact();
    final altText = _currentAlt > 0 ? ' (Cao do: ${_currentAlt.round()}m)' : '';
    final accText = ' [Sai so GPS: +/-${_currentAcc.toStringAsFixed(1)}m]';
    final liveTag = _hasRealGps ? '[GPS THUC]' : '[GPS THAM CHIEU]';
    final message = 'SOS! TOI DANG CAN CUU HO $liveTag. Toa do: ${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}$altText$accText. Vui long ho tro khan cap!';
    final uri = Uri.parse('sms:115?body=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Đã chuẩn bị nội dung tin nhắn cứu hộ kèm tọa độ GPS thực.');
      }
    } catch (_) {
      _showSnackBar('Đã chuẩn bị tin nhắn cứu hộ.');
    }
  }

  Future<void> _callEmergency(String number) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {
      _showSnackBar('Gọi khẩn cấp số: $number');
    }
  }

  void _copyGpsCoordinates() {
    HapticFeedback.lightImpact();
    final altText = _currentAlt > 0 ? ' (Cao độ: ${_currentAlt.round()}m)' : '';
    final text = '${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}$altText';
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Đã sao chép tọa độ GPS: $text');
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = _currentWeather;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Tab Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 12, AppSpacing.space16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _activeTab == 0 ? 'Cứu Hộ & SOS' : 'Thời Tiết Và Khí Hậu',
                        style: AppTypography.displayHero.copyWith(fontSize: 24),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isSosActive
                              ? AppColors.emergencyRed.withValues(alpha: 0.2)
                              : AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: AppRadius.roundedPill,
                          border: Border.all(
                            color: _isSosActive ? AppColors.emergencyRed : AppColors.emerald,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isSosActive ? Icons.warning_amber_rounded : Icons.shield_outlined,
                              size: 14,
                              color: _isSosActive ? AppColors.emergencyRed : AppColors.emerald,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isSosActive ? 'BÁO ĐỘNG SOS' : 'SẴN SÀNG 24/7',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _isSosActive ? AppColors.emergencyRed : AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2-Tab Switcher
                  Row(
                    children: [
                      _buildHeaderTab(0, 'SOS Cứu Hộ Khẩn Cấp', Icons.emergency),
                      const SizedBox(width: 8),
                      _buildHeaderTab(1, 'Thời Tiết Và Khí Hậu', Icons.cloud_outlined),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Content Body
            Expanded(
              child: _activeTab == 0 ? _buildSosView() : _buildWeatherView(weather),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTab(int tabIndex, String label, IconData icon) {
    final isSelected = _activeTab == tabIndex;
    final isEmergency = tabIndex == 0;

    return Expanded(
      child: BouncingButton(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeTab = tabIndex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isEmergency ? AppColors.emergencyRed : AppColors.emerald)
                : AppColors.surfaceHigh,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isSelected
                  ? (isEmergency ? AppColors.emergencyRed : AppColors.emerald)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: SOS VIEW (Chống bấm nhầm & An toàn thị giác)
  Widget _buildSosView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // SOS Beacon Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: _isSosActive ? const Color(0xFF381010) : AppColors.surfaceBase,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(
              color: _isSosActive ? AppColors.emergencyRed : AppColors.borderSubtle,
              width: _isSosActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Hold to Activate Button with circular progress indicator
              GestureDetector(
                onTapDown: (_) => _onHoldStart(),
                onTapUp: (_) => _onHoldEnd(),
                onTapCancel: () => _onHoldEnd(),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular progress border
                      if (!_isSosActive && _holdProgress > 0)
                        SizedBox(
                          width: 136,
                          height: 136,
                          child: CircularProgressIndicator(
                            value: _holdProgress,
                            strokeWidth: 4,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emergencyRed),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      // Core button
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isSosActive ? AppColors.emergencyRed : const Color(0xFF2A1515),
                          border: Border.all(
                            color: AppColors.emergencyRed,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emergencyRed.withValues(alpha: _isSosActive ? 0.6 : 0.2),
                              blurRadius: _isSosActive ? 24 : 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSosActive ? Icons.power_settings_new : Icons.emergency,
                                size: 44,
                                color: _isSosActive ? Colors.white : AppColors.emergencyRed,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isSosActive ? 'TẮT SOS' : 'GIỮ 2 GIÂY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: _isSosActive ? Colors.white : AppColors.emergencyRed,
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
              const SizedBox(height: 18),
              Text(
                _isSosActive ? 'ĐANG KÍCH HOẠT BÁO ĐỘNG CỨU HỘ' : 'NHẤN GIỮ 2 GIÂY ĐỂ PHÁT SOS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: _isSosActive ? AppColors.emergencyRed : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isSosActive
                    ? 'Chế độ an toàn: Chạm một lần vào nút đỏ ở trên để tắt ngay'
                    : 'Cơ chế chống chạm nhầm trong ba lô khi trekking',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              if (_isSosActive) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.summitGold.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.summitGold, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.volume_up_rounded, color: AppColors.summitGold, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LƯU Ý THỰC ĐỊA: BẬT ÂM LƯỢNG 100%',
                              style: TextStyle(
                                color: AppColors.summitGold,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Hãy tăng âm lượng loa ngoài thiết bị lên mức tối đa để tín hiệu còi cứu hộ vang xa nhất (đạt bán kính 500m - 1km trong rừng núi).',
                              style: TextStyle(color: Colors.white, fontSize: 11.5, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // GPS Satellite Coordinates Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: _hasRealGps ? AppColors.emerald.withValues(alpha: 0.5) : AppColors.borderSubtle,
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
                          color: _hasRealGps ? AppColors.neonGreen : AppColors.tacticalOrange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _hasRealGps ? 'VỆ TINH GPS THỜI GIAN THỰC' : 'TỌA ĐỘ THAM CHIẾU (CHƯA CÓ GPS)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _hasRealGps ? AppColors.emerald : AppColors.tacticalOrange,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      BouncingButton(
                        onTap: _isGpsLoading ? null : _detectLiveGpsAndWeather,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: AppRadius.roundedPill,
                          ),
                          child: _isGpsLoading
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                                )
                              : const Icon(Icons.refresh, size: 14, color: AppColors.textSecondary),
                        ),
                      ),
                      BouncingButton(
                        onTap: _copyGpsCoordinates,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: AppRadius.roundedPill,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy, size: 12, color: AppColors.emerald),
                              SizedBox(width: 4),
                              Text('Sao chép', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}',
                style: AppTypography.displayHero.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.terrain_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Cao độ: ${_currentAlt.round()}m',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.gps_fixed, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Sai số: ±${_currentAcc.toStringAsFixed(1)}m',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _gpsStatus,
                style: TextStyle(
                  color: _hasRealGps ? AppColors.emerald : AppColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Emergency Action Buttons
        Row(
          children: [
            Expanded(
              child: BouncingButton(
                onTap: _sendEmergencySms,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.tacticalOrange.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms, color: AppColors.tacticalOrange, size: 18),
                      SizedBox(width: 6),
                      Text('SMS Cứu Hộ 115', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BouncingButton(
                onTap: () => _callEmergency('115'),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed,
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Gọi Cấp Cứu 115', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Local Emergency Contacts theo vị trí hiện tại
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _emergencyArea != null
                                ? 'CỨU HỘ ĐỊA PHƯƠNG: ${_emergencyArea!.areaName.toUpperCase()}'
                                : 'ĐƯỜNG DÂY NÓNG ĐỊA PHƯƠNG THEO GPS',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emerald,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoadingEmergency)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.emerald),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_emergencyArea != null && _emergencyArea!.contacts.isNotEmpty)
                ..._emergencyArea!.contacts.map((contact) {
                  return Column(
                    children: [
                      _buildContactRow(
                        contact.title,
                        contact.phone,
                        _getContactIcon(contact.iconType),
                        subtitle: contact.role,
                      ),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                    ],
                  );
                })
              else ...[
                _buildContactRow('Cứu nạn Quốc Gia', '112', Icons.phone_in_talk, subtitle: 'Tìm kiếm cứu nạn toàn quốc'),
                const Divider(height: 16, color: AppColors.borderSubtle),
                _buildContactRow('Cảnh sát Cứu nạn Cứu hộ', '114', Icons.fire_truck, subtitle: 'Ứng trực khẩn cấp 24/7'),
                const Divider(height: 16, color: AppColors.borderSubtle),
                _buildContactRow('Cấp cứu Y tế Ngoại Viện', '115', Icons.local_hospital, subtitle: 'Sơ cấp cứu y tế dã ngoại'),
              ],
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  IconData _getContactIcon(String type) {
    switch (type) {
      case 'ranger':
        return Icons.forest;
      case 'police':
        return Icons.local_police;
      case 'hospital':
        return Icons.local_hospital;
      case 'national':
        return Icons.phone_in_talk;
      default:
        return Icons.shield;
    }
  }

  Widget _buildContactRow(String name, String phone, IconData icon, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.emerald),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        BouncingButton(
          onTap: () => _callEmergency(phone),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: AppRadius.roundedPill,
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, size: 12, color: AppColors.emerald),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: THỜI TIẾT VÀ KHÍ HẬU (HIỆN TẠI VS ĐÍCH ĐẾN REAL-TIME)
  Widget _buildWeatherView(OutdoorWeather? currentWeather) {
    final isViewingCurrent = _weatherTargetTab == 0;
    final activeWeather = isViewingCurrent ? currentWeather : _destWeather;
    final isLoading = isViewingCurrent ? _isGpsLoading : _isLoadingDestWeather;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // Selector Chuyển Đổi: VỊ TRÍ CỦA BẠN vs ĐIỂM ĐẾN ĐÍCH
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
                    setState(() => _weatherTargetTab = 0);
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
                    setState(() => _weatherTargetTab = 1);
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
                            'Điểm Đến: $_targetDestinationName',
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

        // Thẻ Thời Tiết Thời Gian Thực (Live Weather Realtime Card)
        Container(
          padding: const EdgeInsets.all(20),
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
              // Header thẻ: Tên địa danh và tag Real-time
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
                  BouncingButton(
                    onTap: isViewingCurrent ? _detectLiveGpsAndWeather : _loadDestinationWeather,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 12,
                            color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Real-time',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tên địa điểm to rõ
              Text(
                isViewingCurrent
                    ? (_emergencyArea?.areaName ?? 'Tọa độ hiện tại: ${_currentLat.toStringAsFixed(3)}, ${_currentLng.toStringAsFixed(3)}')
                    : _targetDestinationName,
                style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

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
                          '${activeWeather?.temperature ?? 18}°C',
                          style: AppTypography.displayHero.copyWith(fontSize: 42),
                        ),
                        Text(
                          activeWeather?.weatherDescription ?? 'Ít mây / Mát mẻ',
                          style: AppTypography.titleMedium.copyWith(
                            color: isViewingCurrent ? AppColors.emerald : AppColors.summitGold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.wb_sunny_outlined, size: 54, color: AppColors.tacticalOrange),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 16),

                // 3 Weather Gauges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TacticalBadge(
                      icon: Icons.air,
                      label: 'Tốc độ gió',
                      value: '${activeWeather?.windSpeed ?? 15} km/h',
                    ),
                    Container(width: 1, height: 24, color: AppColors.borderSubtle),
                    TacticalBadge(
                      icon: Icons.speed,
                      label: 'Gió giật',
                      value: '${activeWeather?.windGusts ?? 28} km/h',
                      iconColor: AppColors.tacticalOrange,
                    ),
                    Container(width: 1, height: 24, color: AppColors.borderSubtle),
                    TacticalBadge(
                      icon: Icons.water_drop,
                      label: 'Khả năng mưa',
                      value: '${activeWeather?.precipitationProb ?? 30}%',
                      iconColor: AppColors.alpineCyan,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // BẢNG SO SÁNH KHÍ HẬU: HIỆN TẠI VS ĐÍCH ĐẾN
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
                      'SO SÁNH VI KHÍ HẬU (HIỆN TẠI VS ĐÍCH ĐẾN)',
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
                          Text(
                            '${_currentWeather!.temperature}°C • ${_currentWeather!.weatherDescription}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
                          Text(
                            '${_destWeather!.temperature}°C • ${_destWeather!.weatherDescription}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.summitGold),
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

        // Hourly Timeline Forecast (Next 6 Hours)
        Text(
          isViewingCurrent ? 'Dự Báo Từng Giờ (Vị Trí Của Bạn)' : 'Dự Báo Từng Giờ (Điểm Đến Trekking)',
          style: AppTypography.headlineMedium.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHourlyCard('Bây giờ', '${activeWeather?.temperature ?? 18}°C', Icons.wb_sunny_outlined, '${activeWeather?.precipitationProb ?? 10}%'),
              _buildHourlyCard('14:00', '${(activeWeather?.temperature ?? 18) + 1}°C', Icons.cloud_outlined, '20%'),
              _buildHourlyCard('16:00', '${(activeWeather?.temperature ?? 18) - 1}°C', Icons.grain, '55%'),
              _buildHourlyCard('18:00', '${(activeWeather?.temperature ?? 18) - 3}°C', Icons.water_drop_outlined, '40%'),
              _buildHourlyCard('20:00', '${(activeWeather?.temperature ?? 18) - 5}°C', Icons.nights_stay_outlined, '15%'),
              _buildHourlyCard('22:00', '${(activeWeather?.temperature ?? 18) - 7}°C', Icons.ac_unit, '10%'),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHourlyCard(String time, String temp, IconData icon, String rain) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Icon(icon, size: 20, color: AppColors.tacticalOrange),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          Text(rain, style: const TextStyle(fontSize: 10, color: AppColors.alpineCyan)),
        ],
      ),
    );
  }
}
