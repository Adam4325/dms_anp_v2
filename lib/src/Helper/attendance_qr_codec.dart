import 'dart:convert';

import 'package:http/http.dart' as http;

class AttendanceQrPayload {
  AttendanceQrPayload({
    required this.type,
    required this.issuer,
    required this.role,
    required this.issuedAt,
    required this.expiresAt,
    required this.nonce,
  });

  final String type;
  final String issuer;
  final String role;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String nonce;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'issuer': issuer,
      'role': role,
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'nonce': nonce,
    };
  }

  factory AttendanceQrPayload.fromJson(Map<String, dynamic> json) {
    return AttendanceQrPayload(
      type: json['type']?.toString() ?? '',
      issuer: json['issuer']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      issuedAt: DateTime.parse(json['issued_at'].toString()).toUtc(),
      expiresAt: DateTime.parse(json['expires_at'].toString()).toUtc(),
      nonce: json['nonce']?.toString() ?? '',
    );
  }
}

class AttendanceQrCodec {
  static const String qrType = 'DMS_ANP_ATTENDANCE_QR';
  static const Duration defaultTtl = Duration(minutes: 1);
  static const String _prefix = 'DMSANPQR2.';
  static const String apiUrl =
      'https://apps.tuluatas.com/trucking/mobile/attendance_qr_codec.jsp';

  static Future<AttendanceQrResult> create({
    required String issuer,
    required String role,
    Duration ttl = defaultTtl,
  }) async {
    final uri = Uri.parse(apiUrl).replace(
      queryParameters: {
        'method': 'create',
        'issuer': issuer.trim().toUpperCase(),
        'role': role.trim().toUpperCase(),
        'ttl_seconds': ttl.inSeconds.toString(),
      },
    );
    return _request(uri);
  }

  static Future<AttendanceQrResult> validate(String qrData) async {
    final uri = Uri.parse(apiUrl).replace(
      queryParameters: {
        'method': 'validate',
        'qr_data': qrData.trim(),
      },
    );
    return _request(uri);
  }

  static AttendanceQrPayload? decode(String value) {
    try {
      final raw = value.trim();
      if (!raw.startsWith(_prefix)) {
        return null;
      }
      final envelopeText =
          utf8.decode(base64Url.decode(raw.substring(_prefix.length)));
      final envelope = json.decode(envelopeText);
      if (envelope is! Map<String, dynamic>) {
        return null;
      }
      // Client-side decode is only a light envelope check. Real decrypt and
      // signature validation happen in JSP so the secret stays on the server.
      if ((envelope['iv']?.toString() ?? '').isEmpty ||
          (envelope['data']?.toString() ?? '').isEmpty ||
          (envelope['mac']?.toString() ?? '').isEmpty) {
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<AttendanceQrResult> _request(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(Duration(seconds: 20));
      if (response.statusCode != 200) {
        return AttendanceQrResult(
          statusCode: response.statusCode,
          success: false,
          expired: false,
          valid: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return AttendanceQrResult(
          statusCode: 500,
          success: false,
          expired: false,
          valid: false,
          message: 'Invalid QR response',
        );
      }
      return AttendanceQrResult.fromJson(decoded);
    } catch (e) {
      return AttendanceQrResult(
        statusCode: 500,
        success: false,
        expired: false,
        valid: false,
        message: 'Gagal koneksi QR server: $e',
      );
    }
  }
}

class AttendanceQrResult {
  AttendanceQrResult({
    required this.statusCode,
    required this.success,
    required this.expired,
    required this.valid,
    required this.message,
    this.qrData = '',
    this.payload,
  });

  final int statusCode;
  final bool success;
  final bool expired;
  final bool valid;
  final String message;
  final String qrData;
  final AttendanceQrPayload? payload;

  factory AttendanceQrResult.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'];
    final statusCode = _parseInt(json['status_code'], 500);
    return AttendanceQrResult(
      statusCode: statusCode,
      success: statusCode == 200 && json['status']?.toString() == 'success',
      expired: _parseBool(json['expired']) || statusCode == 410,
      valid: _parseBool(json['valid']) || statusCode == 200,
      message: json['message']?.toString() ?? '',
      qrData: json['qr_data']?.toString() ?? '',
      payload: payloadJson is Map<String, dynamic>
          ? AttendanceQrPayload.fromJson(payloadJson)
          : null,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    return value?.toString().toLowerCase() == 'true';
  }
}
