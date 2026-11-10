import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../src/Helper/Provider.dart';

/// Helper pengamanan absensi untuk mendeteksi aplikasi VPN terinstal maupun koneksi VPN aktif di Android.
/// Mencegah manipulasi lokasi/IP via VPN (Turbo VPN, WARP, OpenVPN, dsb).
class VpnGuard {
  static const MethodChannel _channel = MethodChannel('dms_anp/vpn_guard');

  /// Cek apakah koneksi VPN saat ini sedang aktif (connected) di Android
  static Future<bool> isVpnActive() async {
    if (!GlobalData.checkVpn) return false;
    if (!Platform.isAndroid) return false;

    try {
      final bool? isActive = await _channel.invokeMethod<bool>('isVpnActive');
      return isActive ?? false;
    } catch (e) {
      debugPrint('VpnGuard isVpnActive failed: $e');
      return false;
    }
  }

  /// Ambil daftar nama aplikasi VPN yang terinstal di perangkat (Turbo VPN, dsb)
  static Future<List<String>> getInstalledVpnApps() async {
    if (!GlobalData.checkVpn) return [];
    if (!Platform.isAndroid) return [];

    try {
      final List<dynamic>? list =
          await _channel.invokeMethod<List<dynamic>>('getInstalledVpnApps');
      if (list == null) return [];
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('VpnGuard getInstalledVpnApps failed: $e');
      return [];
    }
  }

  /// Cek apakah VPN terdeteksi: baik koneksi aktif MAUPUN aplikasi VPN terinstal
  static Future<bool> isVpnDetected() async {
    if (!GlobalData.checkVpn) return false;
    if (!Platform.isAndroid) return false;

    try {
      final bool? detected =
          await _channel.invokeMethod<bool>('isVpnDetected');
      return detected ?? false;
    } catch (e) {
      debugPrint('VpnGuard isVpnDetected failed: $e');
      return false;
    }
  }

  /// Buka menu pengaturan VPN bawaan Android langsung
  static Future<void> openVpnSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openVpnSettings');
    } catch (e) {
      debugPrint('VpnGuard openVpnSettings failed: $e');
    }
  }

  /// Memeriksa apakah VPN terdeteksi (aplikasi terinstal atau koneksi aktif).
  /// Menampilkan dialog pemblokiran. Jika [popOnDismiss] bernilai true,
  /// halaman saat ini akan otomatis di-pop (keluar kembali ke Dashboard).
  /// Mengembalikan `true` jika diblokir, atau `false` jika bersih/aman.
  static Future<bool> blockIfVpnDetected(
    BuildContext context, {
    bool popOnDismiss = false,
    String? customMessage,
  }) async {
    final bool detected = await isVpnDetected();
    if (!detected) return false;
    if (!context.mounted) return true;

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    final List<String> installedApps = await getInstalledVpnApps();
    final bool active = await isVpnActive();

    String title = 'Aplikasi VPN Terdeteksi';
    String message = '';

    if (installedApps.isNotEmpty && active) {
      final appListStr = installedApps.map((a) => '• $a').join('\n');
      message =
          'Sistem mendeteksi aplikasi VPN terpasang dan koneksi VPN aktif di perangkat Anda:\n\n'
          '$appListStr\n\n'
          'Untuk memastikan keaslian lokasi dan integritas absensi, Anda WAJIB mematikan koneksi VPN dan mencopot (uninstall) aplikasi VPN sebelum dapat masuk ke menu Absensi.';
    } else if (installedApps.isNotEmpty) {
      final appListStr = installedApps.map((a) => '• $a').join('\n');
      message =
          'Sistem mendeteksi aplikasi VPN terpasang di perangkat Anda:\n\n'
          '$appListStr\n\n'
          'Untuk menjaga keaslian data dan lokasi absensi, Anda TIDAK DIIZINKAN mengakses menu Absensi selama aplikasi VPN terpasang pada perangkat.\n\n'
          'Silakan uninstal / copot aplikasi VPN tersebut terlebih dahulu.';
    } else {
      title = 'Koneksi VPN Aktif Terdeteksi';
      message =
          'Sistem mendeteksi koneksi VPN aktif pada perangkat Anda.\n\n'
          'Untuk memastikan keaslian data dan lokasi absensi, Anda WAJIB mematikan koneksi VPN terlebih dahulu sebelum melakukan absensi.';
    }

    if (customMessage != null) {
      message = customMessage;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),
        ),
        actions: [
          if (active)
            TextButton.icon(
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Pengaturan VPN'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openVpnSettings();
              },
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (popOnDismiss && context.mounted) {
      Navigator.of(context).pop();
    }

    return true;
  }

  /// Alias kompatibilitas
  static Future<bool> blockIfVpnActive(
    BuildContext context, {
    bool popOnDismiss = false,
    String? customMessage,
  }) async {
    return blockIfVpnDetected(context,
        popOnDismiss: popOnDismiss, customMessage: customMessage);
  }

  /// Menampilkan SnackBar peringatan cepat jika VPN terdeteksi
  static void showWarningSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Peringatan: Matikan / Uninstal VPN sebelum melakukan absensi!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'SETTING',
          textColor: Colors.yellow,
          onPressed: () => openVpnSettings(),
        ),
      ),
    );
  }

  /// Widget banner warning visual untuk disematkan di atas form absensi jika terdeteksi VPN
  static Widget buildWarningBanner({
    List<String>? appNames,
    VoidCallback? onPressedSettings,
  }) {
    final String subtitle = (appNames != null && appNames.isNotEmpty)
        ? 'Aplikasi VPN terpasang: ${appNames.join(", ")}. Uninstal untuk absensi.'
        : 'Matikan koneksi VPN / uninstal aplikasi VPN untuk dapat melakukan absensi.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade400, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.red, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERINGATAN: APLIKASI / KONEKSI VPN TERDETEKSI',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 11),
                ),
              ],
            ),
          ),
          if (onPressedSettings != null)
            TextButton(
              onPressed: onPressedSettings,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Setting',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
