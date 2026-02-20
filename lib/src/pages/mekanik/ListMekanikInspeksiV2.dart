import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'ApprovedMekanikDailyCheckScreenP2H.dart';
import 'DailyMekanikCheckScreenP2H.dart';

class ListMekanikInspeksiV2 extends StatefulWidget {
  @override
  _ListMekanikInspeksiV2State createState() => _ListMekanikInspeksiV2State();
}

class _ListMekanikInspeksiV2State extends State<ListMekanikInspeksiV2> {
  GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  String _searchText = "";
  String username = "";
  String userid = "";
  String locid = "";
  // Soft Orange Pastel Theme Colors
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
  Widget customSearchBar = const Text('List P2H Tools');

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



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
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
                          paginatorGlobalKey.currentState!.changeState(
                              pageLoadFuture: sendMekanikDataRequest,
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
                          hintText: 'Cari name/ mekanik...',
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
                    customSearchBar = const Text('List Mekanik 2');
                  }
                });
              },
            ),
          ],
        ),
        body: Paginator.listView(
          key: paginatorGlobalKey,
          pageLoadFuture: sendMekanikDataRequest,
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
                pageLoadFuture: sendMekanikDataRequest, resetState: true);
          },
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  Future<MekanikData> sendMekanikDataRequest(int page) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var loginname = sharedPreferences.getString("loginname");
    var username = sharedPreferences.getString("username");
    var mechanicid = sharedPreferences.getString("mechanicid");
    print('page ${page}');
    print('_searchText ${_searchText}');
    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrl}api/mekanik/list_mekanik.jsp?method=list-mekanik-v2&kryid=${mechanicid}&page=${page}&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      print(myUri);
      http.Response response = await http.get(myUri);
      print('body ${response.body}');
      return MekanikData.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        //paginatorGlobalKey
        alert(context, 2, "Please check your internet connection.", "warning");
        return MekanikData.withError('Please check your internet connection.');
      } else {
        alert(context, 2, "Something went wrong.", "warning");
        return MekanikData.withError('Something went wrong.');
      }
    }
  }

  List<dynamic> listItemsGetter(dynamic data) {
    final mcData = data as MekanikData;
    List<Map<String, dynamic>> list = [];

    for (var value in mcData.mekanikdatas) {
      String karyawanNm = (value['karyawan_nm'] == null ||
              value['karyawan_nm'].toString().toLowerCase() == 'null')
          ? ""
          : value['karyawan_nm'].toString();

      String kryid = (value['kryid'] == null ||
              value['kryid'].toString().toLowerCase() == 'null')
          ? ""
          : value['kryid'].toString();

      String grade = (value['grade'] == null ||
              value['grade'].toString().toLowerCase() == 'null')
          ? ""
          : value['grade'].toString();

      String p2hnumber = (value['p2hnumber'] == null ||
              value['p2hnumber'].toString().toLowerCase() == 'null')
          ? ""
          : value['p2hnumber'].toString();

      String? tgl = (value['tgl'] == null ||
              value['tgl'].toString().toLowerCase() == 'null')
          ? null
          : value['tgl'].toString();

      list.add({
        "karyawan_nm": karyawanNm,
        "kryid": kryid,
        "grade": grade,
        "p2hnumber": p2hnumber,
        "tgl": tgl,
      });
    }

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
                  "KryID: ${value['kryid']} ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Karyawan Name: ${value['karyawan_nm']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
                  Text("Grade: ${value['grade']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
                  Text("P2hNumber: ${value['p2hnumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    height: 0.0,
                    color: Colors.black12,
                  ),
                  Text("Tanggal: ${value['tgl']}",
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
                if ((getAkses("OP") ||
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
                      print(value['kryid']);
                      globals.Mcp2hNumber = value['p2hnumber'];
                      globals.Mckryid = value['kryid'];
                      globals.McName = value['karyawan_nm'];
                      globals.McGrade = value['grade'];
                      globals.McDate = value['tgl'];
                      print(value);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ApprovedMekanikDailyCheckScreenP2H()));
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: primaryOrange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,color: Colors.white)),
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
                      globals.p2hVhcMekanik = '';
                      globals.Mcp2hNumber = value['p2hnumber'];
                      globals.Mckryid = value['kryid'];
                      globals.McGrade = value['grade'];
                      globals.McDate = value['tgl'];
                      print(value);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DailyMekanikCheckScreenP2H()));
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
    final mekanikDatas = data as MekanikData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(mekanikDatas.errorMessage),
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
      child: Text('Tidak ada mekanik dalam list'),
    );
  }

  int totalPagesGetter(dynamic data) {
    final mekanikDatas = data as MekanikData;
    return mekanikDatas.total;
  }

  bool pageErrorChecker(dynamic data) {
    final mekanikDatas = data as MekanikData;
    return mekanikDatas.statusCode != 200;
  }
}

class MekanikData {
  late final List<Map<String, dynamic>> mekanikdatas;
  late final int total;
  late final int statusCode;
  late final String errorMessage;
  late final int nItems;

  MekanikData({
    required this.mekanikdatas,
    required this.total,
    required this.statusCode,
    required this.errorMessage,
    required this.nItems,
  });

  factory MekanikData.fromResponse(http.Response response) {
    final body = json.decode(response.body);

    // Validasi format response (harus List dengan 2 elemen)
    if (body is List && body.length == 2) {
      final meta = body[0];
      final data = body[1];
      print('data ${data}');
      if (data == null || !(data is List)) {
        throw Exception("Data format tidak sesuai");
      }

      List<Map<String, dynamic>> listData =
          List<Map<String, dynamic>>.from(data);
      int total = int.tryParse(meta["total"].toString()) ?? 0;

      return MekanikData(
        mekanikdatas: listData,
        total: total,
        nItems: listData.length,
        statusCode: response.statusCode,
        errorMessage: '',
      );
    } else {
      throw Exception("Response format tidak sesuai");
    }
  }

  factory MekanikData.withError(String error) {
    return MekanikData(
      mekanikdatas: [],
      total: 0,
      errorMessage: error,
      nItems: 0,
      statusCode: 0,
    );
  }
}
