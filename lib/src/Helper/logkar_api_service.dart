import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      final parsed = int.tryParse(body.trim());
      if (parsed != null && parsed > 0) {
        return parsed;
      }
      return null;
    }
    // Response Logkar kadang: "data": [ { "do_id": 59106, ... } ]
    if (body is List) {
      for (final item in body) {
        final parsed = parseDoIdFromJson(item);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
      return null;
    }
    if (body is Map) {
      // Prioritas: do_id di root / di dalam data (object atau array).
      final candidates = <dynamic>[
        body['do_id'],
        body['doId'],
        body['id'],
      ];
      final data = body['data'];
      if (data is Map) {
        candidates.add(data['do_id']);
        candidates.add(data['doId']);
        candidates.add(data['id']);
      } else if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map) {
          candidates.add(first['do_id']);
          candidates.add(first['doId']);
          candidates.add(first['id']);
        }
        candidates.add(data);
      }
      for (final c in candidates) {
        final parsed = parseDoIdFromJson(c);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
      if (data != null) {
        return parseDoIdFromJson(data);
      }
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

  /// Hasil lookup do_id + debug Postman/raw response.
  static Future<({
    int? doId,
    int httpStatus,
    String rawBody,
    String debugInfo,
  })> getLogkarDoIdDetailed({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
  }) async {
    if (doNo.trim().isEmpty) {
      return (
        doId: null,
        httpStatus: 0,
        rawBody: '',
        debugInfo: 'do_no kosong',
      );
    }
    final base = logkarBaseUrl(apiLokar);
    if (base.isEmpty) {
      return (
        doId: null,
        httpStatus: 0,
        rawBody: '',
        debugInfo: 'api_lokar kosong',
      );
    }
    final requestCode = buildRequestCode(clientId, apiToken);
    final uri = Uri.parse('$base/orders/do/get');
    final bodyMap = <String, dynamic>{
      'do_no': doNo.trim(),
      'request_code': requestCode,
    };
    final bodyJson = json.encode(bodyMap);

    print('========== LOGKAR GET DO_ID (Postman) ==========');
    print('METHOD      : POST');
    print('URL         : $uri');
    print('Header Authorization (API Token): $apiToken');
    print('Header Content-Type: application/json');
    print('Body JSON   : $bodyJson');
    print('client_id   : $clientId');
    print('do_no       : ${doNo.trim()}');
    print('request_code: $requestCode');
    print('api_lokar   : $apiLokar');
    print('================================================');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiToken,
        },
        body: bodyJson,
      );

      print('LOGKAR getDoId HTTP status: ${response.statusCode}');
      print('LOGKAR getDoId response body: ${response.body}');

      int? doId;
      String apiHint = '';
      try {
        final dynamic decoded = json.decode(response.body);
        doId = parseDoIdFromJson(decoded);
        if (decoded is Map) {
          final st = decoded['status']?.toString() ?? '';
          final data = decoded['data'];
          final code = decoded['code']?.toString() ?? '';
          apiHint =
              'status=$st code=$code data=${data is Map ? data['do_id'] : data}';
        }
      } catch (e) {
        apiHint = 'parse error: $e';
      }

      print('LOGKAR getDoId parsed do_id: $doId ($apiHint)');

      final debug = StringBuffer()
        ..writeln('POST $uri')
        ..writeln('Authorization: $apiToken')
        ..writeln('Body: $bodyJson')
        ..writeln('HTTP: ${response.statusCode}')
        ..writeln('Response: ${response.body}')
        ..writeln('Parsed do_id: $doId');

      return (
        doId: doId,
        httpStatus: response.statusCode,
        rawBody: response.body,
        debugInfo: debug.toString(),
      );
    } catch (e) {
      print('LOGKAR getDoId exception: $e');
      return (
        doId: null,
        httpStatus: 0,
        rawBody: '',
        debugInfo: 'Exception: $e\nPOST $uri\nBody: $bodyJson',
      );
    }
  }

  static Future<int?> getLogkarDoId({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
  }) async {
    final result = await getLogkarDoIdDetailed(
      apiLokar: apiLokar,
      clientId: clientId,
      apiToken: apiToken,
      doNo: doNo,
    );
    return result.doId;
  }

  /// Pastikan file siap upload ke Logkar: ekstensi .jpg + nama jelas.
  static Future<({String path, String filename})> _prepareJpegForUpload(
    String filePath,
    String doNo,
  ) async {
    final src = File(filePath);
    final bytes = await src.readAsBytes();
    final safeDo = doNo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename =
        'DOIMG_${safeDo}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outPath = '${Directory.systemTemp.path}/$filename';
    final out = File(outPath);
    await out.writeAsBytes(bytes, flush: true);
    print('LOGKAR prepare upload: src=$filePath -> $outPath (${bytes.length} bytes)');
    return (path: outPath, filename: filename);
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
    final lookup = await getLogkarDoIdDetailed(
      apiLokar: apiLokar,
      clientId: clientId,
      apiToken: apiToken,
      doNo: doNo,
    );
    final doId = lookup.doId;
    if (doId == null || doId <= 0) {
      print('========== LOGKAR UPLOAD DOCS GAGAL (do_id null) ==========');
      print(lookup.debugInfo);
      print('===========================================================');
      return (
        ok: false,
        message:
            'do_id Logkar tidak ditemukan untuk DO: $doNo\n\n'
            'Pastikan do_no di Postman SAMA PERSIS dengan app.\n\n'
            '${lookup.debugInfo}',
      );
    }
    final base = logkarBaseUrl(apiLokar);
    final uri = Uri.parse('$base/transporter/upload/docs');
    final requestCode = buildRequestCode(clientId, apiToken);
    final prepared = await _prepareJpegForUpload(filePath, doNo);

    print('========== LOGKAR UPLOAD DOCS (Postman) ==========');
    print('METHOD      : POST multipart/form-data');
    print('URL         : $uri');
    print('Header Authorization: $apiToken');
    print('Form field request_code: $requestCode');
    print('Form field do_id: $doId');
    print('Form file media: ${prepared.path}');
    print('Form filename: ${prepared.filename}');
    print('Content-Type: image/jpeg');
    print('do_no: $doNo');
    print('==================================================');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = apiToken
      ..fields['request_code'] = requestCode
      ..fields['do_id'] = doId.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'media',
        prepared.path,
        filename: prepared.filename,
        contentType: MediaType('image', 'jpeg'),
      ));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('LOGKAR upload HTTP status: ${response.statusCode}');
      print('LOGKAR upload response body: ${response.body}');
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
