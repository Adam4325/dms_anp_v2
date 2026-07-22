import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/inventory/FrmWareHouseOpName.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/widgets/simple_paginator.dart';

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
      });
    });
    return list;
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

  Widget listItemBuilder(value, int index) {
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
                _kv('Part Name', _s(value['wh_part_name'])),
                _kv('Item Desc', _s(value['wh_item_descr'])),
                _kv('Genuine No', _s(value['wh_genuine_no'])),
                _kv('Item Size', _s(value['wh_item_size'])),
                _kv('Type', _s(value['wh_type'])),
                _kv('Accessories', _s(value['wh_access'])),
                _kv('Type PO', _s(value['wh_typepo'])),
                _kv('Currency', _s(value['wh_curyid'])),
                _kv('Qty On Hands', _s(value['wh_on_hands'])),
                _kv('Qty On Actual', _s(value['wh_on_actual'])),
                _kv('With Month', _s(value['wh_withmonth'])),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: SizedBox(
              width: double.infinity,
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
