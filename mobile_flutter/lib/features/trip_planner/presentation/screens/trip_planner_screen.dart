import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/weather_safety/services/weather_service.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _participants = 4;
  String _selectedVehicle = 'Xe máy số (110cc)';
  final int _tripDays = 3;

  List<String> _checklistItems = [];
  Set<String> _checkedItems = {};

  final List<Map<String, dynamic>> _vehicles = const [
    {
      'title': 'Xe máy số (110cc)',
      'icon': Icons.two_wheeler,
      'rate': 2.2,
      'desc': '2.2L / 100km',
    },
    {
      'title': 'Xe cào cào / Côn tay',
      'icon': Icons.motorcycle,
      'rate': 3.2,
      'desc': '3.2L / 100km',
    },
    {
      'title': 'Xe bán tải 4x4',
      'icon': Icons.directions_car,
      'rate': 9.5,
      'desc': '9.5L / 100km',
    },
    {
      'title': 'Đi bộ Trekking',
      'icon': Icons.hiking,
      'rate': 0.0,
      'desc': '0L tiêu hao',
    },
  ];

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

  int get _foodCostPerPerson => _tripDays * 250000;
  int get _campFeePerPerson => 150000;
  int get _totalCostPerPerson => _fuelCostPerPerson + _foodCostPerPerson + _campFeePerPerson;

  void _toggleCheckItem(String item) {
    setState(() {
      if (_checkedItems.contains(item)) {
        _checkedItems.remove(item);
      } else {
        _checkedItems.add(item);
      }
    });
    StorageService.saveChecklist(_checkedItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Lập Kế Hoạch Chuyến Đi (Planner)'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Expedition Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LỊCH TRÌNH ĐÃ CHỌN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.emerald, letterSpacing: 0.5)),
                          SizedBox(height: 2),
                          Text('Tà Năng - Phan Dũng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.tacticalOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.tacticalOrange.withValues(alpha: 0.3)),
                        ),
                        child: const Text('3N2Đ • Độ khó: 8/10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tacticalOrange)),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppTheme.borderLight),

                  // Vehicle Selector Cards
                  const Text('Chọn phương tiện di chuyển:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSub)),
                  const SizedBox(height: 10),
                  Row(
                    children: _vehicles.map((v) {
                      final isSelected = v['title'] == _selectedVehicle;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => setState(() => _selectedVehicle = v['title'] as String),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.emerald.withValues(alpha: 0.15) : AppTheme.surfaceHigh,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.emerald : AppTheme.borderLight,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    v['icon'] as IconData,
                                    color: isSelected ? AppTheme.emerald : AppTheme.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    v['title'] as String,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? AppTheme.emerald : AppTheme.textSub,
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

                  // Participants Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số thành viên tham gia:', style: TextStyle(fontSize: 13, color: AppTheme.textSub)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: AppTheme.textMain),
                              onPressed: _participants > 1 ? () => setState(() => _participants--) : null,
                            ),
                            Text(
                              '$_participants người',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.emerald, fontSize: 13),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: AppTheme.textMain),
                              onPressed: () => setState(() => _participants++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: AppTheme.borderLight),

                  // Total Cost Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DỰ TOÁN CHI PHÍ TRỌN GÓI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5)),
                          SizedBox(height: 2),
                          Text('Tính toán thực tế trên đầu người', style: TextStyle(fontSize: 11, color: AppTheme.textSub)),
                        ],
                      ),
                      Text(
                        '${_totalCostPerPerson.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.tacticalOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Breakdown pills
                  Row(
                    children: [
                      _buildCostPill('Xăng đèo (x1.35)', '${_fuelCostPerPerson ~/ 1000}k'),
                      const SizedBox(width: 6),
                      _buildCostPill('Ăn uống (3N)', '${_foodCostPerPerson ~/ 1000}k'),
                      const SizedBox(width: 6),
                      _buildCostPill('Phí bảo tồn', '${_campFeePerPerson ~/ 1000}k'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Itinerary
            const Text(
              'Lịch Trình Định Tuyến Tối Ưu (TSP Routing)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem(
              1,
              'Rừng thông Tà Năng ➔ Đồi Lính',
              'Di chuyển 14 km • Cao độ tăng +450m • Dựng lều đồi lính trước 16:30 tránh gió xoáy',
              Icons.hiking,
            ),
            _buildTimelineItem(
              2,
              'Sống lưng khủng long ➔ Thác Bay',
              'Di chuyển 18 km • Vượt dốc đá • CẢNH BÁO: Không hạ trại lòng suối khi trời mưa lớn',
              Icons.terrain,
            ),
            _buildTimelineItem(
              3,
              'Rừng khộp Phan Dũng ➔ Ra bìa rừng',
              'Di chuyển 15 km • Khí hậu khô hạn • Bắt buộc tích trữ tối thiểu 2.5L nước/người',
              Icons.sports_score,
            ),

            const SizedBox(height: 24),

            // Smart Checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checklist Chuẩn Bị Đồ Thông Minh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_checkedItems.length}/${_checklistItems.length} Món',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.emerald),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tự động tích hợp dựa trên dự báo khí hậu Open-Meteo tại đỉnh núi:',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),

            // Checklist Cards
            ..._checklistItems.map((item) {
              final isChecked = _checkedItems.contains(item);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isChecked ? AppTheme.surfaceHigh.withValues(alpha: 0.5) : AppTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChecked ? AppTheme.emerald.withValues(alpha: 0.3) : AppTheme.borderLight,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    dense: true,
                    activeColor: AppTheme.emerald,
                    checkColor: Colors.black,
                    title: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isChecked ? FontWeight.normal : FontWeight.w600,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked ? AppTheme.textMuted : AppTheme.textMain,
                      ),
                    ),
                    value: isChecked,
                    onChanged: (val) => _toggleCheckItem(item),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCostPill(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $amount',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSub),
      ),
    );
  }

  Widget _buildTimelineItem(int day, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.emerald.withValues(alpha: 0.2),
            child: Text(
              'D$day',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.emerald),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSub, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
