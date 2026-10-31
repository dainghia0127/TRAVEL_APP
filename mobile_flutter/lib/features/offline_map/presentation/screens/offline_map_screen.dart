import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(11.6420, 108.4230); // Tà Năng
  bool _isLocating = false;
  String _selectedFilter = 'Tất cả';
  String _currentLayer = 'dark'; // 'dark', 'satellite', 'topo'

  // Selected waypoint for bottom sheet preview
  Map<String, dynamic>? _selectedWaypoint;

  // Cung đường trekking mẫu (Tà Năng - Phan Dũng)
  final List<LatLng> _trekkingTrail = const [
    LatLng(11.6420, 108.4230),
    LatLng(11.6380, 108.4410),
    LatLng(11.6250, 108.4650),
    LatLng(11.6090, 108.4980),
    LatLng(11.5950, 108.5300),
    LatLng(11.5820, 108.5620),
  ];

  final List<Map<String, dynamic>> _waypoints = [
    {
      'id': 'wp_1',
      'title': 'Cửa Rừng Tà Năng',
      'category': 'Cửa rừng',
      'icon': Icons.flag,
      'color': AppColors.emerald,
      'position': const LatLng(11.6420, 108.4230),
      'elevation': '1,100 m',
      'water': 'Có tại trạm',
      'signal': '4G chập chờn',
      'desc': 'Điểm xuất phát cung đường trekking. Có trạm kiểm lâm khai báo tạm trú và gửi xe máy qua đêm.',
    },
    {
      'id': 'wp_2',
      'title': 'Suối Cạn Tà Năng',
      'category': 'Nguồn nước',
      'icon': Icons.water_drop,
      'color': AppColors.alpineCyan,
      'position': const LatLng(11.6250, 108.4650),
      'elevation': '980 m',
      'water': 'Nước suối tự nhiên',
      'signal': 'Mất sóng (0%)',
      'desc': 'Nguồn nước tự nhiên duy nhất trong 15km tiếp theo. Cần lọc thô và đun sôi hoặc dùng viên Aquatabs trước khi uống.',
    },
    {
      'id': 'wp_3',
      'title': 'Bãi Trại Đồi Lính',
      'category': 'Cắm trại',
      'icon': Icons.cabin,
      'color': AppColors.tacticalOrange,
      'position': const LatLng(11.6090, 108.4980),
      'elevation': '1,100 m',
      'water': 'Cách suối 1.5km',
      'signal': 'Mất sóng (0%)',
      'desc': 'Khu vực đồi cỏ lộng gió săn bình minh và mây bồng bềnh. Gió giật cấp 6 về đêm, cần chèn néo cọc lều chắc chắn.',
    },
    {
      'id': 'wp_4',
      'title': 'UBND Xã Phan Dũng',
      'category': 'Đích đến',
      'icon': Icons.check_circle,
      'color': AppColors.neonGreen,
      'position': const LatLng(11.5820, 108.5620),
      'elevation': '150 m',
      'water': 'Nước máy dân cư',
      'signal': '4G ổn định 100%',
      'desc': 'Điểm kết thúc hành trình 55km. Nơi tập kết xe ôm trung chuyển ra ngã ba Liên Hương để đón xe khách về TP.HCM.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _isLocating = true);
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentLocation = pos;
        _isLocating = false;
      });
      _mapController.move(pos, 14.0);
    } else {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  List<Map<String, dynamic>> get _filteredWaypoints {
    if (_selectedFilter == 'Tất cả') return _waypoints;
    return _waypoints.where((wp) => wp['category'] == _selectedFilter).toList();
  }

  void _onSelectMarker(Map<String, dynamic> wp) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWaypoint = wp;
    });
    _mapController.move(wp['position'] as LatLng, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['Tất cả', 'Nguồn nước', 'Cắm trại', 'Cửa rừng', 'Đích đến'];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Tactical dark grid background (guarantees screen is never white even before tiles load)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0D1310),
            ),
          ),

          // FlutterMap Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 4.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (_selectedWaypoint != null) {
                  setState(() => _selectedWaypoint = null);
                }
              },
            ),
            children: [
              // High-Contrast Dark Matter / Satellite / Topo Tiles
              if (_currentLayer == 'dark')
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                )
              else if (_currentLayer == 'satellite')
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                )
              else
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                ),

              // Glowing Trail Route
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 8.0,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 4.5,
                    color: AppColors.tacticalOrange,
                  ),
                ],
              ),

              // Tactical Waypoints
              MarkerLayer(
                markers: [
                  // User GPS Radar Ping Marker with concentric wave
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.6), width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 1200.ms, curve: Curves.easeInOut),
                    ),
                  ),

                  // Waypoint Markers
                  ..._filteredWaypoints.map((wp) {
                    final isSelected = _selectedWaypoint?['id'] == wp['id'];
                    final Color color = wp['color'] as Color;

                    return Marker(
                      point: wp['position'] as LatLng,
                      width: isSelected ? 52 : 44,
                      height: isSelected ? 52 : 44,
                      child: GestureDetector(
                        onTap: () => _onSelectMarker(wp),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? color : AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : color,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: isSelected ? 0.6 : 0.3),
                                blurRadius: isSelected ? 16 : 8,
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            wp['icon'] as IconData,
                            size: isSelected ? 24 : 18,
                            color: isSelected ? Colors.black : color,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top Floating Search & Filter Pill
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Top Header Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBase.withValues(alpha: 0.95),
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.explore, size: 18, color: AppColors.emerald),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Cung Tà Năng - Phan Dũng (55km)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ),
                      TacticalPill(
                        text: 'OFFLINE',
                        color: AppColors.emerald,
                        backgroundColor: AppColors.surfaceHigh,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Category Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final f = filters[index];
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: BouncingButton(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedFilter = f);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.emerald : AppColors.surfaceBase.withValues(alpha: 0.9),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: isSelected ? AppColors.emerald : AppColors.borderSubtle),
                            ),
                            child: Center(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Floating Tactical Map Controls on the Right
          Positioned(
            right: 16,
            bottom: _selectedWaypoint != null ? 240 : 32,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.layers_outlined,
                  iconColor: AppColors.emerald,
                  onTap: _showLayerSelectionSheet,
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  icon: Icons.my_location,
                  iconColor: _isLocating ? AppColors.tacticalOrange : AppColors.emerald,
                  onTap: _fetchUserLocation,
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                ),
              ],
            ),
          ),

          // Selected Waypoint Bottom Preview Sheet
          if (_selectedWaypoint != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.roundedXl,
                  border: Border.all(color: AppColors.borderMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TacticalPill(
                          text: _selectedWaypoint!['category'] as String,
                          color: _selectedWaypoint!['color'] as Color,
                          backgroundColor: (_selectedWaypoint!['color'] as Color).withValues(alpha: 0.15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                          onPressed: () => setState(() => _selectedWaypoint = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedWaypoint!['title'] as String,
                      style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedWaypoint!['desc'] as String,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.terrain,
                            label: 'Cao độ',
                            value: _selectedWaypoint!['elevation'] as String,
                          ),
                        ),
                        Container(width: 1, height: 20, color: AppColors.borderSubtle),
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.water_drop,
                            label: 'Nguồn nước',
                            value: _selectedWaypoint!['water'] as String,
                          ),
                        ),
                        Container(width: 1, height: 20, color: AppColors.borderSubtle),
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.signal_cellular_alt,
                            label: 'Sóng 4G',
                            value: _selectedWaypoint!['signal'] as String,
                            iconColor: (_selectedWaypoint!['signal'] as String).contains('0%')
                                ? AppColors.emergencyRed
                                : AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Navigate Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: BouncingButton(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceHigh,
                              content: Text('Đang định tuyến la bàn hướng về ${_selectedWaypoint!['title']}'),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.emeraldGradient,
                            borderRadius: AppRadius.roundedMd,
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation, size: 18, color: Colors.black),
                                SizedBox(width: 6),
                                Text('Dẫn Đường Ngoại Tuyến', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.1, end: 0),
            ),
        ],
      ),
    );
  }

  void _showLayerSelectionSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: AppRadius.roundedPill),
                ),
              ),
              const SizedBox(height: 16),
              Text('CHỌN LỚP BẢN ĐỒ DÃ NGOẠI', style: AppTypography.captionBadge.copyWith(color: AppColors.emerald)),
              const SizedBox(height: 12),
              _buildLayerOption(
                id: 'dark',
                name: 'Bản Đồ Đêm (Dark Matter)',
                desc: 'Tối ưu quan sát ban đêm, tiết kiệm pin & độ tương phản cao',
                icon: Icons.nightlight_round,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'satellite',
                name: 'Ảnh Vệ Tinh (ESRI Satellite)',
                desc: 'Hình ảnh không gian thực tế, độ phủ rừng & tán cây',
                icon: Icons.satellite_alt,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'topo',
                name: 'Địa Hình Núi (Topographic)',
                desc: 'Đường đồng mức cao độ, sống núi, suối & thung lũng',
                icon: Icons.terrain,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerOption({
    required String id,
    required String name,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = _currentLayer == id;
    return BouncingButton(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentLayer = id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHigh : AppColors.surfaceBase,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(
            color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.emerald.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppColors.emerald : AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.emerald, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, Color? iconColor, required VoidCallback onTap}) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.white),
      ),
    );
  }
}
