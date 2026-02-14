
import 'package:dio/dio.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/DailyCheckScreenP2H.dart';
import 'package:dms_anp/src/pages/driver/DailyCheckScreenP2H_New.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../flusbar.dart';
import 'driver/ListDriverInspeksiV2.dart';

List listVehicleId = [];
List dummySearchList2 = [];
List dataSRType = [];
TextEditingController txtSR = new TextEditingController();
TextEditingController txtSearchVehicle = new TextEditingController();
TextEditingController txtVehicleName = new TextEditingController();
TextEditingController txtVHCID = new TextEditingController();
TextEditingController txtVehicleIdList = new TextEditingController();

class _BottomSheetContentVehicle extends StatelessWidget {
  final Function(String) onVehicleSelected; // ✅ Callback function untuk update UI

  _BottomSheetContentVehicle({required this.onVehicleSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE0B2), // Light orange
            Color(0xFFFFF3E0), // Very light orange
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pilih Vehicle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: txtSearchVehicle,
                style: TextStyle(color: Colors.orange.shade800),
                decoration: InputDecoration(
                  labelText: "Cari Vehicle",
                  hintText: "Masukkan nama vehicle...",
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade600),
                  labelStyle: TextStyle(color: Colors.orange.shade600),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.orange.shade200, width: 1),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: listVehicleId == null ? 0 : listVehicleId.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () async {
                      // ✅ Update controllers
                      String selectedVehicle = listVehicleId[index]['vhcid'].toString();
                      txtVehicleName.text = selectedVehicle;
                      txtVehicleIdList.text = selectedVehicle;
                      txtVHCID.text = selectedVehicle;

                      // ✅ Close bottom sheet
                      Navigator.of(context).pop();

                      // ✅ Callback ke parent untuk refresh UI
                      if (onVehicleSelected != null) {
                        onVehicleSelected(selectedVehicle);
                      }
                    },
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      "${listVehicleId[index]['vhcid']}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.orange.shade400,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FrmCreateAntrianNewDriver extends StatefulWidget {
  @override
  _FrmCreateAntrianNewDriverState createState() => _FrmCreateAntrianNewDriverState();
}

