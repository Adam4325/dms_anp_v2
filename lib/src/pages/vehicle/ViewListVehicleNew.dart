import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
import 'package:dms_anp/src/pages/driver/FrmInspeksiVehicleP2H.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ViewListVehicleNew extends StatefulWidget {
  @override
  _ViewListVehicleNewState createState() => _ViewListVehicleNewState();
}

class _ViewListVehicleNewState extends State<ViewListVehicleNew> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  void resetGlobalsTeks(){
    globals.p2hVhcid = "";
    globals.p2hVhclocid = "";
    globals.p2hVhcdate = "";
    globals.p2hVhckm = 0;
    globals.p2hVhcdefaultdriver = "";
    globals.pages_name = "";
    globals.p2hDriverName = "";
  }

  _goBack(BuildContext context) {
    resetGlobalsTeks();
    if(globals.pages_name=="view-service") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewService()));
    }else{
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewDashboard()));
    }
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Vehicle');

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
                      if (_txtSearch.text == null || _txtSearch.text == "") {
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
                        hintText: 'Cari name/ Vehicle...',
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
                  customSearchBar = const Text('List Vehicle');
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

  Future<DriverDataVehicle> sendDriverDataRequest(int page) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var loginname = sharedPreferences.getString("loginname");
    var username = sharedPreferences.getString("username");
    print('page ${page}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrlOri}api/vehicle/list_vehiclev2.jsp?method=list-vehicle-v1&loginname=${loginname}&username=${username}&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body}');
      return DriverDataVehicle.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return DriverDataVehicle.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return DriverDataVehicle.withError('Something went wrong.');
      }
    }
  }

  List<dynamic> listItemsGetter(dynamic data) {
    final vehicleData = data as DriverDataVehicle;
    List<Map<String, dynamic>> list = [];
    vehicleData.vehicledatas.forEach((value) {
      String vhcdefaultdriver = value['vhcdefaultdriver'].toString() == null ||
          value['vhcdefaultdriver'].toString() == 'null'
          ? ""
          : value['vhcdefaultdriver'];
      String drvname = value['drvname'].toString() == null ||
          value['drvname'].toString() == 'null'
          ? ""
          : value['drvname'];

      String vhcdate = value['vhcdate'].toString() == null ||
          value['vhcdate'].toString() == 'null'
          ? null
          : value['vhcdate'];
      list.add({
        "vhcid": value['vhcid'],
        "vhcnopol": value['vhcnopol'],
        "locid": value['locid'],
        "vhcdefaultdriver": vhcdefaultdriver,
        "status": value['status'],
        "vhckm": value['vhckm'],
        "drvname": drvname,
        "vhcdate": vhcdate,
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
                  child: Icon(Icons.car_rental, color: Colors.black),
                ),
                title: Text(
                  "Nopol: ${value['vhcnopol']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  // Text("Status Kendaraan: ${value['status']}",
                  //     style: TextStyle(color: Colors.black)),
                  // Divider(
                  //   height: 0.0,
                  //   color: Colors.black12,
                  // ),
                  Text("Driver Name: ${value['drvname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
                  Text("Kilometer: ${value['vhckm']} KM",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
                  Text("Cabang: ${value['locid']}",
                      style: TextStyle(color: Colors.black)),
                ]),
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
                        Icons.check,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Select"),
                      onPressed: () async {
                        print(value['vhckm']);
                        globals.p2hVhcid = value['vhcid'];
                        globals.p2hVhclocid = value['locid'];
                        globals.p2hVhcdate = value['vhcdate'];
                        globals.p2hDriverName = value['drvname'];
                        globals.p2hVhckm = value['vhckm'] == null ||
                            value['vhckm'] == "null" ||
                            value['vhckm'] == ""
                            ? 0.0
                            : double.parse(value['vhckm']);
                        globals.p2hVhcdefaultdriver = value['vhcdefaultdriver'];
                        if(globals.pages_name=="view-service"){
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewService()));
                        }

                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.blue)))),
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
    final vehicleDatas = data as DriverDataVehicle;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(vehicleDatas.errorMessage),
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
      child: Text('Tidak ada vehicle dalam list'),
    );
  }

  int totalPagesGetter(dynamic data) {
    return (data as DriverDataVehicle).total;
  }

  bool pageErrorChecker(dynamic data) {
    return (data as DriverDataVehicle).statusCode != 200;
  }
}

class DriverDataVehicle {
  late List<dynamic> vehicledatas;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  DriverDataVehicle.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    errorMessage = '';
    List jsonData = json.decode(response.body);
    vehicledatas = jsonData[1] ?? [];
    total = jsonData[0]?['total'] ?? 0;
    nItems = vehicledatas.length;
  }

  DriverDataVehicle.withError(String errMessage) {
    statusCode = 0;
    errorMessage = errMessage;
    vehicledatas = [];
    total = 0;
    nItems = 0;
  }
}
