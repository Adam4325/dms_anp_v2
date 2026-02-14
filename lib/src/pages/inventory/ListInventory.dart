import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/inventory/FrmInventory.dart';
import 'package:dms_anp/src/pages/inventory/ListInventoryTrans.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;

import 'package:dms_anp/src/widgets/simple_paginator.dart';

class ListInventory extends StatefulWidget {
  @override
  _ListInventoryState createState() => _ListInventoryState();
}

class _ListInventoryState extends State<ListInventory> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  // _goBack(BuildContext context) {
  //   Navigator.pushReplacement(
  //       context, MaterialPageRoute(builder: (context) => ListInventoryTrans()));
  // }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ListInventoryTrans()));
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Inventory');

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
                            pageLoadFuture: sendDriverDataRequest,
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
                        hintText: 'Cari part name/ ID Inventory...',
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
        pageLoadFuture: sendDriverDataRequest,
        pageItemsGetter: (data) => listItemsGetter(data as DriverDataModel),
        listItemBuilder: listItemBuilder,
        loadingWidgetBuilder: loadingWidgetMaker,
        errorWidgetBuilder: errorWidgetMaker,
        emptyListWidgetBuilder: (data) => emptyListWidgetMaker(data),
        totalItemsGetter: (data) => totalPagesGetter(data as DriverDataModel),
        pageErrorChecker: (data) => pageErrorChecker(data as DriverDataModel),
        scrollPhysics: const BouncingScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _searchText = "";
            _txtSearch.text = "";
          });
          paginatorGlobalKey.currentState?.changeState(
              pageLoadFuture: sendDriverDataRequest, resetState: true);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<DriverDataModel> sendDriverDataRequest(int page) async {
    var number = globals.inv_trx_number;
    var type = globals.inv_trx_type;
    var from = globals.from_ware_house;
    print(number);
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrl}api/inventory/list_inventory_detail.jsp?method=list-inventory-detail-v1&number=$number&type=$type&from=$from&page=$page&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('${response.body}');
      return DriverDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        alert(context, 2, "Please check your internet connection.", "warning");
        return DriverDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return DriverDataModel.withError('Something went wrong.');
      }
    }
  }

  List<Map<String, dynamic>> listItemsGetter(DriverDataModel driverData) {
    List<Map<String, dynamic>> list = [];
    print('listItemsGetter');
    driverData.driverdatas.forEach((value) {
      String ititemid = value['ititemid'].toString() == null ||
              value['ititemid'].toString() == 'null'
          ? ""
          : value['ititemid'];
      String partname = value['partname'].toString() == null ||
              value['partname'].toString() == 'null'
          ? ""
          : value['partname'];
      list.add({
        "ititemid": ititemid,
        "partname": partname,
        "idqty": value['idqty'],
        "uomid": value['uomid'],
        "itdunitcost": value['itdunitcost'],
        "idtextcost": value['idtextcost'],
        "itdinvtrannbr": value['itdinvtrannbr'],
        "idtype": value['idtype'],
        "itdlinenbr": value['itdlinenbr'],
        "idaccess": value['idaccess'],
        "merk": value['merk'],
        "sntyre": value['sntyre'],
        "idrealqty": value['idrealqty'],
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
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.black45))),
                    child: Icon(Icons.settings_applications, color: Colors.black),
                  ),
                  title: Text(
                    "ItemID: ${value['ititemid']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Wrap(children: <Widget>[
                    Text("Partname: ${value['partname']}",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    Text("Qty: ${value['idqty']}",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    Text("Uom: ${value['uomid']}",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    Text("Type: ${value['idtype']}",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    Text("Merk: ${value['merk']}",
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
                // Expanded(
                //     child: ElevatedButton.icon(
                //   icon: Icon(
                //     Icons.camera,
                //     color: Colors.white,
                //     size: 15.0,
                //   ),
                //   label: Text("Edit"),
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //       elevation: 0.0,
                //       backgroundColor: Colors.blue,
                //       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                //       textStyle:
                //           TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                // )),
                // SizedBox(
                //   width: 2,
                // ),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Select"),
                  onPressed: () async {
                    globals.inv_ititemid = value['ititemid'];
                    globals.inv_partname = value['partname'];
                    globals.inv_idqty = value['idqty'];
                    globals.inv_uomid = value['uomid'];
                    globals.inv_itdunitcost = value['itdunitcost'];
                    globals.inv_idtextcost = value['idtextcost'];
                    globals.inv_itdinvtrannbr = value['itdinvtrannbr'];
                    globals.inv_idtype = value['idtype'];
                    globals.inv_idaccess = value['idaccess'];
                    globals.inv_merk = value['merk'];
                    globals.inv_sntyre = value['sntyre'];
                    globals.inv_idrealqty = value['idrealqty'];
                    globals.inv_itdlinenbr = value['itdlinenbr'];
                    globals.inv_method = "edit";
                    print(globals.inv_itdlinenbr);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FrmInventory(invTrxStatusBarang: '',)));
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
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

  Widget errorWidgetMaker(dynamic data, VoidCallback retry) {
    final driverDatas = data as DriverDataModel?;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(driverDatas?.errorMessage ?? "Something went wrong."),
        ),
        TextButton(
          onPressed: retry,
          child: Text('Retry'),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(dynamic data) {
    return Center(
      child: Text('Tidak ada data dalam list'),
    );
  }

  int totalPagesGetter(dynamic data) {
    return (data as DriverDataModel).total;
  }

  bool pageErrorChecker(dynamic data) {
    return (data as DriverDataModel).statusCode != 200;
  }
}

class DriverDataModel {
  late List<dynamic> driverdatas;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  DriverDataModel.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    List jsonData = json.decode(response.body);
    driverdatas = jsonData[1] ?? [];
    total = ((jsonData[0] as Map)['total'] ?? 0) as int;
    nItems = driverdatas.length;
    errorMessage = '';
  }

  DriverDataModel.withError(String msg)
      : driverdatas = [],
        statusCode = 0,
        total = 0,
        nItems = 0,
        errorMessage = msg;
}
