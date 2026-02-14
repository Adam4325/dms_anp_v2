import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/loginPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/RegistrasiNewDriver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListDriver extends StatefulWidget {
  @override
  _ListDriverState createState() => _ListDriverState();
}

class _ListDriverState extends State<ListDriver> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  String _searchText = "";
  final TextEditingController _filter = new TextEditingController();

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  TextEditingController _txtSearch = new TextEditingController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('List Driver');

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
                        hintText: 'Cari name/ id driver...',
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
                  customSearchBar = const Text('List Driver');
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

  Future<DriverDataModel> sendDriverDataRequest(int page) async {
    print('page ${page}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrlOri}api/driver/list_driver.jsp?method=list-driver-v1&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body}');
      return DriverDataModel.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return DriverDataModel.withError(
            'Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return DriverDataModel.withError('Something went wrong.');
      }
    }
  }

  // List<Map<String, dynamic>> listItemsGetter(DriverDataModel driverData) {
  //   List<Map<String, dynamic>> list = [];
  //   driverData.driverdatas.forEach((value) {
  //     String drvdob = value['drvdob'].toString() == null ||
  //             value['drvdob'].toString() == 'null'
  //         ? ""
  //         : value['drvdob'];
  //     String drvaddress = value['drvaddress'].toString() == null ||
  //             value['drvaddress'].toString() == 'null'
  //         ? ""
  //         : value['drvaddress'];
  //     list.add({
  //       "drvid": value['drvid'],
  //       "drvname": value['drvname'],
  //       "drvnickname": value['drvnickname'],
  //       "drvdob": drvdob,
  //       "drvaddress": drvaddress,
  //       "statusdrv": value['statusdrv'],
  //     });
  //   });
  //   return list;
  // }

  List<dynamic> listItemsGetter(dynamic data) {
    final DriverDataModel driverData = data as DriverDataModel;

    List<Map<String, dynamic>> list = [];

    for (var value in driverData.driverdatas) {
      String drvdob =
      (value['drvdob'] == null || value['drvdob'].toString() == 'null')
          ? ""
          : value['drvdob'].toString();

      String drvaddress =
      (value['drvaddress'] == null || value['drvaddress'].toString() == 'null')
          ? ""
          : value['drvaddress'].toString();

      list.add({
        "drvid": value['drvid'],
        "drvname": value['drvname'],
        "drvnickname": value['drvnickname'],
        "drvdob": drvdob,
        "drvaddress": drvaddress,
        "statusdrv": value['statusdrv'],
      });
    }

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
                    child: Icon(Icons.people, color: Colors.black),
                  ),
                  title: Text(
                    "${value['drvid']}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Wrap(children: <Widget>[
                    Text("${value['drvname']} (${value['statusdrv']})",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.black12,
                    ),
                    Text("${value['drvdob']}",
                        style: TextStyle(color: Colors.black)),
                    Divider(
                      color: Colors.black12,
                    ),
                    Text("${value['drvaddress']}",
                        style: TextStyle(color: Colors.black)),
                  ]),
                  trailing: Icon(Icons.keyboard_arrow_right,
                      color: Colors.black, size: 30.0)),
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
                    Icons.edit,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("Edit"),
                  onPressed: () async {
                    var isActive = value['statusdrv'];
                    print(isActive);
                    if (isActive.toString().toLowerCase() == "non active") {
                      alert(context, 2,
                          "Driver tidak active", "warning");
                    } else {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("is_edit", true);
                      prefs.setString("driver_id", value['drvid'].toString());
                      print(value['drvid'].toString());
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterNewDriver()));
                    }
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
    final driverDatas = data as DriverDataModel;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(driverDatas.errorMessage),
        ),
        TextButton(
          onPressed: retry,
          child: const Text('Retry'),
        )
      ],
    );
  }



  Widget emptyListWidgetMaker(dynamic data) {
    return Center(
      child: Text('Tidak ada driver dalam list'),
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
  final List<dynamic> driverdatas;
  final int statusCode;
  final String errorMessage;
  final int total;
  final int nItems;

  DriverDataModel.fromResponse(http.Response response)
      : statusCode = response.statusCode,
        errorMessage = '',
        driverdatas = _parseDriverData(response.body),
        total = _parseTotal(response.body),
        nItems = _parseDriverData(response.body).length;

  DriverDataModel.withError(String errorMessage)
      : statusCode = 0,
        errorMessage = errorMessage,
        driverdatas = [],
        total = 0,
        nItems = 0;

  static List<dynamic> _parseDriverData(String body) {
    final jsonData = json.decode(body);
    return jsonData[1] ?? [];
  }

  static int _parseTotal(String body) {
    final jsonData = json.decode(body);
    return jsonData[0]?['total'] ?? 0;
  }
}


// class DriverDataModel {
//   List<dynamic> driverdatas;
//   int statusCode;
//   String errorMessage;
//   int total;
//   int nItems;
//
//   DriverDataModel.fromResponse(http.Response response) {
//     this.statusCode = response.statusCode;
//     this.errorMessage = '';
//     List jsonData = json.decode(response.body);
//     driverdatas = jsonData[1] ?? [];
//     total = jsonData[0]?['total'] ?? 0;
//     nItems = driverdatas.length;
//   }
//
//   DriverDataModel.withError(String errorMessage) {
//     this.statusCode = 0;
//     this.errorMessage = errorMessage;
//     this.driverdatas = [];
//     this.total = 0;
//     this.nItems = 0;
//   }
// }
