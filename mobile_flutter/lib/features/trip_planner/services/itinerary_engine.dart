import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';

/// Engine tính toán và phân bổ lộ trình động cho chuyến đi (Dynamic Itinerary Engine)
/// Tự động thích ứng với khoảng cách địa lý (từ vài chục km đến hàng ngàn km)
/// Không gán cứng số ngày, không để bất kỳ ngày nào bị trống dữ liệu.
class ItineraryEngine {
  /// Đề xuất số ngày tối ưu dựa trên cự ly thực tế (km) và số ngày cơ sở của điểm đến
  static int calculateSuggestedDays(double distKm, int? baseDays) {
    final base = (baseDays ?? 1).clamp(1, 4);
    if (distKm >= 3500) {
      // Quốc tế / Liên lục địa (> 3,500 km)
      return (base + 3).clamp(4, 6);
    } else if (distKm >= 1200) {
      // Xuyên Việt cự ly xa (>= 1,200 km, ví dụ TP.HCM ra Sa Pa, Hà Giang ~2,000 km)
      // Cần 1 ngày tiếp cận + các ngày trải nghiệm thực địa + 1 ngày hồi hương
      return (base + 2).clamp(3, 5);
    } else if (distKm >= 450) {
      // Liên vùng Trung Bộ / Tây Nguyên (450km - 1,200km)
      return (base + 1).clamp(2, 4);
    } else if (distKm >= 120) {
      // 120km - 450km
      return base.clamp(2, 3);
    } else {
      // Dưới 120km
      return base.clamp(1, 2);
    }
  }

