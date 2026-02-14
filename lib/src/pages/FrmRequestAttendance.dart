import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Create a Form widget.
class FrmRequestAttendance extends StatefulWidget {
  @override
  FrmRequestAttendanceState createState() => FrmRequestAttendanceState();
}

class FrmRequestAttendanceState extends State<FrmRequestAttendance> {
  final globalScaffoldKey = GlobalKey<FormState>();
  late Location location;
  late LocationData currentLocation;
  final String BASE_URL = GlobalData.baseUrlOri;
  String androidID = "";
  ProgressDialog? pr;
  TextEditingController txtGeofenceName = new TextEditingController();
  TextEditingController txtLat = new TextEditingController();
  TextEditingController txtLon = new TextEditingController();
  TextEditingController txtRadius = new TextEditingController();
  TextEditingController txtAddress = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  late Position userLocation;

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true);

    pr?.style(
      message: 'Proses...',
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
      key: globalScaffoldKey,
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              _goBack(globalScaffoldKey.currentContext!);
            },
          ),
          //backgroundColor: Colors.transparent,
          //elevation: 0.0,
          centerTitle: true,
          title: Text('Request Attendance')),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            FrmAttendance(context),
          ],
        ),
      ),
    );
  }

  // Future<Position> _getLocation() async {
  //   // var currentLocation = null;
  //   // try {
  //   //   currentLocation = await Geolocator.getCurrentPosition(
  //   //       desiredAccuracy: LocationAccuracy.best);
  //   // } catch (e) {
  //   //   currentLocation = null;
  //   // }
  //   // //print(currentLocation);
  //   // return currentLocation;
  // }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    androidID = prefs.getString("androidID")!;
  }

  void ClearTeks() {
    setState(() {
      txtGeofenceName.text = "";
      txtLat.text = "";
      txtLon.text = "";
      txtRadius.text = "";
      txtAddress.text = "";
      txtNotes.text = "";
    });
  }

  Future<String> saveRequestAttendance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String geo_nm = txtGeofenceName.text;
      String lat = txtLat.text;
      String lon = txtLon.text;
      String radius = txtRadius.text;
      String address = txtAddress.text;
      String note = txtNotes.text;
      var user_id = prefs.getString("name");

      if (androidID == null || androidID == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "IMEI ID kosong, silahkan kontak Administrator", "error");
      } else if (user_id == null || user_id == "") {
        alert(globalScaffoldKey.currentContext!, 0, "USER ID tidak boleh kosong",
            "error");
      } else if (geo_nm == null || geo_nm == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Geofence Name tidak boleh kosong", "error");
      } else if (lat == null || lat == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Latitude tidak boleh kosong", "error");
      } else if (lon == null || lon == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Longitude tidak boleh kosong", "error");
      } else if (address == null || address == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Address tidak boleh kosong",
            "error");
      } else if (note == null || note == "") {
        alert(globalScaffoldKey.currentContext!, 0, "Note tidak boleh kosong",
            "error");
      } else {
        //await pr.show();
        print('SAVE request ATTENDANCE');
        if (pr!.isShowing()) {
          await pr?.show();
        }
        var encoded = Uri.encodeFull("${BASE_URL}api/attendance_geofence.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': "create--request-attendance-v1",
          'imeiid': androidID.toString(),
          'geo_nm': geo_nm,
          'lat': lat,
          'lon': lon,
          'radius': radius,
          'address': address,
          'notes': note,
          'employeeid': "",
          'userid': user_id.toUpperCase(),
          'company': 'AN'
        };
        print(data); //DEMO
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );
        print(response.body);
        if (pr!.isShowing()) {
          await pr?.hide();
        }
        setState(() {
          var message = "";
          var status_code = 100;
          if (response.statusCode == 200) {
            message = json.decode(response.body)["message"];
            status_code = json.decode(response.body)["status_code"];

            if (status_code == 200) {
              ClearTeks();
              alert(
                  globalScaffoldKey.currentContext!, 1, "${message}", "success");
            } else if (status_code == 304) {
              alert(
                  globalScaffoldKey.currentContext!, 2, "${message}", "Warning");
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            message = json.decode(response.body)["message"];
            alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
          }
        });
      }
    } catch (e) {
      // if (pr.isShowing()) {
      //   await pr.hide();
      // }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
    return "";
  }

  @override
  void initState() {
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
    // _getLocation().then((position) {
    //   userLocation = position;
    // });
    // getListGeofenceArea(false);
    getSession();
    setState(() {
      if (userLocation != null) {
        txtLat.text = userLocation.latitude.toString();
        txtLon.text = userLocation.longitude.toString();
      }

      txtRadius.text = "100";
    });
    super.initState();
  }

  Widget FrmAttendance(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 0),
      child: Card(
        elevation: 0.0,
        shadowColor: Color(0x802196F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
              child: TextField(
                  controller: txtGeofenceName,
                  decoration: InputDecoration(
                      labelText: "Geofence Name", hintText: "Geofence Name")),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
              child: TextField(
                  controller: txtLat,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]'))
                  ],
                  decoration:
                      InputDecoration(labelText: "Lat", hintText: "Lat")),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
              child: TextField(
                  controller: txtLon,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\.]'))
                  ],
                  decoration:
                      InputDecoration(labelText: "Lon", hintText: "Lon")),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
                child: TextField(
                    controller: txtRadius,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Radius", hintText: "Radius"))),
            Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
              child: TextField(
                  controller: txtAddress,
                  decoration: InputDecoration(
                      labelText: "Address", hintText: "Address")),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
              child: TextField(
                  controller: txtNotes,
                  decoration:
                      InputDecoration(labelText: "Note", hintText: "Note")),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
                child: Row(children: <Widget>[
                  Expanded(
                      child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.create,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    label: Text("Create Request"),
                    onPressed: () async {
                      print('save');
                      print(txtGeofenceName.text);
                      await saveRequestAttendance();
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ))
                ])),
          ],
        ),
      ),
    );
  }
}
