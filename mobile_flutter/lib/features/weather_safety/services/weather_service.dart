import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherIconInfo {
  final IconData icon;
  final Color color;
  const WeatherIconInfo(this.icon, this.color);
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final bool isDay;
  final int precipitationProb;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    required this.precipitationProb,
  });

  String get hourLabel {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  WeatherIconInfo get iconInfo => WeatherService.getWeatherIcon(weatherCode, isDay);
}

class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int precipitationProbMax;

  DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbMax,
  });

  String get dayLabel {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hôm nay';
    }
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final weekdayName = weekdays[date.weekday % 7];
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    return '$weekdayName, $dayStr/$monthStr';
  }

  WeatherIconInfo get iconInfo => WeatherService.getWeatherIcon(weatherCode, true);
}

class OutdoorWeather {
  final double temperature;
  final double windSpeed;
  final double windGusts;
  final int precipitationProb;
  final int weatherCode;
  final bool isDay;
  final int humidity;
  final double apparentTemperature;
  final bool hasFlashFloodRisk;
  final bool hasHypothermiaRisk;
  final bool hasThunderstormRisk;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  OutdoorWeather({
    required this.temperature,
    required this.windSpeed,
    required this.windGusts,
    required this.precipitationProb,
    required this.weatherCode,
    this.isDay = true,
    this.humidity = 65,
    this.apparentTemperature = 22.0,
    required this.hasFlashFloodRisk,
    required this.hasHypothermiaRisk,
    required this.hasThunderstormRisk,
    this.hourly = const [],
    this.daily = const [],
  });

  String get weatherDescription {
    if (weatherCode >= 95) return 'Giông sét nguy hiểm';
    if (weatherCode >= 80) return 'Mưa rào lớn';
    if (weatherCode >= 60) return 'Mưa dầm dã ngoại';
    if (weatherCode >= 50) return 'Mưa phùn / Sương mù';
    if (weatherCode >= 3) return 'Nhiều mây âm u';
    if (weatherCode >= 1) return isDay ? 'Ít mây / Nắng nhẹ' : 'Ít mây / Trời quang';
    return isDay ? 'Trời nắng đẹp' : 'Trời quang đãng (Đêm)';
  }

  WeatherIconInfo get iconInfo => WeatherService.getWeatherIcon(weatherCode, isDay);
}

class WeatherService {
  /// Lấy icon và màu sắc phù hợp chính xác theo ngày/đêm và mã thời tiết Open-Meteo WMO
  static WeatherIconInfo getWeatherIcon(int code, bool isDay) {
    if (code >= 95) {
      return const WeatherIconInfo(Icons.thunderstorm, Color(0xFFEF4444)); // Đỏ cảnh báo giông sét
    }
    if (code >= 80) {
      return const WeatherIconInfo(Icons.shower, Color(0xFF38BDF8)); // Xanh mưa rào
    }
    if (code >= 60) {
      return const WeatherIconInfo(Icons.grain, Color(0xFF60A5FA)); // Xanh mưa dầm
    }
    if (code >= 50) {
      return const WeatherIconInfo(Icons.blur_on, Color(0xFF94A3B8)); // Xám sương mù
    }
    if (code >= 3) {
      return const WeatherIconInfo(Icons.cloud, Color(0xFF94A3B8)); // Mây
    }
    if (code >= 1) {
      return isDay
          ? const WeatherIconInfo(Icons.wb_cloudy_rounded, Color(0xFFFBBF24))
          : const WeatherIconInfo(Icons.nightlight_outlined, Color(0xFFE2E8F0));
    }
    // Code 0: Trời quang đãng
    return isDay
        ? const WeatherIconInfo(Icons.wb_sunny_rounded, Color(0xFFF59E0B))
        : const WeatherIconInfo(Icons.nightlight_round, Color(0xFFFCD34D));
  }

