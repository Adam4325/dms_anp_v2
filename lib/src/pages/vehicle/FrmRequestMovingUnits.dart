
import 'dart:async';
import 'dart:convert';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/Helper/globals.dart' as globals;

var is_edit_req = false;
var gtnumber = "";
String btnSubmitText = "Save Request";
List collectionDriver = [];
List collectionVehicle = [];
List listDriverId = [];
List dummySearchList = [];
List dummySearchList2 = [];
List listVehicleId = [];
List listFrom = [];
List listTo = [];
TextEditingController txtDriverName = new TextEditingController();
TextEditingController txtVehicleName = new TextEditingController();
TextEditingController txtDriverIdList = new TextEditingController();
TextEditingController txtVehicleIdList = new TextEditingController();
TextEditingController txtCabangName = new TextEditingController();
TextEditingController txtCabangId = new TextEditingController();

TextEditingController txtSearchDriver = new TextEditingController();
TextEditingController txtSearchVehicle = new TextEditingController();
TextEditingController txtNotesAlert = new TextEditingController();

class _BottomSheetContentDriver extends StatelessWidget {
  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color cardColor = Color(0xFFFFF8F0);
  final Color shadowColor = Color(0x20FF8C69);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: primaryOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "List Driver",
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: txtSearchDriver,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Search Driver",
                  hintText: "Search Driver",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: primaryOrange),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listDriverId == null ? 0 : listDriverId.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtDriverName.text =
                          listDriverId[index]['title'].toString();
                      txtDriverIdList.text =
                          listDriverId[index]['value'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.person, color: primaryOrange, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${listDriverId[index]['title']}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: primaryOrange, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetContentVehicle extends StatelessWidget {
  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color cardColor = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: primaryOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "List Vehicle",
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: txtSearchVehicle,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Search Vehicle",
                  hintText: "Search Vehicle",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: primaryOrange),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listVehicleId == null ? 0 : listVehicleId.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtVehicleName.text =
                          listVehicleId[index]['title'].toString();
                      txtVehicleIdList.text =
                          listVehicleId[index]['value'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.directions_car, color: primaryOrange, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${listVehicleId[index]['title']}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: primaryOrange, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetContentCabang extends StatelessWidget {
  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color cardColor = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: primaryOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "List Cabang",
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listFrom == null ? 0 : listFrom.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      txtCabangName.text = listFrom[index]['title'].toString();
                      txtCabangId.text = listFrom[index]['value'].toString();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.location_city, color: primaryOrange, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${listFrom[index]['title']}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: primaryOrange, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FrmRequestMovingUnits extends StatefulWidget {
  @override
  _FrmRequestMovingUnitsState createState() => _FrmRequestMovingUnitsState();
}

class _FrmRequestMovingUnitsState extends State<FrmRequestMovingUnits>
    with SingleTickerProviderStateMixin {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog? pr;

  // Orange Soft Theme Colors
  final Color primaryOrange = Color(0xFFFF8C69);
  final Color lightOrange = Color(0xFFFFF4E6);
  final Color accentOrange = Color(0xFFFFB347);
  final Color darkOrange = Color(0xFFE07B39);
  final Color backgroundColor = Color(0xFFFFFAF5);
  final Color cardColor = Color(0xFFFFF8F0);
  final Color shadowColor = Color(0x20FF8C69);

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  final String BASE_URL =
      GlobalData.baseUrl; // "http://apps.tuluatas.com:8080/trucking";
  int status_code = 0;
  int lengTabs = 2;

  String message = "";

  late TabController _tabController;
  TextEditingController txtVehicleId = new TextEditingController();
  TextEditingController txtDriverId = new TextEditingController();

  TextEditingController txtDate = new TextEditingController();
  TextEditingController txtStatus = new TextEditingController();
  TextEditingController txtFromLocid = new TextEditingController();
  TextEditingController txtToLocid = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  List<S2Choice<String>> listStatusRequest = [];
  String _car = '';
  List dataMovingUnits = [];
  String _dateRequest = '';

  int _currentIndex = 0;
  String bSave = "Save Request";
  String bUpdate = "Update Request";

  void _showOrangeAlert(BuildContext context, String message, String type) {
    IconData alertIcon;
    Color alertColor;

    switch (type) {
      case "error":
        alertIcon = Icons.error_outline;
        alertColor = Colors.red.shade400;
        break;
      case "warning":
        alertIcon = Icons.warning_outlined;
        alertColor = accentOrange;
        break;
      case "success":
        alertIcon = Icons.check_circle_outline;
        alertColor = Colors.green.shade400;
        break;
      default:
        alertIcon = Icons.info_outline;
        alertColor = primaryOrange;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: cardColor,
          title: Row(
            children: [
              Icon(alertIcon, color: alertColor, size: 28),
              SizedBox(width: 12),
              Text(
                'Information',
                style: TextStyle(
                  color: darkOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _goBack(BuildContext context) {
    resetTeks();
    btnSubmitText = bSave;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  bool getAkses() {
    //if (getAkses("OP") || username == "ADMIN") {
    var isAkses = false;
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "OP" || x == "ADMIN");
    if (isOK != null) {
      if (isOK.length > 0) {
        isAkses = true;
      }
    }
    return isAkses;
  }

  void resetTeks() {
    setState(() {
      status_code = 0;
      message = "";
      txtDate.text = "";
      gtnumber = "";
      txtNotesAlert.text = "";
      txtDriverName.text = "";
      txtVehicleName.text = "";
      txtDriverIdList.text = "";
      txtVehicleIdList.text = "";
      txtCabangName.text = "";
      txtCabangId.text = "";
      txtSearchVehicle.text = "";
      txtSearchDriver.text = "";
      txtNotes.text = "";
      txtSearchDriver.text = '';
      txtSearchVehicle.text = '';
      txtDriverName.text = '';
      is_edit_req = false;
      _dateRequest = '';
    });
  }

  void _showModalListDriver(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContentDriver();
      },
    );
  }

  void _showModalListVehicle(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContentVehicle();
      },
    );
  }

  void _showModalListCabang(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetContentCabang();
      },
    );
  }

  void getDriverById() async {
    try {
      var urlData = "${BASE_URL}api/gt/list_driver.jsp?method=lookup-driver-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          print('loaded driver');
          listDriverId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchList = listDriverId;
        } else {
          _showOrangeAlert(context, "Gagal load data detail driver", "error");
        }
      });
    } catch (e) {
      _showOrangeAlert(context, "Client, Load data driver", "error");
      print(e.toString());
    }
  }

  void getVehicleList() async {
    try {
      var urlData =
          "${BASE_URL}api/gt/list_vehicle.jsp?method=lookup-vehicle-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          listVehicleId = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          dummySearchList2 = List.from(listVehicleId);
        } else {
          _showOrangeAlert(context, "Gagal load data detail vehcile", "error");
        }
      });
    } catch (e) {
      _showOrangeAlert(context, "Client, Load data driver", "error");
      print(e.toString());
    }
  }

  void getLocidList() async {
    try {
      var urlData = "${BASE_URL}api/gt/list_locid.jsp?method=lookup-locid-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          listFrom = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          listTo = listFrom;
        } else {
          _showOrangeAlert(context, "Gagal load data detail vehcile", "error");
        }
      });
    } catch (e) {
      _showOrangeAlert(context, "Client, Load data driver", "error");
      print(e.toString());
    }
  }

  void saveRequestMoving() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString("name");
      var driverId = txtDriverIdList.text;
      var vehicleId = txtVehicleIdList.text;
      var status = "OPEN";
      var date = txtDate.text;
      var notes = txtNotes.text;
      var locid = txtCabangId.text;

      if (is_edit_req == true && (gtnumber == null || gtnumber == "")) {
        //_tabController.animateTo(0);
        _showOrangeAlert(globalScaffoldKey.currentContext!, "GT Number tidak boleh kosong", "error");
      } else if (date == null || date == "") {
        //_tabController.animateTo(0);
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Date Request tidak boleh kosong", "error");
      } else if (driverId == null || driverId == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Driver ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Vehicle ID tidak boleh kosong", "error");
      } else if (vehicleId == null || vehicleId == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Vehicle ID tidak boleh kosong", "error");
      } else if (status == null || status == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Status tidak boleh kosong", "error");
      } else if (locid == null || locid == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Locid tidak boleh kosong", "error");
      } else {
        await pr!.show();
        var encoded = Uri.encodeFull("${BASE_URL}api/gt/create_or_update.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var method = is_edit_req == false
            ? 'create-request-gt-v1'
            : 'update-request-gt-v1';
        var data = {
          'method': method,
          'gtnumber': gtnumber,
          'drvid': driverId,
          'vhcid': vehicleId,
          'date': date,
          'status': status,
          'locid': locid,
          'notes': notes,
          'userid': user_id,
          'company': 'AN'
        };
        print(data);
        //return;
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: cardColor,
                  title: new Text('Information',
                      style: TextStyle(
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        resetTeks();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            } else {
              _showOrangeAlert(globalScaffoldKey.currentContext!, "${message}", "error");
            }
          } else {
            _showOrangeAlert(globalScaffoldKey.currentContext!, "${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      _showOrangeAlert(globalScaffoldKey.currentContext!, "Client, ${e}", "error");
      print(e.toString());
    }
  }

  void approvedRequest(String gtnumber, String vhcid, String status,
      String locid, String notes) async {
    try {
      var userID = userid;
      var vehicleId = txtVehicleIdList.text;
      if (userID == null || userID == "") {
        //_tabController.animateTo(0);
        _showOrangeAlert(globalScaffoldKey.currentContext!, "UserID tidak boleh kosong", "error");
      } else if (vhcid == null || vhcid == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "VHCID tidak boleh kosong", "error");
      } else if (status == null || status == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Status tidak boleh kosong", "error");
      } else if (locid == null || locid == "") {
        _showOrangeAlert(globalScaffoldKey.currentContext!, "Locid tidak boleh kosong", "error");
      } else {
        await pr!.show();
        var encoded = Uri.encodeFull("${BASE_URL}api/gt/approved.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': 'approved-v1',
          'gtnumber': gtnumber,
          'vhcid': vhcid,
          'status': status,
          'locid': locid,
          'note': notes,
          'userid': userid
        };
        print(data);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
        setState(() {
          if (response.statusCode == 200) {
            status_code = json.decode(response.body)["status_code"];
            message = json.decode(response.body)["message"];
            print(response);
            if (status_code == 200) {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: cardColor,
                  title: new Text('Information',
                      style: TextStyle(
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  content: new Text("$message"),
                  actions: <Widget>[
                    new ElevatedButton.icon(
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      label: Text("Ok"),
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await getJSONData(true);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            } else {
              _showOrangeAlert(globalScaffoldKey.currentContext!, "Gagal ${message}", "error");
            }
          } else {
            _showOrangeAlert(globalScaffoldKey.currentContext!, "Gagal ${response.statusCode}", "error");
          }
        });
      }
    } catch (e) {
      if (pr?.isShowing() == true) {
        await pr?.hide();
      }
      _showOrangeAlert(context, "Client, Gagal Menyimpan Data", "error");
      print(e.toString());
    }
  }

  var username = "";
  var userid = "";
  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? '';
    userid = prefs.getString("name") ?? '';
  }

  Future<String> getJSONData(bool isloading) async {
    //EasyLoading.show();
    try {
      if (isloading == true) {
        if (pr?.isShowing() == false) {
          await pr?.show();
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/gt/list_data_moving.jsp?method=lookup-list-moving-v1");
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      if (isloading == true) {
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
      }
      setState(() {
        // Get the JSON data
        dataMovingUnits = json.decode(response.body);
      });
      if (dataMovingUnits == null || dataMovingUnits.length == 0) {
        _showOrangeAlert(context, "Data Request Moving tidak di temukan", "error");
      }
    } catch (e) {
      if (isloading == true) {
        if (pr?.isShowing() == true) {
          await pr?.hide();
        }
      }
    }
    return "Successfull";
  }

  var isLoadData = false;
  void _dateTimeChange() {
    print(username);
    if (txtDate.text != "" && txtDate.text != null) {
      //if (username == "ADI" || username == "MAJID") {
      if (!getAkses()) {
        _showOrangeAlert(context, "Anda tidak dapat melakukan transaksi ini", "error");
      } else {
        if (isLoadData == false) {
          setState(() {
            getDriverById();
            getVehicleList();
            getLocidList();
            isLoadData = true;
          });
        }
      }
    }
  }

  void _searchDriverName() {
    List dummyListData = [];
    if (txtSearchDriver.text != "" && txtSearchDriver.text != null) {
      if (txtSearchDriver.text.length >= 3) {
        for (var i = 0; i < dummySearchList.length; i++) {
          var dtC = dummySearchList[i]['title'].toLowerCase().toString();
          print(dtC.contains(txtSearchDriver.text));
          if (dtC.contains(txtSearchDriver.text.toLowerCase().toString())) {
            print(dtC);
            dummyListData.add({
              "value": dummySearchList[i]['value'].toString(),
              "title": dummySearchList[i]['title']
            });
          }
        }
      }
      if (dummyListData.length > 0) {
        if (mounted) {
          setState(() {
            listDriverId = [];
            listDriverId = dummyListData;
          });
        }
      }
      return;
    } //else {
    // print('else');
    // if (mounted) {
    //   if(listDriverId.length<=0){
    //     setState(() {
    //       listDriverId = [];
    //       listDriverId = dummySearchList;
    //     });
    //   }
    // }
    // return;
    //}
  }

  void _searchVehicleName() {
    if (dummySearchList2.isEmpty) return;

    final query = (txtSearchVehicle.text ?? "").trim().toLowerCase();
    if (query.isEmpty || query.length < 3) {
      if (mounted) {
        setState(() {
          listVehicleId = List.from(dummySearchList2);
        });
      }
      return;
    }

    List dummyListData2 = [];
    for (var i = 0; i < dummySearchList2.length; i++) {
      final item = dummySearchList2[i];
      final title = (item['title'] ?? '').toString().toLowerCase();
      final nopol = (item['nopol'] ?? item['title'] ?? '').toString().toLowerCase();
      if (title.contains(query) || nopol.contains(query)) {
        dummyListData2.add({
          "value": (item['value'] ?? item['unit_id'] ?? '').toString(),
          "title": (item['title'] ?? item['nopol'] ?? '').toString()
        });
      }
    }
    if (mounted) {
      setState(() {
        listVehicleId = dummyListData2;
      });
    }
  }

  void _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 1:
          Future.delayed(Duration(milliseconds: 50));
          print('Delayed');
          await getJSONData(true);
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    //txtSearchDriver.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //1

    if(EasyLoading.isShow){
      EasyLoading.dismiss();
    }
    _tabController = new TabController(vsync: this, length: lengTabs);

    setState(() {
      // getDriverById();
      // getVehicleList();
      // getLocidList();
      resetTeks();
      getSession();
    });
    _tabController.addListener(_handleTabSelection);
    txtDate.addListener(_dateTimeChange);
    txtSearchDriver.addListener(_searchDriverName);
    txtSearchVehicle.addListener(_searchVehicleName);
    super.initState();
  }

  Widget buildTextField({
    String? labelText,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Color? fillColor,
  }) {
    return Container(
      margin: EdgeInsets.all(12.0),
      child: TextField(
        readOnly: readOnly,
        cursorColor: primaryOrange,
        style: TextStyle(color: Colors.black87, fontSize: 14),
        controller: controller,
        onTap: onTap,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          fillColor: fillColor ?? Colors.white,
          filled: true,
          isDense: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryOrange, width: 2),
          ),
          suffixIcon: readOnly ? Icon(Icons.arrow_drop_down, color: primaryOrange) : null,
        ),
      ),
    );
  }

  //int selectedPage=1;
  //_RegisterNewDriverState(this.selectedPage);
  Widget _buildListView(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: dataMovingUnits == null ? 0 : dataMovingUnits.length,
            itemBuilder: (context, index) {
              return _buildDListMovingUnits(dataMovingUnits[index], index);
            }));
  }

  Widget _buildDListMovingUnits(dynamic item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Header
          Container(
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.settings_applications, color: primaryOrange, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "GT. Number: ${item['gtnumber']}",
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow("Date", "${item['gtdate']}", Icons.calendar_today),
                _buildInfoRow("VHCID", "${item['vhcid']}", Icons.directions_car),
                _buildInfoRow("Driver", "${item['drv_name']}", Icons.person),
                _buildInfoRow("Status", "${item['gtstatus']}", Icons.info),
                //_buildInfoRow("Tujuan", "${item['gttujuan']}", Icons.location_on),
                _buildInfoRow("LOCID", "${item['locid']}", Icons.location_city),
                _buildInfoRow("Notes", "${item['gtnotes']}", Icons.note),
              ],
            ),
          ),
          // Action Buttons
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    label: Text("Edit"),
                    onPressed: () async {
                      showDialog(
                        context: globalScaffoldKey.currentContext!,
                        builder: (context) => new AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: cardColor,
                          title: new Text('Information',
                              style: TextStyle(
                                color: darkOrange,
                                fontWeight: FontWeight.w600,
                              )),
                          content: new Text("Edit data ${item['gtnumber']}"),
                          actions: <Widget>[
                            new TextButton(
                                onPressed: () {
                                  Navigator.of(globalScaffoldKey.currentContext!)
                                      .pop(false);
                                  resetTeks();
                                },
                                child: new Text('No', style: TextStyle(color: Colors.grey.shade600))),
                            new ElevatedButton(
                              onPressed: () async {
                                final ctx = globalScaffoldKey.currentContext;
                                if (ctx != null) Navigator.of(ctx).pop(false);
                                await Future.delayed(Duration(milliseconds: 50));
                                if (!mounted) return;
                                setState(() {
                                  is_edit_req = true;
                                  txtDate.text = item['gtdate']?.toString() ?? '';
                                  txtDriverIdList.text = item['drvid']?.toString() ?? '';
                                  txtVehicleIdList.text = item['vhcid']?.toString() ?? '';
                                  txtVehicleName.text = item['vhcid']?.toString() ?? '';
                                  txtDriverName.text = item['drv_name']?.toString() ?? '';
                                  _dateRequest = item['gtdate']?.toString() ?? '';
                                  txtNotes.text = item['gtnotes']?.toString() ?? '';
                                  txtCabangId.text = item['locid']?.toString() ?? '';
                                  txtCabangName.text = item['locid']?.toString() ?? '';
                                  gtnumber = item['gtnumber']?.toString() ?? '';
                                  btnSubmitText = bUpdate;
                                }); //save ss
                                if (mounted) _tabController.animateTo(0);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: new Text('Ok', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 2.0,
                        backgroundColor: accentOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                _sizeBoxApprove(context),
                buildButtonApprove(
                    context, item['gtnumber'], item['vhcid'], item['locid']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryOrange, size: 16),
          SizedBox(width: 12),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sizeBoxApprove(BuildContext context) {
    if (username == "ADI" || username == "MAJID") {
      //if (!getAkses()) {
      return SizedBox(
        width: 12,
      );
    } else {
      return Container();
    }
  }

  Widget buildButtonApprove(
      BuildContext context, String gtNumber, String vhcid, String locid) {
    if (username == "ADI" || username == "MAJID") {
      //if (!getAkses()) {
      return Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18.0,
            ),
            label: Text("Approve"),
            onPressed: () async {
              showDialog(
                context: globalScaffoldKey.currentContext!,
                builder: (context) => new AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: cardColor,
                  title: new Text('Information',
                      style: TextStyle(
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  content: new Text("Approve data ${gtNumber}"),
                  actions: <Widget>[
                    new TextButton(
                        onPressed: () {
                          Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                          resetTeks();
                        },
                        child: new Text('No', style: TextStyle(color: Colors.grey.shade600))),
                    new ElevatedButton.icon(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("CLOSE"),
                        onPressed: () async {
                          Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: cardColor,
                              title: new Text('Information: CLOSE this data?',
                                  style: TextStyle(
                                    color: darkOrange,
                                    fontWeight: FontWeight.w600,
                                  )),
                              //content: new Text("Cancel data ini?"),
                              content: TextField(
                                //onChanged: (value) { },
                                controller: txtNotesAlert,
                                style: TextStyle(color: Colors.black87, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Note for approved",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: primaryOrange, width: 2),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                new TextButton(
                                    onPressed: () async {
                                      Navigator.of(globalScaffoldKey.currentContext!)
                                          .pop(false);
                                    },
                                    child: new Text('No', style: TextStyle(color: Colors.grey.shade600))),
                                new ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(globalScaffoldKey.currentContext!)
                                        .pop(false);
                                     approvedRequest(gtNumber, vhcid, "CLOSE",
                                        locid, txtNotesAlert.text);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: new Text('Ok', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600))),
                    new ElevatedButton.icon(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 15.0,
                        ),
                        label: Text("CANCEL"),
                        onPressed: () async {
                          Navigator.of(globalScaffoldKey.currentContext!).pop(false);
                          showDialog(
                            context: globalScaffoldKey.currentContext!,
                            builder: (context) => new AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: cardColor,
                              title: new Text('Information: CANCEL this data?',
                                  style: TextStyle(
                                    color: darkOrange,
                                    fontWeight: FontWeight.w600,
                                  )),
                              //content: new Text("Cancel data ini?"),
                              content: TextField(
                                //onChanged: (value) { },
                                controller: txtNotesAlert,
                                style: TextStyle(color: Colors.black87, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: "Note for approved",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: primaryOrange, width: 2),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                new TextButton(
                                    onPressed: () async {
                                      Navigator.of(globalScaffoldKey.currentContext!)
                                          .pop(false);
                                    },
                                    child: new Text('No', style: TextStyle(color: Colors.grey.shade600))),
                                new ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(globalScaffoldKey.currentContext!)
                                        .pop(false);
                                     approvedRequest(gtNumber, vhcid, "CANCEL",
                                        locid, txtNotesAlert.text);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: new Text('Ok', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600))),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ));
    } else {
      return Container();
    }
  }

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(globalScaffoldKey.currentContext!);
      },
      child: DefaultTabController(
      length: lengTabs,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              _goBack(globalScaffoldKey.currentContext!);
            },
          ),
          title: Text(
            'Request Moving Units',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 60.0),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: primaryOrange,
                indicatorWeight: 3,
                labelColor: primaryOrange,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                tabs: [
                  Tab(
                    icon: Icon(Icons.directions_car_outlined, size: 20),
                    child: Text('Moving Units'),
                  ),
                  Tab(
                    icon: Icon(Icons.list_alt_outlined, size: 20),
                    child: Text('List Request'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          key: globalScaffoldKey,
          controller: _tabController,
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: primaryOrange, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Form Request Moving',
                            style: TextStyle(
                              color: darkOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(12.0),
                      child: DateTimePicker(
                        dateMask: 'yyyy-MM-dd',
                        controller: txtDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event, color: primaryOrange),
                        dateLabelText: 'Date',
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Date",
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryOrange, width: 2),
                          ),
                        ),
                        selectableDayPredicate: (date) {
                          return true;
                        },
                        onChanged: (val) => setState(() => _dateRequest = val),
                        validator: (val) {
                          setState(() => _dateRequest = val ?? '');
                          return null;
                        },
                        onSaved: (val) =>
                            setState(() => _dateRequest = val ?? ''),
                      ),
                    ),
                    buildTextField(
                      labelText: "Vehicle Name",
                      controller: txtVehicleName,
                      readOnly: true,
                      onTap: () {
                        _showModalListVehicle(context);
                      },
                      fillColor: lightOrange,
                    ),
                    buildTextField(
                      labelText: "Driver Name",
                      controller: txtDriverName,
                      readOnly: true,
                      onTap: () {
                        _showModalListDriver(context);
                      },
                      fillColor: lightOrange,
                    ),
                    buildTextField(
                      labelText: "Cabang Name",
                      controller: txtCabangName,
                      readOnly: true,
                      onTap: () {
                        _showModalListCabang(context);
                      },
                      fillColor: lightOrange,
                    ),
                    buildTextField(
                      labelText: "Notes",
                      controller: txtNotes,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 12, top: 16, right: 12, bottom: 16),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: Colors.white,
                                size: 18.0,
                              ),
                              label: Text("Cancel"),
                              onPressed: () async {
                                resetTeks();
                                setState(() {
                                  btnSubmitText = bSave;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 2.0,
                                  backgroundColor: Colors.grey.shade500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600)),
                            )),
                        SizedBox(width: 12),
                        Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                                size: 18.0,
                              ),
                              label: Text("${btnSubmitText}"),
                              onPressed: () async {
                                if (is_edit_req != null && is_edit_req == true) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: cardColor,
                                      title: new Text('Information',
                                          style: TextStyle(
                                            color: darkOrange,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      content: new Text("${bUpdate}?"),
                                      actions: <Widget>[
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18.0,
                                          ),
                                          label: Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2.0,
                                              backgroundColor: Colors.grey.shade500,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 18.0,
                                          ),
                                          label: Text("Ok"),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                            print(username);
                                            // if (username == "ADI" ||
                                            //     username == "MAJID") {
                                            if(!getAkses()){
                                              _showOrangeAlert(context,
                                                  "Anda tidak dapat melakukan transaksi ini",
                                                  "error");
                                            } else {
                                              saveRequestMoving();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2.0,
                                              backgroundColor: primaryOrange,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  );
                                  print('Update');
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: cardColor,
                                      title: new Text('Information',
                                          style: TextStyle(
                                            color: darkOrange,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      content: new Text(
                                          "Save new request moving units?"),
                                      actions: <Widget>[
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18.0,
                                          ),
                                          label: Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2.0,
                                              backgroundColor: Colors.grey.shade500,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        new ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.save,
                                            color: Colors.white,
                                            size: 18.0,
                                          ),
                                          label: Text("Ok"),
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                            print(username);
                                            // if (username == "ADI" ||
                                            //     username == "MAJID") {
                                            if(!getAkses()){
                                              _showOrangeAlert(context,
                                                  "Anda tidak dapat melakukan transaksi ini",
                                                  "error");
                                            } else {
                                              saveRequestMoving();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2.0,
                                              backgroundColor: primaryOrange,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              textStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  );
                                  print('save');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 2.0,
                                  backgroundColor: primaryOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  textStyle: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600)),
                            )),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            _buildListView(context),
          ],
        ),
      ),
    ),
    );
  }
}