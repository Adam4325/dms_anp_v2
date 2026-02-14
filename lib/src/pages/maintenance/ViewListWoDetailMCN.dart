import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/FrmWoStart.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoMCN.dart';
import 'package:dms_anp/src/pages/sub_menu_maintenance.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../flusbar.dart';

class ViewListWoDetailMCN extends StatefulWidget {
  @override
  _ViewListWoDetailMCNState createState() => _ViewListWoDetailMCNState();
}

class _ViewListWoDetailMCNState extends State<ViewListWoDetailMCN> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  TextEditingController txtNotes = new TextEditingController();
  dynamic data;
  String status_code = "";
  String message = "";
  String wodwonbr_vhcid = "";

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    wodwonbr_vhcid = prefs.getString("wodwonbr_vhcid") ?? "";
  }

  Future<String?> startWO(String wodwonumber, String loginname, String userid,
      String mechanicid) async {
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      //add-start-detail
      var method = "start";
      if (data != null && data.length > 0) {
        method = "add-start-detail";
      }
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/wo_mcn_start_stop.jsp?method=wo-mcn&act=" +
              method +
              "&wodwonumber=" +
              wodwonumber +
              "&loginname=" +
              loginname +
              "&userid=" +
              userid +
              "&mechanicid=" +
              mechanicid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!!, 1, "${message}", "success");
          getJSONData();
        } else {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          //Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String?> stopWO(String wodwonumber, String loginname, String userid,
      String mechanicid) async {
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/wo_mcn_start_stop.jsp?method=wo-mcn&act=stop" +
              "&wodwonumber=" +
              wodwonumber +
              "&loginname=" +
              loginname +
              "&userid=" +
              userid +
              "&mechanicid=" +
              mechanicid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!!, 1, "${message}", "success");
          //getJSONData();
        } else {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          //Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String?> startWOOld(String wodwonumber, String loginname, String userid,
      String mechanicid) async {
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/wo_mcn_start_stop.jsp?method=wo-mcn&act=start" +
              "&wodwonumber=" +
              wodwonumber +
              "&loginname=" +
              loginname +
              "&userid=" +
              userid +
              "&mechanicid=" +
              mechanicid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!!, 1, "${message}", "success");
          getJSONData();
        } else {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          //Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String?> requestClose(String wodwonumber, String loginname,
      String mechanicid, String notes) async {
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/wo_mcn_start_stop.jsp?method=wo-mcn&act=close-notes" +
              "&wodwonumber=" +
              wodwonumber +
              "&loginname=" +
              loginname +
              "&mechanicid=" +
              mechanicid +
              "&notes=" +
              notes;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!!, 1, "${message}", "success");
          getJSONData();
        } else {
          if (pr?.isShowing() == true) {
            pr?.hide();
          }
          //Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  Future<String> getJSONData() async {
    //EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid") ?? "";
    String locid = prefs.getString("locid") ?? "";
    String mechanicid = prefs.getString("mechanicid") ?? "";
    String wolwonbr = prefs.getString("wodwonbr") ?? "";
    print(drvid);
    var url = "";
    setState(() {
      url =
          "${GlobalData.baseUrl}api/maintenance/list_detail_wo_mcn.jsp?method=list-detail-wo-mcn&mechanicid=" +
              mechanicid.toString() +
              "&wolwonbr=" +
              wolwonbr.toString();
    });
    Uri myUri = Uri.parse(url);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      data = json.decode(response.body)["data"];
      print(data);
      // if (data == null || data.length == 0 || data == "") {
      //   alert(globalScaffoldKey.currentContext!!, 2,
      //       "Anda tidak mempunyai data Work Order", "warning");
      // }
    });
    //EasyLoading.dismiss();
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SubMenuMaintenance()));
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, isDismissible: true);

    pr?.style(
      message: 'Wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        }
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Color(0xFFFF1744),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('Detail List Work Orders')),
        body: new Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              _buildFormSearch(globalScaffoldKey2.currentContext!),
              _buildListView(globalScaffoldKey2.currentContext!),
              _buildFixedButton(globalScaffoldKey2.currentContext!)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 110),
        child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildListData(data[index], index);
            }));
  }

  Widget _buildFixedButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
        child:Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: new Text('Information'),
                  content: new Text("WO Start?"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.red,
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        String _loginname = prefs.getString("loginname") ?? '';
                        String _mechanicid = prefs.getString("drvid") ?? '';
                        String _wodwonbr = prefs.getString("wodwonbr") ?? '';
                        String _userid = prefs.getString("name") ?? '';
                        if (_wodwonbr == "" || _wodwonbr == null) {
                          alert(globalScaffoldKey.currentContext!!, 0,
                              "WOD Number tidak boleh kosong", "error");
                        } else if (_mechanicid == "" || _mechanicid == null) {
                          alert(globalScaffoldKey.currentContext!!, 0,
                              "Mechanic ID tidak boleh kosong", "error");
                        } else if (_loginname == "" || _loginname == null) {
                          alert(globalScaffoldKey.currentContext!!, 0,
                              "LOGIN Name tidak boleh kosong", "error");
                        } else if (_userid == "" || _userid == null) {
                          alert(globalScaffoldKey.currentContext!!, 0,
                              "User ID tidak boleh kosong", "error");
                        } else {
                          Navigator.of(context).pop(false);
                          await startWO(
                              _wodwonbr, _loginname, _userid, _mechanicid);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.blue,
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 5,
            ),
            child: const Text('Start WO', style: TextStyle(fontSize: 14)),
          ),
        )
    );
  }

  Widget _buildFormSearch(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        height: 100.0,
        decoration: new BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xfffdfcfc), const Color(0xfffdfcfc)],
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(15.0))),
        child: new Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 0),
              child: TextField(
                cursorColor: Colors.black,
                controller: txtNotes,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: 'Notes',
                  //fillColor: Colors.black12,
                  //filled: true,
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.only(left: 5, bottom: 11, top: 0, right: 5),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    label: Text("Request Confirmation Close"),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content:
                              new Text("Request Confirmation Close By Note"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("No"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("Ok"),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String _wolwonbr = prefs.getString("wodwonbr") ?? "";
                                String _loginname =
                                    prefs.getString("loginname") ?? "";
                                String _mechanicid = prefs.getString("drvid") ?? "";
                                String _notes = txtNotes.text;
                                if (_wolwonbr == "" || _wolwonbr == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "WO Number tidak boleh kosong", "error");
                                } else if (_mechanicid == "" ||
                                    _mechanicid == null) {
                                  alert(
                                      globalScaffoldKey.currentContext!,
                                      0,
                                      "Mechanic ID tidak boleh kosong",
                                      "error");
                                } else if (_loginname == "" ||
                                    _loginname == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "LOGIN Name tidak boleh kosong", "error");
                                } else if (_notes == "" || _notes == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "Note tidak boleh kosong", "error");
                                } else {
                                  Navigator.of(context).pop(false);
                                  await requestClose(_wolwonbr, _loginname,
                                      _mechanicid, _notes);
                                  txtNotes.text="";
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                ]))
          ],
        ));
  }

  Widget _buildListData(dynamic item, int index) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    var startDate = item["start_date"] != 'null' &&
            item["start_date"] != null &&
            item["start_date"] != ""
        ? dateFormat.parse(item["start_date"]).toString()
        : "";
    var stopDate = item["stop_date"] != 'null' &&
            item["stop_date"] != null &&
            item["stop_date"] != ""
        ? dateFormat.parse(item["stop_date"]).toString()
        : "";
    return new Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 190.0,
        decoration: new BoxDecoration(
            border: Border.all(color: Colors.redAccent),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xfffdfcfc), const Color(0xfffdfcfc)],
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(15.0))),
        child: new Column(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.all(12.0),
              decoration: new BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xfffd3939), const Color(0xffe3023c)],
                  ),
                  borderRadius: new BorderRadius.only(
                      topLeft: new Radius.circular(15.0),
                      topRight: new Radius.circular(15.0))),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("WOD WONUMBER : ${item['wolwonbr']}",
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 12.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("NOPOL : ${wodwonbr_vhcid}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style:
                                TextStyle(color: Colors.black, fontSize: 13)),
                        Text("SEQUENCE : ${item['sequencenbr']}",
                            style:
                                TextStyle(color: Colors.black, fontSize: 13)),
                        Text("START TIME : ${startDate}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(color: Colors.blue, fontSize: 13)),
                        Text("STOP TIME : ${stopDate}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(color: Colors.blue, fontSize: 13)),
                        Text("Note : ${item['notes']}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style:
                                TextStyle(color: Colors.black, fontSize: 13)),
                      ]),
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 12.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 15.0,
                    ),
                    label: Text("Stop WO"),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance(); //SEMENTARA
                      showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                          title: new Text('Information'),
                          content: new Text("Stop Wo?"),
                          actions: <Widget>[
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.close,
                                color: Colors.orange,
                                size: 20.0,
                              ),
                              label: Text("No"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            new ElevatedButton.icon(
                              icon: Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              label: Text("Yes"),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String _loginname =
                                    prefs.getString("loginname") ?? "";
                                String _mechanicid = prefs.getString("drvid") ?? "";
                                String _wodwonbr = item['wolwonbr'] ?? "";
                                String _userid = prefs.getString("name") ?? "";
                                if (_wodwonbr == "" || _wodwonbr == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "WOD Number tidak boleh kosong", "error");
                                } else if (_mechanicid == "" ||
                                    _mechanicid == null) {
                                  alert(
                                      globalScaffoldKey.currentContext!,
                                      0,
                                      "Mechanic ID tidak boleh kosong",
                                      "error");
                                } else if (_loginname == "" ||
                                    _loginname == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "LOGIN Name tidak boleh kosong", "error");
                                } else if (_userid == "" || _userid == null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "User ID tidak boleh kosong", "error");
                                } else if (stopDate != "" && stopDate != null) {
                                  alert(globalScaffoldKey.currentContext!!, 0,
                                      "WO sudah close", "error");
                                } else {
                                  Navigator.of(context).pop(false);
                                  await stopWO(_wodwonbr, _loginname, _userid,
                                      _mechanicid);
                                  getJSONData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  )),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // Expanded(
                  //     child: ElevatedButton.icon(
                  //   icon: Icon(
                  //     Icons.save,
                  //     color: Colors.white,
                  //     size: 15.0,
                  //   ),
                  //   label: Text("Start WO"),
                  //   onPressed: () async {
                  //     SharedPreferences prefs =
                  //         await SharedPreferences.getInstance(); //SEMENTARA
                  //     showDialog(
                  //       context: context,
                  //       builder: (context) => new AlertDialog(
                  //         title: new Text('Information'),
                  //         content: new Text("WO Start?"),
                  //         actions: <Widget>[
                  //           new ElevatedButton.icon(
                  //             icon: Icon(
                  //               Icons.close,
                  //               color: Colors.white,
                  //               size: 20.0,
                  //             ),
                  //             label: Text("No"),
                  //             onPressed: () {
                  //               Navigator.of(context).pop(false);
                  //             },
                  //             style: ElevatedButton.styleFrom(
                  //                 elevation: 0.0,
                  //                 backgroundColor: Colors.red,
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: 10, vertical: 10),
                  //                 textStyle: TextStyle(
                  //                     fontSize: 10,
                  //                     fontWeight: FontWeight.bold)),
                  //           ),
                  //           new ElevatedButton.icon(
                  //             icon: Icon(
                  //               Icons.navigate_next,
                  //               color: Colors.white,
                  //               size: 20.0,
                  //             ),
                  //             label: Text("Ok"),
                  //             onPressed: () async {
                  //               SharedPreferences prefs =
                  //                   await SharedPreferences.getInstance();
                  //               String _loginname =
                  //                   prefs.getString("loginname");
                  //               String _mechanicid = prefs.getString("drvid");
                  //               String _wodwonbr = item['wodwonbr'];
                  //               String _userid = prefs.getString("name");
                  //               if (_wodwonbr == "" || _wodwonbr == null) {
                  //                 alert(globalScaffoldKey.currentContext!!, 0,
                  //                     "WOD Number tidak boleh kosong", "error");
                  //               } else if (_mechanicid == "" ||
                  //                   _mechanicid == null) {
                  //                 alert(
                  //                     globalScaffoldKey.currentContext!,
                  //                     0,
                  //                     "Mechanic ID tidak boleh kosong",
                  //                     "error");
                  //               } else if (_loginname == "" ||
                  //                   _loginname == null) {
                  //                 alert(globalScaffoldKey.currentContext!!, 0,
                  //                     "LOGIN Name tidak boleh kosong", "error");
                  //               } else if (_userid == "" || _userid == null) {
                  //                 alert(globalScaffoldKey.currentContext!!, 0,
                  //                     "User ID tidak boleh kosong", "error");
                  //               } else {
                  //                 Navigator.of(context).pop(false);
                  //                 await startWO(_wodwonbr, _loginname, _userid,
                  //                     _mechanicid);
                  //               }
                  //             },
                  //             style: ElevatedButton.styleFrom(
                  //                 elevation: 0.0,
                  //                 backgroundColor: Colors.blue,
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: 10, vertical: 10),
                  //                 textStyle: TextStyle(
                  //                     fontSize: 10,
                  //                     fontWeight: FontWeight.bold)),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //       elevation: 0.0,
                  //       backgroundColor: Colors.red,
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //       textStyle: TextStyle(
                  //           fontSize: 10, fontWeight: FontWeight.bold)),
                  // )),
                ],
              ),
            )
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    //EasyLoading.init();
    //configLoading();
    this.getJSONData();
    setState(() {
      getSession();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
