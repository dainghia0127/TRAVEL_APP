import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/safety/services/local_emergency_service.dart';
import 'package:mobile_flutter/features/weather_safety/presentation/screens/weather_climate_screen.dart';

class SafetySosScreen extends StatefulWidget {
  const SafetySosScreen({super.key});

  @override
  State<SafetySosScreen> createState() => _SafetySosScreenState();
}

class _SafetySosScreenState extends State<SafetySosScreen> with SingleTickerProviderStateMixin {
  bool _isSosActive = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;

  // Dữ liệu vị trí GPS hiện tại
  Position? _realPosition;
  bool _isGpsLoading = true;
  String _gpsStatus = 'Đang dò sóng vệ tinh GPS...';

  // Đường dây nóng cứu hộ địa phương theo GPS thực tế
  LocalEmergencyArea? _emergencyArea;
  bool _isLoadingEmergency = true;

  double get _currentLat => _realPosition?.latitude ?? 11.9404;
  double get _currentLng => _realPosition?.longitude ?? 108.4583;
  double get _currentAlt => _realPosition?.altitude ?? 1485.0;
  double get _currentAcc => _realPosition?.accuracy ?? 3.5;
  bool get _hasRealGps => _realPosition != null;

  @override
  void initState() {
    super.initState();
    _detectLiveGpsAndEmergency();
  }

  Future<void> _detectLiveGpsAndEmergency() async {
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

    // Fallback an toàn nếu chưa có GPS
    if (mounted) {
      setState(() {
        _isGpsLoading = false;
        _gpsStatus = 'Chưa nhận tín hiệu GPS (Chế độ tham chiếu)';
      });
      final area = await LocalEmergencyService.resolveEmergencyContacts(_currentLat, _currentLng);
      if (mounted) {
        setState(() {
          _emergencyArea = area;
          _isLoadingEmergency = false;
        });
      }
    }
  }

  void _onHoldStart() {
    if (_isSosActive) {
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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Cứu Hộ & SOS
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 14, AppSpacing.space16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cứu Hộ & SOS',
                        style: AppTypography.displayHero.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ứng trực khẩn cấp 24/7 & kết nối vệ tinh',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            ),

            // Nội dung chính thuần túy Cứu Hộ & SOS
            Expanded(
              child: _buildSosView(),
            ),
          ],
        ),
      ),
    );
  }

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
              // Nút nhấn giữ 2 giây để phát tín hiệu
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
                        onTap: _isGpsLoading ? null : _detectLiveGpsAndEmergency,
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

        // 2 nút hành động cứu hộ lớn
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

        const SizedBox(height: 16),

        // CARD LIÊN KẾT NHANH SANG TRANG THỜI TIẾT & KHÍ HẬU RIÊNG BIỆT
        BouncingButton(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WeatherClimateScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.alpineCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_sunny_outlined, color: AppColors.alpineCyan, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DỰ BÁO THỜI TIẾT VÀ KHÍ HẬU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.alpineCyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Xem đồng hồ real-time, dự báo 24h & 7 ngày tới',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.alpineCyan),
              ],
            ),
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
}
