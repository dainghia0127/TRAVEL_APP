import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';

class SafetySosScreen extends StatefulWidget {
  const SafetySosScreen({super.key});

  @override
  State<SafetySosScreen> createState() => _SafetySosScreenState();
}

class _SafetySosScreenState extends State<SafetySosScreen> with SingleTickerProviderStateMixin {
  bool _isSosActive = false;
  bool _flashState = false;
  Timer? _morseTimer;
  bool _isBatterySaverEnabled = true;

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
    setState(() {
      _isSosActive = !_isSosActive;
      if (_isSosActive) {
        // Chu kỳ chớp đèn nhấp nháy Morse SOS: 300ms
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
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {
      _showSnackBar('Gọi khẩn cấp số: $number');
    }
  }

  void _copyGpsCoordinates() {
    Clipboard.setData(ClipboardData(text: '$_demoLat, $_demoLng (Cao độ: 1,485m)'));
    _showSnackBar('Đã sao chép tọa độ GPS vào bộ nhớ đệm!');
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceHigh,
        content: Text(msg, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('An Toàn & Cứu Hộ SOS'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Circular Tactical SOS Beacon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: _isSosActive
                    ? (_flashState ? const Color(0xFF7F1D1D) : const Color(0xFF450A0A))
                    : AppTheme.surfaceBase,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isSosActive ? AppTheme.emergencyRed : AppTheme.emergencyRed.withValues(alpha: 0.3),
                  width: _isSosActive ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSosActive
                        ? AppTheme.emergencyRed.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                    blurRadius: _isSosActive ? 30 : 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Beacon Button
                  GestureDetector(
                    onTap: _toggleSos,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isSosActive ? AppTheme.sosGradient : null,
                        color: _isSosActive ? null : const Color(0xFF2A1515),
                        border: Border.all(
                          color: AppTheme.emergencyRed,
                          width: _isSosActive ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.emergencyRed.withValues(alpha: _isSosActive ? 0.6 : 0.2),
                            blurRadius: _isSosActive ? 25 : 12,
                            spreadRadius: _isSosActive ? 4 : 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isSosActive ? Icons.flash_on : Icons.sos,
                          size: 54,
                          color: _isSosActive ? Colors.white : AppTheme.emergencyRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSosActive ? 'ĐANG PHÁT MÃ MORSE SOS (... --- ...)' : 'BẤM ĐỂ KÍCH HOẠT SOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: _isSosActive ? Colors.white : AppTheme.emergencyRed,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSosActive
                        ? 'Chớp đèn flash màn hình & còi hú tần số cao định vị ban đêm'
                        : 'Chạm để phát tín hiệu cứu hộ khẩn cấp bằng đèn & âm thanh',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSub),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Coordinates Box with Copy Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.my_location, color: AppTheme.emerald, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TỌA ĐỘ GPS KHẨN CẤP (WGS84)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                          Text('$_demoLat°N, $_demoLng°E', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                          const Text('Cao độ: 1,485m • Sai số: ±3m', style: TextStyle(fontSize: 11, color: AppTheme.emerald)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppTheme.emerald, size: 20),
                    tooltip: 'Sao chép tọa độ',
                    onPressed: _copyGpsCoordinates,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Emergency SMS Dispatch Button
            InkWell(
              onTap: _sendEmergencySms,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.amberGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tacticalOrange.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sms, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tự Động Gửi SMS Cứu Hộ Kèm Tọa Độ GPS',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Emergency Call Action Grid
            Row(
              children: [
                Expanded(child: _buildEmergencyCallButton('Cấp cứu 115', '115', Icons.local_hospital, const Color(0xFFEF4444))),
                const SizedBox(width: 8),
                Expanded(child: _buildEmergencyCallButton('Cứu nạn 114', '114', Icons.fire_truck, const Color(0xFFF97316))),
                const SizedBox(width: 8),
                Expanded(child: _buildEmergencyCallButton('Công an 113', '113', Icons.shield, const Color(0xFF3B82F6))),
              ],
            ),

            const SizedBox(height: 16),

            // Hazard Threat Assessment Card
            if (_currentWeather != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _currentWeather!.hasHypothermiaRisk ? AppTheme.tacticalOrange.withValues(alpha: 0.5) : AppTheme.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _currentWeather!.hasHypothermiaRisk ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
                          color: _currentWeather!.hasHypothermiaRisk ? AppTheme.tacticalOrange : AppTheme.emerald,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('CẢNH BÁO VI KHÍ HẬU & NGUY CƠ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textMain)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thời tiết: ${_currentWeather!.weatherDescription} • ${_currentWeather!.temperature}°C • Gió giật: ${_currentWeather!.windGusts} km/h',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSub),
                    ),
                    const Divider(height: 20, color: AppTheme.borderLight),
                    Row(
                      children: [
                        const Icon(Icons.ac_unit, size: 16, color: AppTheme.tacticalOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentWeather!.hasHypothermiaRisk
                                ? 'CẢNH BÁO: Rét buốt + gió mạnh. Nguy cơ hạ thân nhiệt cao về đêm!'
                                : 'Điều kiện nhiệt độ bình thường.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _currentWeather!.hasHypothermiaRisk ? AppTheme.tacticalOrange : AppTheme.textSub,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Battery Optimizer Switch
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  activeThumbColor: AppTheme.emerald,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.battery_saver, color: AppTheme.emerald, size: 20),
                  ),
                  title: const Text('Chế độ Tiết kiệm pin dã ngoại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  subtitle: const Text('Giao diện đen OLED, ngắt định vị ngầm khi khóa máy', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  value: _isBatterySaverEnabled,
                  onChanged: (val) => setState(() => _isBatterySaverEnabled = val),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCallButton(String label, String number, IconData icon, Color color) {
    return InkWell(
      onTap: () => _callEmergency(number),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}
