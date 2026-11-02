import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  /// Lấy chi tiết thông tin GPS phần cứng (Tọa độ, độ cao, sai số, thời gian)
  static Future<Position?> getDetailedPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Yêu cầu cấp quyền và lấy tọa độ GPS phần cứng hiện tại
  static Future<LatLng?> getCurrentLocation() async {
    final pos = await getDetailedPosition();
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Theo dõi vị trí GPS thời gian thực (Position Stream)
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // Cập nhật mỗi khi di chuyển 5 mét
      ),
    );
  }
}

