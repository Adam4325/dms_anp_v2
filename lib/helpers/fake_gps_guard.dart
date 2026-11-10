import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Helper terpusat untuk mendeteksi Mock Location / Fake GPS pada Android.
/// 
/// Menggunakan validasi resmi native Android OS melalui Geolocator:
/// - Android 12+ (API 31+): Location.isMock()
/// - Android < 12: Location.isFromMockProvider()
/// 
/// CATATAN: Jangan gunakan library trust_location karena memiliki bug
/// internal di mana LocationAssistant mengembalikan default `true` saat
/// koordinat awal belum siap (false positive 100%).
class FakeGpsGuard {
  /// Cek apakah posisi GPS terindikasi Fake/Mock Location
  static Future<bool> isMockLocation(Position? position) async {
    if (position == null) {
      return false;
    }
    return position.isMocked;
  }

  /// Cek synchronous langsung dari objek Position
  static bool isMock(Position? position) {
    if (position == null) {
      return false;
    }
    return position.isMocked;
  }

  /// Menampilkan SnackBar peringatan Fake GPS
  static void showWarningSnackBar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Perhatian: Anda terdeteksi menggunakan Fake GPS!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Menampilkan Dialog peringatan Fake GPS
  static Future<void> showWarningDialog(
    BuildContext context, {
    String? customMessage,
    VoidCallback? onConfirm,
  }) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'Fake GPS Terdeteksi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          customMessage ??
              'Sistem mendeteksi Anda menggunakan Fake GPS / Mock Location.\n\n'
                  'Aktivitas absensi Anda akan dicatat dan ditandai sebagai FAKE GPS pada sistem.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (onConfirm != null) {
                onConfirm();
              }
            },
            child: const Text(
              'Saya Mengerti',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget banner warning visual untuk disematkan di atas form absensi jika terdeteksi Fake GPS
  static Widget buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.red, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERINGATAN: FAKE GPS TERDETEKSI',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokasi terdeteksi menggunakan Fake GPS. Status absensi akan diflag FAKE.',
                  style: TextStyle(color: Colors.red.shade800, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
