import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'FormApvRewards.dart';

class ApvRewards extends StatefulWidget {
  const ApvRewards({Key? key}) : super(key: key);

  @override
  _ApvRewardsState createState() => _ApvRewardsState();
}

class _ApvRewardsState extends State<ApvRewards> {
  // Design Tokens (design_list.md & design_tab.md)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> _future;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    _future = _fetchRewards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchRewards() async {
    try {
      final String url =
          "${GlobalData.baseUrl}api/hrd/apv-rewards.jsp?method=list-apv-rewards";
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];
        for (var raw in jsonList) {
          final Map<String, dynamic> row = {
            "RWDNBR": _safeString(raw, 'RWDNBR'),
            "RWDDATE": _safeString(raw, 'RWDDATE'),
            "RWDTYPEID": _safeString(raw, 'RWDTYPEID'),
            "REWARDTYP": _safeString(raw, 'REWARDTYP'),
            "RWDPOINTS": _safeString(raw, 'RWDPOINTS'),
            "RWDQTY": _safeString(raw, 'RWDQTY'),
            "RWDSTATUS": _safeString(raw, 'RWDSTATUS'),
            "DRVID": _safeString(raw, 'DRVID'),
            "RWDTO": _safeString(raw, 'RWDTO'),
            "RWDVNOTE": _safeString(raw, 'RWDVNOTE'),
          };
          items.add(row);
        }
        return items;
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 2, "Server error: ${response.statusCode}", "warning");
        }
        return [];
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        if (e is IOException) {
          alert(ctx, 2, "Cek koneksi internet.", "warning");
        } else {
          alert(ctx, 2, "Terjadi kesalahan.", "warning");
        }
      }
      return [];
    }
  }

  String _safeString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return "";
    final text = value.toString().trim();
    if (text.toLowerCase() == 'null') return "";
    return text;
  }

  String _s(dynamic v) {
    if (v == null) return '-';
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'NULL') return '-';
    return s;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchRewards();
    });
  }

  // --- Design System Helpers ---
  InputDecoration softDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentOrange.withValues(alpha: 0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentOrange.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 1.5),
      ),
    );
  }

  ButtonStyle pmBtnStyle(Color bg) {
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

  Widget pmBtnLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _kv(String label, String value, {bool dense = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 0 : 2),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(110),
          1: FixedColumnWidth(12),
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
                  fontSize: dense ? 11 : 12,
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
                  fontSize: dense ? 11 : 12,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: dense ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _pmListCard({
    required String title,
    required List<Widget> rows,
    Widget? actions,
    Widget? headerTrailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentOrange.withValues(alpha: 0.45)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
              child: actions,
            ),
        ],
      ),
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
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () => goBack(context),
          ),
          title: const Text(
            'List Reward Driver',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh',
              onPressed: () {
                setState(() {
                  _searchText = '';
                  _searchController.clear();
                });
                _refresh();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search row (design_list.md Section 2)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              color: backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      cursorColor: primaryOrange,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) {
                        setState(() {
                          _searchText = v.trim();
                        });
                      },
                      decoration: softDecoration(
                        label: 'Pencarian Reward',
                        hint: 'Cari No. Reward, Driver, dll...',
                      ).copyWith(
                        prefixIcon: const Icon(Icons.search,
                            color: primaryOrange, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.grey),
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchText = _searchController.text.trim();
                      });
                    },
                    style: pmBtnStyle(primaryOrange),
                    child: pmBtnLabel('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: _refresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child:
                              CircularProgressIndicator(color: primaryOrange),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 48, color: Colors.red.shade300),
                              const SizedBox(height: 12),
                              const Text('Terjadi kesalahan saat memuat data',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _refresh,
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white, size: 16),
                                label: pmBtnLabel('Coba Lagi'),
                                style: pmBtnStyle(primaryOrange),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Tidak ada data reward',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    }

                    // Filter berdasarkan pencarian
                    List<Map<String, dynamic>> filtered = data;
                    if (_searchText.isNotEmpty) {
                      final q = _searchText.toLowerCase();
                      filtered = data.where((e) {
                        final rwdnbr = e['RWDNBR'].toString().toLowerCase();
                        final drvid = e['DRVID'].toString().toLowerCase();
                        final rwdto = e['RWDTO'].toString().toLowerCase();
                        final rewardtyp =
                            e['REWARDTYP'].toString().toLowerCase();
                        return rwdnbr.contains(q) ||
                            drvid.contains(q) ||
                            rwdto.contains(q) ||
                            rewardtyp.contains(q);
                      }).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Data tidak ditemukan untuk "$_searchText"',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchText = '';
                                  });
                                },
                                icon: const Icon(Icons.clear, size: 14),
                                label: const Text('Reset Pencarian'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryOrange,
                                  side: const BorderSide(color: primaryOrange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
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

  Widget _buildCard(Map<String, dynamic> item) {
    final status = _s(item['RWDSTATUS']);
    final isOpen = status.toUpperCase() == 'OPEN';

    Widget? statusBadge;
    if (status != '-') {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isOpen ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
            width: 0.8,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isOpen ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
    }

    final rows = <Widget>[
      _kv("Tanggal", _s(item['RWDDATE'])),
      _kv("Tipe", _s(item['RWDTYPEID'])),
      _kv("ID Driver", _s(item['DRVID'])),
      _kv("Nama Driver", _s(item['RWDTO'])),
      _kv("Rewards Name", _s(item['REWARDTYP'])),
      _kv("Points", _s(item['RWDPOINTS'])),
      _kv("Qty", _s(item['RWDQTY'])),
      if (_s(item['RWDVNOTE']) != '-') _kv("Catatan", _s(item['RWDVNOTE'])),
    ];

    return _pmListCard(
      title: item['RWDNBR'] ?? '-',
      headerTrailing: statusBadge,
      rows: rows,
      actions: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormApvRewards(item: item),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 16),
              label: pmBtnLabel('Pilih'),
              style: pmBtnStyle(primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
