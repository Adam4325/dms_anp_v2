import 'dart:async';

import 'package:dms_anp/src/Helper/app_navigator_key.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/services/NotificationServices.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInactivityController {
  UserInactivityController._();

  static VoidCallback? _resetHandler;

  static void registerResetHandler(VoidCallback handler) {
    _resetHandler = handler;
  }

  static void unregisterResetHandler(VoidCallback handler) {
    if (_resetHandler == handler) {
      _resetHandler = null;
    }
  }

  static void resetTimer() {
    _resetHandler?.call();
  }
}

/// Logout otomatis setelah [idleDuration] tanpa sentuhan layar (idle lokal).
/// Berbeda dari [is_sign.jsp]: selama server mengembalikan ACT, polling server tidak akan logout.
class UserInactivityScope extends StatefulWidget {
  static const Duration defaultIdleDuration = Duration(seconds: 90);

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
  Timer? _idleTimer;
  bool _logoutInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    UserInactivityController.registerResetHandler(_handleExternalReset);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleIdleFromPrefs());
  }

  @override
  void dispose() {
    UserInactivityController.unregisterResetHandler(_handleExternalReset);
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _persistLastActiveAt();
      _idleTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _scheduleIdleFromPrefs();
    }
  }

  Future<bool> _hasLoginSession() async {
    final p = await SharedPreferences.getInstance();
    final u = (p.getString('username') ?? '').trim();
    final d = (p.getString('drvid') ?? '').trim();
    return u.isNotEmpty || d.isNotEmpty;
  }

  void _onUserInteraction() {
    _persistLastActiveAt();
    _scheduleIdleFromPrefs();
  }

  void _handleExternalReset() {
    _persistLastActiveAt();
    _scheduleIdleFromPrefs();
  }

  Future<void> _persistLastActiveAt() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_lastActiveAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _scheduleIdleFromPrefs() async {
    _idleTimer?.cancel();
    if (!mounted) {
      return;
    }
    final p = await SharedPreferences.getInstance();
    if (!await _hasLoginSession()) {
      await p.remove(_lastActiveAtKey);
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final lastActiveMs = p.getInt(_lastActiveAtKey) ?? nowMs;
    final idleMs = nowMs - lastActiveMs;
    final idleLimitMs = widget.idleDuration.inMilliseconds;
    if (idleMs >= idleLimitMs) {
      await _onIdleTimeout();
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
