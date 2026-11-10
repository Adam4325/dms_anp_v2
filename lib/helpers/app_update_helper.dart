import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper terpusat untuk In-App Update Google Play Store pada aplikasi DMS ANP.
/// Mendukung:
/// - Pengecekan otomatis versi baru di Google Play saat aplikasi dibuka.
/// - Flexible Update: Pengemudi tetap bisa beraktivitas saat unduhan berjalan di background.
/// - Immediate Update: Untuk pembaruan wajib (force update).
/// - Fallback: Buka link Play Store manual jika dibutuhkan.
class AppUpdateHelper {
  static const String playStorePackage = 'com.anp.dms_anp';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$playStorePackage';

  /// Periksa dan tawarkan pembaruan secara otomatis saat aplikasi/dashboard dibuka.
  /// [immediate]: jika true, akan memaksa update (force update). Default false (flexible).
  static Future<void> checkAndPromptUpdate(
    BuildContext context, {
    bool immediate = false,
  }) async {
    // In-App Update hanya tersedia di platform Android
    if (!Platform.isAndroid) return;

    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (immediate) {
          // Force update: Pengemudi wajib update sebelum lanjut
          await InAppUpdate.performImmediateUpdate();
        } else {
          // Flexible update: Unduh di background
          final AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();
          if (result == AppUpdateResult.success && context.mounted) {
            _showUpdateCompletedBanner(context);
          }
        }
      }
    } catch (e) {
      // Catch silently agar tidak mengganggu jika berjalan di mode debug / perangkat tanpa Play Store
      debugPrint('AppUpdateHelper checkAndPromptUpdate notice: $e');
    }
  }

  /// Menampilkan SnackBar saat unduhan flexible update selesai dan siap dipasang.
  static void _showUpdateCompletedBanner(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1), // Tampil sampai diklik
        backgroundColor: const Color(0xFF2E7D32),
        content: const Row(
          children: [
            Icon(Icons.system_update_alt, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Versi baru DMS ANP selesai diunduh!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'PASANG SEKARANG',
          textColor: Colors.amberAccent,
          onPressed: () async {
            try {
              await InAppUpdate.completeFlexibleUpdate();
            } catch (e) {
              debugPrint('AppUpdateHelper completeFlexibleUpdate error: $e');
            }
          },
        ),
      ),
    );
  }

  /// Buka halaman aplikasi DMS ANP di Google Play Store secara manual
  static Future<void> openPlayStore() async {
    final Uri marketUri = Uri.parse('market://details?id=$playStorePackage');
    final Uri webUri = Uri.parse(playStoreUrl);

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('AppUpdateHelper openPlayStore error: $e');
    }
  }
}

