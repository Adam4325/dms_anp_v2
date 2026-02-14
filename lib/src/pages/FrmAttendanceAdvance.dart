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

class FrmAttendanceAdvanceState extends State<FrmAttendanceAdvance> {
  final String BASE_URL =
      GlobalData.baseUrlOri; // "http://apps.tuluatas.com:8080/trucking";
  bool isMock = true;
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
            label: Text("Camera"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('CAMERA');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          new ElevatedButton.icon(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20.0,
            ),
            label: Text("Gallery"),
            onPressed: () async {
              Navigator.of(contexs).pop(false);
               getPicture('GALLERY');
            },
            style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
          listGeofence = (jsonDecode(response.body) as List)
              //.map((dynamic e) => e as Map<String, dynamic>)
              .toList();
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
      isMock = await TrustLocation.isMockLocation;
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

  Future<String> getAddress(String lat, String lon) async {
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
      // var request = http.Request('GET', Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1'));
      //
      // http.StreamedResponse response = await request.send();
      // print('response.statusCode get Address ${response.statusCode}');
      // if (response.statusCode == 200) {
      //   var resBody = await response.stream.bytesToString();
      //   address = json.decode(resBody)["display_name"];
      // }
      // else {
      //   print(response.reasonPhrase);
      //   address = "";
      // }

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
        print('cetak address ${addr}');

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
    //await saveAttendance(inorout, 24, 'CIOMAS -HOME', "", lat, lon,address);
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
            // address = await getAddress(lat_osm.toString(),
            //     lon_osm.toString());
            // print('cetak address ${address}');
            // setState(() {
            //   txtAddr.text = address;
            // });
            radius = 0;
            geo_idOld = 0;
            geo_nmOld = "UNKNWON";
          }
        }
        print("geo_nmOld ${geo_nmOld}");
        //geo_nmOld="";
        if (geo_nmOld != "" && geo_nmOld != null) {
          setState(() {
            txtAddr.text = geo_nmOld;
            isValid = true;
          });
          // if(geo_nmOld==null || geo_nmOld ==""){
          //   print("ADDRESS 1");
          //   address = await getAddress(userLocation.latitude.toString(),
          //       userLocation.longitude.toString());
          //   setState(() {
          //     txtAddr.text = address;
          //   });
          // }
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
                  label: Text("No"),
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
                  label: Text("checked ${inorout.toUpperCase()}"),
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
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                  label: Text("No"),
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
                  label: Text("checked ${inorout.toUpperCase()}"),
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
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                label: Text("No"),
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
                label: Text("checked ${inorout.toUpperCase()}"),
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
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
          Container(
              child: Card(
                  elevation: 0.0,
                  shadowColor: Color(0x802196F3),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10.0),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(10),
                      //   color: Colors.white,
                      //   boxShadow: [
                      //     BoxShadow(color: Colors.blue, spreadRadius: 1),
                      //   ],
                      // ),
                      //height: MediaQuery.of(context).size.height,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () async {
                                  //_showPicker(context, "DRIVER");
                                  await getImageFromCamera(context, "PROFILE");
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _imageProfile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            _imageProfile!,
                                            width: 175,
                                            height: 200.0,
                                            scale: 0.8,
                                            fit: BoxFit.cover,
                                          ))
                                      : filePathImageProfile != null &&
                                              filePathImageProfile != ""
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.memory(
                                                _bytesImageProfile!,
                                                width: 175,
                                                height: 200.0,
                                                scale: 0.8,
                                                fit: BoxFit.cover,
                                              ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              width: 175,
                                              height: 200,
                                              child: ElevatedButton.icon(
                                                icon: Icon(
                                                  Icons.camera,
                                                  color: Colors.white,
                                                  size: 15.0,
                                                ),
                                                label: Text("Photo"), onPressed: () {  },
                                              ),
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
                              label: Text("Check IN"),
                              onPressed: () async {
                                await updatePosition("IN");
                                //await updatePositionTest("IN","-122.083922","37.4220936");
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
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
                              label: Text("Check OUT"),
                              onPressed: () async {
                                print('CHECK OUT');
                                await updatePosition("OUT");
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
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
                              label: Text("Submit ${dropdownvalue.toString()}"),
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
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ))
                          ]))
                    ],
                    if(akses_detail==true)...[
                    Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.arrow_right_outlined,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                label: Text("View Detail Cuti"),
                                onPressed: () async {
                                  print('Cuti detail');
                                  EasyLoading.show();
                                  Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (context) => ViewDetailCuti()));
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )),
                        ]))]
                  ])))
        ]));
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    namaKaryawan = prefs.getString("name")!;
    androidID = prefs.getString("androidID")!; //a114b4179bc8fd9f
    //androidID = "a114b4179bc8fd9f";
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