class _FrmCreateAntrianNewDriverState extends State<FrmCreateAntrianNewDriver> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController txtDRIVER = new TextEditingController();
  TextEditingController txtNOTES = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  String status_code = "";
  String message = "";
  String vhcid = "";
  String locid = "";
  String userid = "";
  String drvid = "";
  String vhcidNewDriver = "";

  // ✅ Update method dengan callback untuk refresh UI
  void _showModalListVehicle(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContentVehicle(
          onVehicleSelected: (String selectedVehicle) {
            // ✅ setState untuk refresh UI setelah pilih vehicle
            setState(() {
              print("✅ UI refreshed with vehicle: $selectedVehicle");
            });
          },
        );
      },
    );
  }

  Future getListSR() async {
    Uri myUri = Uri.parse("${GlobalData.baseUrl}api/do/refference_master.jsp?method=list_typeservice");
    print(myUri.toString());
    var response = await http.get(myUri, headers: {"Accept": "application/json"});

    dataSRType = json.decode(response.body);
    print(dataSRType);
    if (dataSRType.length == 0 && dataSRType == []) {
      alert(globalScaffoldKey.currentContext!, 0, "Gagal Load data Type Service", "error");
    }
  }

  Future<String> getApiKm() async {
    String _km = "0";
    String vhcidNew = txtVHCID.text;
    if (vhcidNew != null) {
      print('getApiKM');
      var urlData = "${GlobalData.baseUrl}api/get_km_by_vehicle.jsp?method=km_vehicle&vhcid=" + vhcidNew;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(encoded);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});

      setState(() {
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          _km = json.decode(response.body)["km"];
        }
      });
    }
    return _km;
  }

  Future<String?> createAntrian(String vhcid, String vhckm, String locid, String drvid, String userid) async {
    EasyLoading.show();
    try {
      var urlData = "${GlobalData.baseUrl}api/maintenance/create_antrian_new_driver.jsp?method=create-antrian-new-driver-v1&vhcid=" +
          vhcid +
          "&vhckm=" +
          vhckm +
          "&locid=" +
          locid +
          "&drvid=" +
          drvid +
          "&userid=" +
          userid;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(myUri);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        print(json.decode(response.body));
        status_code = json.decode(response.body)["status_code"].toString();
        message = json.decode(response.body)["message"];
        if (int.parse(status_code) == 200) {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          Timer(Duration(seconds: 1), () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
        } else {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          Navigator.of(context).pop(false);
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
      });
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Internal Server Error", "error");
      print(e);
    }
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    drvid = prefs.getString("drvid")!;
    locid = prefs.getString("locid")!;
    var paget_antrian = prefs.getString("page_antrian");
    print(paget_antrian);
    String km = await getApiKm();
    txtKMOld.text = km.toString() == null || km.toString() == '' ? '0' : km.toString();
    userid = prefs.getString("name")!;
    txtDRIVER.text = userid;
  }

  void getVehicleList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _drvid = prefs.getString("drvid");
    try {
      var urlData = "${GlobalData.baseUrl}api/question_form_checklis.jsp?method=list-vehicle-form-v2&driver_id=${_drvid}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        listVehicleId = [];
        listVehicleId = (jsonDecode(response.body) as List).map((dynamic e) => e as Map<String, dynamic>).toList();
        dummySearchList2 = [];
        dummySearchList2 = listVehicleId;
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data detail vehcile", "error");
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data driver", "error");
      print(e.toString());
    }
  }

  void _searchVehicleName() {
    List dummyListData2 = [];
    if (txtSearchVehicle.text != "" && txtSearchVehicle.text != null) {
      if (txtSearchVehicle.text.length >= 3) {
        for (var i = 0; i < dummySearchList2.length; i++) {
          var dtC = dummySearchList2[i]['vhcid'].toLowerCase().toString();
          if (dtC.contains(txtSearchVehicle.text.toLowerCase().toString())) {
            dummyListData2.add({
              "vhcid": dummySearchList2[i]['vhcid'].toString(),
              "vhcid": dummySearchList2[i]['vhcid']
            });
          }
        }
      }
      if (dummyListData2.length > 0) {
        if (mounted) {
          setState(() {
            listVehicleId = [];
            listVehicleId = dummyListData2;
          });
        }
      } else {
        listVehicleId = [];
        listVehicleId = dummySearchList2;
      }
      return;
    }
  }

  @override
  void initState() {
    setState(() {
      getSession();
    });
    getVehicleList();
    txtSearchVehicle.addListener(_searchVehicleName);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    print(' Create New Driver');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _goBack(BuildContext context) {
    globals.page_inspeksi = null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color(0xFFE65100),
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              onPressed: () {
                _goBack(context);
              },
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          key: globalScaffoldKey,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE0B2), // Light orange
                Color(0xFFFFF8E1), // Very light orange
                Color(0xFFFFF3E0), // Cream orange
              ],
            ),
          ),
          child: SafeArea(
            child: _getContent(context),
          ),
        ),
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          // Header Card
          Container(
            margin: EdgeInsets.only(bottom: 30),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Form Antrian Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Lengkapi data untuk membuat antrian',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                // Driver Field
                Container(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.orange.shade600, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "DRIVER",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange.shade200, width: 1),
                        ),
                        child: TextField(
                          readOnly: true,
                          controller: txtDRIVER,
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Nama Driver',
                            hintStyle: TextStyle(color: Colors.orange.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle Field
                Container(
                  padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_car, color: Colors.orange.shade600, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "VEHICLE ID",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          _showModalListVehicle(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  txtVHCID.text.isEmpty ? 'Pilih Vehicle' : txtVHCID.text,
                                  style: TextStyle(
                                    color: txtVHCID.text.isEmpty ? Colors.orange.shade400 : Colors.orange.shade800,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.orange.shade600),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // KM Field
                Container(
                  padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.speed, color: Colors.orange.shade600, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "KM BARU",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: txtKM,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Masukkan KM...',
                            hintStyle: TextStyle(color: Colors.orange.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Submit Button
                Container(
                  padding: EdgeInsets.all(25),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString("p2h_antrian", "true");
                        vhcid = txtVHCID.text;
                        if (vhcid == "" || vhcid == null) {
                          alert(globalScaffoldKey.currentContext!, 0, "Vehicle tidak boleh kosong", "error");
                        } else if (locid == "" || locid == null) {
                          alert(globalScaffoldKey.currentContext!, 0, "LOCID tidak boleh kosong", "error");
                        } else if (drvid == "" || drvid == null) {
                          alert(globalScaffoldKey.currentContext!, 0, "Driver tidak boleh kosong", "error");
                        } else if (userid == "") {
                          alert(globalScaffoldKey.currentContext!, 0, "USER ID tidak boleh kosong", "error");
                        } else if (txtKM.value.text == null || txtKM.value.text == "") {
                          alert(globalScaffoldKey.currentContext!, 0, "KM New tidak boleh kosong", "error");
                        } else if (int.parse(txtKM.value.text) <= 0) {
                          alert(globalScaffoldKey.currentContext!, 0, "KM New tidak boleh 0", "error");
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade600),
                                  SizedBox(width: 10),
                                  Text(
                                    'Konfirmasi',
                                    style: TextStyle(color: Colors.orange.shade700),
                                  ),
                                ],
                              ),
                              content: Text(
                                "Lanjutkan ke proses Inspeksi?",
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text(
                                    "Tidak",
                                    style: TextStyle(color: Colors.orange.shade400),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    globals.p2hVhcDriver = "yes";
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString("km_new", txtKM.text.toString());
                                    prefs.setString("vhcid_last_antrian", txtVHCID.value.text);
                                    prefs.setString("vhcidfromdo", "");
                                    prefs.setString("method", "new");
                                    globals.page_inspeksi = "new_driver";
                                    userid = prefs.getString("name")!;
                                    globals.p2hVhcid = txtVHCID.value.text;
                                    globals.p2hVhclocid = locid;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DailyCheckScreenP2H_New(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Ya, Lanjutkan",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}