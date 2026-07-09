import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimPhoneGuard {
  static const MethodChannel _channel = MethodChannel('dms_anp/sim_phone');

  static String normalizeIdPhone(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }
    if (digits.startsWith('62')) {
      return digits;
    }
    if (digits.startsWith('0')) {
      return '62${digits.substring(1)}';
    }
    if (digits.startsWith('8')) {
      return '62$digits';
    }
    return digits;
  }

  static bool isSamePhone(String? a, String? b) {
    final left = normalizeIdPhone(a);
    final right = normalizeIdPhone(b);
    return left.isNotEmpty && left == right;
  }

  static Future<String?> _getSim1PhoneNumber() async {
    if (!Platform.isAndroid) {
      return null;
    }
    try {
      return await _channel.invokeMethod<String>('getSim1PhoneNumber');
    } catch (e) {
      debugPrint('SimPhoneGuard read SIM failed: $e');
      return null;
    }
  }

  static Future<({bool ok, String message})> canAttend() async {
    if (!Platform.isAndroid) {
      return (ok: true, message: '');
    }

    final prefs = await SharedPreferences.getInstance();
    final registeredPhone = prefs.getString('phone')?.trim() ?? '';
    if (registeredPhone.isEmpty) {
      return (
        ok: false,
        message:
            'Nomor HP terdaftar kosong.\nSilakan hubungi HR/Admin untuk update data.',
      );
    }

    final permission = await Permission.phone.request();
    if (!permission.isGranted) {
      return (
        ok: false,
        message:
            'Izin telepon ditolak.\nAbsensi membutuhkan akses nomor SIM Card 1.',
      );
    }

    final simPhone = await _getSim1PhoneNumber();
    if (simPhone == null || simPhone.trim().isEmpty) {
      return (
        ok: false,
        message:
            'SIM Card 1 tidak terbaca atau nomor SIM kosong.\nAbsensi tidak diizinkan.',
      );
    }

    if (!isSamePhone(simPhone, registeredPhone)) {
      return (
        ok: false,
        message:
            'Nomor SIM Card 1 tidak sesuai nomor terdaftar.\n\nSIM: $simPhone\nTerdaftar: $registeredPhone',
      );
    }

    return (ok: true, message: '');
  }

  static Future<bool> blockIfPhoneInvalid(BuildContext context) async {
    if (!Platform.isAndroid) {
      return false;
    }

    if (EasyLoading.isShow) {
      await EasyLoading.dismiss();
    }

    final result = await canAttend();
    if (result.ok) {
      return false;
    }
    if (!context.mounted) {
      return true;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.sim_card_alert, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('Validasi SIM Gagal')),
          ],
        ),
        content: SingleChildScrollView(child: Text(result.message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return true;
  }
}
