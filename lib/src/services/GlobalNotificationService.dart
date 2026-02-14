// File: lib/src/services/GlobalNotificationService.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/model/NotificationData.dart';

class GlobalNotificationService {
  static final GlobalNotificationService _instance = GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  Timer? _timer;
  OverlayEntry? _overlayEntry;
  BuildContext? _context;

  // Inisialisasi service dengan context global
  void initialize(BuildContext context) {
    _context = context;
    startNotificationTimer();
  }

  // Mulai timer notification
  void startNotificationTimer({int intervalSeconds = 30}) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      _checkApiForNotifications();
    });
  }

  // Stop timer notification
  void stopNotificationTimer() {
    _timer?.cancel();
    _removeOverlay();
  }

  // Check API untuk notifikasi
  Future<void> _checkApiForNotifications() async {
    try {
      // Ganti dengan URL API Anda
      final response = await http.get(
        Uri.parse('https://your-api-endpoint.com/notifications'),
        headers: {
          'Content-Type': 'application/json',
          // Tambahkan header lain jika perlu
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Jika ada notifikasi baru
        if (data['hasNewNotification'] == true) {
          _showNotificationOverlay(data);
        }
      }
    } catch (e) {
      print('Error checking API: $e');
    }
  }

  // Tampilkan overlay notifikasi
  void _showNotificationOverlay(Map<String, dynamic> data) {
    final ctx = _context;
    if (ctx == null) return;

    _removeOverlay(); // Remove existing overlay dulu

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _handleNotificationClick(data);
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Notifikasi Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          data['message'] ?? 'Ada data baru yang perlu perhatian',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.close,
                    color: Colors.blue.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    Overlay.of(ctx).insert(_overlayEntry!);

    // Auto hide setelah 5 detik jika tidak diklik
    Timer(Duration(seconds: 5), () {
      _removeOverlay();
    });
  }

  // Handle click notifikasi
  void _handleNotificationClick(Map<String, dynamic> data) async {
    _removeOverlay();

    // Kirim data kembali ke API
    try {
      await http.post(
        Uri.parse('https://your-api-endpoint.com/notification-response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'notification_id': data['id'],
          'response_data': data,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      print('Notification response sent successfully');
    } catch (e) {
      print('Error sending notification response: $e');
    }
  }

  // Remove overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Dispose service
  void dispose() {
    _timer?.cancel();
    _removeOverlay();
  }
}