  /// Sinh toàn bộ các mốc lịch trình chi tiết cho tất cả các ngày từ 1 đến [totalDays]
  static Map<int, List<Map<String, dynamic>>> generateDynamicItinerary({
    required Destination dest,
    required double distKm,
    required int totalDays,
  }) {
    final Map<int, List<Map<String, dynamic>>> result = {};
    for (int i = 1; i <= totalDays; i++) {
      result[i] = [];
    }

    final stages = dest.route?.stages ?? [];
    final isLongDistance = distKm >= 450;
    final isExtremeDistance = distKm >= 1200;

    // NGÀY 1: TIẾP CẬN VÙNG MIỀN & THÍCH NGHI
    if (isExtremeDistance) {
      // Khoảng cách rất xa (>= 1,200 km - ví dụ TP.HCM ra Sa Pa / Hà Giang / Quốc tế)
      result[1] = [
        {
          'id': 'd1_depart_${dest.id}',
          'time': '06:00',
          'title': 'Khởi hành chặng di chuyển hàng không / đường dài',
          'location': 'Tập kết đoàn tại sân bay/ga trung tâm, làm thủ tục',
          'type': 'start',
          'distance': '0 km',
          'elevation': '10m',
        },
        {
          'id': 'd1_hub_${dest.id}',
          'time': '10:30',
          'title': 'Đến trạm trung chuyển cửa ngõ',
          'location': 'Đáp xuống sân bay/ga cửa ngõ vùng lân cận ${dest.name}',
          'type': 'checkpoint',
          'distance': '+ ${(distKm * 0.85).toStringAsFixed(0)} km',
          'elevation': '50m',
        },
        {
          'id': 'd1_lunch_${dest.id}',
          'time': '12:00',
          'title': 'Nghỉ trưa & Thưởng thức đặc sản vùng miền',
          'location': 'Nạp năng lượng và kiểm tra quân số, tư trang',
          'type': 'rest',
          'distance': '+ 5 km',
          'elevation': '100m',
        },
        {
          'id': 'd1_transit_${dest.id}',
          'time': '14:00',
          'title': 'Xe chuyên tuyến di chuyển lên chân núi/cửa rừng',
          'location': 'Đi qua các cung đường đèo hùng vĩ hướng tới ${dest.name}',
          'type': 'checkpoint',
          'distance': '+ ${(distKm * 0.15).toStringAsFixed(0)} km',
          'elevation': dest.elevationDisplay,
        },
        {
          'id': 'd1_base_${dest.id}',
          'time': '18:00',
          'title': 'Nhận phòng tiền trạm / Dựng lều căn cứ',
          'location': 'Thích nghi khí hậu, kiểm tra balo, họp phổ biến an toàn',
          'type': 'camp',
          'distance': '+ 2 km',
          'elevation': dest.elevationDisplay,
        },
      ];
    } else if (isLongDistance) {
      // Khoảng cách trung bình xa (450km - 1,200km)
      result[1] = [
        {
          'id': 'd1_depart_${dest.id}',
          'time': '05:30',
          'title': 'Xuất phát theo hành lang quốc gia',
          'location': 'Khởi hành theo trục cao tốc/quốc lộ đến ${dest.name}',
          'type': 'start',
          'distance': '0 km',
          'elevation': '20m',
        },
        {
          'id': 'd1_rest_${dest.id}',
          'time': '11:45',
          'title': 'Nghỉ chân tại trạm dừng chân liên tỉnh',
          'location': 'Tiếp nhiên liệu, kiểm tra kỹ thuật phương tiện & ăn trưa',
          'type': 'rest',
          'distance': '+ ${(distKm * 0.5).toStringAsFixed(0)} km',
          'elevation': '150m',
        },
        {
          'id': 'd1_arrive_${dest.id}',
          'time': '16:30',
          'title': 'Đến bìa rừng / Cửa ngõ ${dest.name}',
          'location': 'Gặp kiểm lâm/hướng dẫn viên địa phương làm thủ tục',
          'type': 'checkpoint',
          'distance': '+ ${(distKm * 0.5).toStringAsFixed(0)} km',
          'elevation': dest.elevationDisplay,
        },
        {
          'id': 'd1_camp_${dest.id}',
          'time': '18:00',
          'title': 'Hạ trại căn cứ số 1 & Thưởng thức ẩm thực lửa trại',
          'location': 'Dựng lều, chuẩn bị nước uống và nghỉ ngơi sớm',
          'type': 'camp',
          'distance': '+ 3 km',
          'elevation': dest.elevationDisplay,
        },
      ];
    } else {
      // Khoảng cách ngắn / lân cận (< 450 km)
      result[1] = [
        {
          'id': 'd1_start_${dest.id}',
          'time': '06:00',
          'title': 'Khởi hành dã ngoại tới ${dest.name}',
          'location': 'Tập kết đoàn, kiểm tra xe cộ & đồ đạc cá nhân',
          'type': 'start',
          'distance': '0 km',
          'elevation': '20m',
        },
        {
          'id': 'd1_arrive_${dest.id}',
          'time': '10:30',
          'title': 'Đến cửa rừng / Điểm xuất phát cung đường',
          'location': 'Gửi xe, khai báo tạm trú và bắt đầu đi bộ',
          'type': 'checkpoint',
          'distance': '+ ${distKm.toStringAsFixed(0)} km',
          'elevation': dest.elevationDisplay,
        },
        {
          'id': 'd1_camp_${dest.id}',
          'time': '16:30',
          'title': 'Hạ trại tại điểm ngắm hoàng hôn',
          'location': 'Dựng trại bên suối, ngắm mây trời và nấu nướng',
          'type': 'camp',
          'distance': '+ 8 km',
          'elevation': dest.elevationDisplay,
        },
      ];
    }

    // NẾU CHUYẾN ĐI CHỈ CÓ 1 NGÀY: KẾT THÚC TRONG NGÀY
    if (totalDays == 1) {
      result[1]!.add({
        'id': 'd1_finish_${dest.id}',
        'time': '17:30',
        'title': 'Hạ sơn & Lên xe trở về điểm xuất phát',
        'location': 'Kết thúc chuyến khám phá trong ngày an toàn',
        'type': 'finish',
        'distance': '+ ${(distKm).toStringAsFixed(0)} km',
        'elevation': '0m',
      });
      return result;
    }

    // CÁC NGÀY GIỮA (Từ ngày 2 đến ngày totalDays - 1)
    if (totalDays > 2) {
      final middleDaysCount = totalDays - 2;

      for (int dayOffset = 0; dayOffset < middleDaysCount; dayOffset++) {
        final currentDay = 2 + dayOffset;
        final List<Map<String, dynamic>> dayStops = [];

        // Nếu điểm đến có dữ liệu stages thực tế, phân bổ tương ứng
        if (stages.isNotEmpty) {
          final stageIdx = dayOffset % stages.length;
          final currentStage = stages[stageIdx];

          dayStops.add({
            'id': 'd${currentDay}_wake_${dest.id}',
            'time': '05:30',
            'title': 'Thức giấc đón bình minh & Cà phê sáng',
            'location': 'Khởi động làm nóng cơ bắp, ăn sáng giàu năng lượng',
            'type': 'start',
            'distance': '0 km',
            'elevation': dest.elevationDisplay,
          });

          dayStops.add({
            'id': 'd${currentDay}_stage_${currentStage.stageNumber}',
            'time': '08:00',
            'title': currentStage.title,
            'location': currentStage.description,
            'type': 'checkpoint',
            'distance': currentStage.distanceKm != null ? '+ ${currentStage.distanceKm} km' : '+ 7.5 km',
            'elevation': currentStage.elevationGainMeters != null ? '+${currentStage.elevationGainMeters}m' : '+350m',
          });

          dayStops.add({
            'id': 'd${currentDay}_summit_${dest.id}',
            'time': '12:00',
            'title': 'Check-in mốc tiêu biểu & Dùng đồ ăn khô',
            'location': 'Nghỉ trưa, ngắm trọn cảnh quan thiên nhiên tại đỉnh',
            'type': 'highlight',
            'distance': '+ 2 km',
            'elevation': dest.elevationDisplay,
          });

          dayStops.add({
            'id': 'd${currentDay}_camp_${dest.id}',
            'time': '17:00',
            'title': 'Hạ trại đêm số $currentDay tại điểm ngắm hoàng hôn',
            'location': 'Nhóm bếp sinh tồn, nấu bữa tối và sinh hoạt nhóm',
            'type': 'camp',
            'distance': '+ 5 km',
            'elevation': dest.elevationDisplay,
          });
        } else {
          // Điểm đến không có stages riêng: sinh các mốc dã ngoại phong phú
          dayStops.add({
            'id': 'd${currentDay}_sun_${dest.id}',
            'time': '05:30',
            'title': 'Săn mây & Đón ánh bình minh',
            'location': 'Điểm cao toàn cảnh tuyệt đẹp nhất tại ${dest.name}',
            'type': 'highlight',
            'distance': '+ 3 km',
            'elevation': dest.elevationDisplay,
          });
          dayStops.add({
            'id': 'd${currentDay}_exp_${dest.id}',
            'time': '10:00',
            'title': 'Khám phá rừng sâu & Hang động / Suối thác',
            'location': 'Trải nghiệm kỹ năng sinh tồn và tìm hiểu hệ sinh vật bản địa',
            'type': 'checkpoint',
            'distance': '+ 6 km',
            'elevation': dest.elevationDisplay,
          });
          dayStops.add({
            'id': 'd${currentDay}_camp_${dest.id}',
            'time': '16:30',
            'title': 'Hạ trại đêm số $currentDay & Giao lưu văn hóa',
            'location': 'Cắm trại ngắm dải ngân hà, thưởng trà nóng dã ngoại',
            'type': 'camp',
            'distance': '+ 5 km',
            'elevation': dest.elevationDisplay,
          });
        }

        result[currentDay] = dayStops;
      }
    } else if (totalDays == 2 && stages.isNotEmpty) {
      // 2 ngày nhưng có stages: đưa stage vào ngày 1 và ngày 2
      result[1]?.add({
        'id': 'stage_${dest.id}_1',
        'time': '14:00',
        'title': stages[0].title,
        'location': stages[0].description,
        'type': 'checkpoint',
        'distance': stages[0].distanceKm != null ? '+ ${stages[0].distanceKm} km' : '+ 5 km',
        'elevation': stages[0].elevationGainMeters != null ? '+${stages[0].elevationGainMeters}m' : '--',
      });
    }

    // NGÀY CUỐI CÙNG: HẠ SƠN, THU DỌN HÀNH TRANG & HỒI HƯƠNG
    final lastDay = totalDays;
    result[lastDay] = [
      {
        'id': 'd${lastDay}_sunrise_${dest.id}',
        'time': '06:00',
        'title': 'Bình minh cuối & Thu dọn hành trang',
        'location': 'Thực hiện nguyên tắc bảo vệ thiên nhiên (Dọn sạch toàn bộ rác)',
        'type': 'start',
        'distance': '0 km',
        'elevation': dest.elevationDisplay,
      },
      {
        'id': 'd${lastDay}_descent_${dest.id}',
        'time': '09:30',
        'title': 'Hạ sơn về điểm tập kết ban đầu',
        'location': 'Bàn giao trang thiết bị và nhận lại xe/hành lý gửi',
        'type': 'checkpoint',
        'distance': '+ 6 km',
        'elevation': '100m',
      },
      {
        'id': 'd${lastDay}_lunch_${dest.id}',
        'time': '12:00',
        'title': 'Bữa trưa mừng hoàn thành hành trình',
        'location': 'Giao lưu tổng kết cùng các thành viên trong đoàn',
        'type': 'rest',
        'distance': '+ 2 km',
        'elevation': '50m',
      },
      {
        'id': 'd${lastDay}_return_${dest.id}',
        'time': isExtremeDistance ? '14:30' : (isLongDistance ? '13:30' : '15:00'),
        'title': isExtremeDistance ? 'Lên xe/chuyến bay hồi hương' : 'Hành trình di chuyển trở về',
        'location': 'Di chuyển an toàn về điểm xuất phát ban đầu',
        'type': 'finish',
        'distance': '+ ${(distKm).toStringAsFixed(0)} km',
        'elevation': '0m',
      },
    ];

    return result;
  }
}

