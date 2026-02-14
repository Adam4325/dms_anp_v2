import 'package:dio/dio.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWo.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoNew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../flusbar.dart';

List dataSRType = [];
List dataStaffMCN = [];
List dataForemanMCN = [];
List dataListvehicle = [];
TextEditingController txtSR = new TextEditingController();
TextEditingController txtMechanic1 = new TextEditingController();
TextEditingController txtMechanic2 = new TextEditingController();
TextEditingController txtForeman = new TextEditingController();
TextEditingController txtVehicle = new TextEditingController();
int isMCN = 0;

class _BottomSheetContentVehicle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                "List Vehicle",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dataForemanMCN == null ? 0 : dataForemanMCN.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      GlobalData.vehicle_mcn_id =
                          dataListvehicle[index]['value'].toString();
                      txtForeman.text =
                          dataListvehicle[index]['title'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text("${dataForemanMCN[index]['title']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentStaff extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height:30,
            child: Center(
              child: Text(
                "List Mechanic Staff",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dataStaffMCN == null ? 0 : dataStaffMCN.length,
              itemBuilder: (context, index) {
                // var icon = new Image.asset("assets/img/no-image.jpg",
                //     height: 30.00, width: 30.00);

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (isMCN == 0) {
                        GlobalData.mcn_id1 =
                            dataStaffMCN[index]['mechanicid'].toString();
                        txtMechanic1.text =
                            dataStaffMCN[index]['mechanicname'].toString();
                      } else {
                        GlobalData.mcn_id2 =
                            dataStaffMCN[index]['mechanicid'].toString();
                        txtMechanic2.text =
                            dataStaffMCN[index]['mechanicname'].toString();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${dataStaffMCN[index]['mechanicname']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetContentForeman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                "List Mechanic Foreman",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dataForemanMCN == null ? 0 : dataForemanMCN.length,
              itemBuilder: (context, index) {
                // var icon = new Image.asset("assets/img/no-image.jpg",
                //     height: 30.00, width: 30.00);

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      GlobalData.foreman_mcn_id =
                          dataForemanMCN[index]['mechanicid'].toString();
                      txtForeman.text =
                          dataForemanMCN[index]['mechanicname'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        //leading: icon,
                        title: Text("${dataForemanMCN[index]['mechanicname']}"),
                      ),
                    ));
                // return ListTile(
                //   title: Text("Demo ${index}"),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FrmWoStartNew extends StatefulWidget {
  @override
  _FrmWoStartNewState createState() => _FrmWoStartNewState();
}

class _FrmWoStartNewState extends State<FrmWoStartNew> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtVHCID = new TextEditingController();
  TextEditingController txtDRIVER = new TextEditingController();
  TextEditingController txtNOTES = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  String status_code = "";
  String message = "";
  String vhcid = "";
  String locid = "";
  String userid = "";
  String loginname = "";
  String drvid = "";
  String wodwonbr = "";
  String wodsvcrreqnbr = "";

  Future getListMechanicStaff() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/refferencce_mcn.jsp?method=mechanic-list&jabatan=STAFF");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    dataStaffMCN = json.decode(response.body)["data"];
    print(dataStaffMCN);
      if (dataStaffMCN.length == 0 && dataStaffMCN == []) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Gagal Load data Staff Mechanic", "error");
      }
    }
  }

  Future getListMechanicForeman() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/maintenance/refferencce_mcn.jsp?method=mechanic-list&jabatan=FOREMAN");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    dataForemanMCN = json.decode(response.body)["data"];
    print(dataForemanMCN);
      if (dataForemanMCN.length == 0 && dataForemanMCN == []) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Gagal Load data Foreman Mechanic", "error");
      }
    }
  }

  Future getListVehicle() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/gt/list_vehicle.jsp?method=lookup-vehicle-v1");
    print(myUri.toString());
    var response =
    await http.get(myUri, headers: {"Accept": "application/json"});

    dataListvehicle = json.decode(response.body);
    print(dataListvehicle);
      if (dataListvehicle.length == 0 && dataListvehicle == []) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Gagal Load data vehicle", "error");
      }
    }
  }

  Future<void> getApiKm() async {
    if (vhcid != null) {
      print('getApiKM');
      var urlData =
          "${GlobalData.baseUrl}api/get_km_by_vehicle.jsp?method=km_vehicle&vhcid=" +
              vhcid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        // Get the JSON data
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          txtKM.text = json.decode(response.body)["km"];
        }
      });
    }
  }

  Future<String> saveWo(
      String vhcid,
      String srnumber,
      String wodwonumber,
      String vhckm,
      String loginname,
      String userid,
      String mechanic1,
      String mechanic2,
      String mechanic3,
      String notes) async {
    if (pr!.isShowing() == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/wo_start.jsp?method=create-wo&act=add" +
              "&vhcid=" +
              vhcid +
              "&srnumber=" +
              srnumber +
              "&wodwonumber=" +
              wodwonumber +
              "&vhckm=" +
              vhckm +
              "&userid=" +
              userid +
              "&notes=" +
              notes +
              "&loginname=" +
              loginname +
              "&mechanic1=" +
              mechanic1 +
              "&mechanic2=" +
              mechanic2 +
              "&mechanic3=" +
              mechanic3;

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
          if (pr!.isShowing()) {
            pr?.hide();
          }
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 1, "${message}", "success");
          }
          Timer(Duration(seconds: 1), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ViewListWo()));
          });
        } else {
          if (pr!.isShowing()) {
            pr?.hide();
          }
          Navigator.of(context).pop(false);
          final ctx = globalScaffoldKey.currentContext;
          if (ctx != null) {
            alert(ctx, 0, "${message}", "error");
          }
        }
      });
      return message;
    } catch (e) {
      if (pr!.isShowing()) {
        await pr?.hide();
      }
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Internal Server Error", "error");
      }
      print(e);
      return "error";
    }
  }

  void _showModalListVehicle(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentVehicle();
      },
    );
  }

  void _showModalListStaff(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentStaff();
      },
    );
  }

  void _showModalListForeman(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContentForeman();
      },
    );
  }

  void getSession() async {
    //SEMENTARA
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vhcid = prefs.getString("vhcid_mcn") ?? "";
    drvid = prefs.getString("drvid") ?? "";
    locid = prefs.getString("locid") ?? "";
    userid = prefs.getString("name") ?? "";
    loginname = prefs.getString("loginname") ?? "";
    wodwonbr = prefs.getString("wodwonbr") ?? "";
    wodsvcrreqnbr = prefs.getString("wodsvcrreqnbr") ?? "";
    txtVHCID.text = vhcid;
    txtDRIVER.text = userid;
    getApiKm();
  }

  @override
  void initState() {
    super.initState();
    getListMechanicStaff();
    getListMechanicForeman();
    setState(() {
      txtMechanic1.text = "Silahkan Mechanic 1";
      txtMechanic2.text = "Silahkan Mechanic 2";
      txtForeman.text = "Silahkan click untuk pilih Foreman";
      getSession();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
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
    return new Scaffold(
      backgroundColor: Colors.grey,
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
          title: Text('Form Worked Order')),
      body: Container(
        key: globalScaffoldKey,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            _getContent(context),
          ],
        ),
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 0.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 0),
                    child: Text("WOD NUMBER : ${wodwonbr==null?'':wodwonbr}",
                        style: TextStyle(fontSize: 14)),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("WOD SERVICE NUMBER : ${wodsvcrreqnbr==null?'':wodsvcrreqnbr}",
                        style: TextStyle(fontSize: 14)),
                  ),
                  Divider(
                    color: Colors.red,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("VEHICLE", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtVehicle,
                      // onTap: () {
                      //   _showModalListVehicle(context);
                      // },
                      decoration: new InputDecoration(
                        fillColor: HexColor("#FFF6F1BF"),
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("MECHANIC 1", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtMechanic1,
                      onTap: () {
                        isMCN = 0;
                        _showModalListStaff(context);
                      },
                      decoration: new InputDecoration(
                        fillColor: HexColor("#FFF6F1BF"),
                        filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("MECHANIC 2", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtMechanic2,
                      onTap: () {
                        isMCN = 1;
                        _showModalListStaff(context);
                      },
                      decoration: new InputDecoration(
                        fillColor: HexColor("#FFF6F1BF"),
                        filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("FOREMAN", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtForeman,
                      onTap: () {
                        _showModalListForeman(context);
                      },
                      decoration: new InputDecoration(
                        fillColor: HexColor("#FFF6F1BF"),
                        filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("KM", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtKM,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        //fillColor: Colors.black12, filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Text("NOTES", style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtNOTES,
                      //keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        //fillColor: Colors.black12, filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 5, right: 20, bottom: 5),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 15.0,
                          ),
                          label: Text("Submit"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                title: new Text('Information'),
                                content: new Text("Create Worked Order Start?"),
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
                                        backgroundColor: Colors.blueAccent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  new ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text("Submit"),
                                    onPressed: () async {
                                      String _wodwonbr = wodwonbr;
                                      String _wodsvcrreqnbr = wodsvcrreqnbr;
                                      final ctx = globalScaffoldKey.currentContext;
                                      if (_wodwonbr == "" ||
                                          _wodwonbr == null) {
                                        if (ctx != null) {
                                          alert(ctx, 0, "WOD Number tidak boleh kosong", "error");
                                        }
                                      } else if (_wodsvcrreqnbr == "" ||
                                          _wodsvcrreqnbr == null) {
                                        if (ctx != null) {
                                          alert(ctx, 0, "REQ Number tidak boleh kosong", "error");
                                        }
                                      } else if (vhcid == "" || vhcid == null) {
                                        if (ctx != null) {
                                          alert(ctx, 0, "Vehicle tidak boleh kosong", "error");
                                        }
                                      } else if (GlobalData.mcn_id1 == "") {
                                        if (ctx != null) {
                                          alert(ctx, 0, "Mechanic ID 1 tidak boleh kosong", "error");
                                        }
                                      } else if (txtKM.value.text == "" &&
                                          int.parse(txtKM.value.text) <= 0) {
                                        if (ctx != null) {
                                          alert(ctx, 0, "VHCKM tidak boleh kosong", "error");
                                        }
                                      } else if (userid == "") {
                                        if (ctx != null) {
                                          alert(ctx, 0, "USER ID tidak boleh kosong", "error");
                                        }
                                      } else {
                                        Navigator.of(context).pop(false);
                                        print('SAVE WO----');
                                        print(vhcid);
                                        print(_wodwonbr); // wodwonumber
                                        print(_wodsvcrreqnbr); //srnumber
                                        print(txtKM.text);
                                        print(userid);
                                        print(loginname);
                                        print(GlobalData.mcn_id1);
                                        print(txtMechanic1.text);
                                        print(GlobalData.mcn_id2);
                                        print(txtMechanic2.text);
                                        print(GlobalData.foreman_mcn_id);
                                        print(txtForeman.text);
                                        print(txtNOTES.text);
                                        await saveWo(
                                            vhcid,
                                            _wodsvcrreqnbr,
                                            _wodwonbr,
                                            txtKM.value.text,
                                            loginname,
                                            userid,
                                            GlobalData.mcn_id1,
                                            GlobalData.mcn_id2,
                                            GlobalData.foreman_mcn_id,
                                            txtNOTES.text);
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
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              textStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        )),
                        SizedBox(width: 10,),
                        Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 15.0,
                              ),
                              label: Text("List Wo"),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewListWoNew()));
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold)),
                            )),
                      ]))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
