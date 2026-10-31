import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
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

  List<String> _checklistItems = [];
  Set<String> _checkedItems = {};

  final List<Map<String, dynamic>> _vehicles = const [
    {'title': 'Xe máy số (110cc)', 'icon': Icons.two_wheeler, 'rate': 2.2},
    {'title': 'Xe cào cào', 'icon': Icons.motorcycle, 'rate': 3.2},
    {'title': 'Bán tải 4x4', 'icon': Icons.directions_car, 'rate': 9.5},
    {'title': 'Đi bộ Trekking', 'icon': Icons.hiking, 'rate': 0.0},
  ];

  final Map<int, List<Map<String, dynamic>>> _daysItinerary = {
    1: [
      {
        'id': 'd1_1',
        'time': '05:30',
        'title': 'Xuất phát từ TP. Đà Lạt',
        'location': 'Tập kết tại Bến xe Liên tỉnh',
        'type': 'start',
        'distance': '0 km',
        'elevation': '1,485m',
      },
      {
        'id': 'd1_2',
        'time': '08:00',
        'title': 'Bìa rừng Ma Bó (Lâm Đồng)',
        'location': 'Gặp kiểm lâm & gửi xe máy',
        'type': 'checkpoint',
        'distance': '+ 60 km',
        'elevation': '1,200m',
      },
      {
        'id': 'd1_3',
        'time': '12:30',
        'title': 'Nghỉ trưa tại Đồi Cỏ 1',
        'location': 'Ăn lương khô & tiếp nước',
        'type': 'rest',
        'distance': '+ 14 km',
        'elevation': '1,150m',
      },
      {
        'id': 'd1_4',
        'time': '16:45',
        'title': 'Hạ trại Đồi Cỏ Cháy',
        'location': 'Dựng lều, nhóm lửa & ngắm hoàng hôn',
        'type': 'camp',
        'distance': '+ 12 km',
        'elevation': '1,100m',
      },
    ],
    2: [
      {
        'id': 'd2_1',
        'time': '05:00',
        'title': 'Đón bình minh Sống Lưng Khủng Long',
        'location': 'Điểm check-in đẹp nhất miền Nam',
        'type': 'highlight',
        'distance': '+ 3 km',
        'elevation': '1,100m',
      },
      {
        'id': 'd2_2',
        'time': '08:30',
        'title': 'Hạ sơn vào địa phận Bình Thuận',
        'location': 'Chuyển từ đồi cỏ sang rừng khộp',
        'type': 'checkpoint',
        'distance': '+ 15 km',
        'elevation': '650m',
      },
      {
        'id': 'd2_3',
        'time': '16:00',
        'title': 'Hạ trại ven Suối Cạn Phan Dũng',
        'location': 'Lấy nước ngọt tự nhiên & cắm trại',
        'type': 'camp',
        'distance': '+ 11 km',
        'elevation': '320m',
      },
    ],
    3: [
      {
        'id': 'd3_1',
        'time': '06:30',
        'title': 'Rời bãi cắm trại ven suối',
        'location': 'Dọn sạch rác bảo vệ thiên nhiên',
        'type': 'start',
        'distance': '+ 0 km',
        'elevation': '320m',
      },
      {
        'id': 'd3_2',
        'time': '11:00',
        'title': 'Đến UBND Xã Phan Dũng',
        'location': 'Hoàn thành 55km cung đường huyền thoại',
        'type': 'finish',
        'distance': '+ 10 km',
        'elevation': '150m',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final weather = await WeatherService.getForecast(11.9404, 108.4583);
    final smartList = WeatherService.generateSmartChecklist(weather);
    final savedChecked = await StorageService.getChecklist();

    if (mounted) {
      setState(() {
        _checklistItems = smartList;
        _checkedItems = savedChecked.toSet();
      });
    }
  }

  int get _fuelCostPerPerson {
    const double distanceKm = 180.0;
    const double passMultiplier = 1.35;
    const double gasPrice = 24000.0;

    final selected = _vehicles.firstWhere(
      (v) => v['title'] == _selectedVehicle,
      orElse: () => _vehicles[0],
    );
    final rate = selected['rate'] as double;
    if (rate == 0.0) return 0;

    final totalLiters = (distanceKm * passMultiplier / 100.0) * rate;
    return ((totalLiters * gasPrice) / _participants).round();
  }

  int get _foodCostPerPerson => 3 * 250000;
  int get _campFeePerPerson => 150000;
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
      backgroundColor: AppColors.surfaceElevated,
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
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: AppRadius.roundedPill),
                ),
              ),
              const SizedBox(height: 16),
              Text('Thêm Mốc Lịch Trình Ngày $_selectedDay', style: AppTypography.headlineMedium.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Tên hoạt động / Điểm đến',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Địa điểm / Ghi chú (VD: Lấy nước suối)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Thời gian dự kiến (VD: 15:30)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
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
                      gradient: AppColors.emeraldGradient,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Center(
                      child: Text('Lưu Vào Lịch Trình', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
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

  @override
  Widget build(BuildContext context) {
    final progress = _checklistItems.isEmpty ? 0.0 : _checkedItems.length / _checklistItems.length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Trip Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 12, AppSpacing.space16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kế Hoạch Khám Phá',
                            style: AppTypography.displayHero.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tà Năng - Phan Dũng • 3N2Đ (55km)',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.emerald),
                          ),
                        ],
                      ),
                      TacticalPill(
                        icon: Icons.flag,
                        text: 'SẴN SÀNG',
                        color: AppColors.tacticalOrange,
                        backgroundColor: AppColors.surfaceHigh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Progress Bar
                  Container(
                    padding: const EdgeInsets.all(12),
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
                            Text('Tiến độ chuẩn bị hành trang', style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                            Text('${(progress * 100).toInt()}%', style: AppTypography.labelMetric.copyWith(color: AppColors.emerald)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: AppRadius.roundedPill,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.emerald : AppColors.surfaceHigh,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: isSelected ? AppColors.emerald : AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.black : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: CONTINUOUS TRAIL TIMELINE VIEW (Phá vỡ cấu trúc Card rập khuôn)
  Widget _buildContinuousTimelineView() {
    final currentDayStops = _daysItinerary[_selectedDay] ?? [];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: 8),
      children: [
        // Day Selector Ribbon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [1, 2, 3].map((day) {
            final isSelected = _selectedDay == day;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BouncingButton(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceHigh : AppColors.surfaceBase,
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('NGÀY 0$day', style: AppTypography.captionBadge.copyWith(color: isSelected ? AppColors.emerald : AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(day == 1 ? 'Khởi hành' : (day == 2 ? 'Sống lưng' : 'Hạ sơn'), style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 18),

        // Action Add Stop Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trục Lộ Trình Ngày $_selectedDay (${currentDayStops.length} mốc)', style: AppTypography.headlineMedium.copyWith(fontSize: 16)),
            BouncingButton(
              onTap: _addNewDestinationModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: AppColors.emerald),
                    SizedBox(width: 4),
                    Text('Thêm mốc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Continuous Timeline Spine (Dòng thời gian nối trục sống động)
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
                  // Left Spine: Vertical line with circular waypoint node
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isStart ? AppColors.emerald : (isEnd ? AppColors.neonGreen : AppColors.surfaceElevated),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isStart || isEnd ? Colors.white : AppColors.tacticalOrange,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isStart ? Icons.flag : (isEnd ? Icons.check : Icons.circle),
                              size: 11,
                              color: isStart || isEnd ? Colors.black : AppColors.tacticalOrange,
                            ),
                          ),
                        ),
                        if (!isEnd)
                          Container(
                            width: 2,
                            height: 68,
                            color: AppColors.borderMedium,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Right Timeline Entry (Minimalist Clean Row)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBase,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.borderSubtle),
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
                                      style: AppTypography.labelMetric.copyWith(color: AppColors.emerald, fontSize: 11),
                                    ),
                                    const SizedBox(width: 8),
                                    TacticalPill(
                                      text: stop['distance'] as String,
                                      color: AppColors.tacticalOrange,
                                      backgroundColor: AppColors.surfaceHigh,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stop['title'] as String,
                                  style: AppTypography.titleMedium.copyWith(fontSize: 14),
                                ),
                                Text(
                                  stop['location'] as String,
                                  style: AppTypography.bodyMedium.copyWith(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.drag_indicator, size: 18, color: AppColors.textMuted.withValues(alpha: 0.5)),
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

  // TAB 2: BUDGET & PACK VIEW (Trực quan hóa chi phí dạng thanh phân đoạn)
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
        // Budget Breakdown with Visual Segmented Meter
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
                  Text('Dự Toán Chi Phí', style: AppTypography.headlineMedium.copyWith(fontSize: 17)),
                  Text(
                    '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ/người',
                    style: AppTypography.labelMetric.copyWith(fontSize: 16, color: AppColors.emerald),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Visual Segmented Cost Bar
              ClipRRect(
                borderRadius: AppRadius.roundedPill,
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(flex: (fuelPct * 100).toInt().clamp(1, 100), child: Container(color: AppColors.tacticalOrange)),
                      Expanded(flex: (foodPct * 100).toInt().clamp(1, 100), child: Container(color: AppColors.emerald)),
                      Expanded(flex: (campPct * 100).toInt().clamp(1, 100), child: Container(color: AppColors.alpineCyan)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendItem('Nhiên liệu', AppColors.tacticalOrange, fuel),
                  _buildLegendItem('Ăn uống', AppColors.emerald, food),
                  _buildLegendItem('Trại & Bãi', AppColors.alpineCyan, camp),
                ],
              ),
              const Divider(height: 20, color: AppColors.borderSubtle),

              // Vehicle selector
              const Text('Phương tiện di chuyển:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                            color: isSelected ? AppColors.emerald.withValues(alpha: 0.2) : AppColors.surfaceHigh,
                            borderRadius: AppRadius.roundedSm,
                            border: Border.all(color: isSelected ? AppColors.emerald : AppColors.borderSubtle),
                          ),
                          child: Column(
                            children: [
                              Icon(v['icon'] as IconData, size: 18, color: isSelected ? AppColors.emerald : AppColors.textMuted),
                              const SizedBox(height: 2),
                              Text(v['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isSelected ? AppColors.emerald : Colors.white)),
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
                  const Text('Số người tham gia:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.emerald),
                        onPressed: _participants > 1 ? () => setState(() => _participants--) : null,
                      ),
                      Text('$_participants', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.emerald),
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
        Text('Hành Trang Chuẩn Bị (${_checkedItems.length}/${_checklistItems.length})', style: AppTypography.headlineMedium.copyWith(fontSize: 17)),
        const SizedBox(height: 8),

        ..._checklistItems.map((item) {
          final isChecked = _checkedItems.contains(item);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: isChecked ? AppColors.emerald.withValues(alpha: 0.3) : AppColors.borderSubtle),
            ),
            child: ListTile(
              leading: Icon(
                isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isChecked ? AppColors.emerald : AppColors.textMuted,
                size: 20,
              ),
              title: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
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
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text('${(cost / 1000).toInt()}k', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
