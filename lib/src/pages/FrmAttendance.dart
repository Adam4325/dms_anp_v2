import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmRequestAttendance.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as Io;
import 'package:trust_location/trust_location.dart';

class FrmAttendance extends StatefulWidget {
  @override
  FrmAttendanceState createState() => FrmAttendanceState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class FrmAttendanceState extends State<FrmAttendance> {
  final String BASE_URL = GlobalData.baseUrlOri;
  bool isMock = true;
  String androidID = "";
  List listGeofence = [];
  List<Map<String, dynamic>> listInfoAbsensi = [];
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
  String dropdownvalue = 'no shift';
  var itemsShift = ['no shift', 'shift'];
  double truslat = 0.0;
  double trusLon = 0.0;

  TextEditingController txtAddr = new TextEditingController();
  TextEditingController txtLonLat = new TextEditingController();

  File? _imageProfile;
  String filePathImageProfile = "";
  String noImage = 'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  final picker = ImagePicker();

  Uint8List? _bytesImageProfile;
  ProgressDialog? pr;

  @override
  void initState() {
    _getLocation().then((position) {
      userLocation = position;
    });
    getSession();
    getProfileImage();
    getListGeofenceArea(false);
    getAbsenHariIni(false);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    namaKaryawan = prefs.getString("name") ?? "";
    androidID = prefs.getString("androidID") ?? "";
  }

  void getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final photo = prefs.getString("photoProfile");
    if (photo != null && photo.isNotEmpty) {
      _bytesImageProfile = Base64Decoder().convert(photo);
      filePathImageProfile = photo;
    }
  }

  void getPicture(opsi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("photoProfile", "");
    if (opsi == 'GALLERY') {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
          prefs.setString("photoProfile", filePathImageProfile);
        });
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
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

