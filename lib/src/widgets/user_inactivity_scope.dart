import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/app_navigator_key.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/services/NotificationServices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserInactivityController {
  UserInactivityController._();

  static VoidCallback? _resetHandler;
  static VoidCallback? _reloadIdleDurationHandler;

  static void registerResetHandler(VoidCallback handler) {
    _resetHandler = handler;
  }

  static void unregisterResetHandler(VoidCallback handler) {
    if (_resetHandler == handler) {
      _resetHandler = null;
    }
  }

  static void registerReloadIdleDurationHandler(VoidCallback handler) {
    _reloadIdleDurationHandler = handler;
  }

  static void unregisterReloadIdleDurationHandler(VoidCallback handler) {
    if (_reloadIdleDurationHandler == handler) {
      _reloadIdleDurationHandler = null;
    }
  }

  static void resetTimer() {
    _resetHandler?.call();
  }

  /// Panggil setelah login agar limit idle dari API di-refresh (tanpa reset waktu sentuhan).
  static void reloadIdleDuration() {
    _reloadIdleDurationHandler?.call();
  }
}

/// Logout otomatis: idle foreground (tanpa sentuh layar) dan cek waktu saat app ditutup.
///
/// **Foreground** — timer dari sentuhan terakhir; limit detik dari
/// [duration_logout.jsp](https://apps.tuluatas.com/trucking/mobile/api/duration/duration_logout.jsp?method=get-notif-time)
/// (`time_duration`). Jika `0`, null, respons gagal, atau HTTP **400** → pakai [fallbackIdleSeconds] (90).
///
/// **Tutup / background app** — simpan timestamp. Saat buka lagi: ambil limit dari API lagi;
/// jika detik sejak tutup **≥** limit → logout; jika **<** limit → tidak logout, hitung idle foreground **mulai lagi** penuh.
///
/// `inactive` (keyboard, dialog sistem) **tidak** menggeser waktu sentuhan — supaya idle 50 dtk benar-benar 50 dtk.
class UserInactivityScope extends StatefulWidget {
  static const int fallbackIdleSeconds = 90;

  static const Duration defaultIdleDuration = Duration(seconds: fallbackIdleSeconds);

  static const String idleDurationApiPath = 'api/duration/duration_logout.jsp';
  static const String idleDurationApiMethod = 'get-notif-time';

  const UserInactivityScope({
    super.key,
    required this.child,
    this.idleDuration = defaultIdleDuration,
  });

  final Widget child;
  final Duration idleDuration;

  @override
  State<UserInactivityScope> createState() => _UserInactivityScopeState();
}

