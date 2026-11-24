import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/hrd/frmAssset.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListAsset extends StatefulWidget {
  const ListAsset({Key? key}) : super(key: key);

  @override
  _ListAssetState createState() => _ListAssetState();
}

class _ListAssetState extends State<ListAsset> {
  // Design Tokens (design_list.md & design_tab.md)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  String _searchText = "";
  Future<AssetDataModel>? _future;
  final int _currentPage = 1;
  final TextEditingController _txtSearch = TextEditingController();

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  void _loadData() {
    setState(() {
      _future = sendAssetDataRequest(_currentPage);
    });
  }

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
    _loadData();
  }

  @override
  void dispose() {
    _txtSearch.dispose();
    super.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  String _s(dynamic v) {
    if (v == null) return '-';
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null' || s == 'NULL') return '-';
    return s;
  }

  Widget _kv(String label, String value, {bool dense = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 0 : 2),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(115),
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 20.0,
          onPressed: () => _goBack(context),
        ),
        title: const Text(
          'List Asset',
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
                _searchText = "";
                _txtSearch.clear();
              });
              _loadData();
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
                    controller: _txtSearch,
                    cursorColor: primaryOrange,
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      setState(() {
                        _searchText = v.trim();
                      });
                      _loadData();
                    },
                    decoration: softDecoration(
                      label: 'Pencarian Asset',
                      hint: 'Cari nama / ID asset...',
                    ).copyWith(
                      prefixIcon: const Icon(Icons.search,
                          color: primaryOrange, size: 20),
                      suffixIcon: _txtSearch.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _txtSearch.clear();
                                  _searchText = '';
                                });
                                _loadData();
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
                      _searchText = _txtSearch.text.trim();
                    });
                    _loadData();
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
              onRefresh: () async {
                _loadData();
              },
              child: FutureBuilder<AssetDataModel>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loadingWidgetMaker();
                  }
                  if (snapshot.hasError) {
                    return errorWidgetMaker(
                      AssetDataModel.withError('${snapshot.error}'),
                      _loadData,
                    );
                  }
                  final assetData = snapshot.data;
                  if (assetData == null || assetData.statusCode != 200) {
                    return errorWidgetMaker(
                      assetData ?? AssetDataModel.withError('Unknown error'),
                      _loadData,
                    );
                  }
                  final items = listItemsGetter(assetData);
                  if (items.isEmpty) {
                    return emptyListWidgetMaker();
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return listItemBuilder(items[index], index);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<AssetDataModel> sendAssetDataRequest(int page) async {
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrlOri}api/edp/list_asset.jsp?method=list-asset-v1&page=$page&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      http.Response response = await http.get(myUri);
      return AssetDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        final ctx = context;
        if (ctx.mounted) {
          alert(ctx, 2, "Please check your internet connection.", "warning");
        }
        return AssetDataModel.withError(
            'Please check your internet connection.');
      } else {
        final ctx = context;
        if (ctx.mounted) {
          alert(ctx, 2, "Something went wrong.", "warning");
        }
        return AssetDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(AssetDataModel assetData) {
    List<Map<String, dynamic>> list = [];
    for (var value in assetData.assetdatas) {
      list.add({
        "assetid": value['assetid'],
        "asset_name": value['asset_name'],
        "asset_type": value['asset_type'],
        "asset_order": value['asset_order'],
        "asset_customer": value['asset_customer'],
        "no_seri": value['no_seri'],
        "asset_user": value['asset_user'],
        "divisi": value['divisi'],
        "service": value['service'],
        "asset_customer_service": value['asset_customer_service'],
        "status": value['status'],
        "notes": value['notes'],
        "service1": value['service1'],
        "service2": value['service2'],
        "service3": value['service3'],
        "hardisk": value['hardisk'],
        "memory": value['memory'],
        "type": value['type'],
        "expired_date": value['expired_date'],
      });
    }
    return list;
  }

  Widget listItemBuilder(Map<String, dynamic> value, int index) {
    final statusStr = _s(value['status']);
    final isActive = statusStr.toLowerCase() == 'active';

    final rows = <Widget>[
      _kv("Asset Name", _s(value['asset_name'])),
      _kv("Asset Type", _s(value['asset_type'])),
      _kv("Asset Order", _s(value['asset_order'])),
      if (_s(value['expired_date']) != '-')
        _kv("Expired Date", _s(value['expired_date'])),
      _kv("Customer", _s(value['asset_customer'])),
      _kv("No Seri", _s(value['no_seri'])),
      _kv("User", _s(value['asset_user'])),
      _kv("Divisi", _s(value['divisi'])),
      if (_s(value['service']) != '-')
        _kv("Service", _s(value['service'])),
      if (_s(value['asset_customer_service']) != '-')
        _kv("Cust. Service", _s(value['asset_customer_service'])),
      if (_s(value['notes']) != '-')
        _kv("Notes", _s(value['notes'])),
      if (_s(value['hardisk']) != '-')
        _kv("Hardisk", _s(value['hardisk'])),
      if (_s(value['memory']) != '-')
        _kv("Memory", _s(value['memory'])),
      if (_s(value['type']) != '-' && _s(value['type']) != _s(value['asset_type']))
        _kv("Type", _s(value['type'])),
      if (_s(value['service1']) != '-')
        _kv("Service 1", _s(value['service1'])),
      if (_s(value['service2']) != '-')
        _kv("Service 2", _s(value['service2'])),
      if (_s(value['service3']) != '-')
        _kv("Service 3", _s(value['service3'])),
    ];

    Widget? statusBadge;
    if (statusStr != '-') {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F5E9) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF81C784) : Colors.grey.shade400,
            width: 0.8,
          ),
        ),
        child: Text(
          statusStr,
          style: TextStyle(
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return _pmListCard(
      title: "Asset ID : ${_s(value['assetid'])}",
      headerTrailing: statusBadge,
      rows: rows,
      actions: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 16.0),
              label: pmBtnLabel("Edit Asset"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("is_edit_asset", true);
                prefs.setString("asset_assetid", value['assetid']?.toString() ?? '');
                prefs.setString("asset_name", value['asset_name']?.toString() ?? '');
                prefs.setString("asset_type", value['asset_type']?.toString() ?? '');
                prefs.setString("asset_order", value['asset_order']?.toString() ?? '');
                prefs.setString("asset_customer", value['asset_customer']?.toString() ?? '');
                prefs.setString("asset_no_seri", value['no_seri']?.toString() ?? '');
                prefs.setString("asset_user", value['asset_user']?.toString() ?? '');
                prefs.setString("asset_divisi", value['divisi']?.toString() ?? '');
                prefs.setString("asset_service", value['service']?.toString() ?? '');
                prefs.setString("asset_customer_service", value['asset_customer_service']?.toString() ?? '');
                prefs.setString("asset_status", value['status']?.toString() ?? '');
                prefs.setString("asset_notes", value['notes']?.toString() ?? '');
                prefs.setString("asset_service1", value['service1']?.toString() ?? '');
                prefs.setString("asset_service2", value['service2']?.toString() ?? '');
                prefs.setString("asset_service3", value['service3']?.toString() ?? '');
                prefs.setString("asset_hardisk", value['hardisk']?.toString() ?? '');
                prefs.setString("asset_memory", value['memory']?.toString() ?? '');
                prefs.setString("asset_type", value['type']?.toString() ?? '');
                prefs.setString("asset_expired_date", value['expired_date']?.toString() ?? '');

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FrmAsset()),
                );
              },
              style: pmBtnStyle(primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidgetMaker() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );
  }

  Widget errorWidgetMaker(AssetDataModel assetDatas, VoidCallback retryListener) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              assetDatas.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: retryListener,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: pmBtnLabel('Coba Lagi'),
              style: pmBtnStyle(primaryOrange),
            )
          ],
        ),
      ),
    );
  }

  Widget emptyListWidgetMaker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Tidak ada asset dalam list',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchText.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchText = "";
                    _txtSearch.clear();
                  });
                  _loadData();
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
          ],
        ),
      ),
    );
  }
}

class AssetDataModel {
  List<dynamic> assetdatas;
  int statusCode;
  String errorMessage;
  int total;
  int nItems;

  AssetDataModel({
    required this.assetdatas,
    required this.statusCode,
    required this.errorMessage,
    required this.total,
    required this.nItems,
  });

  factory AssetDataModel.fromResponse(http.Response response) {
    List jsonData = json.decode(response.body);
    final datas = jsonData.length > 1 ? (jsonData[1] ?? []) : [];
    final tot = (jsonData.isNotEmpty && jsonData[0] != null && jsonData[0]['total'] != null)
        ? (jsonData[0]['total'] is int ? jsonData[0]['total'] as int : int.tryParse(jsonData[0]['total'].toString()) ?? 0)
        : 0;
    return AssetDataModel(
      assetdatas: datas,
      statusCode: response.statusCode,
      errorMessage: '',
      total: tot,
      nItems: datas.length,
    );
  }

  factory AssetDataModel.withError(String errorMessage) {
    return AssetDataModel(
      assetdatas: [],
      statusCode: 0,
      errorMessage: errorMessage,
      total: 0,
      nItems: 0,
    );
  }
}
