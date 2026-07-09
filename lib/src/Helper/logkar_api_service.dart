import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogkarApiService {
  static String logkarBaseUrl(String apiLokar) {
    final trimmed = apiLokar.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static String buildRequestCode(String clientId, String apiToken) {
    final raw = '#$clientId#$apiToken#';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  static int? parseDoIdFromJson(dynamic body) {
    if (body == null) {
      return null;
    }
    if (body is int) {
      return body > 0 ? body : null;
    }
    if (body is num) {
      final value = body.toInt();
      return value > 0 ? value : null;
    }
    if (body is String) {
      return int.tryParse(body.trim());
    }
    if (body is Map) {
      final direct = parseDoIdFromJson(body['do_id']);
      if (direct != null && direct > 0) {
        return direct;
      }
      return parseDoIdFromJson(body['data']);
    }
    return null;
  }

  static String parseResponseMessage(String body) {
    if (body.trim().isEmpty) {
      return '';
    }
    try {
      final dynamic decoded = json.decode(body);
      if (decoded is Map) {
        final status = decoded['status']?.toString() ?? '';
        final data = decoded['data']?.toString() ?? '';
        final code = decoded['code']?.toString() ?? '';
        final accessTime = decoded['accessTime']?.toString() ?? '';
        final parts = <String>[];
        if (status.isNotEmpty) parts.add('Status: $status');
        if (data.isNotEmpty) parts.add('Data: $data');
        if (code.isNotEmpty) parts.add('Code: $code');
        if (accessTime.isNotEmpty) parts.add('Waktu: $accessTime');
        if (parts.isNotEmpty) {
          return parts.join('\n');
        }
      }
    } catch (_) {}
    return body;
  }

  static Future<({
    String apiLokar,
    String clientId,
    String apiToken,
  })?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final apiLokar = prefs.getString('api_lokar')?.trim() ?? '';
    final clientId = prefs.getString('lokar_client_id')?.trim() ?? '';
    final apiToken = prefs.getString('lokar_api_token')?.trim() ?? '';
    if (apiLokar.isEmpty || clientId.isEmpty || apiToken.isEmpty) {
      return null;
    }
    return (apiLokar: apiLokar, clientId: clientId, apiToken: apiToken);
  }

  static Future<int?> getLogkarDoId({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
  }) async {
    if (doNo.trim().isEmpty) {
      return null;
    }
    final base = logkarBaseUrl(apiLokar);
    if (base.isEmpty) {
      return null;
    }
    final requestCode = buildRequestCode(clientId, apiToken);
    final uri = Uri.parse('$base/orders/do/get');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': apiToken,
      },
      body: json.encode({
        'do_no': doNo,
        'request_code': requestCode,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    try {
      final dynamic decoded = json.decode(response.body);
      return parseDoIdFromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<({bool ok, String message})> uploadDocument({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
    required String filePath,
  }) async {
    if (!File(filePath).existsSync()) {
      return (ok: false, message: 'File foto tidak ditemukan.');
    }
    final doId = await getLogkarDoId(
      apiLokar: apiLokar,
      clientId: clientId,
      apiToken: apiToken,
      doNo: doNo,
    );
    if (doId == null || doId <= 0) {
      return (
        ok: false,
        message: 'do_id Logkar tidak ditemukan untuk DO: $doNo',
      );
    }
    final base = logkarBaseUrl(apiLokar);
    final uri = Uri.parse('$base/transporter/upload/docs');
    final requestCode = buildRequestCode(clientId, apiToken);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = apiToken
      ..fields['request_code'] = requestCode
      ..fields['do_id'] = doId.toString()
      ..files.add(await http.MultipartFile.fromPath('media', filePath));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final detail = parseResponseMessage(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (
          ok: true,
          message:
              'Upload dokumen Logkar berhasil.\n\nDO: $doNo\ndo_id: $doId${detail.isNotEmpty ? '\n\n$detail' : ''}',
        );
      }
      return (
        ok: false,
        message:
            'Upload dokumen Logkar gagal.\n\nDO: $doNo\nHTTP: ${response.statusCode}${detail.isNotEmpty ? '\n\n$detail' : ''}',
      );
    } catch (e) {
      return (
        ok: false,
        message: 'Upload dokumen Logkar gagal.\n\nDO: $doNo\nError: $e',
      );
    }
  }

  static Future<({bool ok, String message})> sendOrderPosition({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
    required String latitude,
    required String longitude,
  }) async {
    if (doNo.trim().isEmpty) {
      return (ok: false, message: 'Nomor DO kosong.');
    }
    final doId = await getLogkarDoId(
      apiLokar: apiLokar,
      clientId: clientId,
      apiToken: apiToken,
      doNo: doNo,
    );
    if (doId == null || doId <= 0) {
      return (
        ok: false,
        message:
            'do_id Logkar tidak ditemukan untuk DO:\n$doNo\n\nPastikan DO sudah terdaftar di Logkar.',
      );
    }
    final base = logkarBaseUrl(apiLokar);
    final uri = Uri.parse('$base/transporter/order/position');
    final requestCode = buildRequestCode(clientId, apiToken);
    final body = json.encode({
      'request_code': requestCode,
      'do_id': doId,
      'latitude': latitude,
      'longitude': longitude,
    });
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiToken,
        },
        body: body,
      );
      final detail = parseResponseMessage(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (
          ok: true,
          message:
              'Posisi berhasil dikirim ke Logkar.\n\nDO: $doNo\ndo_id: $doId\nLat: $latitude\nLon: $longitude${detail.isNotEmpty ? '\n\n$detail' : ''}',
        );
      }
      return (
        ok: false,
        message:
            'Gagal mengirim posisi ke Logkar.\n\nDO: $doNo\ndo_id: $doId\nHTTP: ${response.statusCode}${detail.isNotEmpty ? '\n\n$detail' : ''}',
      );
    } catch (e) {
      return (
        ok: false,
        message:
            'Gagal mengirim posisi ke Logkar.\n\nDO: $doNo\ndo_id: $doId\nError: $e',
      );
    }
  }

  static Future<({bool ok, String message})> sendOrderStatus({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
    required String latitude,
    required String longitude,
    required int status,
  }) async {
    if (doNo.trim().isEmpty) {
      return (ok: false, message: 'Nomor DO kosong.');
    }
    final doId = await getLogkarDoId(
      apiLokar: apiLokar,
      clientId: clientId,
      apiToken: apiToken,
      doNo: doNo,
    );
    if (doId == null || doId <= 0) {
      return (
        ok: false,
        message:
            'do_id Logkar tidak ditemukan untuk DO:\n$doNo\n\nPastikan DO sudah terdaftar di Logkar.',
      );
    }
    final base = logkarBaseUrl(apiLokar);
    final uri = Uri.parse('$base/transporter/status/order');
    final requestCode = buildRequestCode(clientId, apiToken);
    final body = json.encode({
      'request_code': requestCode,
      'do_id': doId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'goods': {
        'loading_qty': 0,
        'reduce_qty': 0,
        'origin': {'bruto': 0, 'netto': 0, 'tara': 0},
        'destination': {'bruto': 0, 'netto': 0, 'tara': 0},
      },
    });
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiToken,
        },
        body: body,
      );
      final detail = parseResponseMessage(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (
          ok: true,
          message:
              'Status order $status berhasil dikirim ke Logkar.\n\nDO: $doNo\ndo_id: $doId${detail.isNotEmpty ? '\n\n$detail' : ''}',
        );
      }
      return (
        ok: false,
        message:
            'Gagal mengirim status order ke Logkar.\n\nDO: $doNo\nStatus: $status\nHTTP: ${response.statusCode}${detail.isNotEmpty ? '\n\n$detail' : ''}',
      );
    } catch (e) {
      return (
        ok: false,
        message:
            'Gagal mengirim status order ke Logkar.\n\nDO: $doNo\nStatus: $status\nError: $e',
      );
    }
  }

  static Future<({bool ok, String message})> sendPositionFromPrefs({
    required String noDo,
    required String latitude,
    required String longitude,
  }) async {
    final creds = await loadCredentials();
    if (creds == null) {
      return (
        ok: false,
        message: 'Credential Logkar belum tersedia.',
      );
    }
    return sendOrderPosition(
      apiLokar: creds.apiLokar,
      clientId: creds.clientId,
      apiToken: creds.apiToken,
      doNo: noDo,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
