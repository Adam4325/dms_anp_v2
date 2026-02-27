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
      String imeiid = prefs.getString("androidID")!;
      String name_event = prefs.getString("name_event")!;
      var dataParam = {
        "method": "update-or-insert-log",
        "drvid": drVID.toString(),
        "vhcid": vhCID.toString(),
        "name_event": name_event,
        "imeiid": imeiid,
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
    String imeiid = prefs.getString("androidID")!;
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
              "&drvid=${driver_id}&bujnumber=${bujnumber}&imeiid=${imeiid}";
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String imeiid = prefs.getString("androidID")!;
      var notes = txtNOTES.text;
      var lon = txtLon.text;
      var lat = txtLat.text;
      var address =
          await getAddressFromLatLon(double.parse(lat), double.parse(lon));
      var urlData =
          "${GlobalData.baseUrl}api/maintenance/req_service_driver.jsp?method=set-service-v2" +
              "&vhcid=${vhcid}&locid=${locid}&drvid=${drvid}&vhckm=${vhckm}&vhckm=${vhckm}"
                  "&typereq=STORING&userid=${userid}&dlodate=&notes=${notes}&notelpon=${notelpon}&lat=${lat}&lon=${lon}&address=${address}&imeiid${imeiid}";

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
  late Future<Position?> _future;
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


  Future<bool> updatePosition(String inorout) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var locid = prefs.get("locid")!;
    print("locid");
    print(locid);
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
            if(locid.toString()=="BYH-ANP" || locid.toString()=="BYH-ANP MIX"){
              isOutGeo = true; // masih di dalam salah satu geofence
              txtLat.text = latUser.toString();
              txtLon.text = lonUser.toString();
              print("isOutGeo ${txtLat.text .toString()} ${txtLon.text}");
              print(isOutGeo);
              break; // langsung keluar loop
            }else{
              isOutGeo = false;
              break;
            }
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

  /// Mendapatkan posisi GPS: Geolocator.getCurrentPosition + TrustLocation (mock check).
  /// Mengisi txtLat, txtLon dan userLocation agar Submit bisa pakai koordinat yang valid (bukan 0.0).
  Future<Position?> _getLocation() async {
    Position? currentLocation;
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
      TrustLocation.onChange.listen((values) {
        print(
            'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}');
        truslat = values.latitude!;
        trusLon = values.longitude!;
      });

      if (isMock == true) {
        // Mock: pakai nilai dari stream (bisa masih 0.0 sampai stream emit); Submit tetap diblok validasi Fake GPS
        txtLat.text = truslat;
        txtLon.text = trusLon;
      } else {
        // Bukan mock: isi langsung dari currentLocation agar lat/lon tidak tetap 0.0
        if (currentLocation != null) {
          userLocation = currentLocation;
          txtLat.text = currentLocation.latitude.toString();
          txtLon.text = currentLocation.longitude.toString();
          if (mounted) setState(() {});
        }
      }

      TrustLocation.stop();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED' || e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied';
      }
      currentLocation = null;
    } catch (e) {
      error = 'Error: $e';
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    getListGeofenceArea(true);
    _future = _getLocation();
    _getLocation().then((position) {
      if (position != null) userLocation = position;
      if (mounted) setState(() {});
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
    const Color softOrange = Color(0xFFFF8C69);
    const Color softOrangeDark = Color(0xFFE07B39);
    const TextStyle btnTextWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

    return new Scaffold(
      backgroundColor: HexColor("#f0eff4"),
      appBar: AppBar(
          backgroundColor: softOrange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              _goBack(context);
            },
          ),
          centerTitle: true,
          title: Text('Submit Form Storing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
    const Color softOrange = Color(0xFFFF8C69);
    const Color softOrangeDark = Color(0xFFE07B39);
    const TextStyle btnTextWhite = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    const TextStyle labelStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: ListView(
        children: <Widget>[
          Card(
            elevation: 2.0,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text("VHCID", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
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
                                  builder: (context) => ViewListVehicleNew()));
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: globals.pages_name == "view-service"
                          ? "Klik untuk pilih kendaraan"
                          : null,
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("DRIVER", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.grey.shade800),
                    controller: txtDRIVER,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("SERVICE TYPE", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
                    readOnly: true,
                    cursorColor: Colors.black,
                    controller: txtSR,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  if (isShowLonLat == true) ...[
                    SizedBox(height: 12),
                    Text("LONGITUDE", style: labelStyle),
                    SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: txtLon,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text("LATITUDE", style: labelStyle),
                    SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: txtLat,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  Text("KM", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
                    cursorColor: Colors.black,
                    controller: txtKM,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("NO. TELP", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
                    cursorColor: Colors.black,
                    controller: txtNoTelp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("NOTES", style: labelStyle),
                  SizedBox(height: 4),
                  TextField(
                    cursorColor: Colors.black,
                    controller: txtNOTES,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(children: <Widget>[
                    Expanded(
                        child: ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white, size: 18),
                      label: Text("Submit", style: btnTextWhite),
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
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.close, color: Colors.white, size: 18),
                                      label: Text("Tidak", style: btnTextWhite),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Colors.grey.shade600,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.save, color: Colors.white, size: 18),
                                      label: Text("Submit", style: btnTextWhite),
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
                                        } else if (isMock == false) {
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
                                        backgroundColor: softOrangeDark,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
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
                            backgroundColor: softOrangeDark, //
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        )),
                    if (isShowLonLat == true) ...[
                      SizedBox(width: 12),
                      Expanded(
                          child: ElevatedButton.icon(
                        icon: Icon(Icons.map, color: Colors.white, size: 18),
                        label: Text("Refresh Location", style: btnTextWhite),
                        onPressed: () {
                          _future = _getLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: softOrangeDark,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ))
                    ]
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
