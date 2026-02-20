import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmAttendanceAdvance.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewDetailCuti extends StatefulWidget {
  @override
  _ViewDetailCutiState createState() => _ViewDetailCutiState();
}

class _ViewDetailCutiState extends State<ViewDetailCuti> {
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> dataListDetail = [];
  TextEditingController _txtSearch = new TextEditingController();
  TextEditingController _txtSearchDetail = new TextEditingController();
  final List<String> r_rejected = ['REJECTED'];
  final List<String> r_approved = ['APPROVED'];
  var isDetail = true;
  var _oneValue = '';
  var employeeid = '';
  var kryname = '';
  var username = '';

  _goBack(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => FrmAttendanceAdvance()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        },
        child: Scaffold(
          key: globalScaffoldKey,
          backgroundColor: Colors.blueAccent,
          appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 20.0,
                onPressed: () {
                  _goBack(context);
                },
              ),
              centerTitle: true,
              title: Text(
                  'Nama ${kryname != null && kryname != '' ? kryname : ''}')),
          body: Container(
            constraints: BoxConstraints.expand(),
            color: HexColor("#f0eff4"),
            child: Stack(
              children: <Widget>[
                _buildListViewCuti(context),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (isDetail == false) ...[
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Cancel"),
                    onPressed: () async {
                      setState(() {
                        isDetail = true;
                        employeeid = '';
                        kryname = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.orangeAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Submit"),
                    onPressed: () async {
                      print(listChecklistValueCHK);
                      if (listChecklistValueCHK == null ||
                          listChecklistValueCHK.length == 0) {
                        alert(globalScaffoldKey.currentContext!, 0,
                            "Data belum ada yang dipilih", "error");
                      } else {
                        var isValid = true;
                        for (var i = 0; i < listChecklistValueCHK.length; i++) {
                          if (listChecklistValueCHK[i] == '' ||
                              listChecklistValueCHK[i] == null) {
                            isValid = false;
                            break;
                          }
                          if (!listChecklistValueCHK[i].contains("rejected") &&
                              !listChecklistValueCHK[i].contains("approved")) {
                            isValid = false;
                            break;
                          }
                        }
                        if (isValid == false) {
                          alert(globalScaffoldKey.currentContext!, 0,
                              "Beberapa data belum di pilih", "error");
                        } else {
                          print(listChecklistValueCHK);
                          print(listChecklistValueCHK.join(","));
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              title: new Text('Information'),
                              content: new Text("Submit data?"),
                              actions: <Widget>[
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Cancel"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.orangeAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                new SizedBox(width: 10),
                                new ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text("Ok"),
                                  onPressed: () async {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    print('SUbmited');
                                    await ApprovedOrRejected(true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ))
                ]
              ],
            ),
          ),
        ));
  }

  Future getListData(bool isload, String search) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/absensi/get_list_cuti.jsp?method=list-cuti-absensi&search=" +
              search);
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataList = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data list cuti",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data cuti",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future ApprovedOrRejected(bool isload) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();
      SharedPreferences prefs =
      await SharedPreferences.getInstance();
      var userid = prefs.getString("username");
      var str_id_access = listChecklistValueCHK.join(",");
      var urlData = Uri.parse(
          "${GlobalData.baseUrl}api/absensi/approved_or_rejected.jsp?method=approved-cuti-v1&employeeid=${employeeid}&userid=${userid}&id_access=${str_id_access}");
      //var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = urlData;
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        var status_code = json.decode(response.body)["status_code"];
        var message = json.decode(response.body)["message"];
        if(status_code==200){
          alert(globalScaffoldKey.currentContext!, 1,
              message, "success");
        }else{
          alert(globalScaffoldKey.currentContext!, 0, message, "error");
        }

      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal submit approved",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, submit",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListDataDetail(bool isload, String search) async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      var urlData = "${GlobalData.baseUrl}api/absensi/get_list_cuti.jsp?method=list-cuti-absensi-detail&search=" +
          search;
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        //print(jsonDecode(response.body));
        setState(() {
          dataListDetail = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          if (dataListDetail != null && dataListDetail.length > 0) {
            listChecklistValueCHK = [];
            if (dataListDetail != null && dataListDetail.length > 0) {
              for (var i = 0; i < dataListDetail.length; i++) {
                listChecklistValueCHK
                    .add(dataListDetail[i]['id_access'].toString());
              }
              print(listChecklistValueCHK);
            }
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data list cuti detail", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data cuti",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget listDataDetailCutiPersonal(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: dataListDetail == null ? 0 : dataListDetail.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailCutiPersonal(
                        dataListDetail[index], index);
                  })),
        ],
      ),
    );
  }

  List listChecklistValueCHK = [];
  String? _selectedId;
  late StateSetter _setState;
  void _onValueChange(String? value) {
    setState(() {
      _selectedId = value;
    });
  }

  Widget _buildDListDetailCutiPersonal(dynamic item, int index) {
    String id_access = item['id_access'].toString();
    print('id_acces ${id_access}');
    return Card(
      elevation: 20.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),

      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )),
            child: Container(
              // decoration: BoxDecoration(color: Colors.blue,
              //     // borderRadius: const BorderRadius.only(
              //     //   bottomLeft: Radius.circular(10.0),
              //     //   bottomRight: Radius.circular(10.0),
              //     // )
              // ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                subtitle: Wrap(children: <Widget>[
                  Text(
                      "ID Access : ${item['id_access']}"
                      "\n\nTanggal Cuti : ${item['cuti_date']}",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ]),
              ),
            ),
          ),
          Container(
              child: Container(
                  child: Column(
            children: <Widget>[
              new RadioListTile(
                title: Text("Rejected"),
                value: "rejected$id_access",
                groupValue: listChecklistValueCHK[index],
                onChanged: (v) {
                  //print(listChecklistValueCHK[index]);

                  listChecklistValueCHK[index] = v;
                  _onValueChange(v as String?);
                  print(listChecklistValueCHK);
                },
              ),
              new RadioListTile(
                title: Text("Approved"),
                value: "approved$id_access",
                groupValue: listChecklistValueCHK[index],
                onChanged: (v) {
                  //setThis(v);
                  //print(listChecklistValueCHK[index]);
                  listChecklistValueCHK[index] = v;
                  _onValueChange(v as String?);
                },
              ),
            ],
          ))),
        ],
      ),
    );
  }

  Widget listDataDetailCuti(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.all(10.0),
          //   child: TextField(
          //     readOnly: false,
          //     cursorColor: Colors.black,
          //     style: TextStyle(color: Colors.grey.shade800),
          //     controller: _txtSearchDetail,
          //     keyboardType: TextInputType.text,
          //     decoration: new InputDecoration(
          //         suffixIcon: IconButton(
          //           icon: new Image.asset(
          //             "assets/img/search.png",
          //             width: 32.0,
          //             height: 32.0,
          //           ),
          //           onPressed: () async {
          //             if (_txtSearchDetail.text != null &&
          //                 _txtSearchDetail.text != "") {
          //               await getListDataDetail(
          //                   true, _txtSearchDetail.text);
          //             }
          //           },
          //         ),
          //         fillColor: HexColor("FFF6F1BF"),
          //         filled: true,
          //         isDense: true,
          //         labelText: "VHCID",
          //         contentPadding: EdgeInsets.all(5.0),
          //         border: OutlineInputBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          //   ),
          // ),
          Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: dataListDetail == null ? 0 : dataListDetail.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetailCuti(dataListDetail[index], index);
                  })),
        ],
      ),
    );
  }

  Widget _buildDListDetailCuti(dynamic item, int index) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
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
                // title: Text(
                //   "VHCID : ${item['vhcid']}",
                //   style: TextStyle(
                //       color: Colors.black, fontWeight: FontWeight.bold),
                // ),
                subtitle: Wrap(children: <Widget>[
                  Text(
                      "KRRYID  : ${item['kryid']}"
                      "\nNama Karyawan : ${item['nama']}"
                      "\nTgl Pengajuan  : ${item['start_date']} - ${item['end_date']}"
                      "\nCabang : ${item['cabang']}"
                      "\nLast Cuti : ${item['lastcuti']}"
                      "\nNext Cuti : ${item['nextcuti']}"
                      "\nTotal Pengajuan : ${item['total']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding:
                EdgeInsets.only(left: 0, top: 5.0, right: 0.0, bottom: 5.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  label: Text("View Detail"),
                  onPressed: () async {
                    //Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                    setState(() {
                      isDetail = false;
                    });//HR
                    employeeid = item['kryid'];
                    kryname = item['nama'];
                    await getListDataDetail(false, item['kryid']);
                    print('isDetail ${isDetail}');
                    //listDataDetailCutiPersonal
                    // print('NAMA KARYWAN ${item['nama']}');
                    // Timer(Duration(seconds: 1), () {
                    //   showDialog(
                    //       context: globalScaffoldKey.currentContext!,
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           title: Text('List Cuti (${item['nama']})'),
                    //           content: listDataDetailCutiPersonal(context),
                    //           actions: <Widget>[
                    //             new TextButton(
                    //                 onPressed: () {
                    //                   Navigator.of(
                    //                           globalScaffoldKey.currentContext!)
                    //                       .pop(false);
                    //                 },
                    //                 child: new Text('Close')),
                    //           ],
                    //         );
                    //       });
                    // });
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

  Widget _buildListViewCuti(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Container(
          //   margin: EdgeInsets.all(10.0),
          //   child: TextField(
          //     readOnly: false,
          //     cursorColor: Colors.black,
          //     style: TextStyle(color: Colors.grey.shade800),
          //     controller: _txtSearch,
          //     keyboardType: TextInputType.text,
          //     decoration: new InputDecoration(
          //         suffixIcon: IconButton(
          //           icon: new Image.asset(
          //             "assets/img/search.png",
          //             width: 32.0,
          //             height: 32.0,
          //           ),
          //           onPressed: () async {
          //             if (_txtSearch.text != null && _txtSearch.text != "") {
          //               await getListData(true, _txtSearch.text);
          //             }
          //           },
          //         ),
          //         fillColor: HexColor("FFF6F1BF"),
          //         filled: true,
          //         isDense: true,
          //         labelText: "",
          //         contentPadding: EdgeInsets.all(5.0),
          //         border: OutlineInputBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          //   ),
          // ),
          if (isDetail == true) ...[
            Container(
                height: MediaQuery.of(context)
                    .size
                    .height, // Change as per your requirement
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.all(2.0),
                    itemCount: dataList == null ? 0 : dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildDListDetailCuti(dataList[index], index);
                    }))
          ] else ...[
            Container(
                height: MediaQuery.of(context)
                    .size
                    .height, // Change as per your requirement
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.only(top: 2.0,left: 2.0,right: 2.0,bottom: 150.0),
                    itemCount:
                        dataListDetail == null ? 0 : dataListDetail.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildDListDetailCutiPersonal(
                          dataListDetail[index], index);
                    })),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    getListData(true, '');
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }
}
