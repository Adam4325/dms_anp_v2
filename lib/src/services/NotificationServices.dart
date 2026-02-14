// File: lib/src/services/NotificationServices.dart
// FIXED VERSION - Perbaikan Stream Controller

import 'dart:async';
import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/NotificationData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? timer_data;
  final List<NotificationData> _notifications = [];
  StreamController<List<NotificationData>>? _notificationController;

  // ⭐ IMPROVED GETTER WITH PROPER INITIALIZATION
  StreamController<List<NotificationData>> get notificationController {
    if (_notificationController == null || _notificationController!.isClosed) {
      print('🔍 DEBUG: Creating new broadcast stream controller...');
      _notificationController = StreamController<List<NotificationData>>.broadcast();

      // ⭐ ADD STREAM LISTENER FOR DEBUGGING
      _notificationController!.stream.listen(
            (data) {
          print('🔍 DEBUG: Stream controller emitted ${data.length} notifications');
        },
        onError: (error) {
          print('❌ ERROR: Stream controller error: $error');
        },
        onDone: () {
          print('🔍 DEBUG: Stream controller done');
        },
      );
    }
    return _notificationController!;
  }

  Stream<List<NotificationData>> get notificationStream => notificationController.stream;
  List<NotificationData> get notifications => _notifications;

  // ⭐ IMPROVED SAFE ADD TO STREAM
  void _safeAddToStream(List<NotificationData> notifications) {
    print('🔍 DEBUG: _safeAddToStream called with ${notifications.length} notifications');

    try {
      // Pastikan controller ada dan tidak closed
      if (notificationController.isClosed) {
        print('❌ ERROR: Stream controller is closed, cannot add data');
        return;
      }

      // Add to stream
      notificationController.sink.add(notifications);
      print('✅ SUCCESS: Successfully added ${notifications.length} notifications to stream');

      // ⭐ FORCE STREAM UPDATE
      Future.delayed(Duration(milliseconds: 100), () {
        if (!notificationController.isClosed) {
          print('🔍 DEBUG: Forcing stream update...');
          notificationController.sink.add(notifications);
        }
      });

    } catch (e) {
      print('❌ ERROR: Failed to add to stream: $e');

      // Try to recreate controller
      try {
        print('🔍 DEBUG: Attempting to recreate stream controller...');
        _notificationController?.close();
        _notificationController = StreamController<List<NotificationData>>.broadcast();
        _notificationController!.sink.add(notifications);
        print('✅ SUCCESS: Stream controller recreated and data added');
      } catch (e2) {
        print('❌ ERROR: Failed to recreate stream controller: $e2');
      }
    }
  }

  // ⭐ IMPROVED TIMER START
  void startNotificationTimer({int intervalSeconds = 30}) {
    print('🔍 DEBUG: Starting notification timer with ${intervalSeconds}s interval');

    // Cancel existing timer
    timer_data?.cancel();

    // Pastikan controller ready
    if (_notificationController == null || _notificationController!.isClosed) {
      print('🔍 DEBUG: Initializing stream controller before starting timer');
      notificationController; // Initialize getter
    }

    // Start timer
    timer_data = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      print('🔍 DEBUG: Timer tick - checking API...');
      try {
        await checkApiForNotifications();
      } catch (e) {
        print('❌ ERROR: Timer tick error: $e');
      }
    });

    // ⭐ IMMEDIATE FIRST CHECK
    Future.delayed(Duration(seconds: 2), () {
      print('🔍 DEBUG: Performing immediate first API check...');
      checkApiForNotifications();
    });
  }

  // ⭐ IMPROVED API CHECK
  Future<void> checkApiForNotifications() async {
    print('🔍 DEBUG: checkApiForNotifications called');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var drvid = prefs.getString("drvid")?.toString() ?? '';

      if (drvid.isEmpty) {
        print('❌ ERROR: drvid is empty');
        return;
      }

      var urlBase = GlobalData.baseUrl + 'api/notifikasi/notifikasi_driver.jsp?method=notif-v1&drvid=${drvid}';
      print('🔍 DEBUG: API URL: $urlBase');

      final response = await http.get(
        Uri.parse(urlBase),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30)); // ⭐ ADD TIMEOUT

      print('🔍 DEBUG: API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic jsonResponse = json.decode(response.body);
        print('🔍 DEBUG: API Response: $jsonResponse');

        if (jsonResponse is Map<String, dynamic>) {
          final statusCode = jsonResponse['status_code'];
          print('🔍 DEBUG: API Status Code: $statusCode');

          if (statusCode == 200) {
            final dataArray = jsonResponse['data'];

            if (dataArray is List) {
              print('🔍 DEBUG: Found ${dataArray.length} items in data array');

              // ⭐ IMPROVED DATA PROCESSING
              List<NotificationData> newNotifications = [];

              for (var item in dataArray) {
                try {
                  final json = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
                  // Cek is_read kosong atau null
                  var isReadValue = json['is_read'];
                  bool isUnread = (isReadValue == null ||
                      isReadValue.toString().isEmpty ||
                      isReadValue.toString() == 'null');

                  print('🔍 DEBUG: Item ID: ${json['id']}, is_read: "$isReadValue", isUnread: $isUnread');

                  if (isUnread) {
                    var notif = NotificationData.fromJson(json);
                    newNotifications.add(notif);
                    print('✅ SUCCESS: Added unread notification - ID: ${notif.id}, P2H: ${notif.p2hnumber}');
                  } else {
                    print('🔍 DEBUG: Skipping read notification - ID: ${json['id']}');
                  }
                } catch (e) {
                  print('❌ ERROR: Failed to process notification item: $e');
                }
              }

              print('🔍 DEBUG: Total unread notifications: ${newNotifications.length}');

              // ⭐ UPDATE NOTIFICATIONS LIST
              _notifications.clear();
              _notifications.addAll(newNotifications);

              // ⭐ SEND TO STREAM
              _safeAddToStream(_notifications);

              // ⭐ ADDITIONAL DEBUG
              print('🔍 DEBUG: Current notifications in memory: ${_notifications.length}');
              for (var notif in _notifications) {
                print('  - ID: ${notif.id}, P2H: ${notif.p2hnumber}, Note: ${notif.note_verifikasi}');
              }

            } else {
              print('🔍 DEBUG: Data array is not a list or is null');
            }
          } else {
            print('🔍 DEBUG: API status code is not 200: $statusCode');
          }
        } else {
          print('🔍 DEBUG: Response is not a map');
        }
      } else {
        print('❌ ERROR: HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: Exception in checkApiForNotifications: $e');
    }
  }

  // ⭐ IMPROVED FORCE ADD FOR TESTING
  void forceAddNotificationFromAPI() {
    print('🔍 DEBUG: Force adding test notification...');

    final testNotif = NotificationData(
      id: "force_test_${DateTime.now().millisecondsSinceEpoch}",
      p2hnumber: "TEST-P2H-${DateTime.now().millisecondsSinceEpoch}",
      drvid: "TEST_DRIVER_ID",
      note_verifikasi: "Test notification - ${DateTime.now().toString()}",
      is_read: "",
      title: "Test P2H Notification",
      message: "This is a test notification",
      timestamp: DateTime.now(),
      data: {},
    );

    _notifications.add(testNotif);
    print('🔍 DEBUG: Added test notification - ID: ${testNotif.id}');

    // Send to stream
    _safeAddToStream(_notifications);

    print('🔍 DEBUG: Test notification sent to stream');
  }

  // ⭐ IMPROVED RESET SERVICE
  void resetService() {
    print('🔍 DEBUG: Resetting notification service...');

    // Stop timer
    timer_data?.cancel();
    timer_data = null;

    // Close old controller if exists
    if (_notificationController != null && !_notificationController!.isClosed) {
      _notificationController!.close();
    }

    // Clear notifications
    _notifications.clear();

    // Create new controller (will be created by getter when needed)
    _notificationController = null;

    print('🔍 DEBUG: Service reset completed');
  }

  // ⭐ IMPROVED REMOVE NOTIFICATION
  void removeNotification(String notificationId) {
    print('🔍 DEBUG: Removing notification with ID: $notificationId');

    int originalLength = _notifications.length;
    _notifications.removeWhere((notif) => notif.id == notificationId);

    if (_notifications.length < originalLength) {
      print('✅ SUCCESS: Notification removed, remaining: ${_notifications.length}');
      _safeAddToStream(_notifications);
    } else {
      print('⚠️ WARNING: Notification not found with ID: $notificationId');
    }
  }

  // ⭐ IMPROVED CLEAR ALL
  void clearAllNotifications() {
    print('🔍 DEBUG: Clearing all notifications...');
    _notifications.clear();
    _safeAddToStream(_notifications);
    print('✅ SUCCESS: All notifications cleared');
  }

  // ⭐ ENHANCED CHECK STATUS
  void checkStreamStatus() {
    print('🔍 DEBUG: ===== STREAM STATUS =====');
    print('🔍 DEBUG: Stream controller null: ${_notificationController == null}');
    print('🔍 DEBUG: Stream controller closed: ${_notificationController?.isClosed}');
    print('🔍 DEBUG: Stream has listener: ${_notificationController?.hasListener}');
    print('🔍 DEBUG: Current notifications count: ${_notifications.length}');
    print('🔍 DEBUG: Timer active: ${timer_data?.isActive}');

    for (int i = 0; i < _notifications.length; i++) {
      var notif = _notifications[i];
      print('🔍 DEBUG: Notification [$i]: ID=${notif.id}, P2H=${notif.p2hnumber}');
    }
    print('🔍 DEBUG: ========================');
  }

  Future<void> sendNotificationResponse(NotificationData notification) async {
    try {
      print('🔍 DEBUG: Sending notification response for ID: ${notification.id}');
      var UrlBase = GlobalData.baseUrl + 'api/notifikasi/update_notif_driver.jsp?method=update-notif-v1&notification_id=${notification.id}&drvid=${notification.drvid}&p2hnumber=${notification.p2hnumber}&is_read=1';
      print(' UrlBase ${UrlBase}');
      final response = await http.get(
        Uri.parse(UrlBase),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ SUCCESS: Notification response sent successfully');
      } else {
        print('❌ ERROR: Failed to send notification response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: Exception in sendNotificationResponse: $e');
    }
  }

  // ⭐ IMPROVED DISPOSE
  void dispose() {
    print('🔍 DEBUG: Disposing NotificationService...');

    // Cancel timer
    timer_data?.cancel();
    timer_data = null;

    // Close stream controller
    if (_notificationController != null && !_notificationController!.isClosed) {
      _notificationController!.close();
    }

    // Clear notifications
    _notifications.clear();

    print('🔍 DEBUG: NotificationService disposed');
  }
}