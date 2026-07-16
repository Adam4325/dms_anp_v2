import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

/// Guard absensi:
/// - Android: nomor API (`prefs.phone`) harus cocok dengan salah satu nomor SIM di HP.
/// - iOS: Apple tidak izinkan baca nomor SIM → cek nomor terdaftar + device ID
///   yang di-bind saat login (`prefs.androidID` vs `UniqueIdentifier.serial`).
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

  static Future<List<String>> _getAllSimPhoneNumbers() async {
    if (!Platform.isAndroid) {
      return <String>[];
    }
    try {
      final raw =
          await _channel.invokeMethod<List<dynamic>>('getAllSimPhoneNumbers');
      if (raw == null) {
        return <String>[];
      }
      return raw
          .map((e) => (e ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('SimPhoneGuard read all SIM failed: $e');
      return <String>[];
    }
  }

  static Future<String> _currentDeviceId() async {
    try {
      final id = await UniqueIdentifier.serial;
      return (id ?? '').toString().trim();
    } catch (e) {
      debugPrint('SimPhoneGuard read device id failed: $e');
      return '';
    }
  }

  /// iOS: nomor terdaftar wajib ada + device ID sama dengan yang dipakai login.
  static Future<({bool ok, String message})> _canAttendIos() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredPhone = prefs.getString('phone')?.trim() ?? '';
    if (registeredPhone.isEmpty) {
      return (
        ok: false,
        message:
            'Nomor HP terdaftar kosong.\nSilakan hubungi HR/Admin untuk update data.',
      );
    }

    final boundDeviceId = prefs.getString('androidID')?.trim() ?? '';
    if (boundDeviceId.isEmpty) {
      return (
        ok: false,
        message:
            'Device ID belum terikat.\nSilakan logout lalu login ulang di iPhone ini.',
      );
    }

    final currentDeviceId = await _currentDeviceId();
    if (currentDeviceId.isEmpty) {
      return (
        ok: false,
        message:
            'Device ID iPhone tidak terbaca.\nAbsensi tidak diizinkan.',
      );
    }

    if (currentDeviceId != boundDeviceId) {
      return (
        ok: false,
        message:
            'Perangkat iPhone tidak sesuai dengan yang terdaftar saat login.\n'
            'Silakan login ulang di HP ini.\n\n'
            'Device saat ini: $currentDeviceId\n'
            'Device login: $boundDeviceId',
      );
    }

    // iOS tidak bisa bandingkan nomor SIM ↔ API; yang dicek: phone ada + device bind.
    return (ok: true, message: '');
  }

  static Future<({bool ok, String message})> _canAttendAndroid() async {
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
            'Izin telepon ditolak.\nAbsensi membutuhkan akses nomor SIM di HP.',
      );
    }

    final simPhones = await _getAllSimPhoneNumbers();
    if (simPhones.isEmpty) {
      return (
        ok: false,
        message:
            'Tidak ada nomor SIM yang terbaca di HP.\n'
            'Pastikan SIM terpasang dan nomor MSISDN tersedia di SIM.\n'
            'Absensi tidak diizinkan.',
      );
    }

    final matched = simPhones.any((sim) => isSamePhone(sim, registeredPhone));
    if (!matched) {
      return (
        ok: false,
        message:
            'Tidak ada nomor SIM di HP yang sesuai nomor terdaftar.\n\n'
            'SIM di HP: ${simPhones.join(', ')}\n'
            'Terdaftar: $registeredPhone',
      );
    }

    return (ok: true, message: '');
  }

  static Future<({bool ok, String message})> canAttend() async {
    if (Platform.isIOS) {
      return _canAttendIos();
    }
    if (Platform.isAndroid) {
      return _canAttendAndroid();
    }
    return (ok: true, message: '');
  }

  static Future<bool> blockIfPhoneInvalid(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
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

    final title = Platform.isIOS ? 'Validasi Perangkat Gagal' : 'Validasi SIM Gagal';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              Platform.isIOS ? Icons.phone_iphone : Icons.sim_card_alert,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
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
