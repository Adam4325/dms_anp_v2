import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewDetailCuti.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;

class FrmAttendanceAdvance extends StatefulWidget {
  @override
  FrmAttendanceAdvanceState createState() => FrmAttendanceAdvanceState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class FrmAttendanceAdvanceState extends State<FrmAttendanceAdvance> { //
  final String BASE_URL =
      GlobalData.baseUrlOri;
  bool isMock = false;
  String androidID = "";
  List listGeofence = [];
  String address = "";
  Position? userLocation;
  String geo_id = "";
  String geo_nm = "";
  String namaKaryawan = "";
  String jamAbsen = "";
  String tglAbsen = "";
  String timeIN = "";
  String timeOUT = "";
  String duration_check_out = "";
  String dropdownvalue = 'Pilih Absensi';
  var itemsShift = ['Pilih Absensi', 'storing', 'izin', 'sakit', 'cuti'];
  //sample final dt = '2022-02-07 05:00:11';DateFormat('yyyy-MM-dd HH:mm:ss').parse(dt);
  TextEditingController txtAddr = new TextEditingController();
  TextEditingController txtLonLat = new TextEditingController();
  TextEditingController txtNote = new TextEditingController();
  TextEditingController txtStartDate = new TextEditingController();
  TextEditingController txtEndDate = new TextEditingController();
  String start_date = '';
  String end_date = '';
  File? _imageProfile;
  var isShowAddress = false;
  String filePathImageProfile = "";
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();
  var status_absensi = "";
  ProgressDialog? pr;
  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void getPicture(opsi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString("photoProfile", "");
    if (opsi == 'GALLERY') {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
          //prefs.setString("photoProfile", filePathImageProfile);
        });
      }
    } else {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
          //prefs.setString("photoProfile", filePathImageProfile);
        });
      }
    }
  }

  Uint8List? _bytesImageProfile;
  void getProfileImage() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.getString("photoProfile") != null &&
    //     prefs.getString("photoProfile") != "") {
    //   _bytesImageProfile =
    //       Base64Decoder().convert(prefs.getString("photoProfile"));
    //   filePathImageProfile = prefs.getString("photoProfile");
    // }
    filePathImageProfile = '';
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    showDialog(
      context: contexs,
      builder: (contexs) => new AlertDialog(
        title: new Text('Information'),
        content: new Text("Get Picture"),
        actions: <Widget>[
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: const Text(
              "Camera",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: const Color(0xFFFF8C69),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: const Text(
              "Gallery",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: const Color(0xFFFF8C69),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${BASE_URL}api/create_geofence_area.jsp?method=list-geofence-area-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listGeofence = [];
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            listGeofence = List.from(decoded);
          } else if (decoded is Map && decoded.containsKey('data')) {
            final raw = decoded['data'];
            listGeofence = raw is List ? List.from(raw) : [];
          }
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

  double distance_in_meter(lat1, lon1, lat2, lon2) {
    var R = 6371000; // Radius of the earth in m
    var p = 0.017453292519943295;
    var dLat = (lat1 - lat2) * pi / p;
    var dLon = (lon1 - lon2) * pi / p;
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / p) * cos(lat2 * pi / p) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }

  bool arePointsNear(
      checkPoint_lat, checkPoint_lon, centerPoint_lat, centerPoint_lon, meter) {
    var ky = 40000 / 360;
    print(ky);
    var kx = cos(pi * centerPoint_lat / 180.0) * ky;
    var dx = (centerPoint_lon - checkPoint_lon).abs() * kx;
    var dy = (centerPoint_lat - checkPoint_lat).abs() * ky;
    //return sqrt(dx * dx + dy * dy) <= km;
    var ret = (sqrt(dx * dx + dy * dy));
    print('(sqrt(dx * dx + dy * dy))) ${ret}');
    return (1000 * (sqrt(dx * dx + dy * dy))) <= meter;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    //return 12742 * asin(sqrt(a)); for KM
    return 1000 * (12742 * asin(sqrt(a)));
  }

  var truslat = "0.0";
  var trusLon = "0.0";
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

      /// the stream getter where others can listen to.
      TrustLocation.onChange.listen((values) {
            print(
                'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}');
            truslat = values.latitude!;
            trusLon = values.longitude!;
          });

      /// stop repeating by timer
      TrustLocation.stop();
      //pos.
    } catch (e) {
      currentLocation = null;
    }
    //print(currentLocation);
    return currentLocation;
  }

  Future<String> getAddress(String? lat, String? lon) async {
    String address = "";

    // Validasi kosong
    if (lat == null || lon == null || lat.isEmpty || lon.isEmpty) {
      print("LAT LON kosong!");
      return "";
    }

    try {
      final uri = Uri.https(
        "nominatim.openstreetmap.org",
        "/reverse",
        {
          "format": "json",
          "lat": lat,
          "lon": lon,
          "zoom": "18",
          "addressdetails": "1"
        },
      );

      print("URL OSM: $uri");

      final response = await http.get(
        uri,
        headers: {
          "User-Agent": "DMS_ANP/1.0 (ANP Driver Management System)",
          "Accept": "application/json"
        },
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded != null && decoded["display_name"] != null) {
          address = decoded["display_name"];
        }
      }

    } catch (e) {
      print("ERROR Reverse OSM: $e");
    }

    return address;
  }

  Future<String> getAddressOLD(String lat, String lon) async {
    var address = "";
    try {
      var urlOSM ="https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1";
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
      }else{
        address = "";
      }

    } catch ($e) {
      address = "";
    }
    return address;
  }

  Future<String> saveAttendance(String inorout, int geo_id, String geo_nm,
      String employeeid, String lat, String lon, String addr) async {
    print('ADDRESS ${addr}');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString("name"); //Pilih Absensi
      if (androidID.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0,
            "IMEI ID kosong, silahkan kontak Administrator", "error");
      } else if (dropdownvalue.toString() == 'Pilih Absensi') {
        alert(globalScaffoldKey.currentContext!, 0,
            "Type Absensi belum di pilih", "error");
      } else if (user_id == null || user_id == "") {
        alert(globalScaffoldKey.currentContext!, 0, "USER ID tidak boleh kosong",
            "error");
      } else if ((dropdownvalue.toString() == 'cuti' ||
              dropdownvalue.toString() == 'sakit' ||
              dropdownvalue.toString() == 'izin') &&
          (txtNote.text == null || txtNote.text == '')) {
        alert(globalScaffoldKey.currentContext!, 0, "Note tidak boleh kosong",
            "error");
      }else if ((dropdownvalue.toString() == 'cuti') &&
          (start_date == null || start_date == '')) {
        alert(globalScaffoldKey.currentContext!, 0, "Start Date tidak boleh kosong",
            "error");
      }else if ((dropdownvalue.toString() == 'cuti') &&
          (end_date == null || end_date == '')) {
        alert(globalScaffoldKey.currentContext!, 0, "End Date tidak boleh kosong",
            "error");
      } else {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        print('SAVE ATTENDANCE');
        var url_base = "";
        if (inorout == "IN" || inorout == "OUT") {
          url_base = "checkin-attendance-storing";
        } else if (inorout.toUpperCase() == "IZIN") {
          url_base = "checkin-attendance-izin";
        } else if (inorout.toUpperCase() == "SAKIT") {
          url_base = "checkin-attendance-sakit";
        } else if (inorout.toUpperCase() == "CUTI") {
          url_base = "checkin-attendance-cuti";
        }
        //lat ="-6.4538741";
        //lon ="106.8018423";
        address_osm = await getAddress(lat.toString(),
            lon.toString());
        if (address_osm.isEmpty && txtAddr.text.trim().isNotEmpty) {
          address_osm = txtAddr.text.trim();
        }
        print('cetak address ${address_osm}');

        var fake = isMock == true ? '1' : '0';
        EasyLoading.show();
        var data = {
          'method': inorout,
          //'imeiid':"956ad8eab460883e",//androidID.toString(),
          'imeiid':androidID.toString(),
          'status_absensi': dropdownvalue.toString(),
          'geo_id': geo_id.toString(),
          'geo_nm': geo_nm,
          'is_mock': fake,
          'employeeid': "",
          'lat': lat,
          'lon': lon,
          'truslat': truslat,
          'truslon': trusLon,
          'address': address_osm,
          'userid': user_id.toUpperCase(),
          'start_date': start_date,
          'end_date': end_date,
          'company': 'AN',
          'note': txtNote.text,
        };
        print("Data param ${data}"); //DEMO
        print("SAVE "+"${BASE_URL}api/${url_base}.jsp");
        var encoded = Uri.encodeFull("${BASE_URL}api/${url_base}.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print(isMock);
        final response = await http.post(
            urlEncode,
            body: data,
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName('utf-8'),
          );
          print(response.body);
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          setState(() {
            String? message = "";
            var status_code = 100;
            var _tgl_absen = "";
            var _duration = "";
            var _timeIN = "";
            var _timeOUT = "";
            if (response.statusCode == 200) {
              message = json.decode(response.body)["message"];
              status_code = json.decode(response.body)["status_code"];
              _tgl_absen = json.decode(response.body)["tgl_absen"];
              _duration = json.decode(response.body)["duration"];
              _timeIN = json.decode(response.body)["timein"];
              _timeOUT = json.decode(response.body)["timeout"];

              if (status_code == 200) {
                tglAbsen = _tgl_absen;
                duration_check_out = _duration;
                timeIN = _timeIN;
                timeOUT = _timeOUT;
                alert(
                    globalScaffoldKey.currentContext!, 1, "${message}", "success");
              } else if (status_code == 304) {
                tglAbsen = _tgl_absen;
                alert(
                    globalScaffoldKey.currentContext!, 2, "${message}", "Warning");
              } else {
                alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
              }
            } else {
              message = response.reasonPhrase;//json.decode(response.reasonPhrase)["message"];
              alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      print(e.toString());
    }
    return "";
  }
  var address_osm = "";
  Future updatePositionTest(String inorout, String lat, String lon) async {
    print(androidID.toString());
    var address = await getAddress(
        userLocation!.latitude.toString(), userLocation!.longitude.toString());
    print(address);
    //await saveAttendance(inorout, 24, 'CIOMAS -HOME', "", lat, lon,addressss);
  }

  Future updatePosition(String inorout) async {
    print(androidID.toString());
    print("userLocation ${userLocation}");
    //LatLongPosition position = await TrustLocation.getLatLong();
    var address = "";
    if (userLocation != null) {
      print(userLocation);
      if (listGeofence.length > 0) {
        txtAddr.text = "";
        var radiusOld = 0.0;
        var geo_idOld = 0;
        var geo_nmOld = "";
        var isValid = false;
        var lat_osm = "";
        var lon_osm = "";
        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius']);
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lat']), double.parse(a['lon'])),
              LatLng(userLocation!.latitude, userLocation!.longitude));
          print(
              'distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          //userLocation.latitude =  -6.4538741;
          //userLocation.longitude = 106.8018423;
         //if (distanceBetweenPoints >= radius) { //FOR DEV
          //lat_osm = "-6.4538741";//userLocation.latitude.toString();
          //lon_osm = "106.8018423"; //userLocation.longitude.toString();
          if (distanceBetweenPoints <= radius) {
            if (i == 0) {
              radiusOld = radius;
              geo_idOld = int.parse(a['geo_id']);
              geo_nmOld = a['name'];
            } else {
              if (radiusOld < radius) {
                radius = radiusOld;
                geo_idOld = int.parse(a['geo_id']);
                geo_nmOld = a['name'];
              }
            }
          } else if (distanceBetweenPoints > radius) {
            address = await getAddress(
                userLocation!.latitude.toString(),
                userLocation!.longitude.toString());
            print('cetak address ${address}');
            setState(() {
              txtAddr.text = address;
            });
            radius = 0;
            geo_idOld = 0;
            geo_nmOld = address.isEmpty ? "UNKNOWN" : address;
          }
        }
        print("geo_nmOld ${geo_nmOld}");
        //geo_nmOld="";
        if (geo_nmOld != "" && geo_nmOld != null) {
          setState(() {
            txtAddr.text = geo_nmOld;
            isValid = true;
          });
        } else {
          print("ADDRESS 2");
          // address = await getAddress(userLocation.latitude.toString(),
          //     userLocation.longitude.toString());
          // print('cetak address ${address}');
          setState(() {
            txtAddr.text = address;
          });
          showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              content: new Text(
                  "checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?"),
              actions: <Widget>[
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text(
                    "No",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.red,
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
                  label: Text(
                    "checked ${inorout.toUpperCase()}",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await saveAttendance(
                        inorout,
                        0,
                        "",
                        "",
                        userLocation!.latitude.toString(),
                        userLocation!.longitude.toString(),
                        address);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: const Color(0xFFFF8C69),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          print('Address ${address}');
        }

        if (isValid == true) {
          print('create ${inorout} attendance');
          showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Information'),
              content: new Text(
                  "checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?"),
              actions: <Widget>[
                new ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text(
                    "No",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.red,
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
                  label: Text(
                    "checked ${inorout.toUpperCase()}",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await saveAttendance(
                        inorout,
                        geo_idOld,
                        geo_nmOld,
                        "",
                        userLocation!.latitude.toString(),
                        userLocation!.longitude.toString(),
                        address);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: const Color(0xFFFF8C69),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } else {
        //getListGeofenceArea(true);
        address = await getAddress(userLocation!.latitude.toString(),
            userLocation!.longitude.toString());
        txtAddr.text = address;
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Information'),
            content: new Text(
                "checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?"),
            actions: <Widget>[
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text(
                  "No",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              new ElevatedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: Text(
                  "checked ${inorout.toUpperCase()}",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  await saveAttendance(
                      inorout,
                      0,
                      "",
                      "",
                      userLocation!.latitude.toString(),
                      userLocation!.longitude.toString(),
                      address);
                },
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: const Color(0xFFFF8C69),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        print('Address ${address}');
      }
    } else {
      print('No location');
      _getLocation();
    }
  }

  Timer timer = new Timer(new Duration(seconds: 5), () async {
    var currentLocation = null;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      currentLocation = null;
    }
    //print(currentLocation);
    return currentLocation;
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
          return Future.value(false);
        },
        child: Scaffold(
          key: globalScaffoldKey,
          backgroundColor: const Color(0xFFFFF4E6), // soft orange background
          appBar: AppBar(
              backgroundColor: const Color(0xFFFF8C69), // soft orange appBar
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
              title: Text('Attendance Advance')),
          body: Container(
            constraints: BoxConstraints.expand(),
            color: HexColor("#f0eff4"),
            child: Stack(
              children: <Widget>[
                FrmAttendance(context),
              ],
            ),
          ),
        ));
  }

  Widget FrmAttendance(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
        child: ListView(children: <Widget>[
          // Photo section – disamakan desainnya dengan FrmAttendance.dart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Photo Profile",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await getImageFromCamera(context, "PROFILE");
                    },
                    child: Container(
                      width: 180,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: _imageProfile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageProfile!,
                                width: 180,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : filePathImageProfile != ""
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _bytesImageProfile ??
                                        Uint8List.fromList(const []),
                                    width: 180,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          size: 50,
                                          color: Colors.grey.shade600),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tap to add photo",
                                        style: TextStyle(
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 2, right: 20, bottom: 0),
                      child: Text("Nama Karyawan : ${namaKaryawan}",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 15)),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(
                    //       left: 20, top: 50, right: 20, bottom: 0),
                    //   child: InkWell(
                    //     onTap: () {
                    //       Share.share(
                    //           'http://apps.tuluatas.com:8080/trucking/master/update_imei.jsp?imeiid=${androidID}');
                    //     },
                    //     child: Text("IMEI ID : ${androidID}",
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //             fontSize: 18,
                    //             color: Colors.blueAccent,
                    //             decoration: TextDecoration.underline)),
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 2, right: 20, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButtonHideUnderline(
                              child:ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton(
                                  isExpanded: true,
                                  value: dropdownvalue,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: itemsShift.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownvalue = newValue!;
                                      status_absensi = dropdownvalue;
                                    });
                                    if(dropdownvalue!=null && dropdownvalue.toUpperCase()=='CUTI'){
                                      setState(() {
                                        akses_detail=true;
                                      });
                                    }else{
                                      setState(() {
                                        akses_detail=false;
                                      });
                                    }
                                  },
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    if (status_absensi == "storing") ...[
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Location : ${txtAddr.text}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15)),
                      ),
                      if(isShowAddress==true)...[
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Address : ${address_osm}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15)),
                      )],
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Date Absen : ${tglAbsen}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14)),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Time IN : ${timeIN}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14)),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Time OUT : ${timeOUT}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14)),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: Text("Duration : ${duration_check_out}",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15)),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                              left: 20, top: 5, right: 20, bottom: 0),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text(
                                "Check IN",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                await updatePosition("IN");
                                //await updatePositionTest("IN","-122.083922","37.4220936");
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: const Color(0xFF4CAF50),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text(
                                "Check OUT",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                print('CHECK OUT');
                                await updatePosition("OUT");
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: const Color(0xFFFF8C69),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            )),
                          ]))
                    ],
                    if (status_absensi == "cuti") ...[
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: DateTimePicker(
                          //type: DateTimePickerType.dateTimeSeparate,
                          dateMask: 'yyyy-MM-dd',
                          controller: txtStartDate,
                          //initialValue: _initialValue,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          icon: Icon(Icons.event),
                          dateLabelText: 'Start Date',
                          selectableDayPredicate: (date) {
                            return true;
                          },
                          onChanged: (val) => setState(() => start_date = val),
                          validator: (val) {
                            setState(() => start_date = val ?? '');
                            return null;
                          },
                          onSaved: (val) =>
                              setState(() => start_date = val ?? ''),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: DateTimePicker(
                          //type: DateTimePickerType.dateTimeSeparate,
                          dateMask: 'yyyy-MM-dd',
                          controller: txtEndDate,
                          //initialValue: _initialValue,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          icon: Icon(Icons.event),
                          dateLabelText: 'End Date',
                          selectableDayPredicate: (date) {
                            return true;
                          },
                          onChanged: (val) => setState(() => end_date = val),
                          validator: (val) {
                            setState(() => end_date = val ?? '');
                            return null;
                          },
                          onSaved: (val) =>
                              setState(() => end_date = val ?? ''),
                        ),
                      )
                    ],
                    if (status_absensi == "izin" ||
                        status_absensi == "sakit" ||
                        status_absensi == "cuti") ...[
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 2, right: 20, bottom: 0),
                        child: TextField(
                          controller: txtNote,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                              hintText: 'Note',
                              helperText:
                                  'Cuti,sakit dan izin wajib ada catatan',
                              labelText: 'Note',
                              prefixIcon: const Icon(
                                Icons.book,
                                color: Colors.green,
                              ),
                              prefixText: ' ',
                              //suffixText: 'USD',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                              left: 20, top: 5, right: 20, bottom: 0),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              label: Text(
                                "Submit ${dropdownvalue.toString()}",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                print('Submit ${dropdownvalue.toString()}');
                                address = await getAddress(
                                    userLocation!.latitude.toString(),
                                    userLocation!.longitude.toString());
                                var status =
                                    dropdownvalue.toString().toUpperCase();
                                //IJIN,CUTI,SAKIT
                                await saveAttendance(
                                    status,
                                    0,
                                    "",
                                    "",
                                    userLocation!.latitude.toString(),
                                    userLocation!.longitude.toString(),
                                    address);
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: const Color(0xFFFF8C69),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ))
                          ]))
                    ],
                    if (akses_detail == true)
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.arrow_right_outlined,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: const Text(
                                  "View Detail Cuti",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  print('Cuti detail');
                                  EasyLoading.show();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewDetailCuti(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: const Color(0xFFFF8C69),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ]));
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    namaKaryawan = prefs.getString("name")!;
    androidID = prefs.getString("androidID")!; //a114b4179bc8fd9f
  }

  var akses_detail = false;
  void GetAksesViewDetail() async {
    var isAkses = false;
    SharedPreferences sf = await SharedPreferences.getInstance();
    var username = sf.getString("username");
    var isOK = globals.akses_pages == null
        ? globals.akses_pages
        : globals.akses_pages.where((x) => x == "HR");
    if (isOK != null) {
      if (isOK.length > 0) {
        isAkses =  true;
      }
    }
    if(username=="ADMIN"){
      isAkses =  true;
    }

    akses_detail =  isAkses;
    print('akses_detail ${akses_detail}');
  }

  @override
  void initState() {
    //GetAksesViewDetail();
    _getLocation().then((position) {
      userLocation = position;
    });
    //_getLocation();
    getSession();
    getProfileImage();
    getListGeofenceArea(false);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }
}