import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/inventory/FrmWareHouseOpName.dart';
import 'package:dms_anp/src/pages/inventory/OpnameMutasiPanel.dart';
import 'package:dms_anp/src/pages/inventory/OpnamePrintPreview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ListWareHouseOpName extends StatefulWidget {
  @override
  _ListWareHouseOpNameState createState() => _ListWareHouseOpNameState();
}

class _ListWareHouseOpNameState extends State<ListWareHouseOpName> {
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);//

  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _txtSearch = TextEditingController();
  Icon customIcon = const Icon(Icons.search, color: Colors.white);
  Widget customSearchBar = const Text(
    'List Stock Opname',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  );

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FrmWareHouseOpName()),
    );
  }

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
  }

  @override
  void dispose() {
    _txtSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          title: customSearchBar,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () => _goBack(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: customIcon,
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel, color: Colors.white);
                    customSearchBar = ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () async {
                        if (_txtSearch.text.isEmpty) {
                          return;
                        }
                        _searchText = _txtSearch.text;
                        paginatorGlobalKey.currentState?.changeState(
                          pageLoadFuture: sendInventoryDataRequest,
                          resetState: true,
                        );
                      },
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        controller: _txtSearch,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Cari item / warehouse...',
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                        onSubmitted: (v) {
                          _searchText = v;
                          paginatorGlobalKey.currentState?.changeState(
                            pageLoadFuture: sendInventoryDataRequest,
                            resetState: true,
                          );
                        },
                      ),
                    );
                  } else {
                    _searchText = "";
                    _txtSearch.text = "";
                    customIcon = const Icon(Icons.search, color: Colors.white);
                    customSearchBar = const Text(
                      'List Stock Opname',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    );
                    paginatorGlobalKey.currentState?.changeState(
                      pageLoadFuture: sendInventoryDataRequest,
                      resetState: true,
                    );
                  }
                });
              },
            ),
          ],
        ),
        body: Paginator.listView(
          key: paginatorGlobalKey,
          pageLoadFuture: sendInventoryDataRequest,
          pageItemsGetter: (data) =>
              listItemsGetter(data as InventoryTransDataModel),
          listItemBuilder: listItemBuilder,
          loadingWidgetBuilder: loadingWidgetMaker,
          errorWidgetBuilder: errorWidgetMaker,
          emptyListWidgetBuilder: (data) =>
              emptyListWidgetMaker(data as InventoryTransDataModel),
          totalItemsGetter: (data) =>
              totalPagesGetter(data as InventoryTransDataModel),
          pageErrorChecker: (data) =>
              pageErrorChecker(data as InventoryTransDataModel),
          scrollPhysics: BouncingScrollPhysics(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          onPressed: () {
            setState(() {
              _searchText = "";
              _txtSearch.text = "";
            });
            paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: sendInventoryDataRequest,
              resetState: true,
            );
          },
          child: Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Future<InventoryTransDataModel> sendInventoryDataRequest(int page) async {
    print('page ${page}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrl}api/inventory/list_warehouse_opname.jsp?method=list-warehouse-opname-v1&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body} end');
      return InventoryTransDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        alert(context, 2, "Please check your internet connection.", "warning");
        return InventoryTransDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return InventoryTransDataModel.withError('Something went wrong.');
      }
    }
  }

  String _s(dynamic v) {
    if (v == null) return '';
    final t = v.toString().trim();
    if (t == 'null') return '';
    return t;
  }

  /// Fallback dari wh_withmonth "2026-07-22" jika year/month kosong.
  String _monthOf(Map value) {
    final m = _s(value['wh_with_month_month']);
    if (m.isNotEmpty) return m;
    final raw = _s(value['wh_withmonth']);
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.length >= 2) {
      return int.tryParse(parts[1])?.toString() ?? '';
    }
    return '';
  }

  String _yearOf(Map value) {
    final y = _s(value['wh_with_month_year']);
    if (y.isNotEmpty) return y;
    final raw = _s(value['wh_withmonth']);
    final parts = raw.split(RegExp(r'[-/]'));
    if (parts.isNotEmpty) {
      return int.tryParse(parts[0])?.toString() ?? '';
    }
    return '';
  }

  void _openPrintPreview(Map<String, dynamic> value) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpnamePrintPreview(data: value),
      ),
    );
  }

  List<Map<String, dynamic>> listItemsGetter(InventoryTransDataModel data) {
    List<Map<String, dynamic>> list = [];
    data.inventorydataModel.forEach((value) {
      list.add({
        "whswarehpuseid": value['_whswarehpuseid'],
        "wh_desc": value['_wh_desc'],
        "wh_item_id": value['_wh_item_id'],
        "wh_part_name": value['_wh_part_name'],
        "wh_item_descr": value['_wh_item_descr'],
        "wh_on_hands": value['_wh_on_hands'],
        "wh_with_month_year": value['_wh_with_month_year'],
        "wh_with_month_month": value['_wh_with_month_month'],
        "wh_on_actual": value['_wh_on_actual'],
        "wh_item_cost": value['_wh_item_cost'],
        "wh_curyid": value['_wh_curyid'],
        "wh_type": value['_wh_type'],
        "wh_access": value['_wh_access'],
        "wh_typepo": value['_wh_typepo'],
        "wh_withmonth": value['_wh_withmonth'],
        "wh_genuine_no": value['_wh_genuine_no'],
        "wh_item_size": value['_wh_item_size'],
        "wh_vhtid": value['_wh_vhtid'],
        "wh_merk": value['_wh_merk'],
      });
    });
    return list;
  }

  Widget _kv(String label, String value) {
   // print('value list stock opname');
   // print(value);
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().trim().replaceAll(',', '.');
    return num.tryParse(s) ?? 0;
  }

  String _formatNum(num n) {
    if (n == n.roundToDouble()) {
      return n.toInt().toString();
    }
    return n.toString();
  }

  bool _hasSelisih(Map value) {
    final String rawHands = _s(value['wh_on_hands']);
    final String rawActual = _s(value['wh_on_actual']);
    if (rawHands.isEmpty && rawActual.isEmpty) return false;
    final num onHands = _toNum(rawHands);
    final num onActual = _toNum(rawActual);
    return (onActual - onHands).abs() > 0;
  }

  num _calcDiff(Map value) {
    final num onHands = _toNum(value['wh_on_hands']);
    final num onActual = _toNum(value['wh_on_actual']);
    return onActual - onHands;
  }

  Widget _buildSelisihRow(Map value) {
    final String rawHands = _s(value['wh_on_hands']);
    final String rawActual = _s(value['wh_on_actual']);
    if (rawHands.isEmpty && rawActual.isEmpty) {
      return _kv('Selisih', '-');
    }

    final num onHands = _toNum(rawHands);
    final num onActual = _toNum(rawActual);
    final num diff = onActual - onHands;
    final num selisihAbs = diff.abs();

    if (selisihAbs == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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
                  'Selisih',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  ":",
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '0',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ])
          ],
        ),
      );
    }

    final String diffStr = "${diff > 0 ? '+' : ''}${_formatNum(diff)}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(14),
          2: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selisih',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _BlinkingAlertBadge(text: diffStr),
            ),
          ])
        ],
      ),
    );
  }

  Widget listItemBuilder(value, int index) {
    print("LIST STOK ${value}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
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
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryOrange, width: 1.2),
                  ),
                  child: Icon(Icons.warehouse_outlined,
                      color: primaryOrange, size: 20),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "WH ID : ${_s(value['whswarehpuseid'])}",
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Item ID', _s(value['wh_item_id'])),
                if (_s(value['wh_item_id']).isNotEmpty) ...[
                  SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: accentOrange.withOpacity(0.6)),
                      ),
                      child: QrImageView(
                        data: _s(value['wh_item_id']),
                        version: QrVersions.auto,
                        size: 120,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: darkOrange,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      _s(value['wh_item_id']),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: darkOrange,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                ],
                _kv('Part Name', _s(value['wh_part_name'])),
                _kv('Item Desc', _s(value['wh_item_descr'])),
                _kv('Genuine No', _s(value['wh_genuine_no'])),
                _kv('Item Size', _s(value['wh_item_size'])),
                _kv('VhtID', _s(value['wh_vhtid'])),
                _kv('Type', _s(value['wh_type'])),
                _kv('Merk', _s(value['wh_merk'])),
                _kv('Accessories', _s(value['wh_access'])),
                // Type PO dan Currency di-hidden sesuai permintaan
                _kv('Qty On Books', _s(value['wh_on_hands'])),
                _kv('Qty On Actual', _s(value['wh_on_actual'])),
                _buildSelisihRow(value is Map ? value : {}),
                _kv('Tgl Opname', _s(value['wh_withmonth'])),
                if (_hasSelisih(value is Map ? value : {}))
                  _BlinkingAlertBanner(
                    message: () {
                      final num d = _calcDiff(value is Map ? value : {});
                      final String signStr = d > 0 ? "+${_formatNum(d)}" : _formatNum(d);
                      final String desc = d > 0 ? "Fisik Lebih" : "Fisik Kurang";
                      return "ALERT: Terdapat selisih stok $signStr ($desc)!";
                    }(),
                  ),
                OpnameMutasiPanel(
                  warehouseId: _s(value['whswarehpuseid']),
                  itemId: _s(value['wh_item_id']),
                  month: _monthOf(value is Map ? value : {}),
                  year: _yearOf(value is Map ? value : {}),
                  primaryOrange: primaryOrange,
                  lightOrange: lightOrange,
                  accentOrange: accentOrange,
                  darkOrange: darkOrange,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.print, color: Colors.white, size: 16),
                    label: Text(
                      'Print',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () =>
                        _openPrintPreview(Map<String, dynamic>.from(value)),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit, color: Colors.white, size: 16),
                    label: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      globals.wh_id = _s(value['whswarehpuseid']);
                      globals.wh_itemid = _s(value['wh_item_id']);
                      globals.wh_part_name = _s(value['wh_part_name']);
                      globals.wh_type = _s(value['wh_type']);
                      globals.wh_accessories = _s(value['wh_access']);
                      globals.wh_quantity_on_hands = _s(value['wh_on_hands']);
                      globals.wh_quantity_on_actuals = _s(value['wh_on_actual']);
                      globals.wh_typepo = _s(value['wh_typepo']);
                      globals.wh_itemcost = _s(value['wh_item_cost']);
                      globals.wh_currency_id = _s(value['wh_curyid']);
                      globals.wh_month = _s(value['wh_withmonth']);
                      globals.wh_month_year = _s(value['wh_with_month_year']);
                      globals.wh_month_month = _s(value['wh_with_month_month']);
                      globals.wh_item_size = _s(value['wh_item_size']);
                      globals.wh_genuine_no = _s(value['wh_genuine_no']);
                      globals.wh_vhtid = _s(value['wh_vhtid']);
                      globals.wh_merk = _s(value['wh_merk']);
                      globals.wh_method = "edit";
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FrmWareHouseOpName()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(color: primaryOrange),
    );
  }

  Widget errorWidgetMaker(
      dynamic inventorydataModel, VoidCallback retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            inventorydataModel?.errorMessage ?? "Something went wrong.",
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          onPressed: retryListener,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
          ),
          child: Text('Retry', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(InventoryTransDataModel inventorydataModel) {
    return Center(
      child: Text(
        'Tidak ada stock opname dalam list',
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }

  int totalPagesGetter(InventoryTransDataModel inventorydataModel) {
    return inventorydataModel.total;
  }

  bool pageErrorChecker(InventoryTransDataModel inventorydataModel) {
    return inventorydataModel.statusCode != 200;
  }
}

class InventoryTransDataModel {
  late List<dynamic> inventorydataModel;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  InventoryTransDataModel.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    List jsonData = json.decode(response.body);
    inventorydataModel = jsonData[1] ?? [];
    total = ((jsonData[0] as Map)['total'] ?? 0) as int;
    nItems = inventorydataModel.length;
    errorMessage = '';
  }

  InventoryTransDataModel.withError(String msg)
      : inventorydataModel = [],
        statusCode = 0,
        total = 0,
        nItems = 0,
        errorMessage = msg;
}

class _BlinkingAlertBadge extends StatefulWidget {
  final String text;

  const _BlinkingAlertBadge({Key? key, required this.text}) : super(key: key);

  @override
  __BlinkingAlertBadgeState createState() => __BlinkingAlertBadgeState();
}

class __BlinkingAlertBadgeState extends State<_BlinkingAlertBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final g = _glow.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFD32F2F),
              const Color(0xFFFF5722),
              _controller.value,
            )!.withValues(alpha: (0.85 + 0.15 * g).clamp(0.0, 1.0)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: (0.45 * g + 0.25).clamp(0.0, 1.0)),
                blurRadius: 4 + 6 * g,
                spreadRadius: 1 + g,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 13,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlinkingAlertBanner extends StatefulWidget {
  final String message;

  const _BlinkingAlertBanner({Key? key, required this.message})
      : super(key: key);

  @override
  __BlinkingAlertBannerState createState() => __BlinkingAlertBannerState();
}

class __BlinkingAlertBannerState extends State<_BlinkingAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.25, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final p = _pulse.value;
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFFFEBEE),
              const Color(0xFFFFCDD2),
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.shade700.withValues(alpha: (0.5 + 0.5 * p).clamp(0.0, 1.0)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: (p * 0.35).clamp(0.0, 1.0)),
                blurRadius: 6 + 6 * p,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

