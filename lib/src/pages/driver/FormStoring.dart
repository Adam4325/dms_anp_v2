import 'dart:ffi';

import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/vehicle/ViewListVehicleNew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import '../../flusbar.dart';
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

class FormStoring extends StatefulWidget {
  @override
  _FormStoringState createState() => _FormStoringState();
}

class _FormStoringState extends State<FormStoring> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txtVHCID = new TextEditingController();
  TextEditingController txtDRIVER = new TextEditingController();
  TextEditingController txtNOTES = new TextEditingController();
  TextEditingController txtNoTelp = new TextEditingController();
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtLon = new TextEditingController();
  TextEditingController txtLat = new TextEditingController();
  bool isMock = false;
  var isShowLonLat = false;
  Position? userLocation;
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
        if (status_code != null && status_code == "200") {
          _km = json.decode(response.body)["km"];
        }
      });
    }
    print('return KM ${_km}');
    return _km;
  }

  Future<String?> UpdateReceiveLogDo() async {
    try {
      //String _photo = photo!=null && photo!=""?photo.toString().trim():"";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var drVID = prefs.getString("drvid")!;
      String vhCID = prefs.getString("vhcid")!;
      String name_event = prefs.getString("name_event")!;
      var dataParam = {
        "method": "update-or-insert-log",
        "drvid": drVID.toString(),
        "vhcid": vhCID.toString(),
        "name_event": name_event,
        "is_used": "0"
      };
      var urlData = "${GlobalData.baseUrl}api/log_receive_do.jsp";

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
    } catch (e) {
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
              loginname +
              "&name_event=" +
              name_event +
              "&drvid=${driver_id}&bujnumber=${bujnumber}";
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
    print('reset data');
  }

  Future<String> getAddressFromLatLon(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)'}, // wajib untuk Nominatim
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null) {
          return data['display_name'];
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<String?> saveService(
      String vhcid,
      String locid,
      String drvid,
      String vhckm,
      String userid,
      String notes,
      String notelpon,
      String loginname,
      String typereq) async {
    EasyLoading.show();
    try {
      var notes = txtNOTES.text;
      var lon = txtLon.text;
      var lat = txtLat.text;
      var address =
          await getAddressFromLatLon(double.parse(lat), double.parse(lon));
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/req_service_driver.jsp?method=set-service-v2" +
              "&vhcid=${vhcid}&locid=${locid}&drvid=${drvid}&vhckm=${vhckm}&vhckm=${vhckm}"
                  "&typereq=STORING&userid=${userid}&dlodate=&notes=${notes}&notelpon=${notelpon}&lat=${lat}&lon=${lon}&address=${address}";

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
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
          Timer(Duration(seconds: 1), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ViewDashboard()));
          });
        } else {
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
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
      vhcid = prefs.getString("vhcid")!;
      //vhcid = 'B 9565 YM';
      drvid = prefs.getString("drvid")!;
      locid = prefs.getString("locid")!;
      userid =
          globals.pages_name == "view-service" ? "" : prefs.getString("name")!;
      String km = prefs.getString("km_new_storing")!;
      txtKM.text =
          km.toString() == null || km.toString() == '' ? '0' : km.toString();
    }

    txtVHCID.text = vhcid;
    txtDRIVER.text = userid;
  }

  var truslat = "0.0";
  var trusLon = "0.0";
  var error = "";
  late Future<Position> _future;
  String txtAddr = "";

  Future<String> getAddress(String lat, String lon) async {
    var address = "";
    try {
      var urlOSM =
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1";
      print("URL OSM ${urlOSM}");
      var encoded = Uri.encodeFull(urlOSM);
      print(encoded);
      Uri urlEncode = Uri.parse(encoded);
      final response = await http.get(urlEncode, headers: {
        'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)',
      });
      print(response.body);
      if (response.statusCode == 200) {
        address = json.decode(response.body)["display_name"];
        print('JOSN address ${address}');
      } else {
        address = "";
      }
    } catch ($e) {
      address = "";
    }
    return address;
  }

  Future<bool> updatePositionOld(String inorout) async {
    var isOutGeo = false;
    var address = "";
    print("userLocation");
    print(userLocation);
    print(listGeofence);
    if (userLocation != null) {
      //userLocation.latitude = -6.453748413956308;
      //userLocation.longitude = 106.8842482566833;
      if (listGeofence.length > 0) {
        txtAddr = "";
        var radiusOld = 0.0;
        var geo_idOld = -1;
        var geo_nmOld = "";
        var isValid = false;
        var lat_osm = "";
        var lon_osm = "";

        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius']);
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lat']), double.parse(a['lon'])),
              LatLng(-6.453748413956308, 106.8842482566833));
          //LatLng(userLocation.latitude, userLocation.longitude));
          // print(
          //     'distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          geo_idOld = -1;
          print('radius ${radius}');
          if (distanceBetweenPoints <= radius) {
            radiusOld = radius;
            geo_idOld = int.parse(a['geo_id']);
            geo_nmOld = a['name'];
          }
        }
        print("geo_nmOld ${geo_nmOld} ${geo_idOld}");
        //geo_nmOld="";
        if (geo_idOld == -1) {
          isOutGeo = true;
        } else {
          isOutGeo = false;
        }
      }
    } else {
      print('No location');
      isOutGeo = false;
      _getLocation();
    }
    return isOutGeo;
  }

  Future<bool> updatePosition(String inorout) async {
    var isOutGeo = true; // default dianggap di luar
    print("userLocation: $userLocation");

    if (userLocation != null && listGeofence.isNotEmpty) {
      txtAddr = "";
      double latUser = userLocation!.latitude;
      double lonUser = userLocation!.longitude;

      for (var a in listGeofence) {
        double latGeo = double.parse(a['lat']);
        double lonGeo = double.parse(a['lon']);
        double radius = double.parse(a['radius']);

        num distance = SphericalUtil.computeDistanceBetween(
          LatLng(latGeo, lonGeo),
          LatLng(latUser, lonUser),
        );

        print(
            "🔹 Cek geofence ${a['name']}: distance = $distance m, radius = $radius m");
        if (radius > 0) {
          if (distance <= radius) {
            print("✅ Dalam geofence ${a['name']} (${a['geo_id']})");
            isOutGeo = false; // masih di dalam salah satu geofence
            break; // langsung keluar loop
          }
        }
      }

      print(
          "🚧 Hasil akhir: ${isOutGeo ? 'Di luar area geofence' : 'Di dalam area geofence'}");
    } else {
      print('⚠️ Tidak ada lokasi atau data geofence kosong');
      _getLocation();
    }

    return isOutGeo;
  }

  Future<Position> _getLocation() async {
    var currentLocation = null;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      try {
        isMock = await TrustLocation.isMockLocation;
      } catch (e) {
        print('TrustLocation isMockLocation check error: $e');
        isMock = false;
      }
      TrustLocation.start(5);

      /// the stream getter where others can listen to.
      TrustLocation.onChange.listen((values) {
            print(
                'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}');
            truslat = values.latitude!;
            trusLon = values.longitude!;
          });
      if (isMock == true) {
        txtLat.text = truslat;
        txtLon.text = trusLon;
      } else {
        if (currentLocation != null && userLocation != null) {
          print(userLocation!.longitude);
          print(userLocation!.latitude);
          txtLat.text = userLocation!.latitude.toString();
          txtLon.text = userLocation!.longitude.toString();
        }
      }

      /// stop repeating by timer
      TrustLocation.stop();
      //pos.
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == "PERMISSION_DENIED_NEVER_ASK") {
        error = 'Permission denied';
      }
      currentLocation = null;
    }
    print(error);
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    //getListSR();
    getListGeofenceArea(true);
    _future = _getLocation();
    _getLocation().then((position) {
      userLocation = position;
    });
    setState(() {
      txtSR.text = "STORING";
      getSession();
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
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
          title: Text('Submit Form Storing')),
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

  List listGeofence = [];

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/create_geofence_area.jsp?method=list-geofence-storing-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listGeofence = [];
          listGeofence = (jsonDecode(response.body) as List)
              //.map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          print(listGeofence);
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data geofence",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data geofence",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
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
                  if (isShowLonLat == true) ...[
                    ListTile(
                        title:
                            Text("LONGITUDE", style: TextStyle(fontSize: 12))),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 20, bottom: 0),
                      child: TextField(
                        readOnly: true,
                        cursorColor: Colors.black,
                        //style: TextStyle(color: Colors.grey.shade800),
                        controller: txtLon,
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
                            Text("LATITUDE", style: TextStyle(fontSize: 12))),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 20, bottom: 0),
                      child: TextField(
                        readOnly: true,
                        cursorColor: Colors.black,
                        //style: TextStyle(color: Colors.grey.shade800),
                        controller: txtLat,
                        decoration: new InputDecoration(
                          fillColor: Colors.black12,
                          filled: true,
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 5, bottom: 5, top: 5, right: 5),
                        ),
                      ),
                    )
                  ],
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
                      title: Text("NO. TELP", style: TextStyle(fontSize: 12))),
                  Container(
                    margin:
                        EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                    child: TextField(
                      cursorColor: Colors.black,
                      //style: TextStyle(color: Colors.grey.shade800),
                      controller: txtNoTelp,
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
                          onPressed: () async {
                            _future = _getLocation();
                            var isOutGeo = await updatePosition("IN");
                            if (isOutGeo) {
                              showDialog(
                                context: context,
                                builder: (context) => new AlertDialog(
                                  title: new Text('Information'),
                                  content: new Text("Storing kendaraan ?"),
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
                                        } else if (locid == "" ||
                                            locid == null) {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "LOCID tidak boleh kosong",
                                              "error");
                                        } else if (drvid == "" ||
                                            drvid == null) {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "Driver tidak boleh kosong",
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
                                        } else if (txtLat.text == "0.0" ||
                                            txtLon.text == "0.0") {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "Longitude latitude tidak boleh 0.0",
                                              "error");
                                        } else if (txtNoTelp.text == "" ||
                                            txtNoTelp.text == "") {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "No Telpon tidak bolrh kosong",
                                              "error");
                                        } else if (isMock == true) {
                                          alert(
                                              globalScaffoldKey.currentContext!,
                                              0,
                                              "Aplikasi tidak mengijinkan Fake GPS",
                                              "error");
                                        } else {
                                          await saveService(
                                              vhcid,
                                              locid,
                                              drvid,
                                              txtKM.value.text,
                                              userid,
                                              txtNOTES.value.text,
                                              txtNoTelp.text,
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
                            } else {
                              alert(
                                  globalScaffoldKey.currentContext!,
                                  0,
                                  "Anda berada dalam geofence ${txtAddr}",
                                  "error");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              textStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        )),
                        if (isShowLonLat == true) ...[
                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.map,
                              color: Colors.white,
                              size: 15.0,
                            ),
                            label: Text("Refresh Location"),
                            onPressed: () {
                              print('refresh location');
                              _future = _getLocation();
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ))
                        ]
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
