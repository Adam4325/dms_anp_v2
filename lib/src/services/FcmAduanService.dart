import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/firebase_options_manual.dart';
import 'package:dms_anp/src/pages/aduan/AduanMainPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Required for handling background FCM callback in a separate isolate.
  await Firebase.initializeApp(
    options: ManualFirebaseOptions.currentPlatform,
  );
}

class FcmAduanService {
  FcmAduanService._();
  static final FcmAduanService instance = FcmAduanService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'aduan_channel',
    'Aduan Notifications',
    description: 'Notifikasi aduan baru',
    importance: Importance.high,
  );

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayloadTap(response.payload, navigatorKey);
      },
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final title = notification?.title ?? 'Aduan Baru';
      final body = notification?.body ?? 'Ada aduan baru menunggu tindakan';
      final payload = json.encode(message.data);
      await _localNotif.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aduan_channel',
            'Aduan Notifications',
            channelDescription: 'Notifikasi aduan baru',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _openFromData(message.data, navigatorKey);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _openFromData(initialMessage.data, navigatorKey);
    }

    _messaging.onTokenRefresh.listen((token) async {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final loginname = prefs.getString('loginname') ?? '';
      if (username.isNotEmpty) {
        await syncToken(username: username, loginname: loginname, token: token);
      }
    });
  }

  Future<void> syncTokenIfPossible() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final loginname = prefs.getString('loginname') ?? '';
    if (username.isEmpty) {
      return;
    }
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await syncToken(username: username, loginname: loginname, token: token);
  }

  Future<void> syncToken({
    required String username,
    required String loginname,
    required String token,
  }) async {
    final uri = Uri.parse('${GlobalData.baseUrl}api/firebase/save_token_user.jsp')
        .replace(queryParameters: {
      'method': 'save-token-user-v1',
      'username': username,
      'loginname': loginname,
      'token': token,
      'platform': 'android',
    });
    try {
      await http.get(uri, headers: {'Accept': 'application/json'});
    } catch (_) {}
  }

  void _handlePayloadTap(
      String? payload, GlobalKey<NavigatorState> navigatorKey) {
    if (payload == null || payload.isEmpty) {
      return;
    }
    try {
      final decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        _openFromData(decoded, navigatorKey);
      }
    } catch (_) {}
  }

  void _openFromData(
      Map<String, dynamic> data, GlobalKey<NavigatorState> navigatorKey) {
    final screen = (data['screen'] ?? data['type'] ?? '').toString().toLowerCase();
    if (screen != 'aduan') {
      return;
    }
    final nav = navigatorKey.currentState;
    if (nav == null) {
      return;
    }
    nav.push(MaterialPageRoute(builder: (_) => AduanMainPage()));
  }
}

