import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';

class SafetySosScreen extends StatefulWidget {
  const SafetySosScreen({super.key});

  @override
  State<SafetySosScreen> createState() => _SafetySosScreenState();
}

class _SafetySosScreenState extends State<SafetySosScreen> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: SOS Khẩn cấp, 1: Thời tiết vi khí hậu
  bool _isSosActive = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;

  OutdoorWeather? _currentWeather;
  final double _demoLat = 11.9404;
  final double _demoLng = 108.4583;

  @override
  void initState() {
    super.initState();
    _loadWeatherWarning();
  }

  Future<void> _loadWeatherWarning() async {
    final weather = await WeatherService.getForecast(_demoLat, _demoLng);
    if (mounted) setState(() => _currentWeather = weather);
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
    final message = 'SOS! TOI DANG CAN CUU HO. Toa do GPS: $_demoLat, $_demoLng (Cao do: 1,485m). Vui long gui doi cuu ho khan cap!';
    final uri = Uri.parse('sms:115?body=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Đã chuẩn bị nội dung tin nhắn cứu hộ kèm tọa độ GPS.');
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
    Clipboard.setData(ClipboardData(text: '$_demoLat, $_demoLng (Cao độ: 1,485m)'));
    _showSnackBar('Đã sao chép tọa độ GPS vào bộ nhớ đệm!');
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
                        _activeTab == 0 ? 'Cứu Hộ & SOS' : 'Thời Tiết Dã Ngoại',
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
                      _buildHeaderTab(1, 'Thời Tiết Vi Khí Hậu', Icons.cloud_outlined),
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
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TỌA ĐỘ VỆ TINH GPS (WGS84)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald,
                      letterSpacing: 0.4,
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
              const SizedBox(height: 8),
              Text('$_demoLat, $_demoLng', style: AppTypography.displayHero.copyWith(fontSize: 22)),
              const SizedBox(height: 2),
              const Text('Cao độ vệ tinh: 1,485m • Sai số ước lượng: ± 3.5m', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

        // Local Forest Ranger Contacts
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
              const Text(
                'ĐƯỜNG DÂY NÓNG ĐỊA PHƯƠNG (KHẨN CẤP)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.4),
              ),
              const SizedBox(height: 10),
              _buildContactRow('Cứu nạn Quốc Gia', '112', Icons.phone_in_talk),
              const Divider(height: 16, color: AppColors.borderSubtle),
              _buildContactRow('Kiểm Lâm Tà Năng (Đức Trọng)', '02633843115', Icons.forest),
              const Divider(height: 16, color: AppColors.borderSubtle),
              _buildContactRow('UBND Xã Phan Dũng (Tuy Phong)', '02523851115', Icons.location_city),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildContactRow(String name, String phone, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.emerald),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        BouncingButton(
          onTap: () => _callEmergency(phone),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: AppRadius.roundedPill,
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, size: 12, color: AppColors.emerald),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: WEATHER CENTER VIEW
  Widget _buildWeatherView(OutdoorWeather? weather) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // Weather Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${weather?.temperature ?? 18}°C', style: AppTypography.displayHero.copyWith(fontSize: 38)),
                      Text(weather?.weatherDescription ?? 'Ít mây / Mát mẻ', style: AppTypography.titleMedium.copyWith(color: AppColors.emerald)),
                    ],
                  ),
                  const Icon(Icons.wb_sunny_outlined, size: 54, color: AppColors.tacticalOrange),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 16),

              // 3 Weather Gauges (Wind, Gusts, Rain probability)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TacticalBadge(
                    icon: Icons.air,
                    label: 'Tốc độ gió',
                    value: '${weather?.windSpeed ?? 15} km/h',
                  ),
                  Container(width: 1, height: 24, color: AppColors.borderSubtle),
                  TacticalBadge(
                    icon: Icons.speed,
                    label: 'Gió giật',
                    value: '${weather?.windGusts ?? 28} km/h',
                    iconColor: AppColors.tacticalOrange,
                  ),
                  Container(width: 1, height: 24, color: AppColors.borderSubtle),
                  TacticalBadge(
                    icon: Icons.water_drop,
                    label: 'Khả năng mưa',
                    value: '${weather?.precipitationProb ?? 30}%',
                    iconColor: AppColors.alpineCyan,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Severe Weather Warnings Box
        if (weather?.hasHypothermiaRisk == true) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tacticalOrange.withValues(alpha: 0.1),
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.tacticalOrange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.ac_unit, color: AppColors.tacticalOrange, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CẢNH BÁO NGUY CƠ HẠ THÂN NHIỆT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Nhiệt độ vùng đồi cao ban đêm hạ dưới 14°C kèm gió mạnh. Cần túi ngủ chuyên dụng và lều cản gió.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Hourly Timeline Forecast (Next 6 Hours)
        Text('Dự Báo Từng Giờ (Núi Rừng)', style: AppTypography.headlineMedium.copyWith(fontSize: 16)),
        const SizedBox(height: 10),

        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHourlyCard('Bây giờ', '18°C', Icons.wb_sunny_outlined, '10%'),
              _buildHourlyCard('14:00', '19°C', Icons.cloud_outlined, '20%'),
              _buildHourlyCard('16:00', '17°C', Icons.grain, '55%'),
              _buildHourlyCard('18:00', '15°C', Icons.water_drop_outlined, '40%'),
              _buildHourlyCard('20:00', '13°C', Icons.nights_stay_outlined, '15%'),
              _buildHourlyCard('22:00', '11°C', Icons.ac_unit, '10%'),
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
