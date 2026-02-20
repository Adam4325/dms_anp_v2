import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmInventoryMaint.dart';
import 'package:dms_anp/src/pages/inventory/FrmInventory.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMcByForeMan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/widgets/simple_paginator.dart';


class ListInventoryMaint extends StatefulWidget {
  final String widget_wodnumber;
  final String widget_inv_trx_type;
  final String widget_from_ware_house;
  final String widget_formen;
  const ListInventoryMaint(
      {Key? key,
        required this.widget_wodnumber,
        required this.widget_inv_trx_type,
        required this.widget_from_ware_house,
        required this.widget_formen})
      : super(key: key);
  @override
  _ListInventoryMaintState createState() => _ListInventoryMaintState();
}

class _ListInventoryMaintState extends State<ListInventoryMaint> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  //WARNA THEME
  final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = Color(0xFFFFB347); // Peach orange
  final Color darkOrange = Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  final Color cardColor = Color(0xFFF8F0F0); // Light cream (fix typo)
  final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow
  //END

  _goBack(BuildContext context) {
    if (widget.widget_formen != null && widget.widget_formen == "true") {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ViewListWoMcByForeMan()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewListWoMCN()));
    }
    print('widget.widget_formen ${widget.widget_formen}');
    print(widget.widget_formen=="true");
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Inventory MC');

  @override
  void initState() {
    super.initState();
    _txtSearch.text = "";
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
            automaticallyImplyLeading: false,
            title: customSearchBar,
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
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
                    if (customIcon.icon == Icons.search) {
                      customIcon =
                          const Icon(Icons.cancel, color: Colors.white);
                      customSearchBar = ListTile(
                        onTap: () async {
                          if (_txtSearch.text == null ||
                              _txtSearch.text == "") {
                            return;
                          } else {
                            _searchText = _txtSearch.text;
                            paginatorGlobalKey.currentState?.changeState(
                                pageLoadFuture: sendDriverDataRequest,
                                resetState: true);
                          }
                        },
                        leading:
                            Icon(Icons.search, color: Colors.white, size: 26),
                        title: TextField(
                          controller: _txtSearch,
                          decoration: InputDecoration(
                            hintText: 'Cari part name/ ID Inventory...',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      setState(() {
                        _searchText = "";
                        _txtSearch.text = "";
                      });
                      customIcon =
                          const Icon(Icons.search, color: Colors.white);
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
            pageItemsGetter: listItemsGetter,
            listItemBuilder: listItemBuilder,
            loadingWidgetBuilder: loadingWidgetMaker,
            errorWidgetBuilder: errorWidgetMaker,
            emptyListWidgetBuilder: emptyListWidgetMaker,
            totalItemsGetter: totalPagesGetter,
            pageErrorChecker: pageErrorChecker,
            scrollPhysics: BouncingScrollPhysics(),
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
            backgroundColor: accentOrange,
            child: Icon(Icons.refresh, color: Colors.white),
          ),
        ));
  }

  Future<DriverDataModel> sendDriverDataRequest(int page) async {
    var number = widget.widget_wodnumber;
    var type = widget.widget_inv_trx_type;
    var from = widget.widget_from_ware_house;
    try {
      String baseURL =
          '${GlobalData.baseUrl}api/inventory/list_inventory_detail_maint.jsp?method=list-inventory-detail-v1&number=$number&type=$type&from=$from&page=$page&search=' +
              _searchText;
      print(baseURL);
      String url = Uri.encodeFull(baseURL);
      Uri myUri = Uri.parse(url);
      http.Response response = await http.get(myUri);
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

  List<dynamic> listItemsGetter(dynamic data) {
    final driverData = data as DriverDataModel;
    List<Map<String, dynamic>> list = [];
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
    return Card(
      elevation: 6.0,
      shadowColor: shadowColor,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              leading: Container(
                padding: const EdgeInsets.only(right: 12.0),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1.0, color: Colors.black26),
                  ),
                ),
                child: Icon(Icons.settings_applications, color: darkOrange),
              ),
              title: Text(
                "ItemID: ${value['ititemid']}",
                style: TextStyle(
                  color: darkOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("INV.Number: ${value['itdinvtrannbr']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Partname: ${value['partname']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Qty: ${value['idqty']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Qty Bekas: ${value['idrealqty']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Uom: ${value['uomid']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Type: ${value['idtype']}",
                        style: TextStyle(color: Colors.black87)),
                    Text("Merk: ${value['merk']}",
                        style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check,
                        color: Colors.white, size: 16.0),
                    label: const Text("Select"),
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
                      //widget.widget_wodnumber
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FrmInventoryMaint(
                                  widget_wodnumber: widget.widget_wodnumber,
                                  widget_formen: widget.widget_formen,
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget errorWidgetMaker(dynamic data, VoidCallback retry) {
    final driverDatas = data as DriverDataModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(driverDatas.errorMessage,
              style: TextStyle(color: darkOrange)),
        ),
        TextButton(
          onPressed: retry,
          child: Text('Retry',
              style:
                  TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(dynamic data) {
    return Center(
      child: Text('Tidak ada data dalam list',
          style: TextStyle(
              color: darkOrange, fontSize: 16, fontWeight: FontWeight.w500)),
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
    errorMessage = '';
    List jsonData = json.decode(response.body);
    driverdatas = jsonData[1];
    total = jsonData[0]['total'];
    nItems = driverdatas.length;
  }

  DriverDataModel.withError(String errMessage) {
    statusCode = 0;
    errorMessage = errMessage;
    driverdatas = [];
    total = 0;
    nItems = 0;
  }
}
