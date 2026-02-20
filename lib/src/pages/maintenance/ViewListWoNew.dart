
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/FrmWoStart.dart';
import 'package:dms_anp/src/pages/maintenance/FrmWoStartNew.dart';
import 'package:dms_anp/src/pages/sub_menu_maintenance.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../flusbar.dart';

class ViewListWoNew extends StatefulWidget {
  @override
  _ViewListWoNewState createState() => _ViewListWoNewState();
}

class _ViewListWoNewState extends State<ViewListWoNew> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  late List data;
  String status_code = "";
  String message = "";

  // Future<String> cancelWO(
  //     String vhcid,
  //     String srnumber, String wodwonumber, String userid) async {
  //   if (pr.isShowing() == false) {
  //     await pr.show();
  //   }
  //   try {
  //     var urlData =
  //         "${GlobalData.baseUrl}api/maintenance/wo_start.jsp?method=create-wo&act=cancel-sr" +
  //             "&vhcid=" +
  //             vhcid +
  //             "&srnumber=" +
  //             srnumber +
  //             "&wodwonumber=" +
  //             wodwonumber +
  //             "&userid=" +
  //             userid;
  //
  //     var encoded = Uri.encodeFull(urlData);
  //     Uri myUri = Uri.parse(encoded);
  //     print(myUri);
  //     var response =
  //     await http.get(myUri, headers: {"Accept": "application/json"});
  //     setState(() {
  //       print(json.decode(response.body));
  //       status_code = json.decode(response.body)["status_code"].toString();
  //       message = json.decode(response.body)["message"];
  //       if (int.parse(status_code) == 200) {
  //         if (pr.isShowing()) {
  //           pr.hide();
  //         }
  //         alert(globalScaffoldKey.currentContext, 1, "${message}", "success");
  //          getJSONData();
  //       } else {
  //         if (pr.isShowing()) {
  //           pr.hide();
  //         }
  //         Navigator.of(context).pop(false);
  //         alert(globalScaffoldKey.currentContext, 0, "${message}", "error");
  //       }
  //     });
  //   } catch (e) {
  //     if (pr.isShowing()) {
  //       await pr.hide();
  //     }
  //     alert(globalScaffoldKey.currentContext, 0, "Internal Server Error",
  //         "error");
  //     print(e);
  //   }
  // }

  Future<String> getJSONData() async {
    //EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid") ?? "";
    String locid = prefs.getString("locid") ?? "";
    String mechanicid = prefs.getString("mechanicid") ?? "";
    print(drvid);
    var url = "";
    setState(() {
      url = "${GlobalData.baseUrl}api/maintenance/list_wo_start.jsp?method=list-wo&locid="+locid.toString()+"&mechanicid="+mechanicid.toString();
    });
    Uri myUri = Uri.parse(url);
    print(myUri.toString());
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      data = json.decode(response.body)["data"];
      print(data);
      if (data == null || data.length == 0 || data == "") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 2, "Anda tidak mempunyai data Work Order", "warning");
        }
      }
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
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('List Work Orders')),
        body: new Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              Builder(
                builder: (context) => _buildListView(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
        onRefresh: getJSONData,
        child:ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildDMSMenuDO(data[index], index);
            })
    );
  }

  Widget _buildDMSMenuDO(dynamic value, int index) {
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
                  "WOD WONUMBER : ${value['wodwonbr']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("NOPOL: ${value['vhcid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("LOCID: ${value['locid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WOD REQ NUMBER : ${value['wodsvcrreqnbr']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WORKED BY :  ${value['wodworkeddby']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WOD START TIME : ${value['wodstartdatetime']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("WOD END TIME : ${value['wodenddatetime']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 5.0, right: 15.0, top: 12.0),
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
                      label: Text("Cancel WO"),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance(); //SEMENTARA
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            title: new Text('Information'),
                            content: new Text(
                                "Cance Wo?"),
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
                              // new ElevatedButton.icon(
                              //   icon: Icon(
                              //     Icons.navigate_next,
                              //     color: Colors.white,
                              //     size: 20.0,
                              //   ),
                              //   label: Text("Cancel Wo"),
                              //   onPressed: () async{
                              //     SharedPreferences prefs = await SharedPreferences.getInstance();
                              //     prefs.setString("vhcid_mcn",value['vhcid']);
                              //     String _vhcid = value['vhcid'];
                              //     String _wodwonbr = value['wodwonbr'];
                              //     String _wodsvcrreqnbr = value['wodsvcrreqnbr'];
                              //     String _userid = prefs.getString("name");
                              //     if (_wodwonbr == "" ||
                              //         _wodwonbr == null) {
                              //       alert(
                              //           globalScaffoldKey.currentContext,
                              //           0,
                              //           "WOD Number tidak boleh kosong",
                              //           "error");
                              //     } else if (_wodsvcrreqnbr == "" ||
                              //         _wodsvcrreqnbr == null) {
                              //       alert(
                              //           globalScaffoldKey.currentContext,
                              //           0,
                              //           "REQ Number tidak boleh kosong",
                              //           "error");
                              //     } else if (_vhcid == "" || _vhcid == null) {
                              //       alert(
                              //           globalScaffoldKey.currentContext,
                              //           0,
                              //           "Vehicle tidak boleh kosong",
                              //           "error");
                              //     }else{
                              //       Navigator.of(context).pop(false);
                              //       // await cancelWO(_vhcid,_wodsvcrreqnbr,_wodwonbr,_userid);
                              //     }
                              //
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //       elevation: 0.0,
                              //       backgroundColor: Colors.blue,
                              //       padding: EdgeInsets.symmetric(
                              //           horizontal: 10, vertical: 0),
                              //       textStyle: TextStyle(
                              //           fontSize: 10,
                              //           fontWeight: FontWeight.bold)),
                              // ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.deepOrangeAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 15.0,
                      ),
                      label: Text("Submit"),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance(); //SEMENTARA
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            title: new Text('Information'),
                            content: new Text(
                                "WO Start?"),
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
                                onPressed: () async{
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  print(value['vhcid']);
                                  prefs.setString("wodwonbr",value['wodwonbr']);
                                  prefs.setString("wodsvcrreqnbr",value['wodsvcrreqnbr']);
                                  prefs.setString("vhcid_mcn",value['vhcid']);
                                  Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (context) => FrmWoStartNew()));
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
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 0),
                          textStyle: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //EasyLoading.init();
    //configLoading();
    this.getJSONData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
