import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/driver/FrmApprovalReqDriver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApprovedDriverRequest extends StatefulWidget {
  const ApprovedDriverRequest({Key? key}) : super(key: key);

  @override
  _ApprovedDriverRequestState createState() => _ApprovedDriverRequestState();
}

class _ApprovedDriverRequestState extends State<ApprovedDriverRequest> {
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // Soft Orange Pastel Theme (Non-Tera)
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _future = _fetchApprovedRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  InputDecoration softDecoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget ntBtnLabel(String text, {double size = 12}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  AlertDialog ntAlertDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const <Widget>[],
  }) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Text(
        title,
        style: TextStyle(
          color: darkOrange,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  String _safeString(Map<String, dynamic> map, String key) {
    final dynamic value = map[key];
    if (value == null) return "";
    final String text = value.toString().trim();
    if (text.toLowerCase() == 'null') return "";
    return text;
  }

  Future<List<Map<String, dynamic>>> _fetchApprovedRequests() async {
    try {
      final String url = GlobalData.baseUrl +
          'api/driver/list_driver_oprs_approve.jsp?method=list-driver-oprs';
      final uri = Uri.parse(url);
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];
        for (final raw in jsonList) {
          items.add({
            "RDNBR": _safeString(raw, 'rdnbr'),
            "RDDATETIME": _safeString(raw, 'rddatetime'),
            "VHCID": _safeString(raw, 'vhcid'),
            "RDAPVBY": _safeString(raw, 'rdapvby'),
            "RDAPVDATETIME": _safeString(raw, 'rdapvdatetime'),
            "RDSTATUS": _safeString(raw, 'rdstatus'),
            "RDNOTES": _safeString(raw, 'rdnotes'),
            "LOCID": _safeString(raw, 'locid'),
            "RDTYPE": _safeString(raw, 'rdtype'),
          });
        }
        return items;
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      if (e is IOException) {
        alert(globalScaffoldKey.currentContext ?? context, 2,
            "Cek koneksi internet Anda.", "warning");
      }
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchApprovedRequests();
    });
  }

  void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FrmApprovalReqDriver()),
    );
  }

  Future<void> _approve(
    String vhcid,
    String rdnbr,
    String rdtype,
    String userid,
    String locid,
  ) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/approved_req_driver.jsp'
      '?method=approve_req_driver'
      '&vhcid=$vhcid'
      '&rdnbr=$rdnbr'
      '&userid=$userid'
      '&locid=$locid'
      '&rdtype=$rdtype',
    );

    try {
      EasyLoading.show(status: 'Memproses Approve...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 1, 'Approve berhasil: ${data['message']}', 'success');
          await _refresh();
        } else {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 0, 'Approve gagal: ${data['message']}', 'error');
        }
      } else {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, 'Server error: ${response.statusCode}', 'error');
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext ?? context;
      alert(ctx, 0, 'Exception: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _cancel(
    String vhcid,
    String rdnbr,
    String rdtype,
    String userid,
  ) async {
    final url = Uri.parse(
      '${GlobalData.baseUrl}api/driver/cancel_req_driver.jsp'
      '?method=cancel_req_driver'
      '&vhcid=$vhcid'
      '&rdnbr=$rdnbr'
      '&userid=$userid'
      '&rdtype=$rdtype',
    );

    try {
      EasyLoading.show(status: 'Memproses Cancel...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 1, 'Cancel sukses: ${data['message']}', 'success');
          await _refresh();
        } else {
          final ctx = globalScaffoldKey.currentContext ?? context;
          alert(ctx, 0, 'Cancel gagal: ${data['message']}', 'error');
        }
      } else {
        final ctx = globalScaffoldKey.currentContext ?? context;
        alert(ctx, 0, 'Server error: ${response.statusCode}', 'error');
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext ?? context;
      alert(ctx, 0, 'Exception: $e', 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Widget _kv(
    String label,
    String value, {
    bool dense = true,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 1.5 : 2.5),
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
                  fontSize: dense ? 11.5 : 12.5,
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
                  fontSize: dense ? 11.5 : 12.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade900,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: valueWeight ?? FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _ntListCard({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
    Widget? actions,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: actions,
            ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final status = _safeString(item, 'RDSTATUS').toUpperCase();
    Color statusBg = lightOrange;
    Color statusText = darkOrange;
    Color statusBorder = accentOrange;

    if (status == 'APPROVED') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusBorder = Colors.green.shade200;
    } else if (status == 'CANCEL' || status == 'REJECTED') {
      statusBg = Colors.red.shade50;
      statusText = Colors.red.shade800;
      statusBorder = Colors.red.shade200;
    }

    final isActionable = status != 'APPROVED' && status != 'CANCEL';

    return _ntListCard(
      title: "No: ${_safeString(item, 'RDNBR')}",
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusBorder),
        ),
        child: Text(
          status.isEmpty ? 'OPEN' : status,
          style: TextStyle(
            color: statusText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      rows: [
        _kv('Tanggal', _safeString(item, 'RDDATETIME')),
        _kv('VHCID', _safeString(item, 'VHCID'),
            valueWeight: FontWeight.w700, valueColor: darkOrange),
        _kv('Tipe Driver', _safeString(item, 'RDTYPE')),
        _kv('Lokasi', _safeString(item, 'LOCID')),
        _kv('Catatan', _safeString(item, 'RDNOTES')),
        if (_safeString(item, 'RDAPVBY').isNotEmpty)
          _kv('Approve By', _safeString(item, 'RDAPVBY')),
        if (_safeString(item, 'RDAPVDATETIME').isNotEmpty)
          _kv('Tgl Approve', _safeString(item, 'RDAPVDATETIME')),
      ],
      actions: isActionable
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 15),
                    label: ntBtnLabel('Cancel'),
                    style: ntBtnStyle(Colors.redAccent),
                    onPressed: () async {
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => ntAlertDialog(
                          title: 'Konfirmasi Cancel',
                          content: Text(
                              'Cancel request ${_safeString(item, 'RDNBR')}?'),
                          actions: [
                            ElevatedButton(
                              style: ntBtnStyle(Colors.grey.shade500),
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: ntBtnLabel('Tidak'),
                            ),
                            ElevatedButton(
                              style: ntBtnStyle(Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: ntBtnLabel('Ya, Batalkan'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final prefs = await SharedPreferences.getInstance();
                        final username = prefs.getString("name") ?? '';
                        await _cancel(
                          _safeString(item, 'VHCID'),
                          _safeString(item, 'RDNBR'),
                          _safeString(item, 'RDTYPE'),
                          username,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 15),
                    label: ntBtnLabel('Approve'),
                    style: ntBtnStyle(Colors.green.shade600),
                    onPressed: () async {
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => ntAlertDialog(
                          title: 'Konfirmasi Approve',
                          content: Text(
                              'Approve request ${_safeString(item, 'RDNBR')}?'),
                          actions: [
                            ElevatedButton(
                              style: ntBtnStyle(Colors.grey.shade500),
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: ntBtnLabel('Tidak'),
                            ),
                            ElevatedButton(
                              style: ntBtnStyle(Colors.green.shade600),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: ntBtnLabel('Ya, Approve'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final prefs = await SharedPreferences.getInstance();
                        final username = prefs.getString("name") ?? '';
                        await _approve(
                          _safeString(item, 'VHCID'),
                          _safeString(item, 'RDNBR'),
                          _safeString(item, 'RDTYPE'),
                          username,
                          _safeString(item, 'LOCID'),
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => goBack(context),
          ),
          centerTitle: true,
          title: const Text(
            'List Driver Request',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchText = val.trim();
                  });
                },
                decoration: softDecoration(
                  hint: 'Cari no. polisi / no. request...',
                  prefixIcon:
                      Icon(Icons.search, color: primaryOrange, size: 20),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchText = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            // List Items
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: _refresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child:
                            CircularProgressIndicator(color: primaryOrange),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 44, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Terjadi kesalahan saat memuat data',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _refresh,
                              style: ntBtnStyle(primaryOrange),
                              child: ntBtnLabel('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 52, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada data request driver',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    final filteredData = _searchText.isEmpty
                        ? data
                        : data.where((item) {
                            final q = _searchText.toLowerCase();
                            final vhcid =
                                _safeString(item, 'VHCID').toLowerCase();
                            final rdnbr =
                                _safeString(item, 'RDNBR').toLowerCase();
                            final locid =
                                _safeString(item, 'LOCID').toLowerCase();
                            final notes =
                                _safeString(item, 'RDNOTES').toLowerCase();
                            return vhcid.contains(q) ||
                                rdnbr.contains(q) ||
                                locid.contains(q) ||
                                notes.contains(q);
                          }).toList();

                    if (filteredData.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              'Tidak ada data yang cocok dengan "$_searchText"',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        return _buildCard(item);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
