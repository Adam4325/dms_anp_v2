import 'dart:async';
import 'package:dms_anp/src/pages/FrmCreateAntrianNewDriver.dart';
import 'package:dms_anp/src/pages/FrmInspeksiVehicle.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
import 'package:dms_anp/src/pages/maintenance/FrmWoStart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:dms_anp/src/pages/ViewAntrian.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewListDo.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'dart:convert';

import '../flusbar.dart';
import 'ViewAntrianNgepok.dart';
import 'driver/DailyCheckScreenP2H.dart';

class FrmSetKmByDriver extends StatefulWidget {
  @override
  _FrmSetKmByDriverState createState() => _FrmSetKmByDriverState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class _FrmSetKmByDriverState extends State<FrmSetKmByDriver> {
  TextEditingController txtNopol = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  String status_code = "";
  String message = "";
  String _text = "TEXT";

  String loginname = "";
  String drvid = "";
  String locid = "";
  String vhckm = "";
  String dlodetaildonumber = "";
  String vhcid = "";
  String dloorigin = "";
  String dlodestination = "";
  String userid = "";

  bool isNumeric(String? s) {
    if (s == null || s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> _read() async {
    final ctx = globalScaffoldKey.currentContext!;
    if (ctx != null) {
      alert(
        ctx,
        2,
        "Fitur OCR tidak tersedia di versi ini.\nSilakan input KM secara manual.",
        "warning",
      );
    }
  }

  Future<int> getCountHaveDo() async {
    int total = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    vhcid = prefs.getString("vhcidfromdo") ?? "";
    if (vhcid.isNotEmpty) {
      locid = prefs.getString("locid")!;
      String bujnumber = prefs.getString("bujnumber")!;
      var urlData =
          "${GlobalData.baseUrl}api/last_antrian.jsp?method=get-total-do&vhcid=${vhcid}&locid=${locid}&bujnumber=${bujnumber}";

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          var _total = json.decode(response.body)["total"];
          total = _total;
          print('total DO OPEN ${total}');
        }
      });
    }
    return total;
  }

