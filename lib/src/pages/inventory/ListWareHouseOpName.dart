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
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FrmWareHouseOpName()));
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Stock Opname');

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: customSearchBar,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 20.0,
          onPressed: () {
            _goBack(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: customIcon,
            onPressed: () {
              setState(() {
                print(customIcon.icon == Icons.search);
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    onTap: () async {
                      if (_txtSearch.text.isEmpty) {
                        return;
                      } else {
                        _searchText = _txtSearch.text;
                        paginatorGlobalKey.currentState?.changeState(
                            pageLoadFuture: sendInventoryDataRequest,
                            resetState: true);
                      }
                    },
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      controller: _txtSearch,
                      decoration: InputDecoration(
                        hintText: 'Trx Inventory number',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    _searchText = "";
                    _txtSearch.text = "";
                  });
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('List Inventory');
                }
              });
            },
          ),
        ],
      ),
      body: Paginator.listView(
        key: paginatorGlobalKey,
        pageLoadFuture: sendInventoryDataRequest,
        pageItemsGetter: (data) => listItemsGetter(data as InventoryTransDataModel),
        listItemBuilder: listItemBuilder,
        loadingWidgetBuilder: loadingWidgetMaker,
        errorWidgetBuilder: errorWidgetMaker,
        emptyListWidgetBuilder: (data) => emptyListWidgetMaker(data as InventoryTransDataModel),
        totalItemsGetter: (data) => totalPagesGetter(data as InventoryTransDataModel),
        pageErrorChecker: (data) => pageErrorChecker(data as InventoryTransDataModel),
        scrollPhysics: BouncingScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchText = "";
            _txtSearch.text = "";
          });
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: sendInventoryDataRequest, resetState: true);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<InventoryTransDataModel> sendInventoryDataRequest(int page) async {
    print('page ${page}');
    try {
      // String url = Uri.encodeFull(
      //     'http://apps.tuluatas.com:8085/cemindo/api/inventory/list_inventory_trans.jsp?method=list-inventory-trans-v1&page=${page}&search=' +
      //         _searchText);
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
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return InventoryTransDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return InventoryTransDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(InventoryTransDataModel data) {
    List<Map<String, dynamic>> list = [];
    print("listItemsGetter");
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
      });
    });
    return list;
  }

  Widget listItemBuilder(value, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black45))),
                    child: Icon(Icons.settings, color: Colors.black),
                  ),

                  title: Text(
                    "WH ID: ${value['whswarehpuseid']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Wrap(children: <Widget>[
                    Text(
                        "\nITEM ID: ${value['wh_item_id']}"
                        "\nPART NAME: ${value['wh_part_name']}"
                        "\nITEM DESC: ${value['wh_item_descr']}"
                        "\nType: ${value['wh_type']}"
                        "\nAccessories: ${value['wh_access']}"
                        "\nType PO: ${value['wh_typepo']}"
                        "\nCurrency: ${value['wh_curyid']}"
                        "\nQty On Hands: ${value['wh_on_hands']}"
                        "\nQty On Actual: ${value['wh_on_actual']}"
                        "\nWith Month: ${value['wh_withmonth']}",
                        style: TextStyle(color: Colors.black)),
                  ]),
                  // trailing: Icon(Icons.keyboard_arrow_right,
                  //     color: Colors.black, size: 30.0)
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Edit"),
                  onPressed: () {
                    globals.wh_id = value['whswarehpuseid'];
                    globals.wh_itemid = value['wh_item_id'];
                    globals.wh_part_name = value['wh_part_name'];
                    globals.wh_type = value['wh_type'];
                    globals.wh_accessories = value['wh_access'];
                    globals.wh_quantity_on_hands = value['wh_on_hands'];
                    globals.wh_quantity_on_actuals = value['wh_on_actual'];
                    globals.wh_typepo = value['wh_typepo'];
                    globals.wh_itemcost = value['wh_item_cost'];
                    globals.wh_currency_id = value['wh_curyid'];
                    globals.wh_month = value['wh_withmonth'];
                    globals.wh_month_year = value['wh_with_month_year'];
                    globals.wh_month_month = value['wh_with_month_month'];
                    globals.wh_method = "edit";
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FrmWareHouseOpName()));
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.lightBlueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ))
              ]),
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
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetMaker(
      dynamic inventorydataModel, VoidCallback retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(inventorydataModel?.errorMessage ?? "Something went wrong."),
        ),
        TextButton(
          onPressed: retryListener,
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(InventoryTransDataModel inventorydataModel) {
    return Center(
      child: Text('Tidak ada inventory dalam list'),
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
