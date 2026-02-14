// File: lib/src/services/PermissionService.dart
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart'; // Uncomment jika sudah install

class PermissionService {

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      print('🔍 DEBUG: Requesting notification permission...');

      // Jika permission_handler tidak tersedia, return true untuk testing
      // Uncomment code dibawah jika sudah install permission_handler
      /*
      PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        print('✅ SUCCESS: Notification permission granted');
        return true;
      } else if (status.isDenied) {
        print('❌ ERROR: Notification permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        print('⚠️ WARNING: Notification permission permanently denied');
        await openAppSettings();
        return false;
      }
      */

      // Temporary: always return true for testing
      print('⚠️ WARNING: Permission check skipped (permission_handler not configured)');
      return true;

    } catch (e) {
      print('❌ ERROR: Exception in requestNotificationPermission: $e');
      return false;
    }
  }

  // Request system alert window permission (untuk overlay)
  static Future<bool> requestSystemAlertWindowPermission() async {
    try {
      print('🔍 DEBUG: Requesting system alert window permission...');

      // Jika permission_handler tidak tersedia, return true untuk testing
      // Uncomment code dibawah jika sudah install permission_handler
      /*
      PermissionStatus status = await Permission.systemAlertWindow.request();

      if (status.isGranted) {
        print('✅ SUCCESS: System alert window permission granted');
        return true;
      } else {
        print('❌ ERROR: System alert window permission denied');
        return false;
      }
      */

      // Temporary: always return true for testing
      print('⚠️ WARNING: Permission check skipped (permission_handler not configured)');
      return true;

    } catch (e) {
      print('❌ ERROR: Exception in requestSystemAlertWindowPermission: $e');
      return false;
    }
  }

  // Check apakah permission sudah granted
  static Future<bool> checkNotificationPermission() async {
    try {
      print('🔍 DEBUG: Checking notification permission...');

      // Jika permission_handler tidak tersedia, return true untuk testing
      // Uncomment code dibawah jika sudah install permission_handler
      /*
      PermissionStatus status = await Permission.notification.status;
      return status.isGranted;
      */

      // Temporary: always return true for testing
      return true;

    } catch (e) {
      print('❌ ERROR: Exception in checkNotificationPermission: $e');
      return false;
    }
  }

  // Show dialog untuk minta permission
  static Future<void> showPermissionDialog(BuildContext context) async {
    if (context == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Izin Notifikasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Aplikasi memerlukan izin notifikasi untuk menampilkan peringatan penting.'),
                SizedBox(height: 10),
                Text('Silakan aktifkan notifikasi di pengaturan aplikasi.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Pengaturan'),
              onPressed: () {
                Navigator.of(context).pop();
                // openAppSettings(); // Uncomment jika sudah install permission_handler
              },
            ),
          ],
        );
      },
    );
  }
}