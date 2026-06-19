import 'dart:convert';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewMaps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../flusbar.dart';

class ViewListStoring extends StatefulWidget {
  @override
  _ViewListStoringState createState() => _ViewListStoringState();
}

class _ViewListStoringState extends State<ViewListStoring> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  var data = [];

  List<dynamic> get _filteredData {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return data;

    return data.where((item) {
      final reqnbr = item['reqnbr']?.toString().toLowerCase() ?? '';
      final vhcid = item['vhcid']?.toString().toLowerCase() ?? '';
      return reqnbr.contains(keyword) || vhcid.contains(keyword);
    }).toList();
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.deepOrangeAccent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('List Storing',style: TextStyle(color: Colors.white))),
        body: new Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              _buildListView(context)
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getJSONData() async {
    EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid")!;
    String locid = prefs.getString("locid")!;
    print(drvid);
    var url = "";
    setState(() {
      url = "${GlobalData.baseUrl}api/list_storing.jsp?method=list-storing";
    });
    Uri myUri = Uri.parse(url);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      data = json.decode(response.body);
      // print(data);
      if (data == null || data.length == 0 || data == "") {
        alert(globalScaffoldKey.currentContext!, 2, "Tidak ada data", "warning");
      }
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  Future<String> CloseData(String reqnbr, String vhcid, String status) async {
    final reqnbrParam = reqnbr.trim();
    final vhcidParam = vhcid.trim();
    final statusParam = status.trim();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = (prefs.getString("username") ?? "").trim();
    if (userid.isEmpty) {
      userid = (prefs.getString("androidID") ?? "").trim();
    }
    if (userid.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0,
          "USER ID / IMEI ID tidak boleh kosong", "warning");
      return "Failed";
    }
    if (reqnbrParam.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Req NBR tidak boleh kosong",
          "warning");
      return "Failed";
    }
    if (vhcidParam.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "VHCID tidak boleh kosong",
          "warning");
      return "Failed";
    }
    if (statusParam.isEmpty) {
      alert(globalScaffoldKey.currentContext!, 0, "Status tidak boleh kosong",
          "warning");
      return "Failed";
    }

    EasyLoading.show();
    try {
      
      Uri myUri = Uri.parse("${GlobalData.baseUrl}api/list_storing.jsp").replace(
        queryParameters: {
          "method": "close-data-storing",
          "reqnbr": reqnbrParam,
          "vhcid": vhcidParam,
          "userid": userid,
          "status": statusParam,
        },
      );
      print(myUri.toString());
      var response = await http
          .get(myUri, headers: {"Accept": "application/json"})
          .timeout(Duration(seconds: 30));

      print("CloseData HTTP ${response.statusCode}");//
      print("CloseData body: ${response.body}");

      if (response.statusCode != 200) {
        alert(globalScaffoldKey.currentContext!, 0,
            "SERVER ERROR (${response.statusCode})", "Failed");
        return "Failed";
      }

      var jsonData = json.decode(response.body);
      print(jsonData);
      print(jsonData['status_code']);
      var statusCode = int.tryParse(jsonData['status_code'].toString()) ?? 500;
      if (statusCode == 200) {
        alert(globalScaffoldKey.currentContext!, 1, jsonData['message'],
            "Success");
        await getJSONData();
      } else {
        alert(
            globalScaffoldKey.currentContext!, 0, jsonData['message'], "Failed");
      }
    } catch (e) {
      print("CloseData error: $e");
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return "Successfull";
  }

  Widget _buildListView(BuildContext context) {
    final filteredData = _filteredData;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari Req NBR / VHCID',
              prefixIcon: Icon(Icons.search, color: Colors.deepOrangeAccent),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: getJSONData,
            child: filteredData.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      SizedBox(height: 80),
                      Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'Tidak ada data'
                              : 'Data tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      //_controllers[index] = new TextEditingController();
                      return _buildDMSMenu(filteredData[index], index);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: false, forceWebView: true, enableJavaScript: true);
    } else {
      throw 'Cant open URL';
    }
  }

  Widget _buildDMSMenu(dynamic value, int index) {
    //print(value["drvid"]);
    return Card(
      shape: RoundedRectangleBorder(
        //<-- SEE HERE
        side: BorderSide(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        children: <Widget>[
          new Container(
            padding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 10),
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
                  "Req NBR : ${value['reqnbr']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("Req Date: ${value['req_datetime']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Vhcid: ${value['vhcid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Note : ${value['notes']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Driver Name : ${value['drvname']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("Locid : ${value['locid']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          new Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.pin_drop,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text("View Maps",style: TextStyle(color:Colors.white)),
                  onPressed: () async {
                    print(value['latlon']);
                    var arrData = value['latlon'].toString().split(",");
                    if (arrData.length > 0) {
                      print(arrData[1]);
                      print(arrData[2]);
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Location Maps"),
                          actions: <Widget>[
                            new TextButton(
                                onPressed: () async {
                                  Navigator.of(globalScaffoldKey.currentContext!)
                                      .pop(false);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    prefs.setString("view_lat", arrData[1]);
                                    prefs.setString("view_lon", arrData[2]);
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewMaps()));
                                },
                                child: new Text('Tetap disini')),
                            new TextButton(
                              onPressed: () async {
                                //_tabController.animateTo(0);
                                Navigator.of(globalScaffoldKey.currentContext!)
                                    .pop(false);
                                // var urlBw =
                                //     "https://maps.google.com/maps?q=${arrData[1]},${arrData[2]}&amp;amp;t=m&amp;amp;hl=en";
                                // _openURL(urlBw);
                                Share.share('https://www.google.com/maps?q=${arrData[1]},${arrData[2]}&amp;t=m&amp;hl=en');
                              },
                              child: new Text('Share link'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Data latitude/ longitude tidak di temukan", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text("Proses",style: TextStyle(color:Colors.white)),
                  onPressed: () async {
                    print(value['latlon']);
                    var reqnbr = value['reqnbr'].toString();
                    var vhcid = value['vhcid'].toString();
                    if (reqnbr != null && reqnbr != '') {
                      print(reqnbr);
                      print(vhcid);
                      await showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Proses this data?"),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: new Text('No'),
                            ),
                            new TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                await CloseData(reqnbr, vhcid, 'CLOSE');
                              },
                              child: new Text('Ok'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Data latitude/ longitude tidak di temukan", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
              ])),
          new Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 5),
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text("Cancel",style: TextStyle(color:Colors.white)),
                  onPressed: () async {
                    print(value['latlon']);
                    var reqnbr = value['reqnbr'].toString();
                    var vhcid = value['vhcid'].toString();
                    if (reqnbr != null && reqnbr != '') {
                      print(reqnbr);
                      print(vhcid);
                      await showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Cancel this data?"),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: new Text('No'),
                            ),
                            new TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                                await CloseData(reqnbr, vhcid, 'CANCEL');
                              },
                              child: new Text('Ok'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Data req Number tidak di temukan", "error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )),
              ])),
        ],
      ),
    );
  }

  @override
  void initState() {
    getJSONData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
