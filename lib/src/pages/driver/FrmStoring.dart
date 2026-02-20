import 'dart:async';
import 'package:dms_anp/src/pages/FrmInspeksiVehicle.dart';
import 'package:dms_anp/src/pages/ViewService.dart';
import 'package:dms_anp/src/pages/driver/FormStoring.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
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

import '../../flusbar.dart';

class FrmStoring extends StatefulWidget {
  @override
  _FrmStoringState createState() => _FrmStoringState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class _FrmStoringState extends State<FrmStoring> {
  TextEditingController txtNopol = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  String status_code = "";
  String message = "";
  final ImagePicker _imagePicker = ImagePicker();

  String loginname = "";
  String drvid = "";
  String locid = "";
  String vhckm = "";
  String dlodetaildonumber = "";
  String vhcid = "";
  String dloorigin = "";
  String dlodestination = "";
  String userid = "";

  bool isNumeric(String s) {
    if (s.isEmpty) return false;
    return double.tryParse(s) != null;
  }

  Future<void> _read() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo == null || !mounted) return;
      final ctrl = TextEditingController(text: txtKM.text);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Input KM'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan KM dari foto speedometer',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = ctrl.text.trim();
                if (value.isNotEmpty && isNumeric(value)) {
                  setState(() => txtKM.text = value);
                }
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal: $e", "error");
      }
    }
  }

  void updateKM(String vhckm, int isBack) async {
    String km = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SEMENTARA
    print('prefs.getString("vhcidfromdo")${prefs.getString("vhcidfromdo")}');
    vhcid = prefs.getString("vhcidfromdo") ?? "";
    //vhcid = 'B 9189 KYW';
    if (vhcid != null && vhcid != "") {
      drvid = prefs.getString("drvid") ?? "";
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", vhcid);
      locid = prefs.getString("locid") ?? "";
      String name = prefs.getString("name") ?? "";
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
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    var driver_id = prefs.getString("drvid");
    var bujnumber = prefs.getString("bujnumber");
    print(bujnumber);
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
        (vhcid == null || vhcid == '') ? (prefs.getString("vhcidfromdo") ?? "") : vhcid;
    //vhcid = 'B 9189 KYW';
    if (_vhcid != null && _vhcid != "") {
      drvid = prefs.getString("drvid") ?? "";
      prefs.setString("km_new", vhckm);
      prefs.setString("vhcid_last_antrian", _vhcid);
      locid = prefs.getString("locid") ?? "";
      String name = prefs.getString("name") ?? "";
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
        }
      });
    }
  }

  Future<String> getApiKm() async {
    String km = "0";
    SharedPreferences prefs = await SharedPreferences.getInstance(); //SEMENTARA
    String vhcid = prefs.getString("vhcid")!;
    if ((vhcid != null && vhcid != "")) {
      var urlData =
          "${GlobalData.baseUrl}api/get_km_by_vehicle_driver.jsp?method=km_vehicle&vhcid=" +
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
      alert(context, 2, "Please contact your Administrator!", "warning");
    }
    return km;
  }

  Future getLoginName() async {
    //SEMENTARA

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove("bujnumber");
    await getApiKm().then((String result) {
      setState(() {
        txtKMOld.text = result == null || result == "0" ? "0" : result;
      });
    });
    setState(() {
      loginname = prefs.getString("name")!;
      locid = prefs.getString("locid")!;
      //vhcid = prefs.getString("vhcidfromdo");
      vhcid = prefs.getString("vhcid")!;
      print(vhcid);
      //vhcid = 'B 9565 YM';
    });
  }

  @override
  void initState() {
    getLoginName();
    //getVehiceldriverBuj();
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    var vehicleNopol = vhcid == null || vhcid == "" ? "[No Nopol]" : vhcid;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
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
            //backgroundColor: Colors.transparent,
            //elevation: 0.0,
            centerTitle: true,
            title: Text('Form Storing')),
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

  //String vhcid="";

  Widget _getVehicleList(BuildContext context) {
    txtNopol.text = vhcid;
    return Container(
      margin: EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
      child: TextField(
        readOnly: true,
        cursorColor: Colors.black,
        controller: txtNopol,
        keyboardType: TextInputType.text,
        decoration: new InputDecoration(
          fillColor: Colors.black12,
          filled: true,
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding:
              EdgeInsets.only(left: 5, bottom: 11, top: 10, right: 5),
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
              elevation: 14.0,
              shadowColor: Color(0x802196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  ListTile(title: Text("Nopol")), //BUGS
                  _getVehicleList(context),
                  ListTile(title: Text("Kilometer Awal")),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      readOnly: true,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.grey.shade800),
                      controller: txtKMOld,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 11, top: 10, right: 5),
                      ),
                    ),
                  ),
                  ListTile(title: Text("Kilometer Akhir")),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: Row(children: <Widget>[
                      Expanded(
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
                                left: 5, bottom: 11, top: 10, right: 5),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                          child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("Scan KM"),
                        onPressed: () {
                          _read();
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            textStyle: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      )),
                    ]),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 5, right: 20, bottom: 5),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.home_repair_service_sharp,
                            color: Colors.white,
                            size: 15.0,
                          ),
                          label: Text("Service"),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String vhcidNew = vhcid;
                            String km_awal = txtKMOld.value.text.toString();
                            String km_new = txtKM.value.text.toString();

                            prefs.setString("km_new_storing", txtKM.text.toString());

                            print("${vhcidNew}");
                            print("${km_awal}");
                            print("${km_awal}");
                            if (km_new == null || km_new == "") {
                              alert(context, 2, "KM tidak boleh kosong",
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
                            }  else {
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
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          textStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,color: Colors.white)),
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
                                                    FormStoring()));
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
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              textStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ))
                      ])),
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
  //             shadowColor: Color(0x802196F3),
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
                //shadowColor: Color(0x802196F3),
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
                //shadowColor: Color(0x802196F3),
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
                            color: Colors.blue,
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
                //shadowColor: Color(0x802196F3),
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
