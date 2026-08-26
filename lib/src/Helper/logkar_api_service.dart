import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
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

  /// Ambil loading_qty / reduce_qty dari ANP (tblbuj_mix via JSP).
  static Future<({num loadingQty, num reduceQty})> fetchBujQtyForLogkar(
      String doNo) async {
    if (doNo.trim().isEmpty) {
      return (loadingQty: 0, reduceQty: 0);
    }
    try {
      final uri =
          Uri.parse('${GlobalData.baseUrl}api/do_mixer/get_buj_qty_logkar.jsp')
              .replace(queryParameters: <String, String>{
        'method': 'get-buj-qty-logkar-v1',
        'do_no': doNo.trim(),
      });
      print('LOGKAR fetchBujQty URL: $uri');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      print('LOGKAR fetchBujQty HTTP ${response.statusCode}: ${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return (loadingQty: 0, reduceQty: 0);
      }
      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map) {
        return (loadingQty: 0, reduceQty: 0);
      }
      num loading = _toNum(decoded['loading_qty']);
      num reduce = _toNum(decoded['reduce_qty']);
      final data = decoded['data'];
      if (data is Map) {
        if (loading == 0) loading = _toNum(data['loading_qty']);
        if (reduce == 0) reduce = _toNum(data['reduce_qty']);
      }
      return (loadingQty: loading, reduceQty: reduce);
    } catch (e) {
      print('LOGKAR fetchBujQty error: $e');
      return (loadingQty: 0, reduceQty: 0);
    }
  }

  static num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString().trim()) ?? 0;
  }

  static Future<({bool ok, String message})> sendOrderStatus({
    required String apiLokar,
    required String clientId,
    required String apiToken,
    required String doNo,
    required String latitude,
    required String longitude,
    required int status,
    num? loadingQty,
    num? reduceQty,
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

    num loadQty = loadingQty ?? 0;
    num redQty = reduceQty ?? 0;
    if (loadingQty == null || reduceQty == null) {
      final qty = await fetchBujQtyForLogkar(doNo);
      if (loadingQty == null) loadQty = qty.loadingQty;
      if (reduceQty == null) redQty = qty.reduceQty;
    }

    final base = logkarBaseUrl(apiLokar);
    final uri = Uri.parse('$base/transporter/status/order');
    final requestCode = buildRequestCode(clientId, apiToken);
    final bodyMap = <String, dynamic>{
      'request_code': requestCode,
      'do_id': doId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'goods': {
        'loading_qty': loadQty,
        'reduce_qty': redQty,
        'origin': {'bruto': 0, 'netto': 0, 'tara': 0},
        'destination': {'bruto': 0, 'netto': 0, 'tara': 0},
      },
    };
    final body = json.encode(bodyMap);

    print('========== LOGKAR STATUS ORDER (Postman) ==========');
    print('URL: $uri');
    print('Authorization: $apiToken');
    print('Body: $body');
    print('loading_qty=$loadQty reduce_qty=$redQty');
    print('===================================================');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiToken,
        },
        body: body,
      );
      print('LOGKAR status order HTTP ${response.statusCode}: ${response.body}');
      final detail = parseResponseMessage(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (
          ok: true,
          message:
              'Status order $status berhasil dikirim ke Logkar.\n\nDO: $doNo\ndo_id: $doId\nloading_qty: $loadQty\nreduce_qty: $redQty${detail.isNotEmpty ? '\n\n$detail' : ''}',
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

  /// Normalisasi nomor HP ke format 62...
  static String normalizeDriverPhone(String raw) {
    var phone = raw.trim().replaceAll(RegExp(r'[\s\-\+]'), '');
    if (phone.isEmpty) return phone;
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (!phone.startsWith('62') && phone.length >= 9) {
      phone = '62$phone';
    }
    return phone;
  }

  static String todayYmd() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  static const String prefsTmCheckinDateKey = 'logkar_tm_checkin_date';

  static Future<bool> hasTmCheckinToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(prefsTmCheckinDateKey) ?? '';
    return saved == todayYmd();
  }

  static Future<void> markTmCheckinToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsTmCheckinDateKey, todayYmd());
  }

  /// API CHECK IN Motive TM — pair driver–TM via QR scan.
  /// POST /transporter/sync/tm
  static Future<({bool ok, String message, int? code})> checkInMotiveTm({
    required String driverPhone,
    required String qrData,
    required String latitude,
    required String longitude,
  }) async {
    final phone = normalizeDriverPhone(driverPhone);
    if (phone.isEmpty) {
      return (
        ok: false,
        message: 'Nomor HP driver tidak tersedia. Silakan login ulang.',
        code: null,
      );
    }
    if (qrData.trim().isEmpty) {
      return (ok: false, message: 'QR data kosong.', code: null);
    }

    final creds = await loadCredentials();
    if (creds == null) {
      return (
        ok: false,
        message: 'Credential Logkar belum tersedia.',
        code: null,
      );
    }

    final base = logkarBaseUrl(creds.apiLokar);
    if (base.isEmpty) {
      return (ok: false, message: 'api_lokar kosong.', code: null);
    }

    final requestCode = buildRequestCode(creds.clientId, creds.apiToken);
    final uri = Uri.parse('$base/transporter/sync/tm');
    final bodyMap = <String, dynamic>{
      'request_code': requestCode,
      'driver_phone': phone,
      'qr_data': qrData.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };
    final body = json.encode(bodyMap);

    print('========== LOGKAR CHECK-IN MOTIVE TM ==========');
    print('URL: $uri');
    print('Authorization: ${creds.apiToken}');
    print('Body: $body');
    print('===============================================');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': creds.apiToken,
        },
        body: body,
      );
      print('LOGKAR sync/tm HTTP ${response.statusCode}: ${response.body}');

      int? code;
      final detail = parseResponseMessage(response.body);
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final rawCode = decoded['code'];
          if (rawCode is int) {
            code = rawCode;
          } else if (rawCode != null) {
            code = int.tryParse(rawCode.toString());
          }
        }
      } catch (_) {}

      final httpOk = response.statusCode >= 200 && response.statusCode < 300;
      final codeOk = code == null || code == 200;
      if (httpOk && codeOk) {
        return (
          ok: true,
          message: detail.isNotEmpty ? detail : 'Check-in Motive TM berhasil.',
          code: code ?? 200,
        );
      }
      return (
        ok: false,
        message: detail.isNotEmpty
            ? detail
            : 'Gagal check-in Motive TM (HTTP ${response.statusCode}).',
        code: code,
      );
    } catch (e) {
      return (ok: false, message: 'Gagal check-in Motive TM: $e', code: null);
    }
  }
}