//
//
// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:dms_anp/src/Helper/Provider.dart';
// import 'package:dms_anp/src/flusbar.dart';
// import 'package:dms_anp/src/pages/ViewDashboard.dart';
// import 'package:dms_anp/src/pages/ViewDetailCuti.dart';
// import 'package:flutter/material.dart';
// import 'package:dms_anp/src/Color/hex_color.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maps_toolkit/maps_toolkit.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trust_location/trust_location.dart';
// import 'package:dms_anp/src/Helper/globals.dart' as globals;
//
// class FrmAttendanceAdvance extends StatefulWidget {
//   @override
//   FrmAttendanceAdvanceState createState() => FrmAttendanceAdvanceState();
// }
//
// final globalScaffoldKey = GlobalKey<ScaffoldState>();
//
// class FrmAttendanceAdvanceState extends State<FrmAttendanceAdvance> {
//   final String BASE_URL = GlobalData.baseUrlOri;
//   bool isMock = true;
//   String androidID = "";
//   List listGeofence = [];
//   String address = "";
//   Position userLocation;
//   String geo_id = "";
//   String geo_nm = "";
//   String namaKaryawan = "";
//   String jamAbsen = "";
//   String tglAbsen = "";
//   String timeIN = "";
//   String timeOUT = "";
//   String duration_check_out = "";
//   String dropdownvalue = 'Pilih Absensi';
//   var itemsShift = ['Pilih Absensi', 'storing', 'izin', 'sakit', 'cuti'];
//   TextEditingController txtAddr = new TextEditingController();
//   TextEditingController txtLonLat = new TextEditingController();
//   TextEditingController txtNote = new TextEditingController();
//   TextEditingController txtStartDate = new TextEditingController();
//   TextEditingController txtEndDate = new TextEditingController();
//   String start_date = '';
//   String end_date = '';
//   File _imageProfile;
//   var isShowAddress = false;
//   String filePathImageProfile = "";
//   String noImage = 'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
//   final picker = ImagePicker();
//   var status_absensi = "";
//   ProgressDialog pr;
//   var address_osm = "";
//   var akses_detail = false;
//
//   // Orange Soft Color Scheme
//   static const Color primaryOrange = Color(0xFFFF9A56);      // Main orange
//   static const Color lightOrange = Color(0xFFFFB988);        // Light orange
//   static const Color softOrange = Color(0xFFFDD5B8);         // Very soft orange
//   static const Color darkOrange = Color(0xFFE8743B);         // Dark orange
//   static const Color backgroundColor = Color(0xFFFFF8F3);     // Cream background
//   static const Color cardBackground = Color(0xFFFFFBF7);     // Off-white card
//
//   _goBack(BuildContext context) {
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => ViewDashboard()));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () {
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => ViewDashboard()));
//           return Future.value(false);
//         },
//         child: Scaffold(
//           key: globalScaffoldKey,
//           backgroundColor: primaryOrange,
//           appBar: AppBar(
//               backgroundColor: primaryOrange,
//               elevation: 0,
//               leading: IconButton(
//                 icon: Icon(Icons.arrow_back, color: Colors.white),
//                 iconSize: 24.0,
//                 onPressed: () {
//                   _goBack(context);
//                 },
//               ),
//               centerTitle: true,
//               title: Text(
//                 'Attendance Advance',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               )),
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   primaryOrange,
//                   backgroundColor,
//                 ],
//                 stops: [0.0, 0.3],
//               ),
//             ),
//             child: Stack(
//               children: <Widget>[
//                 FrmAttendance(context),
//               ],
//             ),
//           ),
//         ));
//   }
//
//   Widget FrmAttendance(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.all(16.0),
//         child: ListView(children: <Widget>[
//           Container(
//               child: Card(
//                   elevation: 8.0,
//                   shadowColor: softOrange.withOpacity(0.3),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   color: cardBackground,
//                   child: Column(children: <Widget>[
//                     // Header Section
//                     // Container(
//                     //   padding: EdgeInsets.all(20.0),
//                     //   decoration: BoxDecoration(
//                     //     color: softOrange,
//                     //     borderRadius: BorderRadius.only(
//                     //       topLeft: Radius.circular(20),
//                     //       topRight: Radius.circular(20),
//                     //     ),
//                     //   ),
//                     //   child: Column(
//                     //     children: [
//                     //       Icon(
//                     //         Icons.person_pin_circle,
//                     //         size: 40,
//                     //         color: darkOrange,
//                     //       ),
//                     //       SizedBox(height: 8),
//                     //       Text(
//                     //         "Employee Attendance",
//                     //         style: TextStyle(
//                     //           fontSize: 18,
//                     //           fontWeight: FontWeight.bold,
//                     //           color: darkOrange,
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//
//                     // Photo Section
//                     Container(
//                       margin: EdgeInsets.all(20.0),
//                       child: Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         color: Colors.white,
//                         child: Padding(
//                           padding: EdgeInsets.all(15.0),
//                           child: GestureDetector(
//                             onTap: () async {
//                               await getImageFromCamera(context, "PROFILE");
//                             },
//                             child: Container(
//                               alignment: Alignment.center,
//                               child: _imageProfile != null
//                                   ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(15),
//                                   child: Image.file(
//                                     _imageProfile,
//                                     width: 175,
//                                     height: 200.0,
//                                     scale: 0.8,
//                                     fit: BoxFit.cover,
//                                   ))
//                                   : filePathImageProfile != null &&
//                                   filePathImageProfile != ""
//                                   ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(15),
//                                   child: Image.memory(
//                                     _bytesImageProfile,
//                                     width: 175,
//                                     height: 200.0,
//                                     scale: 0.8,
//                                     fit: BoxFit.cover,
//                                   ))
//                                   : Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [lightOrange, softOrange],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 width: 175,
//                                 height: 200,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.camera_alt,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       "Take Photo",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Employee Info
//                     Container(
//                       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       padding: EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: softOrange.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: lightOrange.withOpacity(0.5)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.person, color: darkOrange, size: 20),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               "Employee: ${namaKaryawan}",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: darkOrange,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Dropdown Section
//                     Container(
//                       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: lightOrange),
//                         boxShadow: [
//                           BoxShadow(
//                             color: softOrange.withOpacity(0.2),
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton(
//                           isExpanded: true,
//                           value: dropdownvalue,
//                           icon: Icon(Icons.keyboard_arrow_down, color: primaryOrange),
//                           style: TextStyle(
//                             color: darkOrange,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           items: itemsShift.map((String items) {
//                             return DropdownMenuItem(
//                               value: items,
//                               child: Text(items),
//                             );
//                           }).toList(),
//                           onChanged: (String newValue) {
//                             setState(() {
//                               dropdownvalue = newValue;
//                               status_absensi = dropdownvalue;
//                             });
//                             if (dropdownvalue != null && dropdownvalue.toUpperCase() == 'CUTI') {
//                               setState(() {
//                                 akses_detail = true;
//                               });
//                             } else {
//                               setState(() {
//                                 akses_detail = false;
//                               });
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//
//                     // Conditional Content based on status_absensi
//                     if (status_absensi == "storing") ...[
//                       buildInfoCard("Location", txtAddr.text, Icons.location_on),
//                       if (isShowAddress == true) ...[
//                         buildInfoCard("Address", address_osm, Icons.home),
//                       ],
//                       buildInfoCard("Date", tglAbsen, Icons.calendar_today),
//                       buildInfoCard("Time IN", timeIN, Icons.login),
//                       buildInfoCard("Time OUT", timeOUT, Icons.logout),
//                       buildInfoCard("Duration", duration_check_out, Icons.timer),
//
//                       // Check IN/OUT Buttons
//                       Container(
//                         margin: EdgeInsets.all(20),
//                         child: Row(
//                           children: <Widget>[
//                             Expanded(
//                               child: Container(
//                                 height: 50,
//                                 child: ElevatedButton.icon(
//                                   icon: Icon(Icons.login, color: Colors.white, size: 20),
//                                   label: Text(
//                                     "Check IN",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     await updatePosition("IN");
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: primaryOrange,
//                                     elevation: 4,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 15),
//                             Expanded(
//                               child: Container(
//                                 height: 50,
//                                 child: ElevatedButton.icon(
//                                   icon: Icon(Icons.logout, color: Colors.white, size: 20),
//                                   label: Text(
//                                     "Check OUT",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     await updatePosition("OUT");
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: darkOrange,
//                                     elevation: 4,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//
//                     if (status_absensi == "cuti") ...[
//                       // Date Pickers for Cuti
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                         child: Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(right: 15,left: 15,top: 5,bottom: 5),
//                             child: DateTimePicker(
//                               dateMask: 'yyyy-MM-dd',
//                               controller: txtStartDate,
//                               firstDate: DateTime(1950),
//                               lastDate: DateTime(2100),
//                               icon: Icon(Icons.event, color: primaryOrange),
//                               dateLabelText: 'Start Date',
//                               style: TextStyle(color: darkOrange, fontSize: 16),
//                               decoration: InputDecoration(
//                                 hintText: "Start Date",
//                                 border: InputBorder.none,
//                                 labelStyle: TextStyle(color: primaryOrange),
//                               ),
//                               selectableDayPredicate: (date) {
//                                 return true;
//                               },
//                               onChanged: (val) => setState(() => start_date = val),
//                               validator: (val) {
//                                 setState(() => start_date = val ?? '');
//                                 return null;
//                               },
//                               onSaved: (val) => setState(() => start_date = val ?? ''),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                         child: Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(right: 15,left: 15,top: 5,bottom: 5),
//                             child: DateTimePicker(
//                               dateMask: 'yyyy-MM-dd',
//                               controller: txtEndDate,
//                               firstDate: DateTime(1950),
//                               lastDate: DateTime(2100),
//                               icon: Icon(Icons.event, color: primaryOrange),
//                               dateLabelText: 'End Date',
//                               style: TextStyle(color: darkOrange, fontSize: 16),
//                               decoration: InputDecoration(
//                                 hintText: "End Date",
//                                 border: InputBorder.none,
//                                 labelStyle: TextStyle(color: primaryOrange),
//                               ),
//                               selectableDayPredicate: (date) {
//                                 return true;
//                               },
//                               onChanged: (val) => setState(() => end_date = val),
//                               validator: (val) {
//                                 setState(() => end_date = val ?? '');
//                                 return null;
//                               },
//                               onSaved: (val) => setState(() => end_date = val ?? ''),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//
//                     if (status_absensi == "izin" || status_absensi == "sakit" || status_absensi == "cuti") ...[
//                       // Note Input
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                         child: Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(right: 15,left: 15,top: 5,bottom: 5),
//                             child: TextField(
//                               controller: txtNote,
//                               maxLines: 3,
//                               style: TextStyle(color: darkOrange, fontSize: 16),
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: 'Enter your notes here...',
//                                 hintStyle: TextStyle(color: lightOrange),
//                                 labelText: 'Note',
//                                 labelStyle: TextStyle(color: primaryOrange, fontWeight: FontWeight.w500),
//                                 prefixIcon: Icon(Icons.note_alt, color: primaryOrange),
//                                 helperText: 'Cuti, sakit dan izin wajib ada catatan',
//                                 helperStyle: TextStyle(color: lightOrange, fontSize: 12),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       // Submit Button
//                       Container(
//                         margin: EdgeInsets.all(20),
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton.icon(
//                           icon: Icon(Icons.send, color: Colors.white, size: 20),
//                           label: Text(
//                             "Submit ${dropdownvalue.toString()}",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           onPressed: () async {
//                             address = await getAddress(
//                                 userLocation.latitude.toString(),
//                                 userLocation.longitude.toString());
//                             var status = dropdownvalue.toString().toUpperCase();
//                             await saveAttendance(
//                                 status,
//                                 0,
//                                 "",
//                                 "",
//                                 userLocation.latitude.toString(),
//                                 userLocation.longitude.toString(),
//                                 address);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryOrange,
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//
//                     if (akses_detail == true) ...[
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton.icon(
//                           icon: Icon(Icons.visibility, color: Colors.white, size: 20),
//                           label: Text(
//                             "View Detail Cuti",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           onPressed: () async {
//                             EasyLoading.show();
//                             Navigator.pushReplacement(
//                                 context, MaterialPageRoute(builder: (context) => ViewDetailCuti()));
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: darkOrange,
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//
//                     SizedBox(height: 20),
//                   ])))
//         ]));
//   }
//
//   Widget buildInfoCard(String title, String value, IconData icon) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: lightOrange.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: softOrange.withOpacity(0.1),
//             blurRadius: 2,
//             offset: Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: primaryOrange, size: 20),
//           SizedBox(width: 12),
//           Text(
//             "$title: ",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: darkOrange,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: darkOrange.withOpacity(0.8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // [Keep all the existing methods unchanged]
//   void getPicture(opsi) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (opsi == 'GALLERY') {
//       final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
//       if (pickedFile != null) {
//         setState(() {
//           _imageProfile = File(pickedFile.path);
//           List<int> imageBytes = _imageProfile.readAsBytesSync();
//           filePathImageProfile = base64Encode(imageBytes);
//         });
//       }
//     } else {
//       final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
//       if (pickedFile != null) {
//         setState(() {
//           _imageProfile = File(pickedFile.path);
//           List<int> imageBytes = _imageProfile.readAsBytesSync();
//           filePathImageProfile = base64Encode(imageBytes);
//         });
//       }
//     }
//   }
//
//   Uint8List _bytesImageProfile;
//   void getProfileImage() async {
//     filePathImageProfile = '';
//   }
//
//   Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
//     showDialog(
//       context: contexs,
//       builder: (contexs) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         backgroundColor: cardBackground,
//         title: Row(
//           children: [
//             Icon(Icons.camera_alt, color: primaryOrange),
//             SizedBox(width: 10),
//             Text(
//               'Select Image Source',
//               style: TextStyle(color: darkOrange, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         content: Text(
//           "Choose how you want to get the picture",
//           style: TextStyle(color: darkOrange),
//         ),
//         actions: <Widget>[
//           ElevatedButton.icon(
//             icon: Icon(Icons.camera_alt, color: Colors.white, size: 18),
//             label: Text("Camera"),
//             onPressed: () async {
//               Navigator.of(contexs).pop(false);
//               await getPicture('CAMERA');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryOrange,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//           ElevatedButton.icon(
//             icon: Icon(Icons.photo_library, color: Colors.white, size: 18),
//             label: Text("Gallery"),
//             onPressed: () async {
//               Navigator.of(contexs).pop(false);
//               await getPicture('GALLERY');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: darkOrange,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future getListGeofenceArea(bool isload) async {
//     try {
//       if (isload) {
//         EasyLoading.show();
//       }
//       var urlData = "${BASE_URL}api/create_geofence_area.jsp?method=list-geofence-area-v1";
//       var encoded = Uri.encodeFull(urlData);
//       Uri myUri = Uri.parse(encoded);
//       var response = await http.get(myUri, headers: {"Accept": "application/json"});
//       if (response.statusCode == 200) {
//         setState(() {
//           listGeofence = [];
//           listGeofence = (jsonDecode(response.body) as List).toList();
//         });
//       } else {
//         alert(globalScaffoldKey.currentContext, 0, "Gagal load data geofence", "error");
//       }
//       if (EasyLoading.isShow) {
//         EasyLoading.dismiss();
//       }
//     } catch (e) {
//       alert(globalScaffoldKey.currentContext, 0, "Client, Load data geofence", "error");
//       if (EasyLoading.isShow) {
//         EasyLoading.dismiss();
//       }
//     }
//   }
//
//   double distance_in_meter(lat1, lon1, lat2, lon2) {
//     var R = 6371000;
//     var p = 0.017453292519943295;
//     var dLat = (lat1 - lat2) * pi / p;
//     var dLon = (lon1 - lon2) * pi / p;
//     var a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / p) * cos(lat2 * pi / p) * sin(dLon / 2) * sin(dLon / 2);
//     var c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     var d = R * c;
//     return d;
//   }
//
//   bool arePointsNear(checkPoint_lat, checkPoint_lon, centerPoint_lat, centerPoint_lon, meter) {
//     var ky = 40000 / 360;
//     var kx = cos(pi * centerPoint_lat / 180.0) * ky;
//     var dx = (centerPoint_lon - checkPoint_lon).abs() * kx;
//     var dy = (centerPoint_lat - checkPoint_lat).abs() * ky;
//     var ret = (sqrt(dx * dx + dy * dy));
//     return (1000 * (sqrt(dx * dx + dy * dy))) <= meter;
//   }
//
//   double calculateDistance(lat1, lon1, lat2, lon2) {
//     var p = 0.017453292519943295;
//     var c = cos;
//     var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 1000 * (12742 * asin(sqrt(a)));
//   }
//
//   var truslat = "0.0";
//   var trusLon = "0.0";
//   Future<Position> _getLocation() async {
//     var currentLocation = null;
//     try {
//       currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//       isMock = await TrustLocation.isMockLocation;
//       TrustLocation.start(5);
//       TrustLocation.onChange.listen((values) => {
//         truslat = values.latitude,
//         trusLon = values.longitude
//       });
//       TrustLocation.stop();
//     } catch (e) {
//       currentLocation = null;
//     }
//     return currentLocation;
//   }
//
//   Future<String> getAddress(String lat, String lon) async {
//     var address = "";
//     try {
//       var urlOSM = "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1";
//       var encoded = Uri.encodeFull(urlOSM);
//       Uri urlEncode = Uri.parse(encoded);
//       final response = await http.get(urlEncode);
//       if (response.statusCode == 200) {
//         address = json.decode(response.body)["display_name"];
//       } else {
//         address = "";
//       }
//     } catch ($e) {
//       address = "";
//     }
//     return address;
//   }
//
//   Future<String> saveAttendance(String inorout, int geo_id, String geo_nm, String employeeid, String lat, String lon, String addr) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       var user_id = prefs.getString("name");
//       if (androidID == null || androidID == "") {
//         alert(globalScaffoldKey.currentContext, 0, "IMEI ID kosong, silahkan kontak Administrator", "error");
//       } else if (dropdownvalue.toString() == 'Pilih Absensi') {
//         alert(globalScaffoldKey.currentContext, 0, "Type Absensi belum di pilih", "error");
//       } else if (user_id == null || user_id == "") {
//         alert(globalScaffoldKey.currentContext, 0, "USER ID tidak boleh kosong", "error");
//       } else if ((dropdownvalue.toString() == 'cuti' || dropdownvalue.toString() == 'sakit' || dropdownvalue.toString() == 'izin') && (txtNote.text == null || txtNote.text == '')) {
//         alert(globalScaffoldKey.currentContext, 0, "Note tidak boleh kosong", "error");
//       } else if ((dropdownvalue.toString() == 'cuti') && (start_date == null || start_date == '')) {
//         alert(globalScaffoldKey.currentContext, 0, "Start Date tidak boleh kosong", "error");
//       } else if ((dropdownvalue.toString() == 'cuti') && (end_date == null || end_date == '')) {
//         alert(globalScaffoldKey.currentContext, 0, "End Date tidak boleh kosong", "error");
//       } else {
//         if (EasyLoading.isShow) {
//           EasyLoading.dismiss();
//         }
//         var url_base = "";
//         if (inorout == "IN" || inorout == "OUT") {
//           url_base = "checkin-attendance-storing";
//         } else if (inorout.toUpperCase() == "IZIN") {
//           url_base = "checkin-attendance-izin";
//         } else if (inorout.toUpperCase() == "SAKIT") {
//           url_base = "checkin-attendance-sakit";
//         } else if (inorout.toUpperCase() == "CUTI") {
//           url_base = "checkin-attendance-cuti";
//         }
//         address_osm = await getAddress(lat.toString(), lon.toString());
//
//         var fake = isMock == true ? '1' : '0';
//         EasyLoading.show();
//         var data = {
//           'method': inorout,
//           'imeiid': androidID.toString(),
//           'status_absensi': dropdownvalue.toString(),
//           'geo_id': geo_id.toString(),
//           'geo_nm': geo_nm,
//           'is_mock': fake,
//           'employeeid': "",
//           'lat': lat,
//           'lon': lon,
//           'truslat': truslat,
//           'truslon': trusLon,
//           'address': address_osm,
//           'userid': user_id.toUpperCase(),
//           'start_date': start_date,
//           'end_date': end_date,
//           'company': 'AN',
//           'note': txtNote.text,
//         };
//         var encoded = Uri.encodeFull("${BASE_URL}api/${url_base}.jsp");
//         Uri urlEncode = Uri.parse(encoded);
//         final response = await http.post(
//           urlEncode,
//           body: data,
//           headers: {
//             "Content-Type": "application/x-www-form-urlencoded",
//           },
//           encoding: Encoding.getByName('utf-8'),
//         );
//         if (EasyLoading.isShow) {
//           EasyLoading.dismiss();
//         }
//         setState(() {
//           var message = "";
//           var status_code = 100;
//           var _tgl_absen = "";
//           var _duration = "";
//           var _timeIN = "";
//           var _timeOUT = "";
//           if (response.statusCode == 200) {
//             message = json.decode(response.body)["message"];
//             status_code = json.decode(response.body)["status_code"];
//             _tgl_absen = json.decode(response.body)["tgl_absen"];
//             _duration = json.decode(response.body)["duration"];
//             _timeIN = json.decode(response.body)["timein"];
//             _timeOUT = json.decode(response.body)["timeout"];
//
//             if (status_code == 200) {
//               tglAbsen = _tgl_absen;
//               duration_check_out = _duration;
//               timeIN = _timeIN;
//               timeOUT = _timeOUT;
//               alert(globalScaffoldKey.currentContext, 1, "${message}", "success");
//             } else if (status_code == 304) {
//               tglAbsen = _tgl_absen;
//               alert(globalScaffoldKey.currentContext, 2, "${message}", "Warning");
//             } else {
//               alert(globalScaffoldKey.currentContext, 0, "${message}", "error");
//             }
//           } else {
//             message = response.reasonPhrase;
//             alert(globalScaffoldKey.currentContext, 0, "${message}", "error");
//           }
//         });
//       }
//     } catch (e) {
//       if (EasyLoading.isShow) {
//         EasyLoading.dismiss();
//       }
//       alert(globalScaffoldKey.currentContext, 0, "Client, ${e}", "error");
//     }
//     return "";
//   }
//
//   Future updatePositionTest(String inorout, String lat, String lon) async {
//     var address = await getAddress(userLocation.latitude.toString(), userLocation.longitude.toString());
//   }
//
//   Future updatePosition(String inorout) async {
//     var address = "";
//     if (userLocation != null) {
//       if (listGeofence.length > 0) {
//         txtAddr.text = "";
//         var radiusOld = 0.0;
//         var geo_idOld = 0;
//         var geo_nmOld = "";
//         var isValid = false;
//         var lat_osm = "";
//         var lon_osm = "";
//         for (var i = 0; i < listGeofence.length; i++) {
//           var a = listGeofence[i];
//           var radius = double.parse(a['radius']);
//           var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
//               LatLng(double.parse(a['lat']), double.parse(a['lon'])), LatLng(userLocation.latitude, userLocation.longitude));
//           if (distanceBetweenPoints <= radius) {
//             if (i == 0) {
//               radiusOld = radius;
//               geo_idOld = int.parse(a['geo_id']);
//               geo_nmOld = a['name'];
//             } else {
//               if (radiusOld < radius) {
//                 radius = radiusOld;
//                 geo_idOld = int.parse(a['geo_id']);
//                 geo_nmOld = a['name'];
//               }
//             }
//           } else if (distanceBetweenPoints > radius) {
//             radius = 0;
//             geo_idOld = 0;
//             geo_nmOld = "UNKNWON";
//           }
//         }
//         if (geo_nmOld != "" && geo_nmOld != null) {
//           setState(() {
//             txtAddr.text = geo_nmOld;
//             isValid = true;
//           });
//         } else {
//           setState(() {
//             txtAddr.text = address;
//           });
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               backgroundColor: cardBackground,
//               title: Row(
//                 children: [
//                   Icon(Icons.info, color: primaryOrange),
//                   SizedBox(width: 10),
//                   Text('Confirmation', style: TextStyle(color: darkOrange, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               content: Text("checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?", style: TextStyle(color: darkOrange)),
//               actions: <Widget>[
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.close, color: Colors.white, size: 18),
//                   label: Text("No"),
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.check, color: Colors.white, size: 18),
//                   label: Text("Yes"),
//                   onPressed: () async {
//                     Navigator.of(context).pop(false);
//                     await saveAttendance(inorout, 0, "", "", userLocation.latitude.toString(), userLocation.longitude.toString(), address);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryOrange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (isValid == true) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               backgroundColor: cardBackground,
//               title: Row(
//                 children: [
//                   Icon(Icons.info, color: primaryOrange),
//                   SizedBox(width: 10),
//                   Text('Confirmation', style: TextStyle(color: darkOrange, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               content: Text("checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?", style: TextStyle(color: darkOrange)),
//               actions: <Widget>[
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.close, color: Colors.white, size: 18),
//                   label: Text("No"),
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.check, color: Colors.white, size: 18),
//                   label: Text("Yes"),
//                   onPressed: () async {
//                     Navigator.of(context).pop(false);
//                     await saveAttendance(inorout, geo_idOld, geo_nmOld, "", userLocation.latitude.toString(), userLocation.longitude.toString(), address);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryOrange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else {
//         address = await getAddress(userLocation.latitude.toString(), userLocation.longitude.toString());
//         txtAddr.text = address;
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             backgroundColor: cardBackground,
//             title: Row(
//               children: [
//                 Icon(Icons.info, color: primaryOrange),
//                 SizedBox(width: 10),
//                 Text('Confirmation', style: TextStyle(color: darkOrange, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             content: Text("checked ${inorout.toUpperCase()} absensi ${dropdownvalue.toString()}?", style: TextStyle(color: darkOrange)),
//             actions: <Widget>[
//               ElevatedButton.icon(
//                 icon: Icon(Icons.close, color: Colors.white, size: 18),
//                 label: Text("No"),
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.check, color: Colors.white, size: 18),
//                 label: Text("Yes"),
//                 onPressed: () async {
//                   Navigator.of(context).pop(false);
//                   await saveAttendance(inorout, 0, "", "", userLocation.latitude.toString(), userLocation.longitude.toString(), address);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryOrange,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//     } else {
//       _getLocation();
//     }
//   }
//
//   Timer timer = new Timer(new Duration(seconds: 5), () async {
//     var currentLocation = null;
//     try {
//       currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     } catch (e) {
//       currentLocation = null;
//     }
//     return currentLocation;
//   });
//
//   void getSession() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     namaKaryawan = prefs.getString("name");
//     androidID = prefs.getString("androidID");
//   }
//
//   void GetAksesViewDetail() async {
//     var isAkses = false;
//     SharedPreferences sf = await SharedPreferences.getInstance();
//     var username = sf.getString("username");
//     var isOK = globals.akses_pages == null ? globals.akses_pages : globals.akses_pages.where((x) => x == "HR");
//     if (isOK != null) {
//       if (isOK.length > 0) {
//         isAkses = true;
//       }
//     }
//     if (username == "ADMIN") {
//       isAkses = true;
//     }
//     akses_detail = isAkses;
//   }
//
//   @override
//   void initState() {
//     _getLocation().then((position) {
//       userLocation = position;
//     });
//     getSession();
//     getProfileImage();
//     getListGeofenceArea(false);
//     if (EasyLoading.isShow) {
//       EasyLoading.dismiss();
//     }
//     super.initState();
//   }
// }