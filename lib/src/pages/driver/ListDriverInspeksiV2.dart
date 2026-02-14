import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/FrmInspeksiVehicleP2H.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'ApprovedDailyCheckScreenP2H.dart';
import 'DailyCheckScreenP2H.dart';

class ListDriverInspeksiV2 extends StatefulWidget {
  @override
  _ListDriverInspeksiV2State createState() => _ListDriverInspeksiV2State();
}

class _ListDriverInspeksiV2State extends State<ListDriverInspeksiV2> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  String _searchText = "";
  String username = "";
  String userid = "";
  String locid = "";
  final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  final Color accentOrange = Color(0xFFFFB347); // Peach orange
  final Color darkOrange = Color(0xFFE07B39); // Darker orange
  final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  final Color cardColor = Color(0xFFFFF8F0); // Light cream
  final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow
  final TextEditingController _filter = new TextEditingController();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Vehicle');

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "";
    userid = prefs.getString("name") ?? "";
    locid = prefs.getString("locid") ?? "";
    //listLocid = locid.split(',');
    //print(listLocid);
  }

  @override
  void initState() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    getSession();
    _txtSearch.text = "";
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       title: customSearchBar,
  //       leading: IconButton(
  //         icon: Icon(Icons.arrow_back),
  //         iconSize: 20.0,
  //         onPressed: () {
  //           _goBack(context);
  //         },
  //       ),
  //       actions: <Widget>[
  //         IconButton(
  //           icon: customIcon,
  //           onPressed: () {
  //             setState(() {
  //               print(customIcon.icon == Icons.search);
  //               if (customIcon.icon == Icons.search) {
  //                 customIcon = const Icon(Icons.cancel);
  //                 customSearchBar = ListTile(
  //                   onTap: () async {
  //                     if (_txtSearch.text == null || _txtSearch.text == "") {
  //                       return;
  //                     } else {
  //                       _searchText = _txtSearch.text;
  //                       paginatorGlobalKey.currentState.changeState(
  //                           pageLoadFuture: sendDriverDataRequest,
  //                           resetState: true);
  //                     }
  //                   },
  //                   leading: Icon(
  //                     Icons.search,
  //                     color: Colors.white,
  //                     size: 28,
  //                   ),
  //                   title: TextField(
  //                     controller: _txtSearch,
  //                     decoration: InputDecoration(
  //                       hintText: 'Cari name/ Vehicle...',
  //                       hintStyle: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                         fontStyle: FontStyle.italic,
  //                       ),
  //                       border: InputBorder.none,
  //                     ),
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 );
  //               } else {
  //                 setState(() {
  //                   _searchText = "";
  //                   _txtSearch.text = "";
  //                 });
  //                 customIcon = const Icon(Icons.search);
  //                 customSearchBar = const Text('List Vehicle');
  //               }
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //     body: Paginator.listView(
  //       key: paginatorGlobalKey,
  //       pageLoadFuture: sendDriverDataRequest,
  //       pageItemsGetter: listItemsGetter,
  //       listItemBuilder: listItemBuilder,
  //       loadingWidgetBuilder: loadingWidgetMaker,
  //       errorWidgetBuilder: errorWidgetMaker,
  //       emptyListWidgetBuilder: emptyListWidgetMaker,
  //       totalItemsGetter: totalPagesGetter,
  //       pageErrorChecker: pageErrorChecker,
  //       scrollPhysics: BouncingScrollPhysics(),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         setState(() {
  //           _searchText = "";
  //           _txtSearch.text = "";
  //         });
  //         paginatorGlobalKey.currentState.changeState(
  //             pageLoadFuture: sendDriverDataRequest, resetState: true);
  //       },
  //       child: Icon(Icons.refresh),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack(context);
        return false; // biar tidak auto pop, tapi pakai _goBack
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: darkOrange,
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
          scrollPhysics: BouncingScrollPhysics(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryOrange,
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
          '${GlobalData.baseUrlOri}api/vehicle/list_vehiclev2.jsp?method=list-vehicle-v2&loginname=${loginname}&username=${username}&page=${page}&search=' +
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
        "p2hnumber": value['p2hnumber'],
        "vhcid": value['vhcid'],
        "vhttype": value['vhttype'],
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

  bool getAkses(akses) {
    //print(globals.akses_pages);
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == akses);
    //print("isOK ${isOK}");
    //print("isOK.length ${isOK.length}");
    if (isOK != null) {
      if (isOK.length > 0) {
        //print(isOK);
        isAkses = true;
      }
    }
    return isAkses;
  }

  Widget listItemBuilder(value, int index) {
    print(value);
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
                  "Nopol: ${value['vhcnopol']} (${value['vhttype']})",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Status Kendaraan: ${value['status']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
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
                if (globals.inspeksi_name == 'new_inspeksi' &&
                    (getAkses("OP") ||
                        username == 'ADMIN' ||
                        username == 'NURIZKI')) ...[
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Verifikasi"),
                    onPressed: () async {
                      print(value['vhckm']);
                      globals.p2hNumber = value['p2hnumber'];
                      globals.p2hVhcid = value['vhcid'];
                      globals.p2hVhclocid = value['locid'];
                      globals.p2hVhcdate = value['vhcdate'];
                      globals.p2hVhckm = value['vhckm'] == null ||
                              value['vhckm'] == "null" ||
                              value['vhckm'] == ""
                          ? 0.0
                          : double.parse(value['vhckm']);
                      globals.p2hVhcdefaultdriver = value['vhcdefaultdriver'];
                      // FrmInspeksiVehicleP2H DailyCheckScreenP2H
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ApprovedDailyCheckScreenP2H()));
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: primaryOrange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 10)
                ] else if (!getAkses("OPR") || username == 'ADMIN') ...[
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
                      globals.p2hVhckm = value['vhckm'] == null ||
                              value['vhckm'] == "null" ||
                              value['vhckm'] == ""
                          ? 0.0
                          : double.parse(value['vhckm']);
                      globals.p2hVhcdefaultdriver = value['vhcdefaultdriver'];
                      // FrmInspeksiVehicleP2H DailyCheckScreenP2H
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyCheckScreenP2H()));
                    },
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue)))),
                  ))
                ],
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

  DriverDataVehicle.withError(String errMsg) {
    statusCode = 0;
    errorMessage = errMsg;
    vehicledatas = [];
    total = 0;
    nItems = 0;
  }
}
