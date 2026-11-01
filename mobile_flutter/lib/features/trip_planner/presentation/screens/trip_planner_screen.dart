import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/offline_map/services/routing_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _activeTab = 0; // 0: Lịch trình (Timeline), 1: Chi phí & Hành trang
  int _selectedDay = 1; // 1, 2, 3
  int _participants = 4;
  String _selectedVehicle = 'Xe máy số (110cc)';

  List<Destination> _tripDestinations = [];
  Destination? _selectedDestination;
  LatLng _userLocation = const LatLng(10.8231, 106.6297); // Vị trí GPS hiện tại (Mặc định TP.HCM)
  double _distanceFromUserKm = 180.0;
  int _maxDays = 3;

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
  }

  Future<void> _initTripData() async {
    // 1. Lấy vị trí GPS hiện tại
    final loc = await LocationService.getCurrentLocation();
    if (loc != null) {
      _userLocation = loc;
    }

    // 2. Tải danh sách địa điểm chuyến đi
    final tripIds = await StorageService.getTripDestinations();
    final allDestinations = await ExploreLocalDataSource().getSeedDestinations();
    final List<Destination> loaded = [];

    for (final id in tripIds) {
      final found = allDestinations.where((d) => d.id == id);
      if (found.isNotEmpty) {
        loaded.add(found.first);
      }
    }

    if (loaded.isEmpty && allDestinations.isNotEmpty) {
      loaded.addAll(allDestinations.take(2));
      await StorageService.saveTripDestinations(loaded.map((d) => d.id).toList());
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
  }

  Future<void> _selectDestination(Destination dest, {bool updateChecklist = true}) async {
    final target = LatLng(dest.centerLatitude ?? 11.6420, dest.centerLongitude ?? 108.4230);
    final dist = const Distance().as(LengthUnit.Kilometer, _userLocation, target);

    // Tính số ngày dự kiến theo cung đường
    int days = dest.route?.estimatedDurationDays ?? 2;
    if (days < 1) days = 1;
    if (days > 3) days = 3;

    final itinerary = _generateItinerary(dest, days);

    setState(() {
      _selectedDestination = dest;
      _distanceFromUserKm = dist;
      _maxDays = days;
      _selectedDay = 1;
      _daysItinerary = itinerary;
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
      setState(() {
        _distanceFromUserKm = routeResult.distanceKm;
      });
    }
  }

  Map<int, List<Map<String, dynamic>>> _generateItinerary(Destination dest, int days) {
    final Map<int, List<Map<String, dynamic>>> result = {};
    for (int i = 1; i <= days; i++) {
      result[i] = [];
    }

    // Nếu điểm đến có các chặng trekking thực tế (route.stages)
    if (dest.route != null && dest.route!.stages.isNotEmpty) {
      final stages = dest.route!.stages;
      for (int i = 0; i < stages.length; i++) {
        final stage = stages[i];
        final dayIndex = ((i / stages.length) * days).floor() + 1;
        final targetDay = dayIndex.clamp(1, days);

        result[targetDay]?.add({
          'id': 'stage_${dest.id}_${stage.stageNumber}',
          'time': i == 0 ? '07:30' : (i == stages.length - 1 ? '16:00' : '11:45'),
          'title': stage.title,
          'location': stage.description,
          'type': i == 0 ? 'start' : (i == stages.length - 1 ? 'finish' : 'checkpoint'),
          'distance': stage.distanceKm != null ? '+ ${stage.distanceKm} km' : '+ 6 km',
          'elevation': stage.elevationGainMeters != null ? '+${stage.elevationGainMeters}m' : '--',
        });
      }
    } else {
      // Nếu là điểm dã ngoại tự do, sinh các mốc hợp lý
      result[1]?.addAll([
        {
          'id': 'd1_start_${dest.id}',
          'time': '06:00',
          'title': 'Khởi hành tới ${dest.name}',
          'location': 'Tập kết đoàn dã ngoại & kiểm tra xe cộ',
          'type': 'start',
          'distance': '0 km',
          'elevation': '0m',
        },
        {
          'id': 'd1_mid_${dest.id}',
          'time': '12:00',
          'title': 'Đến trạm trung chuyển ${dest.name}',
          'location': 'Ăn trưa đặc sản vùng miền & chuẩn bị đồ',
          'type': 'checkpoint',
          'distance': '+ ${_distanceFromUserKm.toStringAsFixed(0)} km',
          'elevation': dest.elevationDisplay,
        },
        {
          'id': 'd1_camp_${dest.id}',
          'time': '16:30',
          'title': 'Hạ trại & ngắm hoàng hôn',
          'location': 'Dựng lều, nổi lửa và trải nghiệm thiên nhiên',
          'type': 'camp',
          'distance': '+ 5 km',
          'elevation': dest.elevationDisplay,
        },
      ]);

      if (days >= 2) {
        result[2]?.addAll([
          {
            'id': 'd2_sun_${dest.id}',
            'time': '05:30',
            'title': 'Đón bình minh & săn mây',
            'location': 'Điểm ngắm cảnh đẹp nhất tại ${dest.name}',
            'type': 'highlight',
            'distance': '+ 3 km',
            'elevation': dest.elevationDisplay,
          },
          {
            'id': 'd2_back_${dest.id}',
            'time': '14:00',
            'title': 'Thu dọn hành trang & hạ sơn',
            'location': 'Dọn sạch rác, bảo vệ cảnh quan tự nhiên',
            'type': 'finish',
            'distance': '+ 10 km',
            'elevation': '0m',
          },
        ]);
      }

      if (days >= 3) {
        result[3]?.addAll([
          {
            'id': 'd3_fin_${dest.id}',
            'time': '11:00',
            'title': 'Hoàn thành hành trình khám phá',
            'location': 'Trở về điểm xuất phát an toàn',
            'type': 'finish',
            'distance': '+ 0 km',
            'elevation': '0m',
          },
        ]);
      }
    }

    return result;
  }

  Future<void> _loadChecklistForDestination(Destination dest) async {
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

  Future<void> _removeDestination(Destination dest) async {
    HapticFeedback.mediumImpact();
    await StorageService.removeTripDestination(dest.id);
    await _initTripData();
  }

  // Dự toán chi phí nhiên liệu tính theo cự ly thực tế
  int get _fuelCostPerPerson {
    final totalRoundTripKm = (_distanceFromUserKm * 2).clamp(30.0, 3500.0);
    const double passMultiplier = 1.30;
    const double gasPrice = 24000.0;

    final selected = _vehicles.firstWhere(
      (v) => v['title'] == _selectedVehicle,
      orElse: () => _vehicles[0],
    );
    final rate = selected['rate'] as double;
    if (rate == 0.0) return 0;

    final totalLiters = (totalRoundTripKm * passMultiplier / 100.0) * rate;
    return ((totalLiters * gasPrice) / _participants).round();
  }

  int get _foodCostPerPerson => _maxDays * 220000;
  int get _campFeePerPerson => (_maxDays - 1) * 120000;
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
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController(text: '14:00');

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
              TextField(
                controller: timeController,
                style: const TextStyle(color: AppColors.editorialInk, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Thời gian dự kiến (VD: 15:30)',
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: BouncingButton(
                  onTap: () {
                    if (titleController.text.trim().isNotEmpty) {
                      setState(() {
                        _daysItinerary[_selectedDay]?.add({
                          'id': 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          'time': timeController.text.trim(),
                          'title': titleController.text.trim(),
                          'location': locationController.text.trim().isEmpty ? 'Điểm mốc tự thêm' : locationController.text.trim(),
                          'type': 'custom',
                          'distance': '+ 5 km',
                          'elevation': '--',
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
                        itemCount: _tripDestinations.length + 1,
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
                                    if (_tripDestinations.length > 1) ...[
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _removeDestination(dest),
                                        child: Icon(
                                          Icons.close,
                                          size: 13,
                                          color: isSelected ? Colors.white70 : AppColors.editorialMuted,
                                        ),
                                      ),
                                    ],
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
              ),
            ),

            // Tab Content Body
            Expanded(
              child: _activeTab == 0 ? _buildContinuousTimelineView() : _buildBudgetAndPackView(),
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

  // TAB 1: CONTINUOUS TRAIL TIMELINE VIEW
  Widget _buildContinuousTimelineView() {
    final currentDayStops = _daysItinerary[_selectedDay] ?? [];
    final availableDays = List.generate(_maxDays, (i) => i + 1);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // Day Selector Ribbon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: availableDays.map((day) {
            final isSelected = _selectedDay == day;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BouncingButton(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.editorialSurface : AppColors.editorialBg,
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'NGÀY 0$day',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day == 1 ? 'Khởi hành' : (day == 2 ? 'Khám phá' : 'Hạ sơn'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.editorialInk,
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

        const SizedBox(height: 16),

        // Action Add Stop Button
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

        const SizedBox(height: 14),

        // Timeline Spine
        if (currentDayStops.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
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
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
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
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isStart
                                  ? AppColors.editorialPine
                                  : (isEnd ? AppColors.editorialTerracotta : AppColors.editorialSurface),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isStart || isEnd ? Colors.white : AppColors.editorialPine,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                isStart ? Icons.flag : (isEnd ? Icons.check : Icons.circle),
                                size: 11,
                                color: isStart || isEnd ? Colors.white : AppColors.editorialPine,
                              ),
                            ),
                          ),
                          if (!isEnd)
                            Container(
                              width: 2,
                              height: 68,
                              color: AppColors.editorialBorder,
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
                          color: AppColors.editorialSurface,
                          borderRadius: AppRadius.roundedMd,
                          border: Border.all(color: AppColors.editorialBorder, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0817221B),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        stop['time'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.editorialPine,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.editorialBg,
                                          borderRadius: AppRadius.roundedSm,
                                          border: Border.all(color: AppColors.editorialBorder),
                                        ),
                                        child: Text(
                                          stop['distance'] as String,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.editorialMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stop['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.editorialInk,
                                    ),
                                  ),
                                  Text(
                                    stop['location'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.editorialMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.drag_indicator, size: 18, color: AppColors.editorialBorder),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        const SizedBox(height: 40),
      ],
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
                  const Text(
                    'Dự Toán Chi Phí',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                    ),
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

        // Packing Checklist
        Text(
          'Hành Trang Chuẩn Bị (${_checkedItems.length}/${_checklistItems.length})',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.editorialInk,
          ),
        ),
        const SizedBox(height: 8),

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
