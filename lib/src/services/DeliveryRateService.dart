import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:dms_anp/src/Helper/Provider.dart';

class DeliveryRateService {
  static const String _defaultPhone = "0815-4621-5818";

  /// Mengambil nomor telepon customer berdasarkan nomor DO yang sedang ONGOING
  /// Endpoint: GET /api/delivery/customer-phone?do_number={nodo}
  static Future<Map<String, dynamic>> getCustomerPhone(String doNumber) async {
    try {
      final safeDo = doNumber.trim();
      final uri = Uri.parse('${GlobalData.baseUrl}api/delivery/customer_phone.jsp').replace(
        queryParameters: {'do_number': safeDo},
      );

      final response = await http
          .get(uri, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "success": true,
          "customer_phone": data["customer_phone"] ?? _defaultPhone,
          "formatted_phone": data["formatted_phone"] ?? formatInternationalPhone(_defaultPhone),
          "message": data["message"] ?? "Berhasil",
        };
      }
    } catch (e) {
      print("Error getCustomerPhone: $e");
    }

    // Fallback default jika gagal terhubung
    return {
      "success": false,
      "customer_phone": _defaultPhone,
      "formatted_phone": formatInternationalPhone(_defaultPhone),
      "message": "Menggunakan nomor default",
    };
  }

  /// Submit rating pengiriman ke Backend API
  /// Endpoint: POST /api/delivery/rate
  /// Body: { "do_number": "...", "rate": 0, "status": "OUTUNLOADING" }
  static Future<bool> submitDeliveryRate({
    required String doNumber,
    required int rate,
    String status = "OUTUNLOADING",
    String drvid = "",
    String hpNumber = "",
  }) async {
    try {
      final uri = Uri.parse('${GlobalData.baseUrl}api/delivery/rate.jsp');
      final payload = json.encode({
        "do_number": doNumber.trim(),
        "rate": rate,
        "status": status,
        "drvid": drvid.trim(),
        "hp_number": hpNumber.trim(),
      });

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return (data["status_code"] == 200 || data["status"] == "success");
      }
    } catch (e) {
      print("Error submitDeliveryRate: $e");
    }
    return false;
  }

  /// Konversi nomor telepon lokal Indonesia ke format internasional WA (628...)
  /// Contoh: 0815-4621-5818 -> 6281546215818
  static String formatInternationalPhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('8')) {
      cleaned = '62$cleaned';
    }
    if (cleaned.isEmpty) {
      return '6281546215818';
    }
    return cleaned;
  }

  /// Buka aplikasi WhatsApp langsung dengan pesan template rating
  static Future<bool> openWhatsApp({
    required String phoneWa,
    required String doNumber,
    required String ratingUrl,
  }) async {
    final formattedPhone = formatInternationalPhone(phoneWa);
    final String message =
        "Halo Customer, terima kasih telah menggunakan layanan PT Andalan Nusa Pratama.\n"
        "Mohon kesediaan Anda memberikan nilai rating pelayanan pengiriman untuk No DO: $doNumber melalui link berikut (berlaku 3 hari):\n"
        "$ratingUrl\n\n"
        "Terima kasih atas kerja samanya.";

    final Uri waUri = Uri.parse(
      "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback open via in-app/browser
        await launchUrl(waUri, mode: LaunchMode.platformDefault);
        return true;
      }
    } catch (e) {
      print("Error openWhatsApp: $e");
      return false;
    }
  }
}
