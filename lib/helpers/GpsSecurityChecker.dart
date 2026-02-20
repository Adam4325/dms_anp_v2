import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:trust_location/trust_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsSecurityChecker {
  static Future<Map<String, dynamic>> checkGpsSecurity() async {
    bool isFake = false;
    String reason = "";

    try {
      // 1️⃣ Cek Mock Location
      // bool isMock = await TrustLocation.isMockLocation;
      // if (isMock) {
      //   return {
      //     "isFake": true,
      //     "reason": "Mock location terdeteksi"
      //   };
      // }

      // 2️⃣ Cek apakah GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          "isFake": true,
          "reason": "GPS tidak aktif"
        };
      }

      // 3️⃣ Ambil posisi terbaru
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // 4️⃣ Cek akurasi
      if (position.accuracy > 50) {
        isFake = true;
        reason = "Akurasi buruk (${position.accuracy.toStringAsFixed(2)} m)";
      }

      // 5️⃣ Cek loncatan lokasi
      SharedPreferences prefs = await SharedPreferences.getInstance();

      double? lastLat = prefs.getDouble("last_lat");
      double? lastLng = prefs.getDouble("last_lng");
      int? lastTime = prefs.getInt("last_time");

      if (lastLat != null && lastLng != null && lastTime != null) {
        double distance = Geolocator.distanceBetween(
          lastLat,
          lastLng,
          position.latitude,
          position.longitude,
        );

        int timeDiff =
            DateTime.now().millisecondsSinceEpoch - lastTime;

        double seconds = timeDiff / 1000;

        if (seconds > 0) {
          double speed = distance / seconds; // m/s

          // > 60 m/s = 216 km/jam
          if (speed > 60) {
            isFake = true;
            reason =
            "Pergerakan tidak wajar (${speed.toStringAsFixed(2)} m/s)";
          }
        }
      }

      // Simpan lokasi terakhir
      await prefs.setDouble("last_lat", position.latitude);
      await prefs.setDouble("last_lng", position.longitude);
      await prefs.setInt(
          "last_time", DateTime.now().millisecondsSinceEpoch);

      return {
        "isFake": isFake,
        "reason": reason,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "accuracy": position.accuracy
      };
    } catch (e) {
      return {
        "isFake": true,
        "reason": "Error GPS: $e"
      };
    }
  }
}
