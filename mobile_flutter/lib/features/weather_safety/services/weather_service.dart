import 'dart:convert';
import 'package:http/http.dart' as http;

class OutdoorWeather {
  final double temperature;
  final double windSpeed;
  final double windGusts;
  final int precipitationProb;
  final int weatherCode;
  final bool hasFlashFloodRisk;
  final bool hasHypothermiaRisk;
  final bool hasThunderstormRisk;

  OutdoorWeather({
    required this.temperature,
    required this.windSpeed,
    required this.windGusts,
    required this.precipitationProb,
    required this.weatherCode,
    required this.hasFlashFloodRisk,
    required this.hasHypothermiaRisk,
    required this.hasThunderstormRisk,
  });

  String get weatherDescription {
    if (weatherCode >= 95) return 'Giông sét nguy hiểm';
    if (weatherCode >= 80) return 'Mưa rào lớn';
    if (weatherCode >= 60) return 'Mưa dầm dã ngoại';
    if (weatherCode >= 50) return 'Mưa phùn / Sương mù';
    if (weatherCode >= 1) return 'Ít mây / Quang đãng';
    return 'Trời nắng đẹp';
  }
}

class WeatherService {
  /// Lấy dự báo thời tiết vi khí hậu từ Open-Meteo theo tọa độ GPS
  static Future<OutdoorWeather> getForecast(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,precipitation,weather_code,wind_speed_10m,wind_gusts_10m',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'] ?? {};
        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 22.0;
        final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 15.0;
        final gusts = (current['wind_gusts_10m'] as num?)?.toDouble() ?? 25.0;
        final rain = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final code = (current['weather_code'] as num?)?.toInt() ?? 0;

        return OutdoorWeather(
          temperature: temp,
          windSpeed: wind,
          windGusts: gusts,
          precipitationProb: (rain * 20).clamp(0, 100).toInt(),
          weatherCode: code,
          hasFlashFloodRisk: rain > 15.0 || code >= 80,
          hasHypothermiaRisk: temp < 14.0 && wind > 20.0,
          hasThunderstormRisk: code >= 95,
        );
      }
    } catch (_) {
      // Khi mất mạng offline, tự động trả về dữ liệu an toàn mặc định
    }

    // Dữ liệu an toàn offline mặc định (Đà Lạt / Tây Nguyên)
    return OutdoorWeather(
      temperature: 17.5,
      windSpeed: 18.0,
      windGusts: 32.0,
      precipitationProb: 40,
      weatherCode: 61,
      hasFlashFloodRisk: false,
      hasHypothermiaRisk: true, // Đà Lạt về đêm kèm gió dễ hạ thân nhiệt
      hasThunderstormRisk: false,
    );
  }

  /// Tự động sinh danh mục chuẩn bị đồ (Checklist) thông minh dựa trên điều kiện thời tiết
  static List<String> generateSmartChecklist(OutdoorWeather weather) {
    final list = <String>[
      'Bản đồ ngoại tuyến đã tải về máy',
      'Đèn pin dã ngoại + Pin dự phòng 20,000mAh',
      'Bộ dụng cụ y tế sơ cứu + Thuốc chống côn trùng',
      'Bình nước cá nhân (tối thiểu 2 Lít) + Viên lọc Aquatabs',
      'Còi sinh tồn + Dao đa năng',
    ];

    if (weather.precipitationProb > 30 || weather.hasFlashFloodRisk) {
      list.add('Áo mưa bộ dã ngoại chống rách');
      list.add('Túi khô chống nước (Dry-bag) bọc balo');
      list.add('Ủng đi mưa / Bọc giày đi bộ');
    }

    if (weather.temperature < 18.0 || weather.hasHypothermiaRisk) {
      list.add('Túi ngủ dã ngoại chịu nhiệt dưới 10°C');
      list.add('Áo khoác gió cản nước + Mũ len giữ ấm đầu');
      list.add('Miếng dán giữ nhiệt sinh tồn');
    }

    if (weather.hasThunderstormRisk) {
      list.add('Cảnh báo: Tránh hạ trại ở sống lưng đồi trơ trọi');
    }

    return list;
  }
}

