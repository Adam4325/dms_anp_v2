import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceEnrollStatus {
  final int id;
  final String status;
  final String namakry;
  final String kryid;
  final String photoUrl;
  final String rejectNote;
  final String message;

  const FaceEnrollStatus({
    required this.id,
    required this.status,
    required this.namakry,
    required this.kryid,
    required this.photoUrl,
    required this.rejectNote,
    required this.message,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isNone => status.toUpperCase() == 'NONE' || status.isEmpty;

  factory FaceEnrollStatus.fromJson(Map<String, dynamic> root) {
    final data = root['data'];
    Map<String, dynamic> map = {};
    if (data is Map<String, dynamic>) {
      map = data;
    }
    final rel = (map['photo_url'] ?? '').toString();
    final abs = rel.isEmpty
        ? ''
        : (rel.startsWith('http')
            ? rel
            : '${GlobalData.baseUrlOri}$rel');
    return FaceEnrollStatus(
      id: int.tryParse('${map['id'] ?? 0}') ?? 0,
      status: (map['status'] ?? 'NONE').toString().toUpperCase(),
      namakry: (map['namakry'] ?? '').toString(),
      kryid: (map['kryid'] ?? '').toString(),
      photoUrl: abs,
      rejectNote: (map['reject_note'] ?? '').toString(),
      message: (root['message'] ?? '').toString(),
    );
  }
}

class FaceEnrollService {
  static const _kCacheKry = 'face_enroll_cache_kryid';
  static const _kCacheJson = 'face_enroll_cache_json';
  static const _kCachePhotoUrl = 'face_enroll_cache_photo_url';

  static String get _api =>
      '${GlobalData.baseUrlProd}api/absensi/face_enroll.jsp';

  static Future<Map<String, String>> _sessionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'kryid': prefs.getString('kryid') ?? '',
      'username': prefs.getString('username') ?? '',
      'namakry': prefs.getString('name') ?? '',
      'imeiid': prefs.getString('androidID') ?? '',
    };
  }

  /// GET dengan koneksi baru + retry. Hindari keep-alive yang putus
  /// ("Connection closed before full header was received").
  static Future<http.Response> _httpGet(Uri uri, {int tries = 3}) async {
    Object? last;
    for (var i = 0; i < tries; i++) {
      final client = http.Client();
      try {
        return await client
            .get(uri, headers: {
              'Accept': 'application/json',
              'Connection': 'close',
            })
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        last = e;
        await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
      } finally {
        client.close();
      }
    }
    throw Exception('Koneksi terputus. Coba lagi.');
  }

  static Future<void> _saveStatusCache(FaceEnrollStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _sessionIds();
    await prefs.setString(_kCacheKry, ids['kryid'] ?? '');
    await prefs.setString(
      _kCacheJson,
      json.encode({
        'status_code': 200,
        'message': status.message,
        'data': {
          'id': status.id,
          'status': status.status,
          'namakry': status.namakry,
          'kryid': status.kryid,
          'photo_url': status.photoUrl,
          'reject_note': status.rejectNote,
        },
      }),
    );
  }

  static Future<FaceEnrollStatus?> getCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _sessionIds();
    final kry = ids['kryid'] ?? '';
    if (kry.isEmpty || (prefs.getString(_kCacheKry) ?? '') != kry) {
      return null;
    }
    final raw = prefs.getString(_kCacheJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final root = json.decode(raw);
      if (root is! Map<String, dynamic>) return null;
      return FaceEnrollStatus.fromJson(root);
    } catch (_) {
      return null;
    }
  }

  static Future<File> _photoCacheFile(String kryid) async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = kryid.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return File('${dir.path}/face_enroll_$safe.jpg');
  }

  static Future<Uint8List?> _readPhotoCache(String kryid, String url) async {
    if (kryid.isEmpty || url.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString(_kCachePhotoUrl) ?? '') != url) return null;
    try {
      final file = await _photoCacheFile(kryid);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length < 200 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writePhotoCache(
    String kryid,
    String url,
    Uint8List bytes,
  ) async {
    if (kryid.isEmpty ||
        bytes.length < 200 ||
        bytes[0] != 0xFF ||
        bytes[1] != 0xD8) {
      return;
    }
    try {
      final file = await _photoCacheFile(kryid);
      await file.writeAsBytes(bytes, flush: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCachePhotoUrl, url);
    } catch (_) {}
  }

  static Future<Uint8List?> _downloadBytes(String url) async {
    for (var i = 0; i < 3; i++) {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse(url), headers: {'Connection': 'close'})
            .timeout(const Duration(seconds: 20));
        final body = response.bodyBytes;
        if (response.statusCode == 200 &&
            body.length > 200 &&
            body[0] == 0xFF &&
            body[1] == 0xD8) {
          return body;
        }
      } catch (_) {
      } finally {
        client.close();
      }
      await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
    }
    return null;
  }

  /// Foto enroll: cache lokal dulu, unduh ulang hanya jika URL berubah / cache kosong.
  static Future<Uint8List?> fetchEnrollPhoto(String url) async {
    final ids = await _sessionIds();
    final kry = ids['kryid'] ?? '';
    final cached = await _readPhotoCache(kry, url);
    if (cached != null) return cached;
    if (url.trim().isEmpty) return null;
    final bytes = await _downloadBytes(url);
    if (bytes != null) {
      await _writePhotoCache(kry, url, bytes);
    }
    return bytes;
  }

  static Future<FaceEnrollStatus> getStatus({
    bool allowCacheOnError = true,
  }) async {
    final ids = await _sessionIds();
    final uri = Uri.parse(_api).replace(queryParameters: {
      'method': 'status',
      'kryid': ids['kryid'] ?? '',
      'imeiid': ids['imeiid'] ?? '',
    });
    try {
      final response = await _httpGet(uri);
      if (response.statusCode != 200) {
        throw Exception('Gagal cek enroll wajah (${response.statusCode})');
      }
      final root = json.decode(response.body);
      if (root is! Map<String, dynamic>) {
        throw Exception('Response enroll tidak valid');
      }
      final parsed = FaceEnrollStatus.fromJson(root);
      await _saveStatusCache(parsed);
      if (parsed.isApproved && parsed.photoUrl.isNotEmpty) {
        fetchEnrollPhoto(parsed.photoUrl);
      }
      return parsed;
    } catch (e) {
      if (allowCacheOnError) {
        final cached = await getCachedStatus();
        if (cached != null) return cached;
      }
      throw Exception('Koneksi terputus. Coba lagi.');
    }
  }

  static Future<String> compressToBase64(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return base64Encode(bytes);
    }
    if (decoded.width > 640) {
      decoded = img.copyResize(decoded, width: 640);
    }
    final jpg = img.encodeJpg(decoded, quality: 55);
    return base64Encode(jpg);
  }

  static Future<FaceEnrollStatus> enroll({
    required File photoFile,
  }) async {
    final ids = await _sessionIds();
    if ((ids['kryid'] ?? '').isEmpty) {
      throw Exception('KRYID kosong. Login ulang atau hubungi HRD.');
    }
    final photo = await compressToBase64(photoFile);
    final response = await http.post(
      Uri.parse(_api),
      body: {
        'method': 'enroll',
        'kryid': ids['kryid'],
        'username': ids['username'],
        'namakry': ids['namakry'],
        'imeiid': ids['imeiid'],
        'liveness_ok': 'Y',
        'photo': photo,
      },
    );
    final root = json.decode(response.body);
    if (root is! Map<String, dynamic>) {
      throw Exception('Response enroll tidak valid');
    }
    final code = root['status_code'];
    if (code != 200 && code != '200') {
      throw Exception((root['message'] ?? 'Enroll gagal').toString());
    }
    return FaceEnrollStatus.fromJson(root);
  }

  static Future<List<Map<String, dynamic>>> list({
    String status = 'ALL',
    String q = '',
  }) async {
    final uri = Uri.parse(_api).replace(queryParameters: {
      'method': 'list',
      'status': status,
      'q': q,
    });
    final response = await http.get(uri, headers: {'Accept': 'application/json'});
    final root = json.decode(response.body);
    if (root is! Map<String, dynamic>) {
      return [];
    }
    final data = root['data'];
    final items = data is Map ? data['items'] : null;
    if (items is! List) {
      return [];
    }
    return items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) {
          final rel = (e['photo_url'] ?? '').toString();
          e['photo_abs'] = rel.isEmpty
              ? ''
              : (rel.startsWith('http') ? rel : '${GlobalData.baseUrlOri}$rel');
          return e;
        })
        .toList();
  }

  static Future<String> approve(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(_api),
      body: {
        'method': 'approve',
        'id': id.toString(),
        'userid': prefs.getString('name') ?? prefs.getString('username') ?? '',
      },
    );
    final root = json.decode(response.body);
    if (root is! Map<String, dynamic>) {
      throw Exception('Response approve tidak valid');
    }
    final code = root['status_code'];
    if (code != 200 && code != '200') {
      throw Exception((root['message'] ?? 'Approve gagal').toString());
    }
    return (root['message'] ?? 'Approved').toString();
  }

  static Future<String> reject(int id, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(_api),
      body: {
        'method': 'reject',
        'id': id.toString(),
        'note': note,
        'userid': prefs.getString('name') ?? prefs.getString('username') ?? '',
      },
    );
    final root = json.decode(response.body);
    if (root is! Map<String, dynamic>) {
      throw Exception('Response reject tidak valid');
    }
    final code = root['status_code'];
    if (code != 200 && code != '200') {
      throw Exception((root['message'] ?? 'Reject gagal').toString());
    }
    return (root['message'] ?? 'Rejected').toString();
  }

  static Future<String> delete(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(_api),
      body: {
        'method': 'delete',
        'id': id.toString(),
        'userid': prefs.getString('name') ?? prefs.getString('username') ?? '',
      },
    );
    final root = json.decode(response.body);
    if (root is! Map<String, dynamic>) {
      throw Exception('Response delete tidak valid');
    }
    final code = root['status_code'];
    if (code != 200 && code != '200') {
      throw Exception((root['message'] ?? 'Delete gagal').toString());
    }
    return (root['message'] ?? 'Deleted').toString();
  }
}
