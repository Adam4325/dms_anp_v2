import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsSecurityChecker {
  static Future<Map<String, dynamic>> checkGpsSecurity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          "isFake": false,
          "reason": "GPS tidak aktif",
          "latitude": 0.0,
          "longitude": 0.0,
          "accuracy": 0.0,
        };
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("last_lat", position.latitude);
      await prefs.setDouble("last_lng", position.longitude);
      await prefs.setInt("last_time", DateTime.now().millisecondsSinceEpoch);

      return {
        "isFake": false,
        "reason": "",
        "latitude": position.latitude,
        "longitude": position.longitude,
        "accuracy": position.accuracy,
      };
    } catch (e) {
      return {
        "isFake": false,
        "reason": "Error GPS: $e",
        "latitude": 0.0,
        "longitude": 0.0,
        "accuracy": 0.0,
      };
    }
  }
}