  /// Lấy dự báo thời tiết và khí hậu từ Open-Meteo theo tọa độ GPS (Real-time, Hourly 24h & Daily 7 ngày)
  static Future<OutdoorWeather> getForecast(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$lat&longitude=$lng&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_gusts_10m&'
      'hourly=temperature_2m,precipitation_probability,weather_code,is_day&'
      'daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&'
      'timezone=auto',
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
        final isDayVal = (current['is_day'] as num?)?.toInt() == 1;
        final hum = (current['relative_humidity_2m'] as num?)?.toInt() ?? 65;
        final appTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;

        // Parse Hourly
        final List<HourlyWeather> parsedHourly = [];
        final hourlyData = data['hourly'];
        if (hourlyData != null && hourlyData['time'] is List) {
          final times = hourlyData['time'] as List;
          final temps = (hourlyData['temperature_2m'] as List?) ?? [];
          final probs = (hourlyData['precipitation_probability'] as List?) ?? [];
          final codes = (hourlyData['weather_code'] as List?) ?? [];
          final isDays = (hourlyData['is_day'] as List?) ?? [];

          final now = DateTime.now();
          int startIndex = 0;
          // Tìm mốc giờ gần nhất với hiện tại
          for (int i = 0; i < times.length; i++) {
            final t = DateTime.tryParse(times[i].toString());
            if (t != null && t.isAfter(now.subtract(const Duration(hours: 1)))) {
              startIndex = i;
              break;
            }
          }

          // Lấy 24 giờ tiếp theo
          for (int i = startIndex; i < times.length && parsedHourly.length < 24; i++) {
            final t = DateTime.tryParse(times[i].toString()) ?? now.add(Duration(hours: parsedHourly.length));
            final hTemp = (temps.length > i ? (temps[i] as num?)?.toDouble() : null) ?? temp;
            final hProb = (probs.length > i ? (probs[i] as num?)?.toInt() : null) ?? 0;
            final hCode = (codes.length > i ? (codes[i] as num?)?.toInt() : null) ?? 0;
            final hIsDay = (isDays.length > i ? (isDays[i] as num?)?.toInt() == 1 : null) ?? true;

            parsedHourly.add(HourlyWeather(
              time: t,
              temperature: hTemp,
              weatherCode: hCode,
              isDay: hIsDay,
              precipitationProb: hProb,
            ));
          }
        }

        // Parse Daily
        final List<DailyWeather> parsedDaily = [];
        final dailyData = data['daily'];
        if (dailyData != null && dailyData['time'] is List) {
          final dates = dailyData['time'] as List;
          final dCodes = (dailyData['weather_code'] as List?) ?? [];
          final dMaxs = (dailyData['temperature_2m_max'] as List?) ?? [];
          final dMins = (dailyData['temperature_2m_min'] as List?) ?? [];
          final dProbs = (dailyData['precipitation_probability_max'] as List?) ?? [];

          for (int i = 0; i < dates.length && parsedDaily.length < 7; i++) {
            final d = DateTime.tryParse(dates[i].toString()) ?? DateTime.now().add(Duration(days: i));
            final max = (dMaxs.length > i ? (dMaxs[i] as num?)?.toDouble() : null) ?? (temp + 3);
            final min = (dMins.length > i ? (dMins[i] as num?)?.toDouble() : null) ?? (temp - 4);
            final codeVal = (dCodes.length > i ? (dCodes[i] as num?)?.toInt() : null) ?? code;
            final probVal = (dProbs.length > i ? (dProbs[i] as num?)?.toInt() : null) ?? 20;

            parsedDaily.add(DailyWeather(
              date: d,
              weatherCode: codeVal,
              tempMax: max,
              tempMin: min,
              precipitationProbMax: probVal,
            ));
          }
        }

        return OutdoorWeather(
          temperature: temp,
          windSpeed: wind,
          windGusts: gusts,
          precipitationProb: (rain * 20).clamp(0, 100).toInt(),
          weatherCode: code,
          isDay: isDayVal,
          humidity: hum,
          apparentTemperature: appTemp,
          hasFlashFloodRisk: rain > 15.0 || code >= 80,
          hasHypothermiaRisk: temp < 14.0 && wind > 20.0,
          hasThunderstormRisk: code >= 95,
          hourly: parsedHourly,
          daily: parsedDaily,
        );
      }
    } catch (_) {
      // Khi mất mạng offline, tự động trả về dữ liệu an toàn mặc định
    }

    // Dữ liệu an toàn offline mặc định (Đà Lạt / Tây Nguyên)
    final now = DateTime.now();
    final bool isNight = now.hour < 6 || now.hour >= 18;

    // Sinh giả lập 24h offline an toàn
    final List<HourlyWeather> fallbackHourly = List.generate(24, (index) {
      final t = now.add(Duration(hours: index));
      final bool hNight = t.hour < 6 || t.hour >= 18;
      return HourlyWeather(
        time: t,
        temperature: hNight ? 16.0 : 21.5,
        weatherCode: 1,
        isDay: !hNight,
        precipitationProb: hNight ? 15 : 25,
      );
    });

    // Sinh giả lập 7 ngày tới offline
    final List<DailyWeather> fallbackDaily = List.generate(7, (index) {
      final d = now.add(Duration(days: index));
      return DailyWeather(
        date: d,
        weatherCode: index % 3 == 0 ? 61 : 1,
        tempMax: 23.0 + (index % 2),
        tempMin: 15.5 - (index % 2),
        precipitationProbMax: index % 3 == 0 ? 65 : 20,
      );
    });

    return OutdoorWeather(
      temperature: isNight ? 16.5 : 21.0,
      windSpeed: 18.0,
      windGusts: 32.0,
      precipitationProb: 40,
      weatherCode: 1,
      isDay: !isNight,
      humidity: 78,
      apparentTemperature: isNight ? 15.0 : 20.5,
      hasFlashFloodRisk: false,
      hasHypothermiaRisk: isNight, // Đà Lạt về đêm kèm gió dễ hạ thân nhiệt
      hasThunderstormRisk: false,
      hourly: fallbackHourly,
      daily: fallbackDaily,
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
