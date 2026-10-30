import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
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

  // Cung đường trekking mẫu (Tà Năng - Phan Dũng)
  final List<LatLng> _trekkingTrail = const [
    LatLng(11.6420, 108.4230),
    LatLng(11.6380, 108.4410),
    LatLng(11.6250, 108.4650),
    LatLng(11.6090, 108.4980),
    LatLng(11.5950, 108.5300),
    LatLng(11.5820, 108.5620),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // FlutterMap Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.traveloutdoor.travel_app',
              ),

              // Glowing Trail Route
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 6.0,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 4.0,
                    color: AppTheme.tacticalOrange,
                  ),
                ],
              ),

              // Tactical Waypoints
              MarkerLayer(
                markers: [
                  // User Radar Ping Marker
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppTheme.neonGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cửa rừng Waypoint
                  Marker(
                    point: const LatLng(11.6420, 108.4230),
                    width: 44,
                    height: 44,
                    child: _buildWaypointMarker(
                      Icons.flag,
                      AppTheme.emerald,
                      () => _showSpotDetails('Cửa Rừng Tà Năng', 'Điểm xuất phát cung đường. Cao độ 1,100m. Có trạm kiểm lâm.'),
                    ),
                  ),

                  // Vũng nước tự nhiên
                  Marker(
                    point: const LatLng(11.6250, 108.4650),
                    width: 44,
                    height: 44,
                    child: _buildWaypointMarker(
                      Icons.water_drop,
                      AppTheme.alpineCyan,
                      () => _showSpotDetails('Suối Cạn Tà Năng', 'Nguồn nước tự nhiên duy nhất trong 15km tiếp theo. Cần lọc kỹ trước khi dùng.'),
                    ),
                  ),

                  // Bãi trại Sống lưng khủng long
                  Marker(
                    point: const LatLng(11.6090, 108.4980),
                    width: 44,
                    height: 44,
                    child: _buildWaypointMarker(
                      Icons.cabin,
                      AppTheme.tacticalOrange,
                      () => _showSpotDetails('Bãi Trại Đồi Lính', 'Khu vực cắm trại đồi cỏ lộng gió. Gió mạnh cấp 6 về đêm, cần chèn néo cọc lều chắc chắn.'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Tactical HUD (Garmin / Fenix Style)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBase.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.neonGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'GPS VỆ TINH: KHÓA TỐT',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.neonGreen, letterSpacing: 0.5),
                            ),
                            Text(
                              '${_currentLocation.latitude.toStringAsFixed(4)}°N, ${_currentLocation.longitude.toStringAsFixed(4)}°E',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('CAO ĐỘ', style: TextStyle(fontSize: 8, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                          Text('1,485 m', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.tacticalOrange)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map Control Floating Dock on Right
          Positioned(
            right: 14,
            bottom: 110,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppTheme.textMain, size: 20),
                    onPressed: () {
                      _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                    },
                  ),
                  Container(width: 24, height: 1, color: AppTheme.borderLight),
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppTheme.textMain, size: 20),
                    onPressed: () {
                      _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                    },
                  ),
                  Container(width: 24, height: 1, color: AppTheme.borderLight),
                  IconButton(
                    icon: const Icon(Icons.layers_outlined, color: AppTheme.emerald, size: 20),
                    onPressed: _showOfflineDownloadDialog,
                  ),
                  Container(width: 24, height: 1, color: AppTheme.borderLight),
                  IconButton(
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.emerald),
                          )
                        : const Icon(Icons.my_location, color: AppTheme.emerald, size: 20),
                    onPressed: _fetchUserLocation,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Slide-Up Route Summary Card
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CUNG ĐƯỜNG ĐANG THEO DÕI',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.emerald, letterSpacing: 0.5),
                          ),
                          const Text(
                            'Tà Năng - Phan Dũng (55 km)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.download_done, size: 14, color: AppTheme.emerald),
                            SizedBox(width: 4),
                            Text('Offline 100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.emerald)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniMetric('Đã di chuyển', '14.2 km', Icons.directions_walk),
                      _buildMiniMetric('Còn lại', '40.8 km', Icons.flag_outlined),
                      _buildMiniMetric('Ước tính', '6h 30m', Icons.timer_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointMarker(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
          ],
        ),
      ],
    );
  }

  void _showSpotDetails(String title, String desc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain),
              ),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(color: AppTheme.textSub, height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.turn_right),
                  label: const Text('Tiếp tục dẫn đường tới mốc này', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfflineDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.borderLight)),
          title: const Text('Gói Bản Đồ Ngoại Tuyến', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textMain)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppTheme.emerald),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lâm Đồng — Tà Năng', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                          Text('Dung lượng: 34.2 MB • Vector MBTiles', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bản đồ đã được tải sẵn vào bộ nhớ thiết bị. Bạn có thể sử dụng và định vị GPS mượt mà khi bật chế độ Máy Bay (Offline 100%).',
                style: TextStyle(fontSize: 12, color: AppTheme.textSub, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
