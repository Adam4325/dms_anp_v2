import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmRequestAttendance.dart';
import 'package:dms_anp/src/pages/LogRequestAttendance.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrmAttendanceNew extends StatefulWidget {
  @override
  FrmAttendanceNewState createState() => FrmAttendanceNewState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class FrmAttendanceNewState extends State<FrmAttendanceNew> {
  final String BASE_URL =
      GlobalData.baseUrlOri; // "http://apps.tuluatas.com:8080/trucking";

  String androidID = "";
  List listGeofence = [];
  String address = "";

  String geo_id = "";
  String geo_nm = "";
  String namaKaryawan = "";
  String jamAbsen = "";
  String tglAbsen = "";
  String timeIN = "";
  String timeOUT = "";
  String duration_check_out = "";
  String dropdownvalue = 'no shift';
  var itemsShift = ['no shift', 'shift'];
  TextEditingController txtAddr = new TextEditingController();
  TextEditingController txtLonLat = new TextEditingController();

  Position? userLocation;
  LocationData? currentLocation;
  late Location location;
  double _lat = 0.0;
  double _lon = 0.0;

  bool _serviceEnabled = true;
  bool _isisMock = false;
  File? _imageProfile;
  String filePathImageProfile = "";
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();

  ProgressDialog? pr;
  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void getPicture(opsi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("photoProfile", "");
    if (opsi == 'GALLERY') {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
          prefs.setString("photoProfile", filePathImageProfile);
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
          prefs.setString("photoProfile", filePathImageProfile);
        });
      }
    }
  }

  Uint8List? _bytesImageProfile;
  void getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final photo = prefs.getString("photoProfile");
    if (photo != null && photo.isNotEmpty) {
      _bytesImageProfile = Base64Decoder().convert(photo);
      filePathImageProfile = photo;
    }
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

  // Future<Position> _getLocation() async {
  //   var currentLocation = null;
  //   try {
  //     currentLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   //print(currentLocation);
  //   return currentLocation;
  // }

  void _getLocation() async {
    location = Location();
    var _permissionGranted = await location.hasPermission();
    _serviceEnabled = await location.serviceEnabled();
    print('_permissionGranted');
    print(_permissionGranted);
    print(_serviceEnabled);
    if (_permissionGranted != PermissionStatus.granted || !_serviceEnabled) {
      ///asks permission and enable location dialogs

      _permissionGranted = await location.requestPermission();
      _serviceEnabled = await location.requestService();
    } else {
      ///Do something here
      print('null location');
    }

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      _isisMock = currentLocation?.isMock ?? false;
      //print("currentLocation.latitude ${currentLocation.latitude}");
      //print("currentLocation.longitude ${currentLocation.longitude}");
      _lat = currentLocation?.latitude ?? 0;
      _lon = currentLocation?.longitude ?? 0;
      //print('change location');
    });
  }

  Future<String> saveAttendance(String inorout, int geo_id, String geo_nm,
      String employeeid, String lat, String lon) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString("name");
      if (androidID.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0,
            "IMEI ID kosong, silahkan kontak Administrator", "error");
      } else if (user_id == null || user_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "USER ID tidak boleh kosong", "error");
      } else if (geo_id <= 0) {
        alert(globalScaffoldKey.currentContext!, 0, "GEO ID tidak boleh kosong",
            "error");
      } else {
        print('SAVE ATTENDANCE');
        var isMOCK = _isisMock;
        var encoded =
            Uri.encodeFull("${BASE_URL}api/check_in_out_geofence_new2.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        var data = {
          'method': inorout == "IN"
              ? "checkin-attendance-v3"
              : "checkout-attendance-v3",
          'imeiid': androidID.toString(),
          'shift': dropdownvalue.toString(),
          'geo_id': geo_id.toString(),
          'geo_nm': geo_nm,
          'is_mock': isMOCK == true ? 1 : 0,
          'employeeid': "",
          'lat': lat,
          'lon': lon,
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
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }
        setState(() {
          var message = "";
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
              alert(globalScaffoldKey.currentContext!, 1, "${message}",
                  "success");
            } else if (status_code == 304) {
              tglAbsen = _tgl_absen;
              alert(globalScaffoldKey.currentContext!, 2, "${message}",
                  "Warning");
            } else {
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            message = json.decode(response.body)["message"];
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

  Future updatePositionTest(String inorout, String lat, String lon) async {
    print(androidID.toString());
    await saveAttendance(inorout, 24, 'CIOMAS -HOME', "", lat, lon);
  }

  Future updatePosition(String inorout) async {
    print(androidID.toString());
    print(userLocation);
    if (userLocation != null) {
      print(userLocation);
      if (listGeofence.length > 0) {
        txtAddr.text = "";
        var radiusOld = 0.0;
        var geo_idOld = 0;
        var geo_nmOld = "";
        var isValid = false;
        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius']);
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lat']), double.parse(a['lon'])),
              LatLng(userLocation!.latitude, userLocation!.longitude));
          print(
              'distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          //if (distanceBetweenPoints >= radius) { //FOR DEV
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
          }
        }

        if (geo_nmOld.isNotEmpty) {
          setState(() {
            txtAddr.text = geo_nmOld;
            isValid = true;
          });
        } else {
          setState(() {
            txtAddr.text = "Position tidak dapat";
          });
        }

        if (isValid == true) {
          print('create ${inorout} attendance');
          await saveAttendance(
              inorout,
              geo_idOld,
              geo_nmOld,
              "",
              userLocation!.latitude.toString(),
              userLocation!.longitude.toString());
        }
      } else {
        getListGeofenceArea(true);
      }
    } else {
      print('location');
      _getLocation();
    }
    Timer(const Duration(seconds: 1), () {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    });
  }

  // Timer timer = new Timer(new Duration(seconds: 5), () async {
  //   var currentLocation = null;
  //   try {
  //     currentLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   //print(currentLocation);
  //   return currentLocation;
  // });

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
              title: Text('Attendance 2')),
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
                                                label: Text("Photo Profile"),
                                                onPressed: () {},
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
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 50, right: 20, bottom: 0),
                      child: InkWell(
                        onTap: () {
                          Share.share(
                              'http://apps.tuluatas.com:8080/trucking/master/update_imei.jsp?imeiid=${androidID}');
                        },
                        child: Text("IMEI ID : ${androidID}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 2, right: 20, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton(
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
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 2, right: 20, bottom: 0),
                      child: Text("Location : ${txtAddr.text}",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 15)),
                    ),
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
                                    fontSize: 12, fontWeight: FontWeight.bold)),
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
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          )),
                        ])),
                    Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.create,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: Text("Request Attendance"),
                            onPressed: () async {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FrmRequestAttendance()));
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                textStyle: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          )),
                          //   SizedBox(
                          //     width: 10,
                          //   ),
                          //   Expanded(
                          //       child: ElevatedButton.icon(
                          //         icon: Icon(
                          //           Icons.history,
                          //           color: Colors.white,
                          //           size: 24.0,
                          //         ),
                          //         label: Text("Log Request"),
                          //         onPressed: () async{
                          //           Navigator.pushReplacement(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (context) => LogRequestAttendance()));
                          //         },
                          //         style: ElevatedButton.styleFrom(
                          //             elevation: 0.0,
                          //             backgroundColor: Colors.blue,
                          //             padding:
                          //             EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          //             textStyle: TextStyle(
                          //                 fontSize: 12, fontWeight: FontWeight.bold)),
                          //       )),
                        ])),
                  ])))
        ]));
  }

  Widget FrmAttendanceOld(BuildContext context) {
    return Container(
      //padding: EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 0),
      child: Card(
        elevation: 0.0,
        shadowColor: Color(0x802196F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 0),
              child: InkWell(
                onTap: () {
                  Share.share(
                      'http://apps.tuluatas.com:8080/trucking/master/update_imei.jsp?imeiid=${androidID}');
                },
                child: Text("IMEI ID : ${androidID}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
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
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Nama Karyawan : ${namaKaryawan}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 15)),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Location : ${txtAddr.text}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 15)),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Date Absen : ${tglAbsen}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 14)),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Time IN : ${timeIN}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 14)),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Time OUT : ${timeOUT}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 14)),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 2, right: 20, bottom: 0),
              child: Text("Duration : ${duration_check_out}",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 15)),
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 0),
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
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                ])),
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
                    label: Text("Request Attendance"),
                    onPressed: () async {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FrmRequestAttendance()));
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        textStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  )),
                  //   SizedBox(
                  //     width: 10,
                  //   ),
                  //   Expanded(
                  //       child: ElevatedButton.icon(
                  //         icon: Icon(
                  //           Icons.history,
                  //           color: Colors.white,
                  //           size: 24.0,
                  //         ),
                  //         label: Text("Log Request"),
                  //         onPressed: () async{
                  //           Navigator.pushReplacement(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => LogRequestAttendance()));
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //             elevation: 0.0,
                  //             backgroundColor: Colors.blue,
                  //             padding:
                  //             EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  //             textStyle: TextStyle(
                  //                 fontSize: 12, fontWeight: FontWeight.bold)),
                  //       )),
                ])),
            Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.blue, spreadRadius: 1),
                ],
              ),
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
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
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageProfile!,
                                    width: double.infinity,
                                    height: 200.0,
                                    scale: 0.8,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: double.infinity,
                                  height: 200,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                    label: Text("Photo Profile"),
                                    onPressed: () {},
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    namaKaryawan = prefs.getString("name")!;
    androidID = prefs.getString("androidID")!;
  }

  @override
  void initState() {
    // _getLocation().then((position) {
    //   userLocation = position;
    // });

    getSession();
    getListGeofenceArea(false);
    _getLocation();
    getProfileImage();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }
}
