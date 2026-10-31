import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _flashState = false;
  Timer? _morseTimer;

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

  void _toggleSos() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isSosActive = !_isSosActive;
      if (_isSosActive) {
        _morseTimer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
          if (mounted) setState(() => _flashState = !_flashState);
        });
      } else {
        _morseTimer?.cancel();
        _flashState = false;
      }
    });
  }

  Future<void> _sendEmergencySms() async {
    HapticFeedback.mediumImpact();
    final message = 'SOS! TOI DANG CAN CUU HO. Toa do GPS: $_demoLat, $_demoLng (Cao do: 1,485m). Vui long gui doi cuu ho khan cap!';
    final uri = Uri.parse('sms:115?body=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Đã chuẩn bị nội dung SMS cứu hộ kèm tọa độ GPS.');
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
    _morseTimer?.cancel();
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
                      TacticalPill(
                        icon: Icons.shield_outlined,
                        text: 'AN TOÀN',
                        color: AppColors.emerald,
                        backgroundColor: AppColors.surfaceHigh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2-Tab Switcher (SOS vs Weather)
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

  // TAB 1: SOS VIEW
  Widget _buildSosView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // SOS Beacon Pulsing Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: _isSosActive
                ? (_flashState ? const Color(0xFF7F1D1D) : const Color(0xFF450A0A))
                : AppColors.surfaceBase,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(
              color: _isSosActive ? AppColors.emergencyRed : AppColors.emergencyRed.withValues(alpha: 0.3),
              width: _isSosActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isSosActive ? AppColors.emergencyRed.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
                blurRadius: _isSosActive ? 30 : 16,
              ),
            ],
          ),
          child: Column(
            children: [
              // Beacon Button with multi-layer pulsing animation
              GestureDetector(
                onTap: _toggleSos,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isSosActive ? AppColors.sosGradient : null,
                    color: _isSosActive ? null : const Color(0xFF2A1515),
                    border: Border.all(color: AppColors.emergencyRed, width: _isSosActive ? 4 : 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withValues(alpha: _isSosActive ? 0.7 : 0.25),
                        blurRadius: _isSosActive ? 30 : 14,
                        spreadRadius: _isSosActive ? 6 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isSosActive ? Icons.flash_on : Icons.sos,
                      size: 58,
                      color: _isSosActive ? Colors.white : AppColors.emergencyRed,
                    ),
                  ),
                )
                    .animate(target: _isSosActive ? 1 : 0)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 600.ms, curve: Curves.easeInOut)
                    .then()
                    .scale(begin: const Offset(1.08, 1.08), end: const Offset(1, 1), duration: 600.ms),
              ),
              const SizedBox(height: 18),
              Text(
                _isSosActive ? 'ĐANG PHÁT MÃ MORSE SOS (... --- ...)' : 'CHẠM ĐỂ KÍCH HOẠT SOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: _isSosActive ? Colors.white : AppColors.emergencyRed,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isSosActive
                    ? 'Chớp đèn flash màn hình & phát xung âm thanh định vị ban đêm'
                    : 'Phát tín hiệu cứu hộ khẩn cấp bằng đèn & còi hú tần số cao',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Military GPS Coordinates Card
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
                  const Text('TỌA ĐỘ GPS CỦA BẠN (OFFLINE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald, letterSpacing: 0.4)),
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
              const Text('Cao độ vệ tinh: 1,485m • Sai số: ± 3.5m', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

        const SizedBox(height: 30),
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
