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
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        title: Text(
          'Close UJ',
          style: TextStyle(
            color: darkOrange,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Close UJ ${_s(item['cusnbr'])}? Status akan menjadi ADVANCE.',
          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ntBtnStyle(darkOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: ntBtnLabel('Close UJ'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      EasyLoading.show(status: 'Closing...');
      final prefs = await SharedPreferences.getInstance();
      final userid =
          prefs.getString('name') ?? prefs.getString('username') ?? '';
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

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  Widget ntBtnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusBg = lightOrange;
    Color statusText = darkOrange;
    Color statusBorder = accentOrange;

    final s = status.toUpperCase().trim();
    if (s == 'ADVANCE' || s == 'SELESAI' || s == 'AKTIF' || s == 'ACTIVE') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusBorder = Colors.green.shade200;
    } else if (s == '0' || s == 'DRAFT') {
      statusBg = lightOrange;
      statusText = darkOrange;
      statusBorder = accentOrange;
    } else if (s == 'CANCEL' || s == 'REJECTED' || s == 'BATAL') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade800;
      statusBorder = Colors.red.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusBorder),
      ),
      child: Text(
        s == '0' ? 'DRAFT' : s,
        style: TextStyle(
          color: statusText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
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
    final status = _s(item['status']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'UJ : ${_s(item['cusnbr'])}',
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
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
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    label: ntBtnLabel('Edit'),
                    style: ntBtnStyle(primaryOrange),
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_outline,
                        color: Colors.white, size: 16),
                    label: ntBtnLabel('Close'),
                    style: ntBtnStyle(Colors.grey.shade600),
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
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          title: const Text(
            'Master UJ Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goMasterMenu,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _fetchList(page: _page),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: TextField(
                controller: _txtSearch,
                decoration: InputDecoration(
                  hintText: 'Cari nomor / customer / origin...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon:
                      Icon(Icons.search, color: primaryOrange, size: 20),
                  suffixIcon: _txtSearch.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 18),
                          onPressed: () {
                            _txtSearch.clear();
                            _fetchList(page: 1);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
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
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 48, color: accentOrange),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada data UJ Baru',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13.5),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: primaryOrange,
                          onRefresh: () => _fetchList(page: _page),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 90, top: 4),
                            itemCount: _list.length,
                            itemBuilder: (_, i) => _card(_list[i]),
                          ),
                        ),
            ),
            if (_pages > 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hal $_page / $_pages (total $_total)',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _page > 1
                              ? () => _fetchList(page: _page - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          onPressed: _page < _pages
                              ? () => _fetchList(page: _page + 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: ntBtnLabel('+ Add UJ Baru', size: 15),
                style: ntBtnStyle(primaryOrange).copyWith(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
