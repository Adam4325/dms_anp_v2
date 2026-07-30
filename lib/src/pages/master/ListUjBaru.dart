import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/master/FrmMasterMenu.dart';
import 'package:dms_anp/src/pages/master/FrmUjBaru.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListUjBaru extends StatefulWidget {
  @override
  _ListUjBaruState createState() => _ListUjBaruState();
}

class _ListUjBaruState extends State<ListUjBaru> {
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);

  final TextEditingController _txtSearch = TextEditingController();
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  int _page = 1;
  int _total = 0;
  int _pages = 0;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  @override
  void dispose() {
    _txtSearch.dispose();
    super.dispose();
  }

  void _goMasterMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => FrmMasterMenu()),
    );
  }

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t.isEmpty || t == 'null') return '';
    return t;
  }

  Future<void> _fetchList({int page = 1}) async {
    setState(() {
      _loading = true;
      _page = page;
    });
    try {
      final search = Uri.encodeComponent(_txtSearch.text.trim());
      final url = Uri.parse(
        '${GlobalData.baseUrl}api/master/list_uj_baru.jsp?method=list&page=$page&search=$search',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List && decoded.length >= 2) {
          final meta = decoded[0] as Map;
          final rows = decoded[1] as List;
          setState(() {
            _total = int.tryParse('${meta['total']}') ?? 0;
            _pages = int.tryParse('${meta['pages']}') ?? 0;
            _list = rows
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            _loading = false;
          });
          return;
        }
      }
      setState(() {
        _list = [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _list = [];
        _loading = false;
      });
      if (mounted) {
        alert(context, 0, 'Gagal load list: $e', 'error');
      }
    }
  }

  Future<void> _closeItem(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Close UJ'),
        content: Text(
          'Close UJ ${_s(item['cusnbr'])}? Status akan menjadi ADVANCE.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: darkOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      EasyLoading.show(status: 'Closing...');
      final prefs = await SharedPreferences.getInstance();
      final userid = prefs.getString('name') ?? prefs.getString('username') ?? '';
      final url = Uri.parse(
        '${GlobalData.baseUrl}api/master/close_uj_baru.jsp',
      );
      final res = await http.post(url, body: {
        'method': 'close',
        'cusnbr': _s(item['cusnbr']),
        'ctpid': _s(item['ctpid']),
        'vhtalias': _s(item['vhtalias']),
        'origin': _s(item['origin']),
        'userid': userid,
      });
      EasyLoading.dismiss();
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status'] == 'success') {
          alert(context, 0, body['message'] ?? 'Berhasil', 'success');
          _fetchList(page: _page);
        } else {
          alert(context, 0, body['message'] ?? 'Gagal close', 'error');
        }
      } else {
        alert(context, 0, 'Gagal close', 'error');
      }
    } catch (e) {
      EasyLoading.dismiss();
      alert(context, 0, 'Error: $e', 'error');
    }
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
            Text(':',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
            Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final destLabel = _s(item['destination_name']).isEmpty
        ? _s(item['destination'])
        : '${_s(item['destination_name'])} (${_s(item['destination'])})';
    final originLabel = _s(item['origin_name']).isEmpty
        ? _s(item['origin'])
        : '${_s(item['origin_name'])} (${_s(item['origin'])})';
    final custLabel = _s(item['cpyname']).isEmpty
        ? _s(item['cpyid'])
        : '${_s(item['cpyname'])} (${_s(item['cpyid'])})';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentOrange.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Color(0x20FF8C69),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Text(
              'UJ : ${_s(item['cusnbr'])}',
              style: TextStyle(
                color: darkOrange,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Column(
              children: [
                _kv('Customer', custLabel),
                _kv('Origin', originLabel),
                _kv('Destination', destLabel),
                _kv('Alias', _s(item['vhtalias'])),
                _kv('Tariff', '${_s(item['tariff'])} ${_s(item['uom'])}'),
                _kv('Type UJ', _s(item['ritase'])),
                _kv('Eff. Date', _s(item['effective_date'])),
                _kv('Rute', _s(item['rute'])),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit, color: Colors.white, size: 16),
                    label: Text('Edit',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FrmUjBaru(editItem: item),
                        ),
                      );
                      _fetchList(page: _page);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.lock_outline,
                        color: Colors.white, size: 16),
                    label: Text('Close',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _closeItem(item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goMasterMenu();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          title: Text('Master UJ Baru',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _goMasterMenu,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _fetchList(page: _page),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _txtSearch,
                decoration: InputDecoration(
                  hintText: 'Cari nomor / customer / origin...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: primaryOrange),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _txtSearch.clear();
                      _fetchList(page: 1);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
                onSubmitted: (_) => _fetchList(page: 1),
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryOrange))
                  : _list.isEmpty
                      ? Center(
                          child: Text('Tidak ada data UJ Baru',
                              style: TextStyle(color: Colors.grey.shade700)))
                      : RefreshIndicator(
                          color: primaryOrange,
                          onRefresh: () => _fetchList(page: _page),
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 90, top: 4),
                            itemCount: _list.length,
                            itemBuilder: (_, i) => _card(_list[i]),
                          ),
                        ),
            ),
            if (_pages > 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hal $_page / $_pages (total $_total)',
                        style: TextStyle(fontSize: 12)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _page > 1
                              ? () => _fetchList(page: _page - 1)
                              : null,
                          icon: Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          onPressed: _page < _pages
                              ? () => _fetchList(page: _page + 1)
                              : null,
                          icon: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add UJ Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FrmUjBaru()),
                  );
                  _fetchList(page: 1);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
