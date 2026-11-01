import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:mobile_flutter/features/offline_map/services/location_service.dart';
import 'package:mobile_flutter/features/offline_map/services/routing_service.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(11.6420, 108.4230); // Vị trí GPS người dùng
  bool _isLocating = false;
  String _selectedFilter = 'Tất cả';
  String _currentLayer = 'topo'; // 'topo', 'satellite', 'streets'

  // Quản lý danh sách các địa điểm trong chuyến đi
  List<Destination> _tripDestinations = [];
  Destination? _selectedTripDestination;
  List<LatLng> _routingPolyline = [];
  double _distanceToSelectedKm = 0.0;
  String _estimatedTravelDuration = '';
  bool _isLoadingRoute = false;
  bool _isActualRoad = false;

  // Waypoint được chọn để xem chi tiết
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
    _loadTripDestinations();
  }

  LatLng _getDestLatLng(Destination dest) {
    return LatLng(dest.centerLatitude ?? 11.6420, dest.centerLongitude ?? 108.4230);
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

  Future<void> _loadTripDestinations() async {
    try {
      final tripIds = await StorageService.getTripDestinations();
      final allDestinations = await ExploreLocalDataSource().getSeedDestinations();
      final List<Destination> loaded = [];

      for (final id in tripIds) {
        final found = allDestinations.where((d) => d.id == id);
        if (found.isNotEmpty) {
          loaded.add(found.first);
        }
      }

      // Nếu danh sách trống, khởi tạo ít nhất 2 điểm mẫu chất lượng
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
          _selectTripDestination(active, animateCamera: false);
        }
      }
    } catch (_) {}
  }

  Future<void> _selectTripDestination(Destination dest, {bool animateCamera = true}) async {
    HapticFeedback.selectionClick();
    final targetLoc = _getDestLatLng(dest);
    final directDistKm = const Distance().as(LengthUnit.Kilometer, _currentLocation, targetLoc);

    setState(() {
      _selectedTripDestination = dest;
      _selectedWaypoint = null;
      _distanceToSelectedKm = directDistKm;
      _isLoadingRoute = true;
    });

    StorageService.setSelectedTripDestination(dest.id);

    if (animateCamera) {
      _mapController.move(targetLoc, 13.0);
    }

    final isDomestic = dest.isDomestic('VN') || dest.countryIds.contains('vn') || dest.countryIds.contains('VN');

    // Lấy tuyến đường thực tế qua OSRM (đảm bảo 100% nằm trong lãnh thổ Việt Nam nếu là điểm nội địa)
    final routeResult = await RoutingService.getActualRoute(
      start: _currentLocation,
      end: targetLoc,
      isDomestic: isDomestic,
    );

    if (mounted && _selectedTripDestination?.id == dest.id) {
      setState(() {
        _routingPolyline = routeResult.points;
        _distanceToSelectedKm = routeResult.distanceKm;
        _estimatedTravelDuration = routeResult.durationText;
        _isActualRoad = routeResult.isActualRoadRoute;
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _removeDestinationFromTrip(Destination dest) async {
    HapticFeedback.mediumImpact();
    await StorageService.removeTripDestination(dest.id);
    await _loadTripDestinations();
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

      // Cập nhật lại tuyến đường thực tế từ vị trí GPS mới
      if (_selectedTripDestination != null) {
        final targetLoc = _getDestLatLng(_selectedTripDestination!);
        final isDomestic = _selectedTripDestination!.isDomestic('VN') || _selectedTripDestination!.countryIds.contains('VN');
        final routeResult = await RoutingService.getActualRoute(
          start: pos,
          end: targetLoc,
          isDomestic: isDomestic,
        );
        if (mounted) {
          setState(() {
            _routingPolyline = routeResult.points;
            _distanceToSelectedKm = routeResult.distanceKm;
            _estimatedTravelDuration = routeResult.durationText;
            _isActualRoad = routeResult.isActualRoadRoute;
          });
        }
      }
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

  String get _layerStatusLabel {
    if (_currentLayer == 'satellite') return 'VỆ TINH • ESRI SATELLITE';
    if (_currentLayer == 'streets') return 'ĐƯỜNG MÒN • ESRI STREETS';
    return 'ĐỊA HÌNH • ESRI TOPO';
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['Tất cả', 'Nguồn nước', 'Cắm trại', 'Cửa rừng', 'Đích đến'];
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding') ||
        WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTestWidgetsFlutterBinding');

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Nền đen dã ngoại tránh giật trắng
          Positioned.fill(
            child: Container(color: const Color(0xFF0D1310)),
          ),

          // FlutterMap Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedTripDestination != null
                  ? _getDestLatLng(_selectedTripDestination!)
                  : _currentLocation,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (_selectedWaypoint != null) {
                  setState(() => _selectedWaypoint = null);
                }
              },
            ),
            children: [
              // ESRI Topo / Satellite / Streets Tiles (100% Free, No API Key Required)
              if (_currentLayer == 'satellite')
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                )
              else if (_currentLayer == 'streets')
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                )
              else
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                ),

              // Cung đường mòn mẫu & Đường tìm đường định tuyến (Wayfinding Routing)
              PolylineLayer(
                polylines: [
                  // Trail cố định Tà Năng
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 6.0,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  Polyline(
                    points: _trekkingTrail,
                    strokeWidth: 3.5,
                    color: AppColors.tacticalOrange.withValues(alpha: 0.8),
                  ),

                  // Đường tìm đường định tuyến tới điểm đến đã chọn (Routing Polyline)
                  if (_routingPolyline.isNotEmpty) ...[
                    Polyline(
                      points: _routingPolyline,
                      strokeWidth: 9.0,
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                    Polyline(
                      points: _routingPolyline,
                      strokeWidth: 5.0,
                      color: AppColors.alpineCyan,
                    ),
                  ],
                ],
              ),

              // Tactical Waypoints & Destination Markers
              MarkerLayer(
                markers: [
                  // Marker vị trí GPS người dùng (Radar)
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: Center(
                      child: isTesting
                          ? Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.neonGreen,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Container(
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

                  // Markers cho TẤT CẢ các điểm đến trong chuyến đi
                  ..._tripDestinations.map((dest) {
                    final isSelected = _selectedTripDestination?.id == dest.id;
                    final point = _getDestLatLng(dest);

                    return Marker(
                      point: point,
                      width: isSelected ? 58 : 46,
                      height: isSelected ? 58 : 46,
                      child: GestureDetector(
                        onTap: () => _selectTripDestination(dest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.summitGold : AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : AppColors.summitGold,
                              width: isSelected ? 3.0 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? AppColors.summitGold : Colors.black).withValues(alpha: isSelected ? 0.8 : 0.4),
                                blurRadius: isSelected ? 18 : 8,
                                spreadRadius: isSelected ? 3 : 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            isSelected ? Icons.flag : Icons.place,
                            size: isSelected ? 26 : 20,
                            color: isSelected ? Colors.black : AppColors.summitGold,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Waypoints trạm nghỉ / nước / cắm trại
                  ..._filteredWaypoints.map((wp) {
                    final isSelected = _selectedWaypoint?['id'] == wp['id'];
                    final Color color = wp['color'] as Color;

                    return Marker(
                      point: wp['position'] as LatLng,
                      width: isSelected ? 52 : 42,
                      height: isSelected ? 52 : 42,
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

          // Top Header & Trip Destinations Selector
          Positioned(
            top: 48,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Text(
                          _selectedTripDestination != null
                              ? 'Đích đến: ${_selectedTripDestination!.name}'
                              : 'Bản Đồ Ngoại Tuyến Dã Ngoại',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: AppRadius.roundedPill,
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _layerStatusLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Danh sách (List) các địa điểm đã chọn trong Chuyến đi
                if (_tripDestinations.isNotEmpty) ...[
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _tripDestinations.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _tripDestinations.length) {
                          // Nút Thêm Điểm từ tab Khám phá
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: BouncingButton(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                MainNavigationScreen.switchToTab(0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceBase.withValues(alpha: 0.9),
                                  borderRadius: AppRadius.roundedPill,
                                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 16, color: AppColors.emerald),
                                    SizedBox(width: 4),
                                    Text(
                                      'Thêm điểm',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final dest = _tripDestinations[index];
                        final isSelected = _selectedTripDestination?.id == dest.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: BouncingButton(
                            onTap: () => _selectTripDestination(dest),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.emerald : AppColors.surfaceBase.withValues(alpha: 0.9),
                                borderRadius: AppRadius.roundedPill,
                                border: Border.all(
                                  color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.emerald.withValues(alpha: 0.4),
                                          blurRadius: 10,
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
                                    size: 14,
                                    color: isSelected ? Colors.black : AppColors.summitGold,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    dest.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  if (_tripDestinations.length > 1) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeDestinationFromTrip(dest),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: isSelected ? Colors.black54 : AppColors.textMuted,
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
                  const SizedBox(height: 8),
                ],

                // Category Filter Pills cho Waypoints
                SizedBox(
                  height: 32,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceHigh : AppColors.surfaceBase.withValues(alpha: 0.8),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: isSelected ? AppColors.alpineCyan : AppColors.borderSubtle),
                            ),
                            child: Center(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.alpineCyan : AppColors.textSecondary,
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

          // Floating Map Control Buttons on the Right
          Positioned(
            right: 16,
            bottom: (_selectedTripDestination != null || _selectedWaypoint != null) ? 220 : 32,
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

          // Bottom Sheet Dẫn Đường Cho Địa Điểm Đã Chọn (Trip Destination Routing Panel)
          if (_selectedTripDestination != null && _selectedWaypoint == null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.roundedXl,
                  border: Border.all(color: AppColors.borderMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge trạng thái tìm đường thực tế
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_isLoadingRoute)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.alpineCyan.withValues(alpha: 0.15),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.alpineCyan),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'ĐANG TẢI TUYẾN ĐƯỜNG THỰC TẾ...',
                                  style: TextStyle(
                                    color: AppColors.alpineCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (_isActualRoad ? AppColors.neonGreen : AppColors.alpineCyan).withValues(alpha: 0.15),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(
                                color: (_isActualRoad ? AppColors.neonGreen : AppColors.alpineCyan).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isActualRoad ? Icons.alt_route : Icons.directions,
                                  size: 14,
                                  color: _isActualRoad ? AppColors.neonGreen : AppColors.alpineCyan,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isActualRoad ? 'TUYẾN ĐƯỜNG BỘ THỰC TẾ' : 'LỘ TRÌNH ĐỊNH TUYẾN DÃ NGOẠI',
                                  style: TextStyle(
                                    color: _isActualRoad ? AppColors.neonGreen : AppColors.alpineCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          _getLocationLabel(_selectedTripDestination!),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tên địa điểm
                    Text(
                      _selectedTripDestination!.name,
                      style: AppTypography.headlineLarge.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedTripDestination!.editorialSummary,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // 3 Metric Badges: Cự ly, Thời gian, Cao độ
                    Row(
                      children: [
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.straighten,
                            label: 'Khoảng cách',
                            value: '${_distanceToSelectedKm.toStringAsFixed(1)} km',
                          ),
                        ),
                        Container(width: 1, height: 22, color: AppColors.borderSubtle),
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.timer_outlined,
                            label: 'Ước tính',
                            value: _estimatedTravelDuration,
                          ),
                        ),
                        Container(width: 1, height: 22, color: AppColors.borderSubtle),
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.terrain,
                            label: 'Cao độ đích',
                            value: _selectedTripDestination!.elevationDisplay,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Action Buttons: Xem Lịch Trình Chi Tiết & Căn Giữa Điểm Đến
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 46,
                            child: BouncingButton(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                MainNavigationScreen.switchToTab(2); // Chuyển sang Tab Lịch Trình
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
                                      Icon(Icons.calendar_month, size: 18, color: Colors.black),
                                      SizedBox(width: 6),
                                      Text(
                                        'Xem Lịch Trình Chi Tiết',
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 46,
                          width: 48,
                          child: BouncingButton(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final target = _getDestLatLng(_selectedTripDestination!);
                              // Căn giữa bao quát toàn bộ tuyến đường thực tế
                              final centerLat = (_currentLocation.latitude + target.latitude) / 2.0;
                              final centerLng = (_currentLocation.longitude + target.longitude) / 2.0;
                              double zoom = 12.0;
                              if (_distanceToSelectedKm > 400) {
                                zoom = 6.5;
                              } else if (_distanceToSelectedKm > 150) {
                                zoom = 8.5;
                              } else if (_distanceToSelectedKm > 50) {
                                zoom = 10.0;
                              }
                              _mapController.move(LatLng(centerLat, centerLng), zoom);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: AppRadius.roundedMd,
                                border: Border.all(color: AppColors.borderMedium),
                              ),
                              child: const Center(
                                child: Icon(Icons.center_focus_strong, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Selected Waypoint Bottom Preview Sheet (nếu người dùng bấm vào waypoint suối nước/trạm)
          if (_selectedWaypoint != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
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
                  ],
                ),
              ),
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
                id: 'topo',
                name: 'Bản Đồ Địa Hình & Cao Độ (ESRI Topo)',
                desc: 'Đường đồng mức núi rừng, suối thác, đèo dốc rõ nét',
                icon: Icons.terrain,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'satellite',
                name: 'Ảnh Vệ Tinh Độ Phân Giải Cao (ESRI Satellite)',
                desc: 'Hình ảnh không gian thực tế, độ phủ rừng & tán cây',
                icon: Icons.satellite_alt,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'streets',
                name: 'Đường Mòn & Địa Danh Dã Ngoại (ESRI Streets)',
                desc: 'Địa danh làng xã, suối cạn, đường mòn trekking & ranh giới',
                icon: Icons.map_outlined,
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
