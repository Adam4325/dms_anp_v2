import 'dart:async';
import 'dart:ui';

import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/Helper/logkar_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogkarPositionBackgroundService {
  static const String _prefsRunningKey = 'logkar_bg_running';

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      return;
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: 'DMS ANP Logkar',
        initialNotificationContent: 'Pelacakan posisi mixer aktif',
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<bool> _shouldTrack() async {
    if (!globals.isApiLokarRUN) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('login_type') ?? '';
    final noDo = prefs.getString('logkar_mixer_no_do')?.trim() ?? '';
    if (loginType != 'MIXER' || noDo.isEmpty) {
      return false;
    }
    final creds = await LogkarApiService.loadCredentials();
    return creds != null;
  }

  static Future<void> syncTrackingState() async {
    final shouldTrack = await _shouldTrack();
    if (shouldTrack) {
      await start();
    } else {
      await stop();
    }
  }

  static Future<void> start() async {
    if (!await _shouldTrack()) {
      return;
    }
    await initialize();
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsRunningKey, true);
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('stopService');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsRunningKey, false);
  }
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  Timer? timer;
  service.on('stopService').listen((_) {
    timer?.cancel();
    service.stopSelf();
  });

  timer = Timer.periodic(const Duration(minutes: 1), (_) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await service.setForegroundNotificationInfo(
          title: 'DMS ANP Logkar',
          content: 'Mengirim posisi mixer...',
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('login_type') ?? '';
    final noDo = prefs.getString('logkar_mixer_no_do')?.trim() ?? '';
    if (loginType != 'MIXER' || noDo.isEmpty) {
      return;
    }
    if (!(prefs.getBool('is_api_lokar_run') ?? false)) {
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      await LogkarApiService.sendPositionFromPrefs(
        noDo: noDo,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
      );
    } catch (e) {
      debugPrint('Logkar background position error: $e');
    }
  });
}