  Future<Position?> _getLocation() async {
    bool isMockLocation = await TrustLocation.isMockLocation;
    if (isMockLocation) {
      setState(() {
        isMock = true;
      });
    } else {
      setState(() {
        isMock = false;
      });
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      TrustLocation.start(5);
      TrustLocation.onChange.listen((values) => {
        print('TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}'),
        truslat = values.longitude as double,
        trusLon = values.longitude as double
      });
      TrustLocation.stop();
    } catch (e) {
      print('TrustLocation error: $e');
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = position;
      address = "${position.latitude},${position.longitude}";
    });
    return position;
  }

  Future<String> getAddress(String lat, String lon) async {
    var address = "";
    try {
      var encoded = Uri.encodeFull(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1");
      print(encoded);
      Uri urlEncode = Uri.parse(encoded);
      final response = await http.get(urlEncode, headers: {
        'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)',
      });
      print(response.body);
      if (response.statusCode == 200) {
        address = json.decode(response.body)["display_name"];
      }
    } catch (e) {
      address = "";
    }
    return address;
  }

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData = "${BASE_URL}api/create_geofence_area.jsp?method=list-geofence-area-v1";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          listGeofence = [];
          listGeofence = (jsonDecode(response.body) as List).toList();
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data geofence", "error");
      }

      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data geofence", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getAbsenHariIni(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var imeiid = prefs.getString("androidID");
      var urlData = "${BASE_URL}mobile/api/absensi/get_info_absensi.jsp?method=list-info-absensi&imeiid=${imeiid.toString()}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        setState(() {
          var _listInfoAbsensi = (jsonDecode(response.body) as List).toList();
          if (_listInfoAbsensi.isNotEmpty &&
              _listInfoAbsensi[0]['logdate'] != null &&
              _listInfoAbsensi[0]['logdate'] != '') {
            timeIN = _listInfoAbsensi[0]['logtimein'] ?? "";
            timeOUT = _listInfoAbsensi[0]['logtimeout'] ?? "";
            duration_check_out = _listInfoAbsensi[0]['duration'] ?? "";
            tglAbsen = _listInfoAbsensi[0]['logdate'] ?? "";
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data absensi", "error");
      }

      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data absensi", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> saveAttendance(String inorout, int geo_id, String geo_nm,
      String employeeid, String lat, String lon, String address) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString("name");

      if (androidID.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0, "IMEI ID kosong, silahkan kontak Administrator", "error");
        return "";
      } else if (user_id == null || user_id == "") {
        alert(globalScaffoldKey.currentContext!, 0, "USER ID tidak boleh kosong", "error");
        return "";
      } else {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }

        EasyLoading.show();
        print('SAVE ATTENDANCE');
        var encoded = Uri.encodeFull("${BASE_URL}api/check_in_out_geofence_new4.jsp");
        print(encoded);
        Uri urlEncode = Uri.parse(encoded);
        print(isMock);
        var fake = isMock == true ? '1' : '0';

        var data = {
          'method': inorout == "IN" ? "checkin-attendance-v3" : "checkout-attendance-v3",
          //'imeiid': "e8cb27d0493648cd",
          'imeiid': androidID.toString(),
          'userid': user_id,
          'address': address,
          'lat': lat,
          'lon': lon,
          'geo_id': geo_id.toString(),
          'geo_nm': geo_nm,
          'shift': dropdownvalue,
          'is_mock': fake,
          'photo': filePathImageProfile,
        };
        print('data param ${data}');
        final response = await http.post(urlEncode, body: data);
        print(response.body);

        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }

        if (response.statusCode == 200) {
          var result = json.decode(response.body);
          var status_code = result["status_code"];
          var message = result["message"];
          var _tgl_absen = result["tgl_absen"];
          var _timeIN = result["timein"];
          var _timeOUT = result["timeout"];
          var _duration = result["duration"];

          setState(() {
            if (status_code == 200) {
              tglAbsen = _tgl_absen ?? "";
              duration_check_out = _duration ?? "";
              timeIN = _timeIN ?? "";
              timeOUT = _timeOUT ?? "";
              alert(globalScaffoldKey.currentContext!, 1, "${message}", "success");
            } else if (status_code == 304) {
              tglAbsen = _tgl_absen ?? "";
              alert(globalScaffoldKey.currentContext!, 2, "${message}", "Warning");
            } else {
              alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          });
        } else {
          var message = json.decode(response.body)["message"];
          alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
        }
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

  Future updatePosition(String inorout) async {
    print(androidID.toString());
    print("userLocation ${userLocation}");

    var address = "";
    if (userLocation != null) {
      print(userLocation);
      if (listGeofence.length > 0) {
        txtAddr.text = "";
        var radiusOld = 0.0;
        var geo_idOld = 0;
        var geo_nmOld = "";
        var isValid = false;

        for (var i = 0; i < listGeofence.length; i++) {
          var lat = double.parse(listGeofence[i]['lat'].toString());
          var lon = double.parse(listGeofence[i]['lon'].toString());
          var name = listGeofence[i]['name'];
          var radius = double.parse(listGeofence[i]['radius'].toString());

          final num distance = SphericalUtil.computeDistanceBetween(
            LatLng(userLocation!.latitude, userLocation!.longitude),
            LatLng(lat, lon),
          );
          print(' listGeofence ');
          print(' distance ${distance} radius ${radius} ');

          print(listGeofence[i]);
          if (distance <= radius) { //PROD
          //if (distance >= radius) {
            isValid = true;
            if (radiusOld == 0.0) {
              radiusOld = radius;
              geo_idOld = int.parse(listGeofence[i]['geo_id']);
              geo_nmOld = name;
              print(' listGeofence Ok ${listGeofence[i]['geo_id']}');
              print(' distance ${distance} radius ${radius} ');

            } else {
              if (radius < radiusOld) {
                radiusOld = radius;
                geo_idOld = int.parse(listGeofence[i]['geo_id']);
                geo_nmOld = name;
              }
            }
          }
        }
        if (isValid) {
          address = await getAddress(
              userLocation!.latitude.toString(), userLocation!.longitude.toString());
          txtAddr.text = address;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Information'),
              content: Text("checked ${inorout.toUpperCase()} absensi?"),
              actions: [
                ElevatedButton.icon(
                  icon: Icon(Icons.close, color: Colors.white, size: 20.0),
                  label: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.save, color: Colors.white, size: 20.0),
                  label: Text("checked ${inorout.toUpperCase()}"),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    print('save attend');
                    print({
                      inorout,
                      geo_idOld,
                      geo_nmOld,
                      "",
                      userLocation!.latitude.toString(),
                      userLocation!.longitude.toString(),
                      address
                    });
                    await saveAttendance(
                      inorout,
                      geo_idOld,
                      geo_nmOld,
                      "",
                      userLocation!.latitude.toString(),
                      userLocation!.longitude.toString(),
                      address,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        } else {
          alert(globalScaffoldKey.currentContext!, 0,
              "Anda diLuar geofence/Geofence tidak ditemukan", "error");
        }
      } else {
        address = await getAddress(
            userLocation!.latitude.toString(), userLocation!.longitude.toString());
        txtAddr.text = address;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Information'),
            content: Text("checked ${inorout.toUpperCase()} absensi?"),
            actions: [
              ElevatedButton.icon(
                icon: Icon(Icons.close, color: Colors.white, size: 20.0),
                label: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.save, color: Colors.white, size: 20.0),
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
                    address,
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        print('Address ${address}');
      }
    } else {
      alert(globalScaffoldKey.currentContext!, 0, "Lokasi belum tersedia", "error");
    }
  }

  Timer timer = new Timer(new Duration(seconds: 5), () async {
    var currentLocation = null;
    try {
      currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewDashboard()));
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
          centerTitle: true,
          title: Text('Attendance'),
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          color: HexColor("#f0eff4"),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _getLocation();
    await getListGeofenceArea(false);
    await getAbsenHariIni(false);
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhotoSection(),
          SizedBox(height: 20),
          _buildInfoSection(),
          SizedBox(height: 20),
          _buildAttendanceSection(),
          SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Photo Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: _buildPhotoWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget() {
    if (_imageProfile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _imageProfile!,
          width: 180,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (filePathImageProfile != null && filePathImageProfile != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(filePathImageProfile),
          width: 180,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 50, color: Colors.grey.shade600),
            SizedBox(height: 8),
            Text("Tap to add photo", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoRow("Employee Name", namaKaryawan),
            _buildInfoRow("Date", tglAbsen),
            _buildInfoRow("Time IN", timeIN),
            _buildInfoRow("Time OUT", timeOUT),
            _buildInfoRow("Duration", duration_check_out),
            SizedBox(height: 12),
            _buildShiftDropdown(),
            SizedBox(height: 12),
            _buildLocationInfo(),
            SizedBox(height: 12),
            _buildImeiSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? "-" : value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftDropdown() {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            "Shift:",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: dropdownvalue,
            icon: Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            items: itemsShift.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                dropdownvalue = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (userLocation == null) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              "Location not available",
              style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                "Location Available",
                style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Lat: ${userLocation!.latitude.toStringAsFixed(6)}, Lng: ${userLocation!.longitude.toStringAsFixed(6)}",
            style: TextStyle(color: Colors.green.shade600, fontSize: 11),
          ),
          if (userLocation!.accuracy != null)
            Text(
              "Accuracy: ${userLocation!.accuracy.toStringAsFixed(1)}m",
              style: TextStyle(color: Colors.green.shade600, fontSize: 11),
            ),
          if (isMock)
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Mock Location Detected",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImeiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "IMEI ID:",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () => _shareImeiLink(),
          child: Text(
            androidID == null || androidID.isEmpty ? "-" : androidID,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSection() {
    bool canCheckIn = true;// timeIN == null || timeIN.isEmpty;
    bool canCheckOut = true;// (timeIN != null && timeIN.isNotEmpty) && (timeOUT == null || timeOUT.isEmpty);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Attendance Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text("Check IN"),
                    onPressed: canCheckIn ? () => updatePosition("IN") : null,
                    style: ElevatedButton.styleFrom(backgroundColor: canCheckIn ? Colors.green : Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text("Check OUT"),
                    onPressed: canCheckOut ? () => updatePosition("OUT") : null,
                    style: ElevatedButton.styleFrom(backgroundColor: canCheckOut ? Colors.orange : Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Additional Actions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.create, color: Colors.white),
                label: Text("Request Attendance"),
                onPressed: () => _navigateToRequestAttendance(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  getPicture('CAMERA');
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  getPicture('GALLERY');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareImeiLink() {
    if (androidID != null && androidID.isNotEmpty) {
      Share.share('https://apps.tuluatas.com/trucking/master/update_imei.jsp?imeiid=$androidID');
    }
  }

  void _navigateToRequestAttendance() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FrmRequestAttendance()),
    );
  }
}