class _UserInactivityScopeState extends State<UserInactivityScope>
    with WidgetsBindingObserver {
  static const String _lastActiveAtKey = 'idle_last_active_at_ms';
  static const String _backgroundAtKey = 'idle_background_at_ms';

  Timer? _idleTimer;
  bool _logoutInProgress = false;
  late Duration _idleLimit;
  int _lastKnownActiveMs = DateTime.now().millisecondsSinceEpoch;
  int _scheduleGeneration = 0;
  bool _resumeNeedsBackgroundCheck = false;

  @override
  void initState() {
    super.initState();
    _idleLimit = widget.idleDuration;
    WidgetsBinding.instance.addObserver(this);
    UserInactivityController.registerResetHandler(_handleExternalReset);
    UserInactivityController.registerReloadIdleDurationHandler(_handleReloadIdleDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadIdleDurationFromApi());
    });
  }

  @override
  void dispose() {
    UserInactivityController.unregisterResetHandler(_handleExternalReset);
    UserInactivityController.unregisterReloadIdleDurationHandler(_handleReloadIdleDuration);
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _resumeNeedsBackgroundCheck = true;
      _idleTimer?.cancel();
      unawaited(_persistBackgroundTimestamp());
    } else if (state == AppLifecycleState.inactive) {
      // Jangan bump `lastActive` — sering membuat idle tidak pernah tercapai.
      _idleTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_resumeNeedsBackgroundCheck) {
        _resumeNeedsBackgroundCheck = false;
        unawaited(_handleResumeAfterPossibleBackground());
      } else {
        _scheduleIdleFromPrefs();
      }
    }
  }

  Future<bool> _hasLoginSession() async {
    final p = await SharedPreferences.getInstance();
    final u = (p.getString('username') ?? '').trim();
    final d = (p.getString('drvid') ?? '').trim();
    return u.isNotEmpty || d.isNotEmpty;
  }

  void _bumpLastActive() {
    _lastKnownActiveMs = DateTime.now().millisecondsSinceEpoch;
  }

  /// Simpan waktu saat app masuk background (tutup / home).
  Future<void> _persistBackgroundTimestamp() async {
    if (!await _hasLoginSession()) {
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setInt(_backgroundAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Ambil detik idle dari API. `0`, null, non-200 (termasuk **400**), JSON gagal → [fallbackIdleSeconds].
  Future<int> _fetchIdleLimitSecondsFromApi() async {
    try {
      final uri = Uri.parse(
        '${GlobalData.baseUrlProd}${UserInactivityScope.idleDurationApiPath}',
      ).replace(
        queryParameters: <String, String>{
          'method': UserInactivityScope.idleDurationApiMethod,
        },
      );
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 400 || response.statusCode != 200) {
        return UserInactivityScope.fallbackIdleSeconds;
      }

      var body = response.body.trimLeft();
      if (body.startsWith('\ufeff')) {
        body = body.substring(1);
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return UserInactivityScope.fallbackIdleSeconds;
      }
      final sec = _parsePositiveTimeDurationSeconds(Map<String, dynamic>.from(decoded));
      if (sec == null || sec <= 0) {
        return UserInactivityScope.fallbackIdleSeconds;
      }
      return sec.clamp(1, 86400).toInt();
    } catch (e) {
      debugPrint('UserInactivityScope idle API: $e');
      return UserInactivityScope.fallbackIdleSeconds;
    }
  }

  /// Hanya angka **> 0** dianggap valid; `0` / null / bukan success → null (caller pakai fallback).
  static int? _parsePositiveTimeDurationSeconds(Map<String, dynamic> map) {
    final st = map['status']?.toString().trim().toLowerCase();
    if (st != 'success') {
      return null;
    }
    final data = map['data'];
    if (data is! Map) {
      return null;
    }
    final rawTd = data['time_duration'];
    if (rawTd == null) {
      return null;
    }
    int? v;
    if (rawTd is int) {
      v = rawTd;
    } else if (rawTd is num) {
      v = rawTd.toInt();
    } else {
      v = int.tryParse(rawTd.toString().trim());
    }
    if (v == null || v <= 0) {
      return null;
    }
    return v;
  }

  /// Set limit dari API lalu jadwalkan foreground idle **tanpa** menggeser sentuhan terakhir.
  Future<void> _loadIdleDurationFromApi() async {
    if (!await _hasLoginSession()) {
      if (!mounted) {
        return;
      }
      setState(
        () => _idleLimit =
            const Duration(seconds: UserInactivityScope.fallbackIdleSeconds),
      );
      _scheduleIdleFromPrefs();
      return;
    }

    final sec = await _fetchIdleLimitSecondsFromApi();
    if (!mounted) {
      return;
    }
    setState(() => _idleLimit = Duration(seconds: sec));
    _scheduleIdleFromPrefs();
  }

  /// Setelah buka app dari background: bandingkan lama tutup vs limit API; lalu reset foreground jika masih login.
  Future<void> _handleResumeAfterPossibleBackground() async {
    if (!await _hasLoginSession()) {
      final p = await SharedPreferences.getInstance();
      await p.remove(_backgroundAtKey);
      return;
    }

    final limitSec = await _fetchIdleLimitSecondsFromApi();
    final p = await SharedPreferences.getInstance();
    final bgMs = p.getInt(_backgroundAtKey);
    await p.remove(_backgroundAtKey);

    if (bgMs != null) {
      final elapsedSec =
          (DateTime.now().millisecondsSinceEpoch - bgMs) / 1000.0;
      if (elapsedSec >= limitSec) {
        await _onIdleTimeout();
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() => _idleLimit = Duration(seconds: limitSec));
    // Hitung idle foreground mulai lagi dari sekarang (penuh `limitSec`).
    _bumpLastActive();
    await _persistLastActiveAt();
    _scheduleIdleFromPrefs();
  }

  void _onUserInteraction() {
    _bumpLastActive();
    unawaited(_persistLastActiveAt());
    _scheduleIdleFromPrefs();
  }

  void _handleExternalReset() {
    _bumpLastActive();
    unawaited(_persistLastActiveAt());
    _scheduleIdleFromPrefs();
  }

  void _handleReloadIdleDuration() {
    unawaited(_loadIdleDurationFromApi());
  }

  Future<void> _persistLastActiveAt() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastActiveAtKey, _lastKnownActiveMs);
  }

  Future<void> _scheduleIdleFromPrefs() async {
    final gen = ++_scheduleGeneration;
    _idleTimer?.cancel();
    if (!mounted) {
      return;
    }
    final p = await SharedPreferences.getInstance();
    if (gen != _scheduleGeneration || !mounted) {
      return;
    }
    if (!await _hasLoginSession()) {
      await p.remove(_lastActiveAtKey);
      await p.remove(_backgroundAtKey);
      return;
    }
    if (gen != _scheduleGeneration || !mounted) {
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final fromDisk = p.getInt(_lastActiveAtKey);
    final lastActiveMs = math.max(fromDisk ?? _lastKnownActiveMs, _lastKnownActiveMs);
    final idleMs = nowMs - lastActiveMs;
    final idleLimitMs = _idleLimit.inMilliseconds;
    if (idleMs >= idleLimitMs) {
      await _onIdleTimeout();
      return;
    }
    if (gen != _scheduleGeneration || !mounted) {
      return;
    }

    final remainingMs = idleLimitMs - idleMs;
    _idleTimer = Timer(Duration(milliseconds: remainingMs), _onIdleTimeout);
  }

  Future<void> _onIdleTimeout() async {
    if (_logoutInProgress || !mounted) {
      return;
    }
    if (!await _hasLoginSession()) {
      return;
    }
    _logoutInProgress = true;
    try {
      NotificationService().stopPolling();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActiveAtKey);
      await prefs.remove(_backgroundAtKey);
      await prefs.clear();
      final nav = appNavigatorKey.currentState;
      if (nav != null && mounted) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => LoginPage()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('UserInactivityScope logout: $e');
    } finally {
      _logoutInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserInteraction(),
      child: widget.child,
    );
  }
}
