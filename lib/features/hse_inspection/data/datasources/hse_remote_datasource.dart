import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:http/http.dart' as http;

class HseApiException implements Exception {
  final String message;
  final int statusCode;

  const HseApiException(this.message, {this.statusCode = 100});

  @override
  String toString() => message;
}

class HseRemoteDataSource implements HseRepository {
  final http.Client _client;

  HseRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  static String get _endpoint {
    final base = GlobalData.baseUrl.endsWith('/')
        ? GlobalData.baseUrl
        : '${GlobalData.baseUrl}/';
    return '${base}api/hse/hse_api.jsp';
  }

  static int _parseCode(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  Future<http.Response> _getWithRetry(
    Uri uri, {
    Duration timeout = const Duration(seconds: 12),
    int retries = 2,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final res = await _client
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(timeout);
        if ((res.statusCode == 502 ||
                res.statusCode == 503 ||
                res.statusCode == 504) &&
            attempt < retries) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          continue;
        }
        return res;
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt >= retries) {
          throw const HseApiException(
            'Koneksi server timeout saat mengambil data. Silakan coba lagi.',
            statusCode: 408,
          );
        }
      } on SocketException catch (e) {
        lastError = e;
        if (attempt >= retries) {
          throw const HseApiException(
            'Koneksi jaringan terputus. Periksa internet lalu coba lagi.',
            statusCode: 503,
          );
        }
      } on http.ClientException catch (e) {
        lastError = e;
        if (attempt >= retries) {
          throw HseApiException(
            'Gagal terhubung ke server: ${e.message}',
            statusCode: 503,
          );
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    throw HseApiException('Koneksi gagal: $lastError', statusCode: 503);
  }

  Future<http.Response> _postWithTimeout(
    Uri uri,
    Map<String, String> body, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    try {
      return await _client
          .post(
            uri,
            headers: {'Accept': 'application/json'},
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const HseApiException(
        'Koneksi server timeout saat mengirim data. Silakan coba lagi.',
        statusCode: 408,
      );
    } on SocketException {
      throw const HseApiException(
        'Koneksi jaringan terputus. Periksa internet lalu coba lagi.',
        statusCode: 503,
      );
    } on http.ClientException catch (e) {
      throw HseApiException(
        'Gagal terhubung ke server: ${e.message}',
        statusCode: 503,
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HseApiException(
        'Server HTTP ${res.statusCode}',
        statusCode: res.statusCode,
      );
    }
    final decoded = json.decode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const HseApiException('Format respon server tidak valid');
    }
    final code = _parseCode(decoded['status_code']);
    if (code != 200) {
      throw HseApiException(
        decoded['message']?.toString() ?? 'Terjadi kesalahan server',
        statusCode: code,
      );
    }
    return decoded;
  }

  @override
  Future<List<ViolationTypeModel>> fetchViolationTypes(String entityType) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'method': 'violation-types',
      'entity_type': entityType,
    });
    final res = await _getWithRetry(uri);
    final body = _decodeResponse(res);
    final raw = body['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => ViolationTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<String>> fetchSanctionTypes(String entityType) async {
    try {
      final uri = Uri.parse(_endpoint).replace(queryParameters: {
        'method': 'sanction-types',
        'entity_type': entityType,
      });
      final res = await _getWithRetry(uri);
      final body = _decodeResponse(res);
      final raw = body['data'];
      if (raw is! List) return HseEntityType.sanctionOptions(entityType);
      final list = raw
          .whereType<Map>()
          .map((e) => (e['sanction_name'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return list.isNotEmpty ? list : HseEntityType.sanctionOptions(entityType);
    } catch (_) {
      return HseEntityType.sanctionOptions(entityType);
    }
  }

  @override
  Future<List<EntityPreviewModel>> searchEntities(
    String entityType,
    String query,
  ) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'method': 'search-entities',
      'type': entityType,
      'q': query,
    });
    final res = await _getWithRetry(uri);
    final body = _decodeResponse(res);
    final raw = body['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => EntityPreviewModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<EntityPreviewModel> lookupEntity(String entityType, String id) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'method': 'lookup',
      'type': entityType,
      'id': id.trim(),
    });
    final res = await _getWithRetry(uri);
    final body = _decodeResponse(res);
    final raw = body['data'];
    if (raw is! Map) {
      throw const HseApiException('Data entitas tidak ditemukan');
    }
    return EntityPreviewModel.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<Map<String, dynamic>> createFinding(
    FindingSubmissionModel payload,
  ) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      payload.toFormMap(),
      timeout: const Duration(seconds: 30),
    );
    final body = _decodeResponse(res);
    final data = body['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  @override
  Future<HseListResult> listFindings({
    required String username,
    String statusFlow = 'ALL',
    String entityType = 'ALL',
    String query = '',
  }) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'method': 'list-findings',
      'username': username,
      'status_flow': statusFlow,
      'entity_type': entityType,
      'q': query,
    });
    final res = await _getWithRetry(uri);
    final body = _decodeResponse(res);

    final summaryRaw = body['summary'];
    final summary = summaryRaw is Map
        ? HseSummaryModel.fromJson(Map<String, dynamic>.from(summaryRaw))
        : const HseSummaryModel();

    final dataRaw = body['data'];
    final items = dataRaw is List
        ? dataRaw
            .whereType<Map>()
            .map((e) => HseFindingItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <HseFindingItem>[];

    return HseListResult(summary: summary, items: items);
  }

  @override
  Future<HseFindingItem> detailFinding({
    required String username,
    required String findingNo,
  }) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'method': 'detail-finding',
      'username': username,
      'finding_no': findingNo,
    });
    final res = await _getWithRetry(uri);
    final body = _decodeResponse(res);
    final raw = body['data'];
    if (raw is! Map) {
      throw const HseApiException('Detail finding tidak ditemukan');
    }
    return HseFindingItem.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<String> submitRepair({
    required String username,
    required String findingNo,
    required String repairActionNote,
    required String evidenceAfterBase64,
  }) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      {
        'method': 'submit-repair',
        'username': username,
        'repaired_by': username,
        'finding_no': findingNo,
        'repair_action_note': repairActionNote,
        'evidence_after': evidenceAfterBase64,
      },
      timeout: const Duration(seconds: 30),
    );
    final body = _decodeResponse(res);
    return body['message']?.toString() ?? 'Perbaikan berhasil disimpan';
  }

  @override
  Future<String> verifyShe({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      {
        'method': 'verify-she',
        'username': username,
        'finding_no': findingNo,
        'status': status,
        'notes': notes,
      },
      timeout: const Duration(seconds: 20),
    );
    final body = _decodeResponse(res);
    return body['message']?.toString() ?? 'Verifikasi berhasil disimpan';
  }

  @override
  Future<String> approveBp({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      {
        'method': 'approve-bp',
        'username': username,
        'finding_no': findingNo,
        'status': status,
        'notes': notes,
      },
      timeout: const Duration(seconds: 20),
    );
    final body = _decodeResponse(res);
    return body['message']?.toString() ?? 'Approval status BP berhasil disimpan';
  }

  @override
  Future<String> finalApprove({
    required String username,
    required String findingNo,
    required String status,
    required String notes,
  }) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      {
        'method': 'final-approve',
        'username': username,
        'finding_no': findingNo,
        'status': status,
        'notes': notes,
      },
      timeout: const Duration(seconds: 20),
    );
    final body = _decodeResponse(res);
    return body['message']?.toString() ?? 'Approval final berhasil disimpan';
  }

  @override
  Future<List<LockedDriverItem>> listLockedDrivers({
    required String username,
    String query = '',
  }) async {
    final params = <String, String>{
      'method': 'list-locked-drivers',
      'username': username,
    };
    if (query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    final uri = Uri.parse(_endpoint).replace(queryParameters: params);
    final res = await _getWithRetry(uri, timeout: const Duration(seconds: 12));
    final body = _decodeResponse(res);
    final data = body['data'];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => LockedDriverItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  @override
  Future<String> unlockDriver({
    required String username,
    required String drvid,
    String notes = '',
  }) async {
    final uri = Uri.parse(_endpoint);
    final res = await _postWithTimeout(
      uri,
      {
        'method': 'unlock-driver',
        'username': username,
        'drvid': drvid,
        'notes': notes,
      },
      timeout: const Duration(seconds: 20),
    );
    final body = _decodeResponse(res);
    return body['message']?.toString() ?? 'Status Driver berhasil dibuka menjadi Active';
  }
}

