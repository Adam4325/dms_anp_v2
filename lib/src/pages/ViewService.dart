import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/vehicle/ViewListVehicleNew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../flusbar.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;

List dataSRType = [];
TextEditingController txtSR = new TextEditingController();

class _BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Center(
              child: Text(
                "List Type Service",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dataSRType == null ? 0 : dataSRType.length,
              itemBuilder: (context, index) {
                var icon = new Image.asset("assets/img/no-image.jpg",
                    height: 30.00, width: 30.00);
                var srType =
                    dataSRType[index]['id'].toString().replaceAll("\\s", "");
                if (srType == "BODY-REPAIRE" || srType == "BODY - REPAIRE") {
                  icon = new Image.asset('assets/img/body-repair.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "BOOKING") {
                  icon = new Image.asset('assets/img/booking.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "BAN-VELG" || srType == "BAN - VELG") {
                  icon = new Image.asset('assets/img/ban.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "REPAIR") {
                  icon = new Image.asset('assets/img/repair.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "KELENGKAPAN") {
                  icon = new Image.asset('assets/img/kelengkapan.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "SERVICE") {
                  icon = new Image.asset('assets/img/service.png',
                      height: 30.00, width: 30.00);
                } else if (srType == "STORING") {
                  icon = new Image.asset('assets/img/storing.png',
                      height: 30.00, width: 30.00);
                } else {
                  icon = new Image.asset("assets/img/no-image.jpg",
                      height: 30.00, width: 30.00);
                }

                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      GlobalData.servicetype =
                          dataSRType[index]['id'].toString();
                      txtSR.text = dataSRType[index]['text'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: icon,
                        title: Text("${dataSRType[index]['text']}"),
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

class ViewService extends StatefulWidget {
  @override
  _ViewServiceState createState() => _ViewServiceState();
}

class _ViewServiceState extends State<ViewService> {
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
  String drvid = "";

  Future getListSR() async {
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/do/refference_master.jsp?method=list_typeservice");
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    dataSRType = json.decode(response.body);
    print(dataSRType);
    if (dataSRType.length == 0 && dataSRType == []) {
      alert(globalScaffoldKey.currentContext!, 0, "Gagal Load data Type Service",
          "error");
    }
  }

  Future<String> getApiKm() async {
    String _km = "0";
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
          _km = json.decode(response.body)["km"];
        }
      });
    }
    return _km;
  }
  Future<String?> UpdateReceiveLogDo() async{
    try {
      //String _photo = photo!=null && photo!=""?photo.toString().trim():"";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var drVID = prefs.getString("drvid");
      String vhCID = prefs.getString("vhcidfromdo")!;
      String name_event = prefs.getString("name_event")!;
      var dataParam = {
        "method": "update-or-insert-log",
        "drvid": drVID.toString(),
        "vhcid": vhCID.toString(),
        "name_event": name_event,
        "is_used": "0"
      };
      var urlData =
          "${GlobalData.baseUrl}api/log_receive_do.jsp";

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      final response = await http.post(
        myUri,
        body: dataParam,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
      );
    }
    catch(e){
      print(e);
    }
  }

  Future<bool> closeAntrian(String vhcid, String loginname) async {
    bool isClosed = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name_event = prefs.getString("name_event")!;
    String driver_id = prefs.getString("drvid")!;
    String bujnumber = prefs.getString("bujnumber")!;
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/create_antrian_service.jsp?method=service&vhcid=" +
              vhcid +
              "&loginname=" +
              loginname+"&name_event="+name_event+"&drvid=${driver_id}&bujnumber=${bujnumber}";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        print("int.parse(status_code) ${int.parse(status_code)}");
        if (int.parse(status_code) == 200) {
          isClosed = true;
          if (pr!.isShowing()) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
        } else {
          if (pr!.isShowing()) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (pr!.isShowing()) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error",
          "error");
      print(e);
    }
    return isClosed;
  }

  void ResetData() {
    setState(() {
      globals.p2hVhcid = "";
      globals.p2hVhclocid = "";
      globals.p2hVhcdate = "";
      globals.p2hVhckm = 0;
      globals.p2hVhcdefaultdriver = "";
      globals.pages_name =
          globals.pages_name == "view-service" ? globals.pages_name : "";
      globals.p2hDriverName = "";

      globals.page_inspeksi = "";
      globals.rvhcOil = null;
      globals.rvhcOliMesin = null;
      globals.rvhcOliGardan = null;
      globals.rvhcOliTransmisi = null;
      globals.rvhcAir = null;
      globals.rvhcAccu = null;
      globals.rvhcOLips = null;
      globals.rvhcMrem = null;

      globals.p2hVhcid = null;
      globals.p2hVhckm = 0.0;
      globals.p2hVhcdate = null;
      globals.p2hVhcdefaultdriver = null;

      //KABIN
      globals.rvhcKabin = null;
      globals.rvhcKaca = null;
      globals.rvhcSpion = null;
      globals.rvhcSpeedo = null;
      globals.rvhcWiper = null;
      globals.rvhcKlak = null;
      globals.rvhcJok = null;
      globals.rvhcSeatBealt = null;
      globals.rvhcApar = null;
      globals.rvhcP3k = null;
      globals.rvhcCone = null;
      globals.rvhcStikerRef = null;

      //ELECTTRIC
      globals.rvhcLampd = null;
      globals.rvhcLamps = null;
      globals.rvhcLampBlk = null;
      globals.rvhcLampr = null;
      globals.rvhcLampm = null;
      globals.rvhcLampAlarm = null;

      //CHASIS
      globals.rvhcKopling = null;
      globals.rvhcGardan = null;
      globals.rvhcParking = null;
      globals.rvhcFoot = null;
      globals.rvhcBautRoda = null;
      globals.rvhcVelg = null;

      //BAN
      globals.rvhcBan = null;
      globals.rvhcAngin = null;

      //PERALATAN
      globals.rvhcTerpal = null;
      globals.rvhcWebing = null;
      globals.rvhcTambang = null;
      globals.rvhcDongkrak = null;
      globals.rvhcKRoda = null;
      globals.rvhcGBan = null;
      globals.rvhcGps = null;
      globals.rvhcDashCam = null;

      //DOCUMENT
      globals.rvhcSurat = null;
      globals.rvhcKir = null;
      globals.rvhcSim = null;

      globals.rvhcNotes = "";

      globals.vhcposisiban1 = 0;
      globals.vhcposisiban2 = 0;
      globals.vhcposisiban3 = 0;
      globals.vhcposisiban4 = 0;
      globals.vhcposisiban5 = 0;
      globals.vhcposisiban6 = 0;
      globals.vhcposisiban7 = 0;
      globals.vhcposisiban8 = 0;
      globals.vhcposisiban9 = 0;
      globals.vhcposisiban10 = 0;
      globals.vhcposisiban11 = 0;
      globals.vhcposisiban12 = 0;
      globals.vhcposisiban13 = 0;
      globals.vhcposisiban14 = 0;
      globals.vhcposisiban15 = 0;
      globals.vhcposisiban16 = 0;
      globals.vhcposisiban17 = 0;
      globals.vhcposisiban18 = 0;
      globals.vhcposisiban19 = 0;
      globals.vhcposisiban20 = 0;
      globals.vhcposisiban21 = 0;
      globals.vhcposisiban22 = 0;
      globals.vhcposisiban23 = 0;
      globals.vhcposisiban24 = 0;
    });
  }

  Future<String?> saveService(
      String vhcid,
      String locid,
      String drvid,
      String vhckm,
      String userid,
      String notes,
      String loginname,
      String typereq) async {
    if (pr?.isShowing() == false) {
      await pr?.show();
    }
    try {
      // var urlData =
      //     "${GlobalData.baseUrl}api/maintenance/req_service.jsp?method=set-service&vhcid=" +
      //         vhcid +
      //         "&locid=" +
      //         locid +
      //         "&drvid=" +
      //         drvid +
      //         "&vhckm=" +
      //         vhckm +
      //         "&userid=" +
      //         userid +
      //         "&notes=" +
      //         notes +
      //         "&loginname=" +
      //         loginname +
      //         "&typereq=" +
      //         typereq;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String bujnumber = prefs.getString("bujnumber")!;
      var notes  =txtNOTES.text;

      var urlData = "${GlobalData.baseUrl}api/maintenance/req_service.jsp?method=set-service-v1"+
      "&vhcid=${vhcid}&locid=${locid}&drvid=${drvid}&vhckm=${vhckm}&vhckm=${vhckm}"
          "&typereq=${typereq}&userid=${userid}&dlodate=&notes=${notes}&bujnumber=${bujnumber}";

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      // var dataParam = {
      //   "method": "set-service-v1",
      //   "vhcid": vhcid,
      //   "locid": locid,
      //   "drvid": drvid,
      //   "vhckm": vhckm,
      //   "typereq": typereq,
      //   "dlodate": ""
      // };
      //print(dataParam);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      // final response = await http.post(
      //   myUri,
      //   body: dataParam,
      //   headers: {
      //     "Content-Type": "application/x-www-form-urlencoded",
      //   },
      //   encoding: Encoding.getByName('utf-8'),
      // );
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (pr!.isShowing()) {
            pr?.hide();
          }
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          Timer(Duration(seconds: 1), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
        } else {
          if (pr!.isShowing()) {
            pr?.hide();
          }
          Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
        if (int.parse(status_code) == 403) {
          //CLOSE ANTRIAN
          alert(context, 2, "${message}", "warning");

          showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              content: new Text("Close Antrian ${vhcid}"),
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
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("Submit"),
                  onPressed: () async {
                    print(vhcid);
                    if (vhcid == "" || vhcid == null) {
                      alert(globalScaffoldKey.currentContext!, 0,
                          "Vehicle tidak boleh kosong", "error");
                    }
                    // else if (globals.rvhcOLips == null) {
                    //   alert(globalScaffoldKey.currentContext!, 0,
                    //       "Form Inspeksi tidak boleh kosong", "error");
                    // }
                    else {
                      if (pr!.isShowing()) {
                        pr?.hide();
                      }
                      Navigator.of(context).pop(false);
                      await closeAntrian(vhcid, loginname);
                      await UpdateReceiveLogDo();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          //END CLOSE
        }
      });
    } catch (e) {
      if (pr!.isShowing()) {
        await pr?.hide();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error",
          "error");
      print(e);
    }
  }

  void _showModalListSR(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContent();
      },
    );
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (globals.pages_name == "view-service") {
      vhcid = globals.p2hVhcid!;
      drvid = globals.p2hVhcdefaultdriver!;
      locid = globals.p2hVhclocid!;
      userid = globals.p2hDriverName!;
      txtKM.text = globals.p2hVhckm.toString();
    } else {
      vhcid = prefs.getString("vhcidfromdo")!;
      //vhcid = 'B 9565 YM';
      drvid = prefs.getString("drvid")!;
      locid = prefs.getString("locid")!;
      userid =
          globals.pages_name == "view-service" ? "" : prefs.getString("name")!;
      String km = prefs.getString("km_new")!;
      txtKM.text =
          km.toString() == null || km.toString() == '' ? '0' : km.toString();
    }

    txtVHCID.text = vhcid;
    txtDRIVER.text = userid;
  }

  @override
  void initState() {
    super.initState();
    getListSR();
    setState(() {
      txtSR.text = "Silahkan click untuk pilih type Service";
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
    pr = new ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);

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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: new Scaffold(
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
            title: Text('Form Service')),
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
                children: <Widget>[
                  ListTile(
                      title: Text("VHCID", style: TextStyle(fontSize: 12))),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtVHCID,
                      onTap: () {
                        var isOK = globals.akses_pages == null
                            ? globals.akses_pages
                            : globals.akses_pages.where((x) => x == "OP");
                        if (isOK != null) {
                          if (isOK.length > 0) {
                            globals.pages_name = "view-service";
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewListVehicleNew()));
                          }
                        }
                      },
                      decoration: new InputDecoration(
                        hintText: globals.pages_name == "view-service"
                            ? "klick for view list vehicle"
                            : "",
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  ListTile(
                      title: Text("DRIVER", style: TextStyle(fontSize: 12))),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtDRIVER,
                      decoration: new InputDecoration(
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  ListTile(
                      title:
                          Text("SERVICE TYPE", style: TextStyle(fontSize: 12))),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtSR,
                      onTap: () {
                        _showModalListSR(context);
                      },
                      decoration: new InputDecoration(
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        //labelText: 'Hello input here',
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 5, top: 5, right: 5),
                      ),
                    ),
                  ),
                  ListTile(title: Text("KM", style: TextStyle(fontSize: 12))),
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
                  ListTile(
                      title: Text("NOTES", style: TextStyle(fontSize: 12))),
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
                                content: new Text(
                                    "Service kendaraan ${txtKM.value.text} ?"),
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
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 12,
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
                                      print(GlobalData.servicetype);
                                      print(txtKM.value.text);
                                      print(vhcid);
                                      if (vhcid == "" || vhcid == null) {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "Vehicle tidak boleh kosong",
                                            "error");
                                      } else if (locid == "" || locid == null) {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "LOCID tidak boleh kosong",
                                            "error");
                                      } else if (drvid == "" || drvid == null) {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "Driver tidak boleh kosong",
                                            "error");
                                      } else if (GlobalData.servicetype == "") {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "Service Name tidak boleh kosong",
                                            "error");
                                      } else if (txtKM.value.text == "" &&
                                          int.parse(txtKM.value.text) <= 0) {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "VHCKM tidak boleh kosong",
                                            "error");
                                      } else if (userid == "") {
                                        alert(
                                            globalScaffoldKey.currentContext!,
                                            0,
                                            "USER ID tidak boleh kosong",
                                            "error");
                                      } else {
                                        await saveService(
                                            vhcid,
                                            locid,
                                            drvid,
                                            txtKM.value.text,
                                            userid,
                                            txtNOTES.value.text,
                                            userid,
                                            GlobalData.servicetype);
                                        ResetData();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                        textStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              textStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
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
