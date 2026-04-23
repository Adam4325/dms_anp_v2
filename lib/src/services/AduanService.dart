import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/AduanItem.dart';
import 'package:http/http.dart' as http;

/// API: [server_api/aduan/aduan_api.jsp](server_api/aduan/aduan_api.jsp)
class AduanService {
  static String get _base =>
      '${GlobalData.baseUrl}api/aduan/aduan_api.jsp';
  static String get _roleAksesNotifBase =>
      '${GlobalData.baseUrl}api/firebase/role_akses_notif.jsp';

  static int _statusCode(dynamic v) {
    if (v == null) {
      return 0;
    }
    if (v is int) {
      return v;
    }
    return int.tryParse(v.toString()) ?? 0;
  }

  static Future<int> fetchUnreadNotifCount(String username) async {
    if (username.isEmpty) {
      return 0;
    }
    try {
      final uri = Uri.parse(_base).replace(queryParameters: {
        'method': 'aduan-notif-count',
        'username': username,
      });
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        return 0;
      }
      final j = json.decode(res.body) as Map<String, dynamic>;
      if (_statusCode(j['status_code']) != 200) {
        return 0;
      }
      final data = j['data'];
      if (data is List && data.isNotEmpty && data[0] is Map) {
        final u = data[0]['unread'];
        if (u is int) {
          return u;
        }
        return int.tryParse(u?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}
    // Fallback: jika endpoint count bermasalah, coba hitung dari daftar open.
    try {
      final list = await listOpen(username);
      return list.length;
    } catch (_) {}
    return 0;
  }

  static Future<List<AduanItem>> listOpen(String username) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'method': 'aduan-list-open',
      'username': username,
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    return _parseList(res.body);
  }

  static Future<Set<String>> fetchRoleAksesNotifUsers() async {
    try {
      final uri = Uri.parse(_roleAksesNotifBase).replace(queryParameters: {
        'method': 'getUserNotif',
      });
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        return <String>{};
      }
      final j = json.decode(res.body);
      if (j is! Map<String, dynamic>) {
        return <String>{};
      }
      final status = (j['status'] ?? '').toString().toLowerCase();
      if (status != 'success') {
        return <String>{};
      }
      final data = j['data'];
      if (data is! List) {
        return <String>{};
      }
      return data
          .whereType<Map>()
          .map((e) => (e['username'] ?? '').toString().trim().toUpperCase())
          .where((u) => u.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<List<AduanItem>> listMine({
    required String username,
    required String statusKaryawan,
    required String drvid,
    required String kryid,
  }) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'method': 'aduan-list-mine',
      'username': username,
      'status_karyawan': statusKaryawan,
      'drvid': drvid,
      'kryid': kryid,
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    return _parseList(res.body);
  }

  static List<AduanItem> _parseList(String body) {
    final j = json.decode(body) as Map<String, dynamic>;
    if (_statusCode(j['status_code']) != 200) {
      return [];
    }
    final data = j['data'];
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map>()
        .map((e) => AduanItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<String?> create({
    required String username,
    required String statusKaryawan,
    required String drvid,
    required String kryid,
    required String loginname,
    required String pesan,
  }) async {
    var body = {
      'method': 'aduan-create',
      'username': username,
      'status_karyawan': statusKaryawan,
      'drvid': drvid,
      'kryid': kryid,
      'loginname': loginname,
      'pesan': pesan,
    };
    print(body);
    final uri = Uri.parse(_base).replace(queryParameters: body);
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    final j = json.decode(res.body) as Map<String, dynamic>;
    final code = _statusCode(j['status_code']);
    if (code == 200) {
      return null;
    }
    return j['message']?.toString() ?? 'Gagal mengirim aduan';
  }

  static Future<String?> close({
    required String username,
    required int id,
  }) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'method': 'aduan-close',
      'username': username,
      'id': id.toString(),
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    final j = json.decode(res.body) as Map<String, dynamic>;
    final code = _statusCode(j['status_code']);
    if (code == 200) {
      return null;
    }
    return j['message']?.toString() ?? 'Gagal menutup aduan';
  }
}
