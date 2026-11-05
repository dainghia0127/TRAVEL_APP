import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/data/models/destination_model.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/offline_map/services/routing_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';
import '../../services/itinerary_engine.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _activeTab = 0; // 0: Lịch trình (Timeline), 1: Chi phí & Hành trang
  int _selectedDay = 1; // 1, 2, 3
  bool _isJourneyActive = false; // Trạng thái: Đang bật chế độ đi hành trình thực địa
  int _participants = 4;
  String _selectedVehicle = 'Xe máy số (110cc)';

  List<Destination> _tripDestinations = [];
  Destination? _selectedDestination;
  LatLng _userLocation = const LatLng(10.8231, 106.6297); // Vị trí GPS hiện tại (Mặc định TP.HCM)
  double _distanceFromUserKm = 180.0;
  int _maxDays = 3;

  DateTime _startDate = DateTime.now();
  double _gasPrice = 24500.0; // Đơn giá xăng RON95 thực tế
  int _foodPerDay = 220000; // Chi phí ăn uống dã ngoại / ngày
  int _campFeePerNight = 120000; // Phí bãi trại / đêm

  DateTime get _currentDayDate => _startDate.add(Duration(days: _selectedDay - 1));
  String get _currentDayDateFormatted {
    final d = _currentDayDate;
    const weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ Nhật'];
    final weekdayStr = weekdays[(d.weekday - 1).clamp(0, 6)];
    final dayStr = d.day < 10 ? '0${d.day}' : '${d.day}';
    final monthStr = d.month < 10 ? '0${d.month}' : '${d.month}';
    return '$weekdayStr, ngày $dayStr/$monthStr/${d.year}';
  }

  Future<void> _selectStartDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'CHỌN NGÀY BẮT ĐẦU CHUYẾN ĐI',
      confirmText: 'XÁC NHẬN',
      cancelText: 'ĐÓNG',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.summitGold,
              onPrimary: Colors.black,
              surface: Color(0xFF1B231F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  void _showCostConfigDialog() {
    HapticFeedback.mediumImpact();
    final gasCtrl = TextEditingController(text: _gasPrice.round().toString());
    final foodCtrl = TextEditingController(text: _foodPerDay.toString());
    final campCtrl = TextEditingController(text: _campFeePerNight.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B231F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.tune, color: AppColors.summitGold, size: 20),
              SizedBox(width: 8),
              Text('Tùy Chỉnh Định Mức Chi Phí', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: gasCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Giá xăng RON95 (đ/lít)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: foodCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Ăn uống trung bình (đ/người/ngày)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: campCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Phí bãi trại / lều (đ/người/đêm)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.editorialPine),
              onPressed: () {
                final g = double.tryParse(gasCtrl.text);
                final f = int.tryParse(foodCtrl.text);
                final c = int.tryParse(campCtrl.text);
                if (mounted) {
                  setState(() {
                    if (g != null && g > 0) _gasPrice = g;
                    if (f != null && f >= 0) _foodPerDay = f;
                    if (c != null && c >= 0) _campFeePerNight = c;
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  List<String> _checklistItems = [];
  Set<String> _checkedItems = {};

  final List<Map<String, dynamic>> _vehicles = const [
    {'title': 'Xe máy số (110cc)', 'icon': Icons.two_wheeler, 'rate': 2.2},
    {'title': 'Xe cào cào', 'icon': Icons.motorcycle, 'rate': 3.2},
    {'title': 'Bán tải 4x4', 'icon': Icons.directions_car, 'rate': 9.5},
    {'title': 'Đi bộ Trekking', 'icon': Icons.hiking, 'rate': 0.0},
  ];

  Map<int, List<Map<String, dynamic>>> _daysItinerary = {};

  @override
  void initState() {
    super.initState();
    _initTripData();
    MainNavigationScreen.activeTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    MainNavigationScreen.activeTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() async {
    if (MainNavigationScreen.activeTabNotifier.value == 2 && mounted) {
      final tripIds = await StorageService.getTripDestinations();
      final currentIds = _tripDestinations.map((d) => d.id).toList();
      final isDifferent = tripIds.length != currentIds.length ||
          !tripIds.every((id) => currentIds.contains(id));
      if (isDifferent || _selectedDestination == null) {
        _initTripData();
      }
    }
  }

  Future<void> _initTripData() async {
    // 1. Tải danh sách địa điểm chuyến đi NGAY LẬP TỨC (Không chờ GPS chặn giao diện)
    final tripIds = await StorageService.getTripDestinations();
    final allDestinations = await ExploreLocalDataSource().getSeedDestinations();
    final List<Destination> loaded = [];

    for (final id in tripIds) {
      final found = allDestinations.where((d) => d.id == id);
      if (found.isNotEmpty) {
        loaded.add(found.first);
      } else {
        // Fallback đọc trực tiếp Custom Route từ SharedPreferences
        final cJson = await StorageService.getCustomRouteJson(id);
        if (cJson != null && cJson.isNotEmpty) {
          try {
            final decoded = jsonDecode(cJson) as Map<String, dynamic>;
            loaded.add(DestinationModel.fromJson(decoded));
          } catch (_) {}
        }
      }
    }

    // Khi người dùng đã xóa hết địa điểm: dọn sạch dữ liệu hành trình, giữ nguyên rỗng, không tự ý nạp lại
    if (loaded.isEmpty) {
      if (mounted) {
        setState(() {
          _tripDestinations = [];
          _selectedDestination = null;
          _daysItinerary = {};
          _checklistItems = [];
          _checkedItems = {};
          _isJourneyActive = false;
          _distanceFromUserKm = 0.0;
          _maxDays = 1;
          _selectedDay = 1;
        });
      }
      return;
    }

    final selectedId = await StorageService.getSelectedTripDestination();
    Destination? active;
    if (selectedId != null) {
      final matches = loaded.where((d) => d.id == selectedId);
      if (matches.isNotEmpty) {
        active = matches.first;
      }
    }
    active ??= loaded.isNotEmpty ? loaded.first : null;

    if (mounted) {
      setState(() {
        _tripDestinations = loaded;
      });
      if (active != null) {
        _selectDestination(active, updateChecklist: true);
      }
    }

    // 2. Lấy vị trí GPS trong nền bất đồng bộ để cập nhật khoảng cách (Tuyệt đối không await chặn UI)
    LocationService.getCurrentLocation().then((loc) {
      if (loc != null && mounted) {
        setState(() {
          _userLocation = loc;
          if (_selectedDestination != null) {
            final target = LatLng(
              _selectedDestination!.centerLatitude ?? 11.6420,
              _selectedDestination!.centerLongitude ?? 108.4230,
            );
            _distanceFromUserKm = const Distance().as(LengthUnit.Kilometer, loc, target);
          }
        });
      }
    });
  }

  Future<void> _selectDestination(Destination dest, {bool updateChecklist = true}) async {
    final target = LatLng(dest.centerLatitude ?? 11.6420, dest.centerLongitude ?? 108.4230);
    final directDist = const Distance().as(LengthUnit.Kilometer, _userLocation, target);

    // XỬ LÝ LỘ TRÌNH TỰ CHỌN A-B: Xóa sạch các mốc trekking giả định, chỉ tạo 2 mốc khởi hành và đến đích
    final isCustomRoute = dest.id.startsWith('custom_route_') || dest.categoryIds.contains('custom_route');
    if (isCustomRoute) {
      String startName = 'Điểm khởi hành (A)';
      String destName = 'Điểm đến (B)';
      String durationText = '';
      double distanceKm = dest.route?.distanceKm ?? directDist;

      try {
        final detailStr = await StorageService.getCustomRouteDetail(dest.id);
        if (detailStr != null && detailStr.isNotEmpty) {
          final decoded = jsonDecode(detailStr) as Map<String, dynamic>;
          startName = decoded['startName'] as String? ?? startName;
          destName = decoded['destName'] as String? ?? destName;
          durationText = decoded['durationText'] as String? ?? durationText;
          distanceKm = (decoded['distanceKm'] as num?)?.toDouble() ?? distanceKm;
        } else {
          final parts = dest.name.split('➔').map((s) => s.trim()).toList();
          if (parts.isNotEmpty) startName = parts[0];
          if (parts.length > 1) destName = parts[1];
        }
      } catch (_) {}

      final customItinerary = {
        1: [
          {
            'time': '07:30',
            'title': 'Khởi hành: $startName',
            'location': 'Điểm xuất phát A',
            'distance': '0 km',
            'desc': 'Bắt đầu chuyến đi theo lộ trình',
            'type': 'start',
            'isCompleted': false,
          },
          {
            'time': '11:00',
            'title': 'Đến đích: $destName',
            'location': 'Điểm đến B',
            'distance': '${distanceKm.toStringAsFixed(1)} km',
            'desc': durationText.isNotEmpty ? 'Thời gian dự kiến: $durationText' : 'Dự kiến tới đích an toàn',
            'type': 'destination',
            'isCompleted': false,
          },
        ],
      };

      setState(() {
        _selectedDestination = dest;
        _distanceFromUserKm = distanceKm;
        _maxDays = 1;
        _selectedDay = 1;
        _daysItinerary = customItinerary;
      });

      StorageService.setSelectedTripDestination(dest.id);

      if (updateChecklist) {
        _loadChecklistForDestination(dest);
      }
      return;
    }

    // Tính số ngày đề xuất sơ bộ qua ItineraryEngine
    final suggestedDays = ItineraryEngine.calculateSuggestedDays(directDist, dest.route?.estimatedDurationDays);
    final initialItinerary = ItineraryEngine.generateDynamicItinerary(
      dest: dest,
      distKm: directDist,
      totalDays: suggestedDays,
    );

    setState(() {
      _selectedDestination = dest;
      _distanceFromUserKm = directDist;
      _maxDays = suggestedDays;
      _selectedDay = 1;
      _daysItinerary = initialItinerary;
    });

    StorageService.setSelectedTripDestination(dest.id);

    if (updateChecklist) {
      _loadChecklistForDestination(dest);
    }

    // Tải cự ly đường bộ thực tế qua OSRM Routing (đảm bảo trong lãnh thổ quốc gia nếu nội địa)
    final isDomestic = dest.isDomestic('VN') || dest.countryIds.contains('vn') || dest.countryIds.contains('VN');
    final routeResult = await RoutingService.getActualRoute(
      start: _userLocation,
      end: target,
      isDomestic: isDomestic,
    );
    if (mounted && _selectedDestination?.id == dest.id) {
      // Cập nhật lại số ngày và lộ trình chi tiết theo cự ly thực tế chính xác qua ItineraryEngine
      final actualDays = ItineraryEngine.calculateSuggestedDays(routeResult.distanceKm, dest.route?.estimatedDurationDays);
      final dynamicItinerary = ItineraryEngine.generateDynamicItinerary(
        dest: dest,
        distKm: routeResult.distanceKm,
        totalDays: actualDays,
      );

      setState(() {
        _distanceFromUserKm = routeResult.distanceKm;
        _maxDays = actualDays;
        _daysItinerary = dynamicItinerary;
        if (_selectedDay > actualDays) {
          _selectedDay = 1;
        }
      });
    }
  }

  Future<void> _loadChecklistForDestination(Destination dest) async {
    // Đối với Lộ trình tự chọn A-B: Chỉ đưa danh sách vật dụng cơ bản, không sinh đồ leo núi cực đoan
    if (dest.id.startsWith('custom_route_') || dest.categoryIds.contains('custom_route')) {
      final customList = [
        'Giấy tờ tùy thân (CCCD & Bằng lái xe)',
        'Tiền mặt & Thẻ ngân hàng',
        'Điện thoại & Sạc pin dự phòng',
        'Nước uống & Đồ ăn nhẹ',
        'Áo mưa & Kính râm',
      ];
      final savedChecked = await StorageService.getChecklist();
      if (mounted) {
        setState(() {
          _checklistItems = customList;
          _checkedItems = savedChecked.toSet();
        });
      }
      return;
    }

    final weather = await WeatherService.getForecast(
      dest.centerLatitude ?? 11.9404,
      dest.centerLongitude ?? 108.4583,
    );
    final smartList = WeatherService.generateSmartChecklist(weather);

    // Bổ sung các vật phẩm đặc thù theo độ cao và tính chất địa danh
    if ((dest.elevationMeters ?? 0) > 1800) {
      if (!smartList.contains('Áo ấm giữ nhiệt chuyên dụng')) {
        smartList.insert(0, 'Áo ấm giữ nhiệt chuyên dụng (< 5°C)');
      }
      if (!smartList.contains('Thuốc chống sốc độ cao (Acetazolamide)')) {
        smartList.insert(1, 'Thuốc chống sốc độ cao (Acetazolamide)');
      }
    }

    final savedChecked = await StorageService.getChecklist();

    if (mounted) {
      setState(() {
        _checklistItems = smartList;
        _checkedItems = savedChecked.toSet();
      });
    }
  }

  /// Dialog thêm món đồ hành trang tùy chỉnh
  void _showAddChecklistItemDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.editorialSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
          side: const BorderSide(color: AppColors.editorialBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_task, color: AppColors.editorialPine, size: 20),
            SizedBox(width: 8),
            Text(
              'Thêm Món Đồ Chuẩn Bị',
              style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.editorialInk),
            ),
          ],
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Nhập tên đồ dùng (VD: Áo gió, Kính râm...)',
            hintStyle: const TextStyle(color: AppColors.editorialMuted, fontSize: 12.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.editorialMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.editorialPine,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (!_checklistItems.contains(text)) {
                    _checklistItems.add(text);
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm ngay', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Xóa 1 món đồ khỏi danh sách hành trang
  void _removeChecklistItem(String item) {
    HapticFeedback.selectionClick();
    setState(() {
      _checklistItems.remove(item);
      _checkedItems.remove(item);
    });
    StorageService.saveChecklist(_checkedItems.toList());
  }

  /// Dialog xác nhận xóa sạch toàn bộ địa điểm chuyến đi
  void _showClearAllDestinationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.editorialSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
          side: const BorderSide(color: AppColors.editorialBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppColors.emergencyRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Xóa Toàn Bộ Chuyến Đi?',
              style: TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.editorialInk),
            ),
          ],
        ),
        content: const Text(
          'Hành động này sẽ dọn sạch tất cả địa điểm và lộ trình hiện tại để bạn bắt đầu lập kế hoạch mới từ đầu.',
          style: TextStyle(fontSize: 13, color: AppColors.editorialMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ lại', style: TextStyle(color: AppColors.editorialMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              await StorageService.clearAllTripDestinations();
              if (mounted) {
                setState(() {
                  _tripDestinations = [];
                  _selectedDestination = null;
                  _daysItinerary = {};
                  _checklistItems = [];
                  _checkedItems = {};
                  _isJourneyActive = false;
                  _distanceFromUserKm = 0.0;
                });
              }
            },
            child: const Text('Xóa sạch', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDestination(Destination dest) async {
    HapticFeedback.mediumImpact();
    // 1. Optimistic UI: Xóa khỏi danh sách ngay lập tức trong RAM (0 mili-giây)
    final updatedList = List<Destination>.from(_tripDestinations)..removeWhere((d) => d.id == dest.id);

    if (updatedList.isEmpty) {
      setState(() {
        _tripDestinations = [];
        _selectedDestination = null;
        _daysItinerary = {};
        _checklistItems = [];
        _checkedItems = {};
        _isJourneyActive = false;
        _distanceFromUserKm = 0.0;
        _maxDays = 1;
        _selectedDay = 1;
      });
      await StorageService.removeTripDestination(dest.id);
      await StorageService.setSelectedTripDestination('');
      return;
    }

    Destination? newActive = _selectedDestination;
    if (_selectedDestination?.id == dest.id) {
      newActive = updatedList.first;
    }

    setState(() {
      _tripDestinations = updatedList;
    });

    if (newActive != null && newActive.id != _selectedDestination?.id) {
      _selectDestination(newActive, updateChecklist: true);
    }

    // 2. Ghi bộ nhớ ngầm không chặn UI
    StorageService.removeTripDestination(dest.id);
  }

  // Dự toán chi phí nhiên liệu tính theo cự ly thực tế và giá xăng thời gian thực
  int get _fuelCostPerPerson {
    final totalRoundTripKm = (_distanceFromUserKm * 2).clamp(30.0, 3500.0);
    const double passMultiplier = 1.30;

    final selected = _vehicles.firstWhere(
      (v) => v['title'] == _selectedVehicle,
      orElse: () => _vehicles[0],
    );
    final rate = selected['rate'] as double;
    if (rate == 0.0) return 0;

    final totalLiters = (totalRoundTripKm * passMultiplier / 100.0) * rate;
    return ((totalLiters * _gasPrice) / _participants).round();
  }

  int get _foodCostPerPerson => _maxDays * _foodPerDay;
  int get _campFeePerPerson => (_maxDays - 1) * _campFeePerNight;
  int get _totalCostPerPerson => _fuelCostPerPerson + _foodCostPerPerson + _campFeePerPerson;

  void _toggleCheckItem(String item) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_checkedItems.contains(item)) {
        _checkedItems.remove(item);
      } else {
        _checkedItems.add(item);
      }
    });
    StorageService.saveChecklist(_checkedItems.toList());
  }

  void _addNewDestinationModal() {
    HapticFeedback.mediumImpact();
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController(text: '14:00');
    final distanceController = TextEditingController(text: '3.5');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.editorialBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.editorialBorder, borderRadius: AppRadius.roundedPill),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thêm Mốc Lịch Trình Ngày $_selectedDay',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.editorialInk,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Tên hoạt động / Điểm dừng chân',
                  labelStyle: const TextStyle(color: AppColors.editorialMuted),
                  filled: true,
                  fillColor: AppColors.editorialSurface,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: const BorderSide(color: AppColors.editorialBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: const BorderSide(color: AppColors.editorialBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Địa điểm / Ghi chú (VD: Lấy nước suối)',
                  labelStyle: const TextStyle(color: AppColors.editorialMuted),
                  filled: true,
                  fillColor: AppColors.editorialSurface,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: const BorderSide(color: AppColors.editorialBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: const BorderSide(color: AppColors.editorialBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: timeController,
                      style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Thời gian (VD: 15:30)',
                        labelStyle: const TextStyle(color: AppColors.editorialMuted),
                        filled: true,
                        fillColor: AppColors.editorialSurface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.editorialBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.editorialBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Cự ly chặng (km)',
                        hintText: 'VD: 3.5 hoặc 8',
                        labelStyle: const TextStyle(color: AppColors.editorialMuted),
                        filled: true,
                        fillColor: AppColors.editorialSurface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.editorialBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.editorialBorder),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: BouncingButton(
                  onTap: () {
                    if (titleController.text.trim().isNotEmpty) {
                      final rawDist = distanceController.text.trim();
                      final formattedDist = rawDist.isEmpty
                          ? '+ 0 km'
                          : (rawDist.toLowerCase().contains('km')
                              ? (rawDist.startsWith('+') ? rawDist : '+ $rawDist')
                              : '+ $rawDist km');

                      setState(() {
                        _daysItinerary[_selectedDay]?.add({
                          'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          'time': timeController.text.trim().isEmpty ? '14:00' : timeController.text.trim(),
                          'title': titleController.text.trim(),
                          'location': locationController.text.trim().isEmpty ? 'Điểm mốc tự thêm' : locationController.text.trim(),
                          'type': 'custom',
                          'distance': formattedDist,
                          'elevation': '--',
                          'isCompleted': false,
                        });
                      });
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.editorialPine,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Center(
                      child: Text(
                        'Lưu Vào Lịch Trình',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bật/Tắt chế độ Đi Lịch Trình Thực Địa (Live Trekking Mode)
  void _toggleJourneyMode() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isJourneyActive = !_isJourneyActive;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: _isJourneyActive ? const Color(0xFF0F261B) : const Color(0xFF261814),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _isJourneyActive ? AppColors.emerald : AppColors.tacticalOrange,
            width: 1.5,
          ),
        ),
        content: Row(
          children: [
            Icon(
              _isJourneyActive ? Icons.navigation_rounded : Icons.pause_circle_filled_rounded,
              color: _isJourneyActive ? AppColors.emerald : AppColors.tacticalOrange,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isJourneyActive
                    ? 'Đã BẮT ĐẦU LỊCH TRÌNH THỰC ĐỊA! Chạm vào mốc hoặc dấu tick khi di chuyển đến để hoàn thành.'
                    : 'Đã tạm dừng chế độ hành trình thực địa.',
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Đánh dấu hoặc hủy đánh dấu hoàn thành một mốc lịch trình
  void _toggleMilestoneCompletion(Map<String, dynamic> stop) {
    HapticFeedback.mediumImpact();
    setState(() {
      final current = stop['isCompleted'] == true;
      stop['isCompleted'] = !current;
    });
    final isDone = stop['isCompleted'] == true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: const Color(0xFF141E18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDone ? AppColors.emerald : AppColors.editorialMuted,
            width: 1.2,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isDone ? AppColors.emerald : AppColors.editorialMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isDone ? 'Đã hoàn thành mốc: "${stop['title']}" ✓' : 'Đã bỏ đánh dấu mốc: "${stop['title']}"',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationLabel(Destination dest) {
    final reg = dest.regionId;
    if (reg.contains('tay_nguyen')) return 'Tây Nguyên, Việt Nam';
    if (reg.contains('tay_bac') || reg.contains('dong_bac') || reg.contains('mien_bac')) return 'Miền Bắc, Việt Nam';
    if (reg.contains('mien_trung')) return 'Miền Trung, Việt Nam';
    if (reg.contains('mien_nam')) return 'Miền Nam, Việt Nam';
    if (reg.contains('tay_nam_bo')) return 'Đồng Bằng Sông Cửu Long';
    if (reg.contains('intl_')) return 'Điểm đến Quốc Tế';
    return 'Việt Nam';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _checklistItems.isEmpty ? 0.0 : _checkedItems.length / _checklistItems.length;

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header, Trip Selector & Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 14, AppSpacing.space16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề & Nút Mở Bản Đồ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kế Hoạch Khám Phá',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialInk,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedDestination != null
                                ? '${_selectedDestination!.name} • ${_maxDays}N${_maxDays - 1}Đ'
                                : 'Chọn địa điểm chuyến đi',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.editorialPine,
                            ),
                          ),
                        ],
                      ),
                      BouncingButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          MainNavigationScreen.switchToTab(1); // Chuyển sang Tab Bản đồ
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurface,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(color: AppColors.editorialPine, width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_outlined, size: 14, color: AppColors.editorialPine),
                              SizedBox(width: 4),
                              Text(
                                'XEM BẢN ĐỒ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.editorialPine,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Thanh chọn địa điểm chuyến đi (Trip Destinations Ribbon)
                  if (_tripDestinations.isNotEmpty) ...[
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _tripDestinations.length + 2,
                        itemBuilder: (context, index) {
                          if (index == _tripDestinations.length) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: BouncingButton(
                                onTap: () => MainNavigationScreen.switchToTab(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.editorialSurface,
                                    borderRadius: AppRadius.roundedPill,
                                    border: Border.all(color: AppColors.editorialBorder),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, size: 14, color: AppColors.editorialPine),
                                      SizedBox(width: 4),
                                      Text(
                                        'Thêm điểm',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.editorialPine),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          if (index == _tripDestinations.length + 1) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: BouncingButton(
                                onTap: _showClearAllDestinationsDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.emergencyRed.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.roundedPill,
                                    border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 14, color: AppColors.emergencyRed),
                                      SizedBox(width: 4),
                                      Text(
                                        'Xóa tất cả',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emergencyRed),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final dest = _tripDestinations[index];
                          final isSelected = _selectedDestination?.id == dest.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: BouncingButton(
                              onTap: () => _selectDestination(dest),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
                                  borderRadius: AppRadius.roundedPill,
                                  border: Border.all(
                                    color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.editorialPine.withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.place,
                                      size: 13,
                                      color: isSelected ? Colors.white : AppColors.editorialMuted,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      dest.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.editorialInk,
                                      ),
                                    ),
                                    // Cho phép xóa bất kỳ địa điểm nào kể cả điểm cuối cùng
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeDestination(dest),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white24 : AppColors.editorialBorder,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 12,
                                          color: isSelected ? Colors.white : AppColors.editorialMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Destination Info Summary Card
                  if (_selectedDestination != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.editorialBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.terrain_outlined, size: 16, color: AppColors.editorialTerracotta),
                              const SizedBox(width: 6),
                              Text(
                                _getLocationLabel(_selectedDestination!),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.editorialInk),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Cự ly: ${_distanceFromUserKm.toStringAsFixed(0)} km',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.editorialPine),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•  Độ cao: ${_selectedDestination!.elevationDisplay}',
                                style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Chỉ hiển thị Progress Bar và 2-Tab Selector khi chuyến đi có ít nhất 1 địa điểm
                  if (_tripDestinations.isNotEmpty) ...[
                    // Progress Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.editorialBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tiến độ chuẩn bị hành trang',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.editorialInk,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.editorialPine,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: AppRadius.roundedPill,
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: AppColors.editorialBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.editorialPine),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Main 2-Tab Selector
                    Row(
                      children: [
                        _buildHeaderTab(0, 'Trục Lộ Trình (Timeline)', Icons.timeline),
                        const SizedBox(width: 8),
                        _buildHeaderTab(1, 'Hành Trang & Chi Phí', Icons.account_balance_wallet_outlined),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Tab Content Body: Khi không có địa điểm thì ẩn toàn bộ và hiển thị Empty State toàn màn hình
            Expanded(
              child: _tripDestinations.isEmpty
                  ? _buildEmptyTripPlannerView()
                  : (_activeTab == 0 ? _buildContinuousTimelineView() : _buildBudgetAndPackView()),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện Trạng thái Rỗng toàn màn hình khi chưa có hoặc đã xóa hết địa điểm
  Widget _buildEmptyTripPlannerView() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.editorialPine.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.editorialPine.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.alt_route_rounded, size: 40, color: AppColors.editorialPine),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa Có Địa Điểm Nào Trong Kế Hoạch',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.editorialInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn có thể tự chọn tuyến đường xuất phát và đích đến (A ➔ B) trên bản đồ, hoặc chọn các đỉnh núi, đèo dốc từ mục Khám phá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.editorialMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: BouncingButton(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  MainNavigationScreen.openCustomRouteOnMap = true;
                  MainNavigationScreen.switchToTab(1);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.editorialPine, Color(0xFF143022)],
                    ),
                    borderRadius: AppRadius.roundedMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.editorialPine.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_road_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'TẠO LỘ TRÌNH A-B TRÊN BẢN ĐỒ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: BouncingButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  MainNavigationScreen.switchToTab(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.editorialSurface,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.editorialBorder, width: 1.2),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore_outlined, color: AppColors.editorialInk, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Khám Phá Địa Danh Mới',
                          style: TextStyle(color: AppColors.editorialInk, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTab(int tabIndex, String label, IconData icon) {
    final isSelected = _activeTab == tabIndex;
    return Expanded(
      child: BouncingButton(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeTab = tabIndex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : AppColors.editorialMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.editorialInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: CONTINUOUS TRAIL TIMELINE VIEW (STICKY HEADER CHỌN NGÀY & THÊM MỐC)
  Widget _buildContinuousTimelineView() {
    final currentDayStops = _daysItinerary[_selectedDay] ?? [];
    final availableDays = List.generate(_maxDays, (i) => i + 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final headerWidget = _buildStickyTimelineHeader(availableDays, currentDayStops);
        final timelineContent = _buildTimelineListContent(currentDayStops);

        // Khi chiều cao khả dụng thấp (< 280px như test runner 800x600 hoặc màn hình xoay ngang):
        // Cho phép cuộn toàn bộ trong 1 ListView duy nhất tránh RenderFlex Overflow
        if (constraints.maxHeight < 280) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              headerWidget,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 4),
                child: timelineContent,
              ),
              const SizedBox(height: 40),
            ],
          );
        }

        // Màn hình dọc chuẩn: Header ghim cố định bên trên, cuộn các mốc bên dưới
        return Column(
          children: [
            headerWidget,
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 4),
                children: [
                  timelineContent,
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStickyTimelineHeader(List<int> availableDays, List<Map<String, dynamic>> currentDayStops) {
    return Container(
          color: AppColors.editorialBg,
          padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 8, AppSpacing.space16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Day Selector Ribbon
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableDays.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final day = availableDays[idx];
                    final isSelected = _selectedDay == day;
                    final String daySublabel = day == 1
                        ? 'Khởi hành'
                        : (day == _maxDays
                            ? 'Hồi hương'
                            : (_maxDays <= 3 ? 'Khám phá' : 'Chặng 0${day - 1}'));

                    return BouncingButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDay = day);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        constraints: const BoxConstraints(minWidth: 86),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(
                            color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.editorialPine.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NGÀY ${day < 10 ? '0$day' : '$day'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : AppColors.editorialPine,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              daySublabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.editorialInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 2. Lịch thời gian thực của chặng đang chọn
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.editorialSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.editorialBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.editorialPine),
                        const SizedBox(width: 8),
                        Text(
                          _currentDayDateFormatted,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                        ),
                      ],
                    ),
                    BouncingButton(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.editorialSurfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.editorialBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_calendar, size: 12, color: AppColors.editorialPine),
                            SizedBox(width: 4),
                            Text('Đổi ngày', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.editorialPine)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 2.5 NÚT BẮT ĐẦU LỊCH TRÌNH / BANNER TRẠNG THÁI HÀNH TRÌNH LIVE TREKKING
              if (!_isJourneyActive)
                BouncingButton(
                  onTap: _toggleJourneyMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B3B2B), Color(0xFF14291F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.summitGold.withValues(alpha: 0.6), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.summitGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BẮT ĐẦU LỊCH TRÌNH THỰC TẾ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Check-in & tick xanh từng mốc khi di chuyển',
                                style: TextStyle(color: AppColors.summitGold, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.summitGold, size: 20),
                      ],
                    ),
                  ),
                )
              else ...[
                // Banner đang chạy Live Trekking HUD
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F261B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                                decoration: const BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'HÀNH TRÌNH ĐANG DIỄN RA (LIVE)',
                                style: TextStyle(
                                  color: AppColors.emerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          BouncingButton(
                            onTap: _toggleJourneyMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E1C1A),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.editorialTerracotta.withValues(alpha: 0.6)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stop_rounded, size: 12, color: AppColors.editorialTerracotta),
                                  SizedBox(width: 3),
                                  Text(
                                    'Kết thúc',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.editorialTerracotta),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final completed = currentDayStops.where((s) => s['isCompleted'] == true).length;
                        final total = currentDayStops.length;
                        final pct = total == 0 ? 0.0 : (completed / total);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tiến độ ngày $_selectedDay: $completed/$total mốc',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${(pct * 100).round()}% Hoàn thành',
                                  style: const TextStyle(color: AppColors.emerald, fontSize: 11.5, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                color: AppColors.emerald,
                                backgroundColor: const Color(0xFF1B3B2B),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // 3. Action Add Stop Button (Ghim cố định)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trục Lộ Trình Ngày $_selectedDay (${currentDayStops.length} mốc)',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                    ),
                  ),
                  BouncingButton(
                    onTap: _addNewDestinationModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.editorialPine.withValues(alpha: 0.1),
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(color: AppColors.editorialPine.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: AppColors.editorialPine),
                          SizedBox(width: 4),
                          Text(
                            'Thêm mốc',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.editorialPine),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildTimelineListContent(List<Map<String, dynamic>> currentDayStops) {
    if (currentDayStops.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.editorialSurface,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: AppColors.editorialBorder),
        ),
        child: const Center(
          child: Text(
            'Chưa có mốc lịch trình cho ngày này. Hãy bấm "Thêm mốc" để lập kế hoạch!',
            style: TextStyle(fontSize: 12, color: AppColors.editorialMuted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentDayStops.length,
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = currentDayStops.removeAt(oldIndex);
                currentDayStops.insert(newIndex, item);
              });
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context, index) {
              final stop = currentDayStops[index];
              final isStart = index == 0;
              final isEnd = index == currentDayStops.length - 1;
              final isCompleted = stop['isCompleted'] == true;

              return Padding(
                key: ValueKey(stop['id']),
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Spine
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _toggleMilestoneCompletion(stop),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.emerald
                                    : (isStart
                                        ? AppColors.editorialPine
                                        : (isEnd ? AppColors.editorialTerracotta : AppColors.editorialSurface)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted ? Colors.white : (isStart || isEnd ? Colors.white : AppColors.editorialPine),
                                  width: 2,
                                ),
                                boxShadow: isCompleted
                                    ? [
                                        BoxShadow(
                                          color: AppColors.emerald.withValues(alpha: 0.45),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_rounded
                                      : (isStart ? Icons.flag : (isEnd ? Icons.check : Icons.circle)),
                                  size: isCompleted ? 14 : 11,
                                  color: isCompleted || isStart || isEnd ? Colors.white : AppColors.editorialPine,
                                ),
                              ),
                            ),
                          ),
                          if (!isEnd)
                            Container(
                              width: 2.5,
                              height: 68,
                              color: isCompleted ? AppColors.emerald : AppColors.editorialBorder,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Right Timeline Entry
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF132219)
                              : AppColors.editorialSurface,
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(
                            color: isCompleted ? AppColors.emerald : AppColors.editorialBorder,
                            width: isCompleted ? 1.6 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isCompleted
                                  ? AppColors.emerald.withValues(alpha: 0.1)
                                  : const Color(0x0817221B),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _toggleMilestoneCompletion(stop),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          stop['time'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isCompleted ? AppColors.emerald : AppColors.editorialPine,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? AppColors.emerald.withValues(alpha: 0.15)
                                                : AppColors.editorialBg,
                                            borderRadius: AppRadius.roundedSm,
                                            border: Border.all(
                                              color: isCompleted
                                                  ? AppColors.emerald.withValues(alpha: 0.4)
                                                  : AppColors.editorialBorder,
                                            ),
                                          ),
                                          child: Text(
                                            stop['distance'] as String,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isCompleted ? AppColors.emerald : AppColors.editorialMuted,
                                            ),
                                          ),
                                        ),
                                        if (isCompleted) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.emerald.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_rounded, size: 10, color: AppColors.emerald),
                                                SizedBox(width: 3),
                                                Text(
                                                  'HOÀN THÀNH',
                                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.emerald),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      stop['title'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCompleted ? AppColors.emerald : AppColors.editorialInk,
                                      ),
                                    ),
                                    Text(
                                      stop['location'] as String,
                                      style: const TextStyle(fontSize: 12, color: AppColors.editorialMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Micro Action Controls (Check-in Tick Button + Up / Down / Drag Handle)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Check-in Button
                                BouncingButton(
                                  onTap: () => _toggleMilestoneCompletion(stop),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Icon(
                                      isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                      color: isCompleted ? AppColors.emerald : AppColors.editorialMuted,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (index > 0)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        final item = currentDayStops.removeAt(index);
                                        currentDayStops.insert(index - 1, item);
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.arrow_upward, size: 16, color: AppColors.editorialMuted),
                                    ),
                                  ),
                                if (index < currentDayStops.length - 1)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        final item = currentDayStops.removeAt(index);
                                        currentDayStops.insert(index + 1, item);
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.arrow_downward, size: 16, color: AppColors.editorialMuted),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.editorialBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.drag_indicator, size: 18, color: AppColors.editorialPine),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  // TAB 2: BUDGET & PACK VIEW
  Widget _buildBudgetAndPackView() {
    final fuel = _fuelCostPerPerson;
    final food = _foodCostPerPerson;
    final camp = _campFeePerPerson;
    final total = _totalCostPerPerson;

    final fuelPct = total == 0 ? 0.0 : (fuel / total);
    final foodPct = total == 0 ? 0.0 : (food / total);
    final campPct = total == 0 ? 0.0 : (camp / total);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // Budget Breakdown Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.editorialSurface,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: AppColors.editorialBorder, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C17221B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dự Toán Chi Phí',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.editorialInk,
                        ),
                      ),
                      const SizedBox(width: 6),
                      BouncingButton(
                        onTap: _showCostConfigDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.editorialBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune, size: 12, color: AppColors.editorialPine),
                              SizedBox(width: 2),
                              Text('Tùy chỉnh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.editorialPine)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ/người',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialPine,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segmented Cost Bar
              ClipRRect(
                borderRadius: AppRadius.roundedPill,
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      Expanded(flex: (fuelPct * 100).toInt().clamp(1, 100), child: Container(color: AppColors.editorialTerracotta)),
                      Expanded(flex: (foodPct * 100).toInt().clamp(1, 100), child: Container(color: AppColors.editorialPine)),
                      Expanded(flex: (campPct * 100).toInt().clamp(1, 100), child: Container(color: const Color(0xFF638C6D))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendItem('Nhiên liệu', AppColors.editorialTerracotta, fuel),
                  _buildLegendItem('Ăn uống', AppColors.editorialPine, food),
                  _buildLegendItem('Trại & Bãi', const Color(0xFF638C6D), camp),
                ],
              ),
              const Divider(height: 24, color: AppColors.editorialBorder),

              // Vehicle selector
              const Text('Phương tiện di chuyển:', style: TextStyle(color: AppColors.editorialMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: _vehicles.map((v) {
                  final isSelected = v['title'] == _selectedVehicle;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: BouncingButton(
                        onTap: () => setState(() => _selectedVehicle = v['title'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.editorialPine.withValues(alpha: 0.1) : AppColors.editorialBg,
                            borderRadius: AppRadius.roundedSm,
                            border: Border.all(
                              color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                v['icon'] as IconData,
                                size: 18,
                                color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                v['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.editorialPine : AppColors.editorialInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Participants Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số người tham gia:', style: TextStyle(color: AppColors.editorialMuted, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.editorialPine),
                        onPressed: _participants > 1 ? () => setState(() => _participants--) : null,
                      ),
                      Text('$_participants', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.editorialInk)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.editorialPine),
                        onPressed: () => setState(() => _participants++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Packing Checklist Header with "+ Thêm đồ" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hành Trang Chuẩn Bị (${_checkedItems.length}/${_checklistItems.length})',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.editorialInk,
              ),
            ),
            BouncingButton(
              onTap: _showAddChecklistItemDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.editorialPine.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(color: AppColors.editorialPine.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: AppColors.editorialPine),
                    SizedBox(width: 4),
                    Text(
                      '+ Thêm đồ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.editorialPine),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_checklistItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.editorialSurface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.editorialBorder),
            ),
            child: const Center(
              child: Text(
                'Chưa có vật dụng nào trong danh sách.\nHãy nhấn "+ Thêm đồ" để chuẩn bị hành trang cho chuyến đi!',
                style: TextStyle(fontSize: 12.5, color: AppColors.editorialMuted, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ..._checklistItems.map((item) {
            final isChecked = _checkedItems.contains(item);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.editorialSurface,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(
                  color: isChecked ? AppColors.editorialPine.withValues(alpha: 0.4) : AppColors.editorialBorder,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0617221B),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isChecked ? AppColors.editorialPine : AppColors.editorialBorder,
                  size: 20,
                ),
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    color: isChecked ? AppColors.editorialMuted : AppColors.editorialInk,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.editorialMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Xóa món này',
                  onPressed: () => _removeChecklistItem(item),
                ),
                onTap: () => _toggleCheckItem(item),
              ),
            );
          }),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color, int cost) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.editorialMuted)),
            Text(
              '${(cost / 1000).toInt()}k',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.editorialInk),
            ),
          ],
        ),
      ],
    );
  }
}