  void updateKM(String vhckm, int isBack) async {
    String km = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SEMENTARA
    print('prefs.getString("vhcidfromdo")${prefs.getString("vhcidfromdo")}');
    vhcid = prefs.getString("vhcidfromdo") ?? "";
    //vhcid = 'B 9189 KYW';
    if (vhcid.isNotEmpty) {
      drvid = prefs.getString("drvid")!;
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", vhcid);
      locid = prefs.getString("locid")!;
      String name = prefs.getString("name")!;
      var urlData =
          "${GlobalData.baseUrl}api/update_km_vehicle.jsp?method=update_vhc&vhcid=" +
              vhcid +
              "&vhckm=" +
              vhckm +
              "&userid=" +
              name +
              "&driverid=" +
              drvid +
              "&locid=" +
              locid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          //SHOW ALERT SUCCESS
          //prefs.remove("bujnumber");
          if (isBack == 0) {
            Timer(Duration(seconds: 1), () {
              // 5s over, navigate to a new page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ViewAntrian()));
            });
          }
          //END ALERT SUCCESS
        } else {
          //alert(context, 0, message.toString(), "error");
          showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              content: new Text("$message"),
              actions: <Widget>[
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  label: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.orange.shade400,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  var dataListVehicle = [];
  void getVehiceldriverBuj() async {
    //get_list_vehicle_driver_buj
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("drvid","0007-03.1997.02.09.68");
    // prefs.setString("bujnumber","ANBU23130626");
    var driver_id = prefs.getString("drvid");
    var bujnumber = prefs.getString("bujnumber");
    print(bujnumber);
    if (bujnumber == null || bujnumber == '') return;
    var urlData =
        "${GlobalData.baseUrl}api/get_list_vehicle_driver_buj.jsp?method=list-vehicle&drvid=${driver_id}&bujnumber=${bujnumber}";
    print(urlData);
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});
    setState(() {
      dataListVehicle = json.decode(response.body);
      print(dataListVehicle);
    });
  }

  void updateKMStandby(
      String bujnumber, BuildContext context, String vhckm, int isBack) async {
    String km = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SEMENTARA
    print('prefs.getString("vhcidfromdo")${prefs.getString("vhcidfromdo")}');
    var _vhcid =
        vhcid == null && vhcid == '' ? prefs.getString("vhcidfromdo") : vhcid;
    //vhcid = 'B 9189 KYW';
    if (_vhcid != null && _vhcid != "") {
      drvid = prefs.getString("drvid")!;
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", _vhcid);
      locid = prefs.getString("locid")!;
      String name = prefs.getString("name")!;
      var urlData =
          "${GlobalData.baseUrl}api/update_km_vehicle.jsp?method=update_vhc-standby&vhcid=" +
              _vhcid +
              "&vhckm=" +
              vhckm +
              "&drvid=" +
              drvid +
              "&bujnumber=" +
              bujnumber;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          //prefs.remove("bujnumber");
          // print(status_code);
          // print(message);
          // //SHOW ALERT SUCCESS
          alert(context, 1, message, "Success");
          Timer(Duration(seconds: 2), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
          //END ALERT SUCCESS
          // Timer(Duration(seconds: 1), () {
          //   // 5s over, navigate to a new page
          //   showDialog(
          //     context: context,
          //     builder: (context) => new AlertDialog(
          //       title: new Text('Information'),
          //       content: new Text(message),
          //       actions: <Widget>[
          //         new ElevatedButton.icon(
          //           icon: Icon(
          //             Icons.close,
          //             color: Colors.white,
          //             size: 20.0,
          //           ),
          //           label: Text("Ok"),
          //           onPressed: () {
          //             Navigator.of(context).pop(false);
          //             Navigator.pushReplacement(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => ViewDashboard()));
          //           },
          //           style: ElevatedButton.styleFrom(
          //               elevation: 0.0,
          //               backgroundColor: Colors.blue,
          //               padding:
          //                   EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          //               textStyle: TextStyle(
          //                   fontSize: 10, fontWeight: FontWeight.bold)),
          //         )
          //       ],
          //     ),
          //   );
          // });
        }
      });
    }
  }

  Future<String?> GetListVehicleDoDiTerima() async {
    String km = "0";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString('drvid')!;
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/do/do_diterima.jsp?method=list-set_vehicle_diterima_apps&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      SharedPreferences prefs =
          await SharedPreferences.getInstance(); //SEMENTARA
      if (response.statusCode == 200) {
        int status_code = jsonDecode(response.body)["status_code"];
        print('status_code ${status_code}');
        if (status_code == 200) {
          var vhcid = "";
          var bujnumber = "";
          setState(() {
            vhcid = jsonDecode(response.body)["vhcid"];
            bujnumber = jsonDecode(response.body)["bujnumber"];
            prefs.setString("vhcidfromdo", vhcid);
            prefs.setString("bujnumber", bujnumber);
          });
          print('vhcid ${vhcid}');
          print('bujnumber ${bujnumber}');
          print('bujnumber get api km ${bujnumber}');
          km = await getApiKm(vhcid, bujnumber);
          print("KM ${km}");
          setState(() {
            txtKMOld.text = km;
          });
          print("KILO METER ${km}");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data do diterima", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      return km;
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load do diterima",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> getApiKm(String vhcid, String bujnumber) async {
    String km = "0";
    SharedPreferences prefs = await SharedPreferences.getInstance(); //SEMENTARA
    // String vhcid = prefs.getString("vhcidfromdo");
    // String bujnumber = prefs.getString("bujnumber");
    String submit_bujnumber = "ok";//prefs.getString("submit_bujnumber");

    //String vhcid = 'B 9565 YM';
    print('submit_bujnumber ${submit_bujnumber}');
    if ((vhcid != null && vhcid != "") &&
        (bujnumber != null && bujnumber != "") &&
        (submit_bujnumber != null &&
            submit_bujnumber != "" &&
            submit_bujnumber == 'ok')) {
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
        String _km = "0";
        _km = json.decode(response.body)["km"];
        if (status_code != null && status_code == "200") {
          km = _km;
        } else {
          km = "0";
        }
      });
    } else {
      alert(
          context,
          2,
          "Silahkan Klik menu terima do terlebih dahulu, dan submit",
          "warning");
    }
    return km;
  }

  Future getLoginName() async {
    //SEMENTARA

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove("bujnumber");
    // await getApiKm().then((String result) {
    //   setState(() {
    //     txtKMOld.text = result == null || result == "0" ? "0" : result;
    //   });
    // });
    await GetListVehicleDoDiTerima();
    setState(() {
      loginname = prefs.getString("name") ?? "";
      locid = prefs.getString("locid") ?? "";
      vhcid = prefs.getString("vhcidfromdo") ?? "";
      //vhcid = 'B 9575 YU';
    });
     getVehiceldriverBuj();
  }

  @override
  void initState() {
    getLoginName();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("vhcidfromdo")!;
    prefs.remove("bujnumber")!;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: true);
    //
    // pr.style(
    //   message: 'Wait...',
    //   borderRadius: 10.0,
    //   backgroundColor: Colors.white,
    //   elevation: 10.0,
    //   insetAnimCurve: Curves.easeInOut,
    //   progress: 0.0,
    //   maxProgress: 100.0,
    //   progressTextStyle: TextStyle(
    //       color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    //   messageTextStyle: TextStyle(
    //       color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    // );
    var vehicleNopol = vhcid == null || vhcid == "" ? "[No Nopol]" : vhcid;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("vhcidfromdo");
        prefs.remove("bujnumber");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        backgroundColor: Colors.orange.shade400,
        appBar: AppBar(
            backgroundColor: Colors.orange.shade400,
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
            title: Text('Form Set KM')),
        //title: Text('Form Set KM B 9575 YU')),//TEST
        body: Container(
          key: scafoldGlobal,
          constraints: BoxConstraints.expand(),
          color: HexColor("#f0eff4"),
          child: Stack(
            children: <Widget>[
              ImgHeader1(context),
              ImgHeader2(context),
              BuildHeader(context),
              _getContent(context),
              // _getContentNewDriver(context),
            ],
          ),
        ),
      ),
    );
  }

  static const _inputRadius = 12.0;
  static const _fieldPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  Widget _sectionLabel(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.orange.shade600),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getVehicleList(BuildContext context) {
  print("dataListVehicle");
  print(dataListVehicle);
    if (dataListVehicle != null && dataListVehicle.length > 0) {
      print('dataListVehicle ${dataListVehicle[0]['id']}');
      txtNopol.text = dataListVehicle[0]['id'];
      vhcid = dataListVehicle[0]['id'];
      return Container(
        margin: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_inputRadius),
          border: Border.all(color: Colors.orange.shade200, width: 1.5),
        ),
        child: TextField(
          readOnly: true,
          cursorColor: Colors.orange.shade600,
          controller: txtNopol,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            filled: true,
            border: InputBorder.none,
            contentPadding: _fieldPadding,
            prefixIcon: Icon(Icons.directions_car, color: Colors.orange.shade400, size: 22),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_inputRadius),
          border: Border.all(color: Colors.orange.shade200, width: 1.5),
        ),
        child: DropdownButton<String>(
          hint: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.orange.shade400, size: 22),
              SizedBox(width: 12),
              Text('Pilih Nopol', style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          isExpanded: true,
          underline: SizedBox(),
          icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade600),
          items: dataListVehicle.map((item) {
            return DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(item['text'].toString()),
            );
          }).toList(),
          onChanged: (newVal) {
            setState(() {
              vhcid = newVal!;
              txtNopol.text = newVal!;
            });
          },
          value: vhcid.isEmpty ? null : vhcid,
        ),
      );
    }
  }

  Widget _getContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
      child: ListView(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 12.0,
              shadowColor: Colors.orange.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_road, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Form Set KM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("Nopol", Icons.directions_car),
                        _getVehicleList(context),
                        _sectionLabel("Kilometer Awal", Icons.speed),
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(_inputRadius),
                            border: Border.all(color: Colors.orange.shade200, width: 1.5),
                          ),
                          child: TextField(
                            readOnly: true,
                            cursorColor: Colors.orange.shade600,
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                            controller: txtKMOld,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: _fieldPadding,
                              prefixIcon: Icon(Icons.straighten, color: Colors.orange.shade400, size: 22),
                            ),
                          ),
                        ),
                        _sectionLabel("Kilometer Akhir", Icons.flag),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(_inputRadius),
                                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                                ),
                                child: TextField(
                                  cursorColor: Colors.orange.shade600,
                                  controller: txtKM,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    border: InputBorder.none,
                                    contentPadding: _fieldPadding,
                                    prefixIcon: Icon(Icons.straighten, color: Colors.orange.shade400, size: 22),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  label: Text("Scan KM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () => _read(),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    backgroundColor: Colors.orange.shade400,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_inputRadius)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Aksi",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.home_repair_service_sharp, color: Colors.white, size: 20),
                                      label: Text("Service", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String vhcidNew = prefs.getString(
                                "vhcidfromdo")!; //==null || prefs.getString("vhcidfromdo")==""?txtNopol.text:prefs.getString("vhcidfromdo");
                            String km_awal = txtKMOld.value.text.toString();
                            String km_new = txtKM.value.text.toString();

                            //String vhcidNew = prefs.getString("vhcidfromdo");
                            //String km_awal = txtKMOld.value.text.toString();
                            //String km_new = txtKM.value.text.toString();

                            String bujnumber = prefs.getString("bujnumber")!;

                            print("${vhcidNew}");
                            print("${km_awal}");
                            print("${km_awal}");
                            if (vhcidNew == null || vhcidNew == "") {
                              alert(context, 2, "Vehicle tidak boleh kosong",
                                  "warning");
                            } else if (km_awal == null || km_awal == "") {
                              alert(context, 2, "KM tidak boleh kosong",
                                  "warning");
                            } else if (km_new == null || km_new == "") {
                              alert(context, 2, "KM tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_awal) <= 0) {
                              alert(context, 2, "KM Awal tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_new) <= 0) {
                              alert(context, 2, "KM Akhir tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_awal) >=
                                int.parse(km_new)) {
                              print(
                                  "${int.parse(km_awal)}-${int.parse(km_new)}");
                              alert(context, 2, "KM Akhir harus > dari KM Awal",
                                  "warning");
                            } else if (bujnumber == null || bujnumber == '') {
                              alert(context, 2, "Buj Number tidak boleh kosong",
                                  "warning");
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString("km_new", txtKM.text.toString());
                              if (prefs.getString("vhcidfromdo") == null ||
                                  prefs.getString("vhcidfromdo") == "") {
                                if (txtNopol.text == null ||
                                    txtNopol.text == "") return;
                                prefs.setString("vhcidfromdo", txtNopol.text);
                              }

                              showDialog(
                                context: context,
                                builder: (context) => new AlertDialog(
                                  title: new Text('Information'),
                                  content: new Text(
                                      "Lanjutkan proses ke Maintenance Service?"),
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
                                          backgroundColor: Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    new ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.navigate_next,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      label: Text("Ok"),
                                      onPressed: () async {
                                        globals.page_inspeksi = '';
                                        globals.p2hVhckm = 0;
                                        prefs.setString(
                                            "name_event", "service");
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewService()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_inputRadius)),
                              textStyle: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.save, color: Colors.white, size: 20),
                                      label: Text("Antrian", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                            var totalHaveDo = await getCountHaveDo(); //DEV
                            //totalHaveDo = 0;
                            if (totalHaveDo > 0) {
                              SharedPreferences prefs = await SharedPreferences
                                  .getInstance(); //SEMENTARA
                              globals.page_inspeksi = 'driver';
                              String vhcidNew =
                                  prefs.getString("vhcidfromdo") == null ||
                                          prefs.getString("vhcidfromdo") == ""
                                      ? txtNopol.text
                                      : prefs.getString("vhcidfromdo")!;
                              String km_awal = txtKMOld.value.text.toString();
                              String km_new = txtKM.value.text.toString();

                              //DEV
                              // vhcidNew = "B 9570 YU";
                              // km_awal = "1";
                              // km_new = "2";
                              //
                              // prefs.setString("vhcidfromdo", vhcidNew);
                              // prefs.setString(
                              //     "km_new", km_new);
                              //END DEV

                              print("${km_new}");
                              print("${km_awal}");

                              globals.p2hVhcKilometer = km_new;
                              if (vhcidNew == null || vhcidNew == "") {
                                alert(context, 2, "Vehicle tidak boleh kosong",
                                    "warning");
                              } else if (km_awal == null || km_awal == "") {
                                alert(context, 2, "KM tidak boleh kosong",
                                    "warning");
                              } else if (km_new == null || km_new == "") {
                                alert(context, 2, "KM tidak boleh kosong",
                                    "warning");
                              } else if (int.parse(km_awal) <= 0) {
                                alert(context, 2, "KM Awal tidak boleh kosong",
                                    "warning");
                              } else if (int.parse(km_new) <= 0) {
                                alert(context, 2, "KM Akhir tidak boleh kosong",
                                    "warning");
                              } else if (int.parse(km_new) <=
                                  int.parse(km_awal)) {
                                alert(context, 2,
                                    "KM Akhir harus > dari KM Awal", "warning");
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                //OPEN FOR PROD
                                prefs.setString(
                                    "km_new", txtKM.text.toString());
                                prefs.setString("vhcid_last_antrian", vhcidNew);
                                if (prefs.getString("vhcidfromdo") == null ||
                                    prefs.getString("vhcidfromdo") == "") {
                                  if (txtNopol.text == null ||
                                      txtNopol.text == "") return;
                                  prefs.setString("vhcidfromdo", txtNopol.text);
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) => new AlertDialog(
                                    title: new Text('Information'),
                                    content: new Text(
                                        "Lanjutkan proses ke Form Inspeksi?"),
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
                                            backgroundColor: Colors.orange.shade400,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                      SizedBox(width: 5),
                                      new ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.navigate_next,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: Text("Ngepok"),
                                        onPressed: () {
                                          EasyLoading.show();
                                          userid = prefs.getString("name")!;
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewAntrianNgepok()));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                      SizedBox(width: 5),
                                      new ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.navigate_next,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        label: Text("Normal"),
                                        onPressed: () async{
                                          EasyLoading.show();
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          userid = prefs.getString("name")!;
                                          globals.p2hVhcid = prefs.getString("vhcidfromdo");
                                          globals.p2hVhclocid = locid;
                                          globals.p2hVhcKilometer = txtKM.text;
                                          globals.p2hVhcDriver = "yes";
                                          // Navigator.pushReplacement(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             FrmInspeksiVehicleDailyCheckScreenP2H()));
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DailyCheckScreenP2H()));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.orange.shade400,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              alert(
                                  context,
                                  2,
                                  "Anda tidak punya DO, silahkan klik standby",
                                  "warning");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_inputRadius)),
                              textStyle: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.pending_actions, color: Colors.white, size: 22),
                            label: Text("StandBy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String vhcidNew = prefs.getString(
                                "vhcidfromdo")!; //==null || prefs.getString("vhcidfromdo")==""?txtNopol.text:prefs.getString("vhcidfromdo");
                            String km_awal = txtKMOld.value.text.toString();
                            String km_new = txtKM.value.text.toString();

                            //String vhcidNew = prefs.getString("vhcidfromdo");
                            //String km_awal = txtKMOld.value.text.toString();
                            //String km_new = txtKM.value.text.toString();

                            print("${vhcidNew}");
                            print("${km_awal}");
                            print("${km_awal}");
                            if (vhcidNew == null || vhcidNew == "") {
                              alert(context, 2, "Vehicle tidak boleh kosong",
                                  "warning");
                            } else if (km_awal == null || km_awal == "") {
                              alert(context, 2, "KM tidak boleh kosong",
                                  "warning");
                            } else if (km_new == null || km_new == "") {
                              alert(context, 2, "KM tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_awal) <= 0) {
                              alert(context, 2, "KM Awal tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_new) <= 0) {
                              alert(context, 2, "KM Akhir tidak boleh kosong",
                                  "warning");
                            } else if (int.parse(km_awal) >=
                                int.parse(km_new)) {
                              print(
                                  "${int.parse(km_awal)}-${int.parse(km_new)}");
                              alert(context, 2,
                                  "KM Akhir harus > dari KM Awal 2", "warning");
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              //prefs.setString("km_new", txtKM.text.toString());
                              if (prefs.getString("vhcidfromdo") == null ||
                                  prefs.getString("vhcidfromdo") == "") {
                                if (txtNopol.text == null ||
                                    txtNopol.text == "") return;
                                //prefs.setString("vhcidfromdo",txtNopol.text);
                              }

                              if (prefs.getString("bujnumber") == null ||
                                  prefs.getString("bujnumber") == "") {
                                return;
                              }

                              showDialog(
                                context: context,
                                builder: (context) => new AlertDialog(
                                  title: new Text('Information'),
                                  content: new Text("Close DO?"),
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
                                          backgroundColor: Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                    new ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.navigate_next,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      label: Text("Ok"),
                                      onPressed: () async {
                                        //Navigator.of(context).pop(false);
                                        globals.page_inspeksi = '';
                                        globals.p2hVhckm = 0;
                                        prefs.setString(
                                            "name_event", "stand_by");
                                        print('Close DO');
                                         updateKMStandby(
                                            prefs.getString("bujnumber")!,
                                            context,
                                            txtKM.text,
                                            0);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Colors.orange.shade400,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.orange.shade400,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_inputRadius)),
                              textStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //DISABLE
  // Widget _getContentNewDriver(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.fromLTRB(0, 270.0, 0, 0),
  //     padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
  //     child: ListView(
  //       children: <Widget>[
  //         Container(
  //           child: Card(
  //             elevation: 14.0,
  //             shadowColor: Colors.orange.shade200,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15.0)),
  //             clipBehavior: Clip.antiAlias,
  //             child: Column(
  //               children: <Widget>[
  //                 ListTile(title: Text("Create Antrian New Driver")),
  //                 Container(
  //                     margin: EdgeInsets.only(
  //                         left: 20, top: 5, right: 20, bottom: 5),
  //                     child: Row(children: <Widget>[
  //                       Expanded(
  //                           child: ElevatedButton.icon(
  //                         icon: Icon(
  //                           Icons.save,
  //                           color: Colors.white,
  //                           size: 15.0,
  //                         ),
  //                         label: Text("Create Antrian"),
  //                         onPressed: () async {
  //                           SharedPreferences prefs = await SharedPreferences
  //                               .getInstance(); //SEMENTARA
  //                           showDialog(
  //                             context: context,
  //                             builder: (context) => new AlertDialog(
  //                               title: new Text('Information'),
  //                               content: new Text("Buat Antrian?"),
  //                               actions: <Widget>[
  //                                 new ElevatedButton.icon(
  //                                   icon: Icon(
  //                                     Icons.close,
  //                                     color: Colors.white,
  //                                     size: 20.0,
  //                                   ),
  //                                   label: Text("No"),
  //                                   onPressed: () {
  //                                     Navigator.of(context).pop(false);
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                       elevation: 0.0,
  //                                       backgroundColor: Colors.blue,
  //                                       padding: EdgeInsets.symmetric(
  //                                           horizontal: 10, vertical: 0),
  //                                       textStyle: TextStyle(
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold)),
  //                                 ),
  //                                 new ElevatedButton.icon(
  //                                   icon: Icon(
  //                                     Icons.navigate_next,
  //                                     color: Colors.white,
  //                                     size: 20.0,
  //                                   ),
  //                                   label: Text("Ok"),
  //                                   onPressed: () {
  //                                     userid = prefs.getString("name");
  //                                     Navigator.pushReplacement(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (context) =>
  //                                                 FrmCreateAntrianNewDriver()));
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                       elevation: 0.0,
  //                                       backgroundColor: Colors.blue,
  //                                       padding: EdgeInsets.symmetric(
  //                                           horizontal: 10, vertical: 0),
  //                                       textStyle: TextStyle(
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold)),
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                             elevation: 0.0,
  //                             backgroundColor: Colors.blue,
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal: 5, vertical: 0),
  //                             textStyle: TextStyle(
  //                                 fontSize: 10, fontWeight: FontWeight.bold)),
  //                       )),
  //                     ]))
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget LoadListMenu(BuildContext context) {
    return Expanded(
      child: Container(
        //padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 0),
        child: GridView.count(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 3,
          //childAspectRatio: .90,
          children: <Widget>[
            Container(
              height: 10,
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5.0,
                //shadowColor: Colors.orange.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ViewListDo())),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.pageview,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        //AutoSizeText('Dashboard')
                        Text('List DO OPENED',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Card(
                elevation: 5.0,
                //shadowColor: Colors.orange.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  // onTap: () => Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => DoPage())),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.orange.shade400,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.work,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        Text('Profile',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Card(
                elevation: 5.0,
                //shadowColor: Colors.orange.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: () {
                    print("LOGOUT");
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Material(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 34.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        Text('Log Out',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 20.0)),
                        //Text('Dashboard',
                        //    style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ImgHeader1(BuildContext context) {
    return Container(
      child: new Image.asset(
        "assets/img/truck_header.jpg",
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: new BoxConstraints.expand(height: 295.0),
    );
  }

  Widget ImgHeader2(BuildContext context) {
    return Container(
      margin: new EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          //colors: <Color>[new Color(0x00736AB7), new Color(0xFF736AB7)],
          colors: <Color>[new Color(0x00736AB7), HexColor("#f0eff4")],
          stops: [0.0, 0.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Widget BuildHeader(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
        title: Text(
          'Driver Management System',
          style: TextStyle(
              color: AppTheme.nearlyWhite,
              fontWeight: FontWeight.w500,
              fontSize: 16.0),
        ),
        trailing: Icon(Icons.account_circle,
            size: 35,
            color: AppTheme
                .nearlyBlack) //CircleAvatar(backgroundColor: AppTheme.white),
        );
  }
}
