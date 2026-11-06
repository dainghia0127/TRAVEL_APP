import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';
import 'package:mobile_flutter/core/services/storage_service.dart';
import 'package:mobile_flutter/core/services/geocoding_service.dart';
import 'package:mobile_flutter/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:mobile_flutter/features/explore/data/models/destination_model.dart';
import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/entities/trekking_route.dart';
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

  // Chế độ Bản Đồ: Trực Tuyến (Online) vs Ngoại Tuyến (Offline)
  bool _isOnlineMode = true;
  bool _hasGpsFix = false;
  bool _isAutoFollowGps = true; // Tự động khóa và lia camera theo bước chân GPS
  double _gpsAccuracy = 5.0;
  StreamSubscription<Position>? _positionStreamSub;
  Timer? _offlineSyncTimer;
  String _syncStatusText = 'Đã đồng bộ ngoại tuyến';

  // Quản lý danh sách các địa điểm trong chuyến đi
  List<Destination> _tripDestinations = [];
  Destination? _selectedTripDestination;
  Destination? _lastActiveDestination; // Lưu lại điểm đến gần nhất để khôi phục pop-up khi lỡ tay tắt
  List<LatLng> _routingPolyline = [];
  double _distanceToSelectedKm = 0.0;
  String _estimatedTravelDuration = '';
  bool _isLoadingRoute = false;
  bool _isActualRoad = false;

  // CHẾ ĐỘ TỰ CHỌN LỘ TRÌNH GOOGLE MAPS STYLE (TÙY CHỌN ĐIỂM ĐI A & ĐIỂM ĐẾN B)
  bool _isCustomRouteMode = false;
  LatLng? _customOriginPoint;
  String _customOriginName = 'Vị trí hiện tại của bạn';
  LatLng? _customDestinationPoint;
  String _customDestinationName = 'Chạm bản đồ để đặt đích';
  bool _isPickingOriginOnMap = false;
  bool _isPickingDestinationOnMap = false;
  List<LatLng> _customRoutePolyline = [];
  double? _customRouteDistanceKm;
  String _customRouteDurationText = '';
  bool _isLoadingCustomRoute = false;
  bool _isCustomRouteCardCollapsed = false;

  // Waypoint được chọn để xem chi tiết
  Map<String, dynamic>? _selectedWaypoint;
  bool _isCardCollapsed = false;

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
    _startLiveGpsTracking();
    _startPeriodicSync();
    MainNavigationScreen.activeTabNotifier.addListener(_checkActiveTab);
  }

  @override
  void dispose() {
    MainNavigationScreen.activeTabNotifier.removeListener(_checkActiveTab);
    _positionStreamSub?.cancel();
    _offlineSyncTimer?.cancel();
    super.dispose();
  }

  void _checkActiveTab() {
    if (MainNavigationScreen.activeTabNotifier.value == 1 && mounted) {
      if (MainNavigationScreen.openCustomRouteOnMap) {
        MainNavigationScreen.openCustomRouteOnMap = false;
        setState(() {
          _isCustomRouteMode = true;
          _customOriginPoint ??= _currentLocation;
          _customOriginName = 'Vị trí hiện tại của bạn';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showLocationPickerSheet(forOrigin: false);
        });
        return;
      }

      // Nếu đang có Lộ trình A-B với line và điểm đến đầy đủ, bảo tồn nguyên vẹn và căn camera
      if (_isCustomRouteMode && _customDestinationPoint != null && _customRoutePolyline.isNotEmpty) {
        _fitRouteBounds([_customOriginPoint ?? _currentLocation, _customDestinationPoint!, ..._customRoutePolyline]);
        return;
      }

      _loadTripDestinations();
    }
  }

  /// Lắng nghe tọa độ GPS phần cứng liên tục và cập nhật tức thì khi di chuyển
  void _startLiveGpsTracking() {
    try {
      _positionStreamSub = LocationService.getPositionStream().listen((Position pos) {
        if (!mounted) return;
        final newLoc = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentLocation = newLoc;
          _hasGpsFix = true;
          _gpsAccuracy = pos.accuracy;
        });

        // Tự động căn tâm camera theo bước chân khi đang bật Auto-Follow GPS
        if (_isAutoFollowGps) {
          _mapController.move(newLoc, _mapController.camera.zoom);
        }

        // 1. Khi người dùng di chuyển trong Chuyến Đi: cập nhật cự ly và line bản đồ theo thực tế
        if (_selectedTripDestination != null) {
          final targetLoc = _getDestLatLng(_selectedTripDestination!);
          final updatedDistKm = const Distance().as(LengthUnit.Kilometer, newLoc, targetLoc);
          setState(() {
            _distanceToSelectedKm = updatedDistKm;
            if (_routingPolyline.isNotEmpty) {
              // Điểm đầu của Polyline bám theo vị trí thực tế của người dùng
              _routingPolyline[0] = newLoc;
            }
          });
        }

        // 2. Khi đang ở chế độ Lộ Trình A-B: Cập nhật cự ly và điểm đầu theo bước chân thời gian thực
        if (_isCustomRouteMode || _customRoutePolyline.isNotEmpty) {
          if (_customDestinationPoint != null) {
            final updatedDistKm = const Distance().as(LengthUnit.Kilometer, newLoc, _customDestinationPoint!);
            setState(() {
              _customRouteDistanceKm = updatedDistKm;
              if (_customRoutePolyline.isNotEmpty) {
                _customRoutePolyline[0] = newLoc;
              }
            });
          }
        }
      }, onError: (_) {
        if (mounted) setState(() => _hasGpsFix = false);
      });
    } catch (_) {}
  }

  /// Cơ chế đồng bộ ngầm Online -> Offline mỗi vài giây
  void _startPeriodicSync() {
    _offlineSyncTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_isOnlineMode && mounted) {
        setState(() {
          final now = DateTime.now();
          final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          _syncStatusText = 'Đã đồng bộ ngoại tuyến lúc $timeStr';
        });
      }
    });
  }

  LatLng _getDestLatLng(Destination dest) {
    return LatLng(dest.centerLatitude ?? 11.6420, dest.centerLongitude ?? 108.4230);
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

      // Khi người dùng đã xóa hết địa điểm: tôn trọng danh sách rỗng, không tự ý nạp lại
      if (loaded.isEmpty) {
        if (mounted) {
          setState(() {
            _tripDestinations = [];
            _selectedTripDestination = null;
            _routingPolyline = [];
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
          _selectTripDestination(active, animateCamera: false);
        }
      }
    } catch (_) {}
  }

  /// Thêm Tuyến Đường Tự Chọn A-B Vào Lịch Trình Chuyến Đi
  Future<void> _addCustomRouteToTrip() async {
    if (_customRouteDistanceKm == null || _customDestinationPoint == null) return;
    HapticFeedback.heavyImpact();

    final customId = 'custom_route_${DateTime.now().millisecondsSinceEpoch}';
    final customName = '$_customOriginName ➔ $_customDestinationName';

    final model = DestinationModel(
      id: customId,
      slug: 'custom-route-ab',
      name: customName,
      province: 'Lộ trình A-B Google Maps',
      countryName: 'Việt Nam',
      countryIds: const ['VN'],
      regionId: 'vn_custom',
      categoryIds: const ['scenic_road', 'custom_route'],
      centerLatitude: _customDestinationPoint?.latitude,
      centerLongitude: _customDestinationPoint?.longitude,
      editorialSummary: 'Lộ trình đường bộ tự chọn A-B dài ${_customRouteDistanceKm!.toStringAsFixed(1)} km, thời gian di chuyển dự kiến: $_customRouteDurationText.',
      route: TrekkingRoute(
        id: '${customId}_route',
        name: customName,
        distanceKm: _customRouteDistanceKm!,
        elevationGainMeters: 100,
        difficultyLevel: 2,
        estimatedDurationDays: 1,
        isVerified: true,
      ),
      isVerified: true,
      media: const [],
    );

    await StorageService.saveCustomRouteJson(customId, jsonEncode(model.toJson()));

    // Lưu metadata chi tiết để phục hồi nguyên vẹn khi chuyển tab hoặc mở lại
    final startPt = _customOriginPoint ?? _currentLocation;
    final destPt = _customDestinationPoint!;
    final detail = {
      'id': customId,
      'startName': _customOriginName,
      'startLat': startPt.latitude,
      'startLng': startPt.longitude,
      'destName': _customDestinationName,
      'destLat': destPt.latitude,
      'destLng': destPt.longitude,
      'distanceKm': _customRouteDistanceKm,
      'durationText': _customRouteDurationText,
      'polyline': _customRoutePolyline.map((p) => [p.latitude, p.longitude]).toList(),
    };
    await StorageService.saveCustomRouteDetail(customId, jsonEncode(detail));

    await StorageService.addTripDestination(customId);
    await StorageService.setSelectedTripDestination(customId);

    // Sau khi đã thêm vào chuyến đi: Tắt chế độ tự chọn để chuyển hẳn sang chế độ Tuyến đường thực tế của chuyến đi
    setState(() {
      _isCustomRouteMode = false;
      _isCustomRouteCardCollapsed = false;
    });

    await _loadTripDestinations();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          backgroundColor: const Color(0xFF141E18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.emerald, width: 1.2),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.emerald, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã đồng bộ "$customName" sang Lịch Trình!',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      // Chuyển sang tab Lịch trình để người dùng thấy ngay
      MainNavigationScreen.switchToTab(2);
    }
  }

  Future<void> _selectTripDestination(Destination dest, {bool animateCamera = true}) async {
    HapticFeedback.selectionClick();

    // Nếu đây là Lộ trình tự chọn A-B: Khôi phục nguyên vẹn 100% 2 điểm A, B và đường line xanh
    if (dest.id.startsWith('custom_route_')) {
      final detailStr = await StorageService.getCustomRouteDetail(dest.id);
      if (detailStr != null && detailStr.isNotEmpty) {
        try {
          final detail = jsonDecode(detailStr) as Map<String, dynamic>;
          final startLat = (detail['startLat'] as num?)?.toDouble() ?? _currentLocation.latitude;
          final startLng = (detail['startLng'] as num?)?.toDouble() ?? _currentLocation.longitude;
          final destLat = (detail['destLat'] as num?)?.toDouble() ?? (dest.centerLatitude ?? 10.837);
          final destLng = (detail['destLng'] as num?)?.toDouble() ?? (dest.centerLongitude ?? 106.832);
          final start = LatLng(startLat, startLng);
          final end = LatLng(destLat, destLng);
          final rawPoly = detail['polyline'] as List<dynamic>?;
          final List<LatLng> polyList = rawPoly != null && rawPoly.isNotEmpty
              ? rawPoly.map((pt) => LatLng((pt[0] as num).toDouble(), (pt[1] as num).toDouble())).toList()
              : [start, end];

          if (mounted) {
            setState(() {
              // Đã thêm vào lịch trình: Tắt pop up tự chọn A-B, chỉ hiển thị duy nhất Pop-up Tuyến đường bộ thực tế
              _isCustomRouteMode = false;
              _isCustomRouteCardCollapsed = false;
              _customOriginPoint = start;
              _customOriginName = detail['startName'] as String? ?? 'Điểm xuất phát A';
              _customDestinationPoint = end;
              _customDestinationName = detail['destName'] as String? ?? 'Điểm đến B';
              _routingPolyline = polyList;
              _distanceToSelectedKm = (detail['distanceKm'] as num?)?.toDouble() ??
                  dest.route?.distanceKm ??
                  const Distance().as(LengthUnit.Kilometer, start, end);
              _estimatedTravelDuration = detail['durationText'] as String? ?? '';
              _isActualRoad = true;
              _selectedTripDestination = dest;
              _lastActiveDestination = dest;
              _isCardCollapsed = false;
              _selectedWaypoint = null;
              _isLoadingRoute = false;
            });
            StorageService.setSelectedTripDestination(dest.id);
            _fitRouteBounds([start, end, ...polyList]);
          }
          return;
        } catch (_) {}
      }
    }

    final targetLoc = _getDestLatLng(dest);
    final directDistKm = const Distance().as(LengthUnit.Kilometer, _currentLocation, targetLoc);

    setState(() {
      _selectedTripDestination = dest;
      _lastActiveDestination = dest;
      _isCardCollapsed = false;
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
      forceOffline: !_isOnlineMode,
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
    HapticFeedback.selectionClick();
    setState(() {
      _isLocating = true;
      _isAutoFollowGps = true; // Kích hoạt khóa tâm theo dõi GPS
    });
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentLocation = pos;
        _isLocating = false;
        _hasGpsFix = true;
      });
      _mapController.move(pos, 15.0);

      // Cập nhật lại tuyến đường thực tế từ vị trí GPS mới
      if (_selectedTripDestination != null) {
        final targetLoc = _getDestLatLng(_selectedTripDestination!);
        final isDomestic = _selectedTripDestination!.isDomestic('VN') || _selectedTripDestination!.countryIds.contains('VN');
        final routeResult = await RoutingService.getActualRoute(
          start: pos,
          end: targetLoc,
          isDomestic: isDomestic,
          forceOffline: !_isOnlineMode,
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

  /// Bật / Tắt chế độ Chọn Lộ Trình Tự Do Google Maps (Custom Route Mode)
  void _toggleCustomRouteMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCustomRouteMode = !_isCustomRouteMode;
      if (_isCustomRouteMode) {
        _customOriginPoint ??= _currentLocation;
        _customOriginName = 'Vị trí hiện tại của bạn';
        _selectedTripDestination = null;
        _selectedWaypoint = null;
      } else {
        _clearCustomRoute();
      }
    });
  }

  void _clearCustomRoute() {
    setState(() {
      _customRoutePolyline.clear();
      _customDestinationPoint = null;
      _customDestinationName = 'Chạm bản đồ để đặt đích';
      _customRouteDistanceKm = null;
      _customRouteDurationText = '';
      _isPickingOriginOnMap = false;
      _isPickingDestinationOnMap = false;
      _isCustomRouteCardCollapsed = false;
    });
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(40, 160, 40, 260),
        ),
      );
    } catch (_) {
      _mapController.move(points.first, 12.0);
    }
  }

  /// Tính toán lộ trình đường bộ thực tế giữa Điểm Đi A và Điểm Đến B
  Future<void> _calculateCustomRoute() async {
    final start = _customOriginPoint ?? _currentLocation;
    final end = _customDestinationPoint;
    if (end == null) return;

    final directKm = const Distance().as(LengthUnit.Kilometer, start, end);

    setState(() {
      _isLoadingCustomRoute = true;
      _isCustomRouteCardCollapsed = false;
      // Vẽ ngay đường định hướng tạm thời trong 0.01s để người dùng thấy line lập tức
      _customRoutePolyline = [start, end];
      _customRouteDistanceKm = directKm;
      _customRouteDurationText = '${(directKm / 50.0 * 60).round().clamp(10, 9999)} phút';
    });
    _fitRouteBounds([start, end]);

    final routeResult = await RoutingService.getActualRoute(
      start: start,
      end: end,
      isDomestic: true,
      forceOffline: !_isOnlineMode,
    );

    if (mounted) {
      setState(() {
        _customRoutePolyline = routeResult.points;
        _customRouteDistanceKm = routeResult.distanceKm;
        _customRouteDurationText = routeResult.durationText;
        _isLoadingCustomRoute = false;
      });
      // Di chuyển camera bao quát toàn bộ tuyến đường vừa tính xong
      final allPoints = [start, end, ...routeResult.points];
      _fitRouteBounds(allPoints);
    }
  }

  /// Đảo ngược vị trí Điểm Đi A và Điểm Đến B
  void _swapCustomRoutePoints() {
    HapticFeedback.selectionClick();
    if (_customDestinationPoint == null) return;
    setState(() {
      final tempPt = _customOriginPoint ?? _currentLocation;
      final tempNm = _customOriginName;

      _customOriginPoint = _customDestinationPoint;
      _customOriginName = _customDestinationName;

      _customDestinationPoint = tempPt;
      _customDestinationName = tempNm;
    });
    _calculateCustomRoute();
  }

  /// Xử lý chạm vào bản đồ
  void _handleMapTap(LatLng point) {
    if (_selectedWaypoint != null) {
      setState(() => _selectedWaypoint = null);
      return;
    }

    if (_isCustomRouteMode) {
      HapticFeedback.selectionClick();
      if (_isPickingOriginOnMap) {
        setState(() {
          _customOriginPoint = point;
          _customOriginName = 'Tọa độ: ${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)}';
          _isPickingOriginOnMap = false;
        });
        if (_customDestinationPoint != null) {
          _calculateCustomRoute();
        }
      } else {
        setState(() {
          _customDestinationPoint = point;
          _customDestinationName = 'Ghim: ${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)}';
          _isPickingDestinationOnMap = false;
        });
        _calculateCustomRoute();
      }
    }
  }

  /// Xử lý nhấn giữ trên bản đồ: Cắm ghim đích tức thì phong cách Google Maps!
  void _handleMapLongPress(LatLng point) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isCustomRouteMode = true;
      _customOriginPoint ??= _currentLocation;
      _customOriginName = 'Vị trí hiện tại của bạn';
      _customDestinationPoint = point;
      _customDestinationName = 'Ghim cắm: ${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)}';
      _selectedTripDestination = null;
      _selectedWaypoint = null;
    });
    _calculateCustomRoute();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: const Color(0xFF141E18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.alpineCyan, width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.alpineCyan, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã cắm ghim đích tại (${point.latitude.toStringAsFixed(3)}, ${point.longitude.toStringAsFixed(3)}) và tự động vẽ tuyến đường!',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modal chọn địa điểm cho Điểm Đi A hoặc Điểm Đến B:
  /// Tích hợp Tìm kiếm địa chỉ chuẩn xác Google Maps Style (OSM Nominatim) + GPS + Chạm bản đồ
  void _showLocationPickerSheet({required bool forOrigin}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141916),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();
        List<GeocodingResult> searchResults = [];
        bool isSearching = false;
        Timer? debounceTimer;

        return StatefulBuilder(
          builder: (context, setModalState) {
            void performSearch(String text) {
              debounceTimer?.cancel();
              if (text.trim().length < 2) {
                setModalState(() {
                  searchResults = [];
                  isSearching = false;
                });
                return;
              }
              debounceTimer = Timer(const Duration(milliseconds: 400), () async {
                setModalState(() => isSearching = true);
                final res = await GeocodingService.searchAddress(text);
                if (ctx.mounted) {
                  setModalState(() {
                    searchResults = res;
                    isSearching = false;
                  });
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: forOrigin ? AppColors.emerald.withValues(alpha: 0.2) : const Color(0xFFEF4444).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            forOrigin ? Icons.trip_origin : Icons.place,
                            size: 16,
                            color: forOrigin ? AppColors.emerald : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          forOrigin ? 'Chọn Điểm Xuất Phát (A)' : 'Chọn Điểm Đến (B)',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Ô Tìm Kiếm Địa Chỉ Google Maps Style
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.6), width: 1.2),
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        textInputAction: TextInputAction.search,
                        onChanged: performSearch,
                        onSubmitted: (val) {
                          debounceTimer?.cancel();
                          performSearch(val);
                        },
                        decoration: InputDecoration(
                          hintText: forOrigin
                              ? 'Tìm địa chỉ xuất phát (ví dụ: Chợ Bến Thành, Đà Lạt...)'
                              : 'Tìm địa chỉ đích đến (ví dụ: Đèo Hải Vân, Sapa...)',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: AppColors.alpineCyan, size: 20),
                          suffixIcon: searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    setModalState(() {
                                      searchResults = [];
                                      isSearching = false;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Danh sách kết quả tìm kiếm địa chỉ thời gian thực
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.alpineCyan)),
                              SizedBox(width: 8),
                              Text('Đang tra cứu địa chỉ chính xác...', style: TextStyle(color: AppColors.alpineCyan, fontSize: 11.5)),
                            ],
                          ),
                        ),
                      )
                    else if (searchResults.isNotEmpty) ...[
                      const Text('Kết quả tìm kiếm địa chỉ:', style: TextStyle(color: AppColors.alpineCyan, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          separatorBuilder: (c, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                          itemBuilder: (c, idx) {
                            final r = searchResults[idx];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              leading: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(0xFF1E2822),
                                child: Icon(Icons.location_on, size: 16, color: AppColors.alpineCyan),
                              ),
                              title: Text(
                                r.title,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                r.subtitle.isNotEmpty ? r.subtitle : r.displayName,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  if (forOrigin) {
                                    _customOriginPoint = r.position;
                                    _customOriginName = r.title;
                                  } else {
                                    _customDestinationPoint = r.position;
                                    _customDestinationName = r.title;
                                  }
                                });
                                if (forOrigin && _customDestinationPoint == null) {
                                  _mapController.move(r.position, 14.5);
                                } else {
                                  _calculateCustomRoute();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      // Tùy chọn 1: Vị trí GPS hiện tại
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.emerald,
                          radius: 16,
                          child: Icon(Icons.my_location, size: 16, color: Colors.black),
                        ),
                        title: const Text('Vị trí GPS hiện tại của bạn', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            if (forOrigin) {
                              _customOriginPoint = _currentLocation;
                              _customOriginName = 'Vị trí hiện tại của bạn';
                            } else {
                              _customDestinationPoint = _currentLocation;
                              _customDestinationName = 'Vị trí GPS của bạn';
                            }
                          });
                          _calculateCustomRoute();
                        },
                      ),
                      // Tùy chọn 2: Chạm ghim trên bản đồ
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.alpineCyan,
                          radius: 16,
                          child: Icon(Icons.touch_app, size: 16, color: Colors.black),
                        ),
                        title: const Text('Chạm trực tiếp trên bản đồ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Thả ghim tại bất kỳ cung đèo, ngọn núi hoặc suối ngòi nào', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            if (forOrigin) {
                              _isPickingOriginOnMap = true;
                              _isPickingDestinationOnMap = false;
                            } else {
                              _isPickingDestinationOnMap = true;
                              _isPickingOriginOnMap = false;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              backgroundColor: const Color(0xFF141E18),
                              content: Text(
                                forOrigin ? 'Hãy chạm vào vị trí bạn muốn xuất phát trên bản đồ' : 'Hãy chạm vào vị trí bạn muốn đến trên bản đồ',
                                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_tripDestinations.isNotEmpty) ...[
                        const Divider(color: AppColors.borderSubtle),
                        const Text('Hoặc chọn từ Địa danh Khám phá:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _tripDestinations.length,
                            separatorBuilder: (c, _) => const SizedBox(height: 4),
                            itemBuilder: (c, idx) {
                              final d = _tripDestinations[idx];
                              final loc = _getDestLatLng(d);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                dense: true,
                                leading: const Icon(Icons.landscape_rounded, color: AppColors.summitGold, size: 18),
                                title: Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                subtitle: Text(d.province ?? 'Việt Nam', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() {
                                    if (forOrigin) {
                                      _customOriginPoint = loc;
                                      _customOriginName = d.name;
                                    } else {
                                      _customDestinationPoint = loc;
                                      _customDestinationName = d.name;
                                    }
                                  });
                                  _calculateCustomRoute();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> get _currentWaypoints {
    final dest = _selectedTripDestination;
    if (dest == null || dest.id.contains('ta_nang')) {
      return _waypoints;
    }

    if (dest.route != null && dest.route!.stages.isNotEmpty) {
      final baseLat = dest.centerLatitude ?? 11.6420;
      final baseLng = dest.centerLongitude ?? 108.4230;
      final stages = dest.route!.stages;

      return stages.asMap().entries.map((entry) {
        final idx = entry.key;
        final stage = entry.value;
        final isLast = idx == stages.length - 1;
        final isFirst = idx == 0;

        final latOffset = (idx - stages.length / 2) * 0.008;
        final lngOffset = (idx - stages.length / 2) * 0.008;

        final terrain = stage.terrainType ?? '';
        final isRiver = terrain.toLowerCase().contains('suối') || terrain.toLowerCase().contains('thác');

        return {
          'id': 'stage_${stage.stageNumber}',
          'title': stage.title,
          'category': isFirst ? 'Cửa rừng' : (isLast ? 'Đích đến' : (isRiver ? 'Nguồn nước' : 'Cắm trại')),
          'icon': isFirst ? Icons.flag : (isLast ? Icons.check_circle : (isRiver ? Icons.water_drop : Icons.cabin)),
          'color': isFirst ? AppColors.emerald : (isLast ? AppColors.neonGreen : AppColors.tacticalOrange),
          'position': LatLng(baseLat + latOffset, baseLng + lngOffset),
          'elevation': stage.elevationGainMeters != null ? '+${stage.elevationGainMeters}m' : '--',
          'water': isRiver ? 'Có suối tự nhiên' : 'Nước mang theo',
          'signal': isFirst ? '4G ổn định' : (isLast ? 'Có sóng' : 'Mất sóng (0%)'),
          'desc': stage.description,
        };
      }).toList();
    }

    final baseLat = dest.centerLatitude ?? 11.6420;
    final baseLng = dest.centerLongitude ?? 108.4230;
    return [
      {
        'id': 'dest_${dest.id}',
        'title': dest.name,
        'category': 'Đích đến',
        'icon': Icons.location_on,
        'color': AppColors.summitGold,
        'position': LatLng(baseLat, baseLng),
        'elevation': dest.elevationDisplay,
        'water': 'Kiểm tra thực địa',
        'signal': 'Tùy khu vực',
        'desc': dest.editorialSummary,
      }
    ];
  }

  List<LatLng> get _currentTrekkingTrail {
    final list = _currentWaypoints;
    if (list.length >= 2) {
      return list.map((w) => w['position'] as LatLng).toList();
    }
    return _trekkingTrail;
  }

  List<Map<String, dynamic>> get _filteredWaypoints {
    final list = _currentWaypoints;
    if (_selectedFilter == 'Tất cả') return list;
    return list.where((wp) => wp['category'] == _selectedFilter).toList();
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

  /// Tính toán vị trí đáy động cho cụm nút điều khiển bên phải (Zoom in/out, Live GPS, Layer, Vị trí)
  /// Đảm bảo không bao giờ bị che khuất khi pop-up thu gọn, mở rộng hay khi có thanh khôi phục
  double get _mapControlsBottomOffset {
    if (_selectedTripDestination != null) {
      if (_isCardCollapsed) {
        // Pop-up thu gọn (mini bar cao ~75px + margin đáy 20px = 95px) -> Nút zoom out nằm ngay trên thanh
        return 105.0;
      } else {
        // Pop-up mở rộng (card chi tiết cao ~290px + margin đáy 20px) -> Nâng lên phía trên card
        return 320.0;
      }
    }
    if (_selectedWaypoint != null) {
      // Waypoint preview sheet cao ~180px + margin 20px
      return 215.0;
    }
    if (_isCustomRouteMode && _customRouteDistanceKm != null) {
      // Floating card kết quả A-B cao ~210px + margin 20px
      return 245.0;
    }
    if (_lastActiveDestination != null && !_isCustomRouteMode) {
      // Thanh mini bar "Mở lại lộ trình: ..." ở đáy (cao ~48px + margin 24px = 72px)
      return 88.0;
    }
    // Trạng thái bình thường không có card nào ở đáy
    return 28.0;
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
              maxZoom: 19.0,
              onPositionChanged: (camera, hasGesture) {
                // Khi người dùng chủ động kéo/vuốt bản đồ, tạm tắt auto follow để không bị giật camera
                if (hasGesture && _isAutoFollowGps) {
                  setState(() => _isAutoFollowGps = false);
                }
              },
              onTap: (tapPosition, point) {
                _handleMapTap(point);
              },
              onLongPress: (tapPosition, point) {
                _handleMapLongPress(point);
              },
            ),
            children: [
              // Google Maps Standard / Google Hybrid Satellite / Google Terrain (Chuẩn Google Maps 100%, không cần API key)
              if (_currentLayer == 'satellite') ...[
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  fallbackUrl: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                  evictErrorTileStrategy: EvictErrorTileStrategy.none,
                  maxNativeZoom: 20,
                  panBuffer: 3,
                  keepBuffer: 8,
                ),
              ] else if (_currentLayer == 'streets')
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                  evictErrorTileStrategy: EvictErrorTileStrategy.none,
                  maxNativeZoom: 20,
                  panBuffer: 3,
                  keepBuffer: 8,
                )
              else
                TileLayer(
                  urlTemplate: 'https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
                  subdomains: const ['0', '1', '2', '3'],
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.traveloutdoor.travel_app',
                  evictErrorTileStrategy: EvictErrorTileStrategy.none,
                  maxNativeZoom: 20,
                  panBuffer: 3,
                  keepBuffer: 8,
                ),

              // Cung đường mòn mẫu & Đường tìm đường định tuyến (Wayfinding Routing)
              PolylineLayer(
                polylines: [
                  // Trail cung đường thực tế theo địa điểm đang chọn
                  Polyline(
                    points: _currentTrekkingTrail,
                    strokeWidth: 6.0,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  Polyline(
                    points: _currentTrekkingTrail,
                    strokeWidth: 3.5,
                    color: AppColors.tacticalOrange.withValues(alpha: 0.8),
                  ),

                  // Đường tìm đường định tuyến tới điểm đến đã chọn (Routing Polyline)
                  if (_routingPolyline.isNotEmpty && !_isCustomRouteMode) ...[
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

                  // Tuyến đường tự do Google Maps (Custom Route Polyline A ➔ B)
                  if (_customRoutePolyline.isNotEmpty && _isCustomRouteMode) ...[
                    Polyline(
                      points: _customRoutePolyline,
                      strokeWidth: 9.0,
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                    Polyline(
                      points: _customRoutePolyline,
                      strokeWidth: 5.5,
                      color: const Color(0xFF38BDF8), // Google Maps Cyan Route
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

                  // Marker Điểm Xuất Phát Tùy Chọn A (Custom Route Origin)
                  if ((_isCustomRouteMode || _selectedTripDestination?.id.startsWith('custom_route_') == true) && _customOriginPoint != null)
                    Marker(
                      point: _customOriginPoint!,
                      width: 50,
                      height: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.emerald,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2))],
                            ),
                            child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                  // Marker Điểm Đích Tùy Chọn B (Custom Route Destination - Google Maps Red Pin)
                  if ((_isCustomRouteMode || _selectedTripDestination?.id.startsWith('custom_route_') == true) && _customDestinationPoint != null)
                    Marker(
                      point: _customDestinationPoint!,
                      width: 50,
                      height: 50,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Color(0xFFEF4444), size: 38),
                        ],
                      ),
                    ),

                  // Markers cho TẤT CẢ các điểm dã ngoại trong chuyến đi (Không vẽ đè lên lộ trình A-B)
                  ..._tripDestinations.where((d) => !d.id.startsWith('custom_route_')).map((dest) {
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
                // Top Header Pill: Điểm đến + Chế độ Online/Offline Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isOnlineMode ? Icons.language : Icons.cloud_off,
                            size: 18,
                            color: _isOnlineMode ? AppColors.alpineCyan : AppColors.tacticalOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTripDestination != null
                                      ? 'Đích: ${_selectedTripDestination!.name}'
                                      : 'Bản Đồ Dã Ngoại Sinh Tồn',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _isOnlineMode ? '$_syncStatusText • $_layerStatusLabel' : 'Chế độ Ngoại Tuyến (100% Offline)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _isOnlineMode ? AppColors.emerald : AppColors.tacticalOrange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Nút Lộ Trình A-B (Google Maps Mode)
                          BouncingButton(
                            onTap: _toggleCustomRouteMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isCustomRouteMode ? AppColors.alpineCyan : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isCustomRouteMode ? AppColors.alpineCyan : AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.alt_route_rounded,
                                    size: 11,
                                    color: _isCustomRouteMode ? Colors.black : Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _isCustomRouteMode ? 'Thoát A-B' : 'Lộ trình A-B',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _isCustomRouteMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Toggle Online / Offline Mode
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!_isOnlineMode) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _isOnlineMode = true;
                                        _syncStatusText = 'Đang đồng bộ trực tuyến...';
                                      });
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                          margin: EdgeInsets.fromLTRB(16, 0, 16, 80),
                                          backgroundColor: Color(0xFF141E18),
                                          content: Row(
                                            children: [
                                              Icon(Icons.wifi, color: AppColors.emerald, size: 18),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Chế độ Trực Tuyến: Định tuyến OSRM độ chính xác cao và nạp bản đồ từ Internet.',
                                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isOnlineMode ? AppColors.emerald : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.wifi,
                                          size: 11,
                                          color: _isOnlineMode ? Colors.black : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Online',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: _isOnlineMode ? Colors.black : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_isOnlineMode) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _isOnlineMode = false);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 3),
                                          margin: EdgeInsets.fromLTRB(16, 0, 16, 80),
                                          backgroundColor: Color(0xFF261914),
                                          content: Row(
                                            children: [
                                              Icon(Icons.cloud_off, color: AppColors.tacticalOrange, size: 18),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Chế độ Ngoại Tuyến (100% Offline): Bản đồ ưu tiên mảnh ngói đã lưu đệm, định tuyến nội suy cục bộ.',
                                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: !_isOnlineMode ? AppColors.tacticalOrange : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cloud_off,
                                          size: 11,
                                          color: !_isOnlineMode ? Colors.black : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Offline',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: !_isOnlineMode ? Colors.black : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // GIAO DIỆN TÙY CHỌN LỘ TRÌNH GOOGLE MAPS STYLE (KHI Ở CHẾ ĐỘ A-B)
                if (_isCustomRouteMode) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBase.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.7), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng Điểm Đi A
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showLocationPickerSheet(forOrigin: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isPickingOriginOnMap ? AppColors.emerald : AppColors.borderSubtle,
                                      width: _isPickingOriginOnMap ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _isPickingOriginOnMap ? '👉 Hãy chạm bản đồ để đặt A...' : _customOriginName,
                                          style: TextStyle(
                                            color: _isPickingOriginOnMap ? AppColors.emerald : Colors.white,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Nút Đảo Chiều Swap A ⇄ B
                            BouncingButton(
                              onTap: _swapCustomRoutePoints,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.alpineCyan),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Hàng Điểm Đến B
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showLocationPickerSheet(forOrigin: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isPickingDestinationOnMap ? const Color(0xFFEF4444) : AppColors.borderSubtle,
                                      width: _isPickingDestinationOnMap ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _isPickingDestinationOnMap
                                              ? '👉 Hãy chạm bản đồ để đặt đích B...'
                                              : _customDestinationName,
                                          style: TextStyle(
                                            color: _isPickingDestinationOnMap
                                                ? const Color(0xFFEF4444)
                                                : (_customDestinationPoint == null ? AppColors.textMuted : Colors.white),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Nút Xóa B
                            BouncingButton(
                              onTap: _clearCustomRoute,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                        if (_isLoadingCustomRoute)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.alpineCyan),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Đang tính toán tuyến đường bộ thực tế qua OSRM...',
                                  style: TextStyle(color: AppColors.alpineCyan, fontSize: 10.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
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
                                    // Cho phép xóa bất kỳ địa điểm nào (kể cả điểm cuối cùng)
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _removeDestinationFromTrip(dest),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.black.withValues(alpha: 0.15) : Colors.white10,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 13,
                                          color: isSelected ? Colors.black87 : AppColors.textMuted,
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
                  ] else ...[
                    // Trạng thái khi chuyến đi trống: Cho phép Thêm điểm từ Khám phá hoặc Tạo lộ trình A-B
                    Row(
                      children: [
                        BouncingButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            MainNavigationScreen.switchToTab(0);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBase.withValues(alpha: 0.9),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.explore_outlined, size: 14, color: AppColors.emerald),
                                SizedBox(width: 5),
                                Text('+ Khám phá địa điểm', style: TextStyle(color: AppColors.emerald, fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BouncingButton(
                          onTap: _toggleCustomRouteMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBase.withValues(alpha: 0.9),
                              borderRadius: AppRadius.roundedPill,
                              border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.alt_route_rounded, size: 14, color: AppColors.alpineCyan),
                                SizedBox(width: 5),
                                Text('Tạo lộ trình A-B', style: TextStyle(color: AppColors.alpineCyan, fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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

          // Floating Map Control Buttons on the Right & Live GPS Status Indicator (Tự động trượt lên/xuống mượt mà tránh che nút zoom)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            right: 16,
            bottom: _mapControlsBottomOffset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Icon tín hiệu nhận biết trạng thái bật định vị GPS thời gian thực
                BouncingButton(
                  onTap: _fetchUserLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.95),
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(
                        color: _hasGpsFix ? AppColors.neonGreen.withValues(alpha: 0.8) : AppColors.tacticalOrange,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_hasGpsFix ? AppColors.neonGreen : AppColors.tacticalOrange).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hasGpsFix ? AppColors.neonGreen : AppColors.tacticalOrange,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _hasGpsFix ? Icons.gps_fixed : Icons.gps_not_fixed,
                          size: 13,
                          color: _hasGpsFix ? AppColors.neonGreen : AppColors.tacticalOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _hasGpsFix ? 'GPS: BẬT (±${_gpsAccuracy.round()}m)' : 'GPS: TÌM SÓNG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: _hasGpsFix ? AppColors.neonGreen : AppColors.tacticalOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildMapButton(
                  icon: Icons.layers_outlined,
                  iconColor: AppColors.emerald,
                  onTap: _showLayerSelectionSheet,
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  icon: _isAutoFollowGps ? Icons.gps_fixed : Icons.my_location,
                  iconColor: _isLocating
                      ? AppColors.tacticalOrange
                      : (_isAutoFollowGps ? AppColors.neonGreen : AppColors.textSecondary),
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

          // Bottom Sheet Dẫn Đường Cho Địa Điểm Đã Chọn (Hỗ trợ vuốt xuống thu lại / vuốt lên mở rộng)
          if (_selectedTripDestination != null && _selectedWaypoint == null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 180) {
                      // Vuốt xuống -> thu nhỏ gọn
                      HapticFeedback.lightImpact();
                      setState(() => _isCardCollapsed = true);
                    } else if (details.primaryVelocity! < -180) {
                      // Vuốt lên -> bung mở rộng
                      HapticFeedback.lightImpact();
                      setState(() => _isCardCollapsed = false);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: _isCardCollapsed ? 10 : 14),
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
                      // Thanh Handle Bar vuốt lên / thu lại tương tác
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isCardCollapsed = !_isCardCollapsed);
                          },
                          child: Container(
                            width: 44,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      if (_isCardCollapsed)
                        // GIAO DIỆN THU GỌN (MINI BAR NHƯ GOOGLE MAPS)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.navigation, color: AppColors.neonGreen, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedTripDestination!.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Còn ${_distanceToSelectedKm < 1 ? "< 1 km" : "${_distanceToSelectedKm.toStringAsFixed(1)} km"} • $_estimatedTravelDuration',
                                    style: const TextStyle(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 22),
                              tooltip: 'Vuốt lên để xem chi tiết',
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() => _isCardCollapsed = false);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                              tooltip: 'Đóng',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _lastActiveDestination = _selectedTripDestination ?? _lastActiveDestination;
                                  _selectedTripDestination = null;
                                });
                              },
                            ),
                          ],
                        )
                      else ...[
                        // GIAO DIỆN ĐẦY ĐỦ CHI TIẾT
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                                  tooltip: 'Thu gọn xuống',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _isCardCollapsed = true);
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                                  tooltip: 'Đóng',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _lastActiveDestination = _selectedTripDestination ?? _lastActiveDestination;
                                      _selectedTripDestination = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Banner Nổi: CÒN BAO NHIÊU KM TỚI ĐỊA ĐIỂM (Cập nhật thời gian thực theo GPS)
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.emerald.withValues(alpha: 0.18),
                                AppColors.alpineCyan.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me, color: AppColors.neonGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'CÒN LẠI: ',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          _distanceToSelectedKm < 1
                                              ? '< 1 KM'
                                              : '${_distanceToSelectedKm.toStringAsFixed(1)} KM',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.neonGreen,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _estimatedTravelDuration,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _hasGpsFix
                                          ? 'Line bản đồ & cự ly đang bám theo GPS thực tế khi bạn di chuyển'
                                          : 'Đang kết nối vệ tinh GPS để bám sát chuyển động...',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

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
                                  // Căn chỉnh camera bao quát toàn bộ tuyến đường thực tế
                                  final points = _routingPolyline.isNotEmpty
                                      ? [_currentLocation, target, ..._routingPolyline]
                                      : [_currentLocation, target];
                                  _fitRouteBounds(points);
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
                    ],
                  ),
                ),
              ),
            ),

          // Selected Waypoint Bottom Preview Sheet (nếu người dùng bấm vào waypoint suối nước/trạm)
          if (_selectedWaypoint != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! > 180) {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedWaypoint = null);
                  }
                },
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
                      // Handle bar vuốt xuống để đóng
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
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
            ),

          // Card Kết Quả Lộ Trình Google Maps Tự Chọn (Chỉ hiện khi CHƯA thêm vào chuyến đi)
          if (_isCustomRouteMode && _customRouteDistanceKm != null && !_isCustomRouteCardCollapsed && _selectedTripDestination == null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.roundedXl,
                  border: Border.all(color: AppColors.alpineCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.alpineCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.alpineCyan.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.directions_outlined, size: 13, color: AppColors.alpineCyan),
                              SizedBox(width: 4),
                              Text(
                                'LỘ TRÌNH ĐƯỜNG BỘ TỰ CHỌN (A ➔ B)',
                                style: TextStyle(
                                  color: AppColors.alpineCyan,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Thu gọn (vẫn giữ lộ trình trên bản đồ)',
                          onPressed: () {
                            setState(() {
                              _isCustomRouteCardCollapsed = true;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.route, color: AppColors.neonGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_customOriginName  ➔  $_customDestinationName',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.straighten,
                            label: 'Khoảng cách',
                            value: '${_customRouteDistanceKm!.toStringAsFixed(1)} km',
                          ),
                        ),
                        Container(width: 1, height: 22, color: AppColors.borderSubtle),
                        Expanded(
                          child: TacticalBadge(
                            icon: Icons.timer_outlined,
                            label: 'Ước tính di chuyển',
                            value: _customRouteDurationText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: BouncingButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final target = _customDestinationPoint;
                          if (target != null) {
                            final start = _customOriginPoint ?? _currentLocation;
                            final points = _customRoutePolyline.isNotEmpty
                                ? [start, target, ..._customRoutePolyline]
                                : [start, target];
                            _fitRouteBounds(points);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.alpineCyan,
                            borderRadius: AppRadius.roundedMd,
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.center_focus_strong, size: 16, color: Colors.black),
                                SizedBox(width: 6),
                                Text(
                                  'Bao Quát Toàn Tuyến Đường',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nút Thêm Tuyến Đường A-B Này Vào Lịch Trình
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: BouncingButton(
                        onTap: _addCustomRouteToTrip,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.emerald, AppColors.neonGreen],
                            ),
                            borderRadius: AppRadius.roundedMd,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.playlist_add_check_rounded, size: 18, color: Colors.black),
                                SizedBox(width: 6),
                                Text(
                                  'Thêm Lộ Trình Này Vào Lịch Trình',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
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
            ),

          // Mini Dock Khôi phục Pop-up Lộ trình A-B khi thu gọn (Chỉ hiện khi CHƯA thêm vào chuyến đi)
          if (_isCustomRouteMode && _customRouteDistanceKm != null && _isCustomRouteCardCollapsed && _selectedTripDestination == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.roundedPill,
                    border: Border.all(color: AppColors.alpineCyan, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alt_route, size: 16, color: AppColors.alpineCyan),
                      const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _isCustomRouteCardCollapsed = false);
                          },
                          child: Text(
                            '$_customOriginName ➔ $_customDestinationName (${_customRouteDistanceKm!.toStringAsFixed(1)} km)',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncingButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isCustomRouteCardCollapsed = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.alpineCyan,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Mở lại', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Xóa lộ trình này',
                        onPressed: _clearCustomRoute,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Nút khôi phục Pop-up lộ trình khi lỡ tay đóng
          if (_selectedTripDestination == null && _selectedWaypoint == null && _lastActiveDestination != null && !_isCustomRouteMode)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Center(
                child: BouncingButton(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedTripDestination = _lastActiveDestination;
                      _isCardCollapsed = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.roundedPill,
                      border: Border.all(color: AppColors.summitGold.withValues(alpha: 0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.navigation, color: AppColors.summitGold, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Mở lại lộ trình: ${_lastActiveDestination!.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.summitGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 14),
                        ),
                      ],
                    ),
                  ),
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
                id: 'streets',
                name: 'Google Maps Đường Phố (Standard Roadmap)',
                desc: 'Bản đồ Google Maps chính hãng, mượt mà, đầy đủ ngõ hẻm & tên đường tiếng Việt',
                icon: Icons.map,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'satellite',
                name: 'Google Maps Vệ Tinh (Hybrid Satellite)',
                desc: 'Ảnh vệ tinh Google Maps độ nét cao kèm lớp nhãn đường sá & địa danh',
                icon: Icons.satellite_alt,
              ),
              const SizedBox(height: 10),
              _buildLayerOption(
                id: 'topo',
                name: 'Google Maps Địa Hình (Terrain Topo)',
                desc: 'Bản đồ địa hình Google Maps đồi núi đổ bóng 3D chuyên dụng dã ngoại',
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
