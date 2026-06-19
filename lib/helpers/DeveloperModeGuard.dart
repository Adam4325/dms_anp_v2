import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DeveloperModeGuard {
  static const MethodChannel _channel = MethodChannel('dms_anp/developer_mode');

  static Future<bool> isDeveloperModeEnabled() async {
    if (!GlobalData.checkDeveloperMode) return false;
    if (!Platform.isAndroid) return false;

    try {
      return await _channel.invokeMethod<bool>('isDeveloperModeEnabled') ?? false;
    } catch (e) {
      debugPrint('DeveloperModeGuard check failed: $e');
      return false;
    }
  }

  static Future<bool> blockIfDeveloperModeEnabled(BuildContext context) async {
    final enabled = await isDeveloperModeEnabled();
    if (!enabled) return false;
    if (!context.mounted) return true;

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disable Developer Mode'),
        content: const Text(
          'Developer Mode aktif. Silahkan matikan Developer Mode terlebih dahulu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!context.mounted) return true;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ViewDashboard()),
      (_) => false,
    );
    return true;
  }
}
