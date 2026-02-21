import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:dms_anp/src/custom_loader.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewImageDo.dart';
import 'package:dms_anp/src/pages/ViewListDo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';

import '../../helpers/GpsSecurityChecker.dart';
import 'PageMessageResponse.dart';

class FrmCloseVehicleMixer extends StatefulWidget {
  // List Data;
  // int ITId;
  // FrmCloseVehicle({this.Data, this.ITId});
  @override
  _FrmCloseVehicleMixerState createState() => _FrmCloseVehicleMixerState();
}

class _FrmCloseVehicleMixerState extends State<FrmCloseVehicleMixer> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  SharedPreferences? prefs;
  String imageDo = "";
  String noImageImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';

  File? _image;
  String filePathImage = "";
  CameraController? controller;
  List? cameras;
  int? selectedCameraIdx;
  String? imagePath;

  Timer? _timer;
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  //GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  String status_code = "";
  String message = "";

  String drvid = "";
  String locid = "";
  String vhckm = "";
  String dlodetaildonumber = "";
  String vhcid = "";
  String dloorigin = "";
  String dlodestination = "";
  String userid = "";

  //Geolocator geolocator = Geolocator();
  //Position userLocation;

  Position? userLocation;
  //LocationData currentLocation;
  //Location location;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = false;
  String androidID = "";
  List listGeofence = [];
  List listGeofenceAllowed = [];
  String txtAddr = "";
  Future updatePosition(String inorout) async {
    //print(androidID.toString());
    //print(userLocation);
    if (userLocation != null) {
      //print(userLocation);
      if (listGeofence.length > 0) {
        var radiusOld = 0.0;
        var geo_idOld = 0;
        var geo_nmOld = "";
        var isValid = false;
        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius']);
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lon']), double.parse(a['lat'])),
              LatLng(userLocation!.longitude, userLocation!.latitude));
          //print('distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          //if (distanceBetweenPoints >= radius) {
          //FOR DEV
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

        if (geo_nmOld != "" && geo_nmOld != null) {
          //var abc = listGeofenceAllowed.where((x) => int.parse(x['geo_id']) == geo_idOld);
          var abc = listGeofenceAllowed.where((x) {
            var geoIdStr = "0"; // default
            if (x['geo_id'] != null && x['geo_id'].toString().trim() != "") {
              geoIdStr = x['geo_id'].toString();
            }
            var geoId = 0;
            try {
              geoId = int.parse(geoIdStr);
            } catch (e) {
              geoId = 0;
            }
            return geoId == geo_idOld;
          });

          if(abc.isNotEmpty){
            setState(() {
              txtAddr = "OUTGEO";
              print("valid geo_nmOld ${geo_nmOld}");
              isValid = true;
            });
          }else{
            setState(() {
              txtAddr = "INGEO";
              print("valid geo_nmOld ${geo_nmOld}");
              isValid = true;
            });
          }

        } else {
          setState(() {
            txtAddr = "OUTGEO";
            print("not valid geo_nmOld ${geo_nmOld}");
          });
        }

        if (isValid == true) {}
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

  bool isMock = false;
  var truslat = "0.0";
  var trusLon = "0.0";

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      currentLocation = null;
    }
    //print(currentLocation);
    return currentLocation;
  }

  // void _getLocation() async {
  //   location = Location();
  //
  //   print(location);
  //   var _permissionGranted = await location.hasPermission();
  //   _serviceEnabled = await location.serviceEnabled();
  //   print('_permissionGranted');
  //   print(_permissionGranted);
  //   print(_serviceEnabled);
  //   if (_permissionGranted != PermissionStatus.granted || !_serviceEnabled) {
  //     ///asks permission and enable location dialogs
  //
  //     _permissionGranted = await location.requestPermission();
  //     _serviceEnabled = await location.requestService();
  //   } else {
  //     ///Do something here
  //     print('null location');
  //   }
  //
  //
  //   location.onLocationChanged.listen((LocationData cLoc) {
  //     currentLocation = cLoc;
  //     _isisMock = currentLocation.isMock;
  //     //print("currentLocation.latitude ${currentLocation.latitude}");
  //     //print("currentLocation.longitude ${currentLocation.longitude}");
  //     _lat = currentLocation.latitude ?? 0;
  //     _lon = currentLocation.longitude ?? 0;
  //     //print('change location');
  //   });
  // }

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrlOri}api/create_geofence_area.jsp?method=list-geofence-area-do-terima-v1";
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
      // alert(globalScaffoldKey.currentContext!, 0, "Client, Load data geofence",
      //     "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getListGeofenceAreaAllowed(bool isload) async {
    try {

      var urlData =
          "${GlobalData.baseUrlOri}api/create_geofence_area.jsp?method=allowed-geofence";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listGeofenceAllowed = [];
          listGeofenceAllowed = (jsonDecode(response.body) as List)
              .toList();
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool?> GetExceptionDO(String donumber) async {
    bool isAllowed = false;
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/do/exception_do_geofence.jsp?method=exception-do-v1&donumber=${donumber}"; //DO15-IDC240800428";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        var sttsCode = json.decode(response.body)["status_code"];
        var msg = json.decode(response.body)["message"];
        if (sttsCode == 200) {
          isAllowed = true;
        }
        print(isAllowed);
        print(msg);
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load exception do ${urlData}", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      return isAllowed;
    } catch (e) {
      //alert(globalScaffoldKey.currentContext!, 0, "Client, Load data", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String?> closeTujuanDo(
      //TIDAK DIPAKE
      String dlocustdonumber,
      String vhcid,
      String drvid,
      String userid,
      String locid,
      String lat,
      String lon,
      String geo_code,
      String photo) async {
    pr!.show();
    Uri myUri = Uri.parse("${GlobalData.baseUrlServlet}CloseTujuanDo}");
    // print("${GlobalData.baseUrlServlet}CloseTujuanDo}");
    try {
      Map data = {
        'method': 'close_do',
        'dlocustdonumber': dlocustdonumber,
        'vhcid': vhcid,
        'drvid': drvid,
        'userid': userid,
        'locid': locid,
        'lat': lat,
        'lon': lon,
        'geo_code': geo_code,
        'photo': ""
      };
      // print(json.encode(data));
      try {
        var dio = Dio();
        Response response = await dio.post(
          "${GlobalData.baseUrl}api/do_mixer/close_do_mixer.jsp?}",
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
            HttpHeaders.acceptHeader: "application/json"
          }),
          data: jsonEncode(data),
        );

        // print(response.data);
        if (response.statusCode == 200) {
          setState(() {
            // Get the JSON data
            status_code = json.decode(response.data)["status_code"];
            message = json.decode(response.data)["message"];
            if (status_code != null && status_code == "200") {
              GlobalData.responseMessage = message;
            } else {
              GlobalData.responseMessage = message;
              alert(globalScaffoldKey.currentContext!, 0,
                  GlobalData.responseMessage, "error");
            }
          });
          //EasyLoading.dismiss();
        } else {
          status_code = '100';
          print("Error during connection to server");
          pr!.hide();
        }
      } on DioError catch (e) {
        print(e);
        pr!.hide();
        return null;
      }

      //var response = await http.post(myUri, body: json.encode(data),headers: {"Content-Type": "application/json"});

    } catch (e) {
      status_code = '100';
      print("Error during converting to ${e}");
      alert(globalScaffoldKey.currentContext!, 0, "error ,${e}", "error");
    }
    pr!.hide();
    return status_code;
  }

  Future<String?> UpdateReceiveLogDo(String drvid, String vhcid) async {
    try {
      //String _photo = photo!=null && photo!=""?photo.toString().trim():"";
      var dataParam = {
        "method": "update-or-insert-log",
        "drvid": drvid.toString(),
        "vhcid": vhcid.toString(),
        "is_used": "1"
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

  Future<String> CreateVehicleDoDiTerima(
      String vhcid, String bujnumber, String drvid) async {
    String bujnumber_diterima = "";
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/do/do_diterima.jsp?method=set_vehicle-do_diterima&vhcid=${vhcid}&bujnumber=${bujnumber}&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        int status_code = jsonDecode(response.body)["status_code"];
        if (status_code == 200) {
          bujnumber_diterima = jsonDecode(response.body)["bujnumber"];
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal create session data ",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      // alert(globalScaffoldKey.currentContext!, 0, "Client, create session",
      //     "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return bujnumber_diterima;
  }

  Future<String?> closeDo(
      String bujnumber,
      String dlocustdonumber,
      String vhcid,
      String drvid,
      String userid,
      String locid,
      String lat,
      String lon,
      String geo_code,
      String photo) async {
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    }
    try {
      //String _photo = photo!=null && photo!=""?photo.toString().trim():"";
      print("photo ${photo}");
      if (photo == "" || photo == null) {
        alert(globalScaffoldKey.currentContext!, 0, "Photo tidak boleh kosong",
            "error");
      } else {
        var dataParam = {
          "method": "close_do-v1",
          "bujnumber": bujnumber,
          "dlocustdonumber": dlocustdonumber,
          "vhcid": vhcid.toString(),
          "drvid": drvid.toString(),
          "userid": userid.toString(),
          "locid": locid.toString(),
          "geo_code": geo_code.toString(),
          "lat": lat,
          "lon": lon,
          "photo": photo,
        };
        print("close DO ${dataParam}");
        //var urlData = "${GlobalData.baseUrl}api/close_do_v3.jsp";//
        var urlData = "${GlobalData.baseUrl}api/do_mixer/close_do_mixer.jsp";
        print(urlData);
        print(dataParam);

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

        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        if (status_code != null && status_code == "200") {
          var bjNUmber = await CreateVehicleDoDiTerima(
              vhcid.toString(), bujnumber, drvid.toString());
          print("Create do diterima ${bjNUmber}");
        } else {
          //alert(context, 0, message.toString(), "error");
          GlobalData.responseMessage = message;
        }
        setState(() {
          GlobalData.responseMessage = message;
        });
        if (EasyLoading.isShow) {
          EasyLoading.show();
        }
      }
      return status_code;
    } catch (e) {
      print(e);
      pr!.hide();
      alert(globalScaffoldKey.currentContext!, 0, "error ,${e}", "error");
    }
  }

  // Future<Position> _getLocation() async {
  //   var currentLocation;
  //   try {
  //     currentLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   return currentLocation;
  // }

  List? dataDo;
  Future GetListDo(String no_do) async {
    EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid")!;
    String locid = prefs.getString("locid")!;
    print(drvid);
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/list_do_single.jsp?method=list_do_driver&driverid=" +
            drvid.toString() +
            "&locid=" +
            locid.toString() +
            "&search=" +
            no_do);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      dataDo = json.decode(response.body)["data"];
      print(dataDo);
      if (dataDo == null || dataDo!.length == 0 || dataDo == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "Anda tidak mempunyai data DO", "error");
      }
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  Future<String?> GetListDoDiTerima(String drvid) async {
    String noDo_Diterima = "";
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/do/do_diterima.jsp?method=list-do_diterima&drvid=${drvid}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        int status_code = jsonDecode(response.body)["status_code"];
        if (status_code == 200) {
          noDo_Diterima = jsonDecode(response.body)["no_do"];
          await GetListDo(noDo_Diterima);
        }
        setState(() {
          if (dataDo != null) {
            print(dataDo![0]);
            var items = dataDo![0];
            GlobalData.loginname = prefs!.getString("loginname")!;
            GlobalData.frmLocid = prefs!.getString("locid")!;
            GlobalData.frmDrvId = items["driverid"];
            GlobalData.frmUserId = prefs!.getString("name")!;
            GlobalData.frmVhcid = items["vhcid"]!;
            prefs?.setString("vhcidfromdo", GlobalData.frmVhcid);
            GlobalData.frmGeoCodeAsal = items["dloorigin"];
            GlobalData.frmGeoCodeTujuan = items["dlodestination"];
            if(items["dlodetaildonumber"]==GlobalData.frmDloDoNumber){
              GlobalData.frmDloDoNumber = items["dlodetaildonumber"];
            }
            GlobalData.frmBujDoNumber = items["dlodonumber"];
            if (prefs!.getString("imageDo")! != null &&
                prefs!.getString("imageDo")! != "") {
              imageDo = prefs!.getString("imageDo")!;
            }
            txtKMOld.text = prefs!.getString("vhckm")!.toString();
          }
        });
      } else {
        alert(globalScaffoldKey.currentContext!, 0,
            "Gagal load data do diterima", "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      return noDo_Diterima;
    } catch (e) {
      // alert(globalScaffoldKey.currentContext!, 0, "Client, Load do diterima",
      //     "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future getLoginName() async {
    prefs = await SharedPreferences.getInstance();
    var noDO = await GetListDoDiTerima(prefs!.getString("drvid")!);
    //print(GlobalData.loginname);
  }

  @override
  void initState() {
    print('RECEIVE DO CLOSE');
    configLoading();
    // _getLocation();
    _getLocation().then((position) {
      userLocation = position;
    });
    getLoginName();
    getListGeofenceAreaAllowed(true);
    super.initState();
  }

  void GetSessionRemove() async{

  }
  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewListDo()));
  }

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        filePathImage = base64UrlEncode(imageBytes);
      });
      //print(filePathImage);
    } else {
      print('No image selected.');
    }
  }

  ProgressDialog? pr;
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
      backgroundColor: Colors.orange.shade400,
      appBar: AppBar(
          backgroundColor: Colors.orange.shade400,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () {
              final ctx = globalScaffoldKey.currentContext;
              if (ctx != null) _goBack(ctx);
            },
          ),
          centerTitle: true,
          title: Text('Form DO DiTerima Mixer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      body: Container(
        key: globalScaffoldKey2,
        constraints: BoxConstraints.expand(),
        color: HexColor("#f0eff4"),
        child: Stack(
          children: <Widget>[
            _getViewImage(context),
            _getContent(context),
            Container(
              margin: EdgeInsets.only(top: 270),
              padding: EdgeInsets.fromLTRB(20.0, 165.0, 10.0, 0.0),
              child: Text(
                  "Untuk melakukan transaksi ini, hanya boleh di lakukan di tempat tujuan",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.redAccent,
                    fontSize: 12, // Set your desired font size
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _getViewImage(BuildContext context) {
    if (filePathImage == null || filePathImage == '') {
      // filePathImage =
      //     imageDo != "" && imageDo != null ? imageDo : noImageImageBase64;
      filePathImage = "";
    } else {
      filePathImage =
          imageDo != "" && imageDo != null ? imageDo : filePathImage;
    }
    if (filePathImage == null || filePathImage == '') {
      //print("BASE64 ${prefs.getString('imageDo')}");
      Uint8List bytes = base64Decode(filePathImage);
      return InkWell(
          onTap: () async {
            print('tap');
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              margin: new EdgeInsets.only(top: 0.0),
              height: 150,
              width: double.infinity,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: Colors.amber,
                      width: 10,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('testing');
//                                  setState(() {
//                                    _localVehicleSelected =
//                                        vdata[index]["pr"].toString();
//                                  });
//
//                                  doSomething(vdata[index]["pr"].toString());
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //new Row(
                            // mainAxisSize: MainAxisSize.max,

                            //children: <Widget>[
                            new Text(
                              'No Picture',
                            ),

                            //style: Theme.of(context).textTheme.body2
                            //],
                            //),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )));
    } else {
      //print("BASE64 ${prefs.getString('imageDo')}");
      Uint8List bytes = base64Decode(filePathImage);
      return InkWell(
          onTap: () async {
            if (filePathImage != null && filePathImage != "") {
              //SharedPreferences prefsImage = await SharedPreferences.getInstance();
              setState(() {
                prefs!.setString("imageDO", filePathImage);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ViewImageDo()));
              });
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            margin: new EdgeInsets.only(top: 0.0),
            width: double.infinity,
            child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 14.0,
                shadowColor: Color(0x802196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: new Image.memory(bytes, fit: BoxFit.cover, height: 250)),
          ));
    }
  }

  Widget _getContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      padding: EdgeInsets.fromLTRB(10.0, 165.0, 10.0, 0.0),
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
                  ListTile(
                    title: Text("${GlobalData.frmVhcid}\n${GlobalData.frmDloDoNumber}"),
                    subtitle: Text("${GlobalData.frmUserId}"),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FloatingActionButton.extended(
                        heroTag:UniqueKey(),// 'btn1',
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          try {
                            await getImage();
                          } catch (e) {
                            print('Capture error: $e');
                            final ctx = globalScaffoldKey.currentContext;
                            if (ctx != null) alert(ctx, 0, "Gagal capture foto. Pastikan izin kamera aktif.", "error");
                          }
                        },
                        icon: Icon(Icons.camera, color: Colors.white),
                        label: Text('Capture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      FloatingActionButton.extended(
                        heroTag: UniqueKey(),//'btn2',
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          print('DO NUMBER');
                          print(GlobalData.frmDloDoNumber);

                          final ctx = globalScaffoldKey.currentContext;
                          if (userLocation == null) {
                            if (ctx != null) alert(ctx, 0,
                                "Lokasi belum tersedia. Silahkan aktifkan GPS dan tunggu sebentar.",
                                "warning");
                            return;
                          }
                          String lat = userLocation!.latitude.toString();
                          String lon = userLocation!.longitude.toString();
                          String speed = userLocation!.speed.toString();
                          if (lon.isEmpty && lat.isEmpty) {
                            if (ctx != null) alert(ctx, 0,
                                "Coordinate/Lokasi tidak di temukan, silahkan aktifkan GPS nya terlebih dahulu",
                                "warning");
                            return;
                          }
                          bool? isAllowed =
                              await GetExceptionDO(GlobalData.frmDloDoNumber ?? '');
                          if (isAllowed == true) {
                              txtAddr = "OUTGEO";
                              print('NOT UPDATEPOSITION');
                            } else {
                              txtAddr = "";
                              await updatePosition("IN");
                              print('UPDATEPOSITION');
                            }
                            if (txtAddr != null &&
                                txtAddr.toString() != "" &&
                                txtAddr.toString().toUpperCase() == "INGEO") {
                              if (ctx != null) alert(ctx, 0,
                                  "Close DO tidak di ijinkan, silahkan ke tempat tujuan di diterima",
                                  "warning");
                            } else if (txtAddr == null || txtAddr == "") {
                              if (ctx != null) alert(ctx, 0,
                                  "Coba lagi untuk melakukan submit",
                                  "warning");
                            } else if (ctx == null) {
                              return;
                            } else {
                              //CLOSE DO
                              print('CLOSE DO');
                              await showDialog(
                                context: ctx,
                                builder: (context) => new AlertDialog(
                                  title: new Text('Information'),
                                  content: new Text(
                                      'Close DO BUJNUMBER: ${GlobalData.frmBujDoNumber}'),
                                  actions: <Widget>[
                                    // ignore: deprecated_member_use
                                    new TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: new Text('No'),
                                    ),
                                    new TextButton(
                                      onPressed: () async {
                                        SharedPreferences prefs2 =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs2.setString("vhcid_last_antrian", "");
                                        final dialogCtx = globalScaffoldKey.currentContext;
                                        // Cek keamanan GPS sebelum submit close DO
                                        if (dialogCtx == null) {
                                          Navigator.of(context).pop(false);
                                        } else {
                                          var gpsResult = await GpsSecurityChecker.checkGpsSecurity();
                                          if (gpsResult["isFake"] == true) {
                                            final fakeReason = gpsResult["reason"] ?? "";
                                            alert(dialogCtx, 0, "FAKE GPS terdeteksi: $fakeReason", "error");
                                            return;
                                          }
                                          if (GlobalData.frmDloDoNumber ==
                                                  null ||
                                              GlobalData.frmDloDoNumber == "") {
                                            Navigator.of(dialogCtx).pop(false);
                                            alert(dialogCtx, 0,
                                                "DLOCUSTDONUMBER tidak boleh kosong",
                                                "error");
                                          } else if (filePathImage == null ||
                                              filePathImage.isEmpty) {
                                            Navigator.of(dialogCtx).pop(false);
                                            alert(dialogCtx, 0,
                                                "Photo tidak boleh kosong",
                                                "error");
                                          } else {
                                            Navigator.of(dialogCtx).pop(false);
                                            print('Close Do test');
                                            var scode = await closeDo(
                                                GlobalData.frmBujDoNumber,
                                                GlobalData.frmDloDoNumber,
                                                GlobalData.frmVhcid,
                                                GlobalData.frmDrvId,
                                                GlobalData.frmUserId,
                                                GlobalData.frmLocid,
                                                lat,
                                                lon,
                                                GlobalData.frmGeoCodeTujuan,
                                                filePathImage);
                                            //var scode = "100";

                                            if (scode != null &&
                                                scode == "200") {
                                              prefs2.setString(
                                                  "submit_bujnumber", "ok");
                                              print("SCODE : " + scode);
                                              SharedPreferences resPreps =
                                                  await SharedPreferences
                                                      .getInstance();
                                              resPreps.setString("route_pages",
                                                  "view_list_do");
                                              resPreps.setString(
                                                  "route_pages_message",
                                                  GlobalData.responseMessage);
                                              resPreps.setString("vhcidfromdo",
                                                  GlobalData.frmVhcid);
                                              await UpdateReceiveLogDo(
                                                  GlobalData.frmDrvId,
                                                  GlobalData.frmVhcid);
                                              // alert(
                                              //     context,
                                              //     0,
                                              //     GlobalData.responseMessage,
                                              //     "success");

                                              //SHOW ALERT SUCCESS
                                              final showCtx = globalScaffoldKey.currentContext;
                                              if (showCtx != null) {
                                                await showDialog(
                                                  context: showCtx,
                                                  builder: (ctx) =>
                                                      new AlertDialog(
                                                    title:
                                                        new Text('Information'),
                                                    content: new Text(
                                                        "${GlobalData.responseMessage}"),
                                                    actions: <Widget>[
                                                      new TextButton(
                                                        onPressed: () async {
                                                          Navigator.pushReplacement(
                                                              ctx,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ViewDashboard()));
                                                        },
                                                        child: new Text('Ok'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              //END ALERT SUCCESS
                                              pr?.hide();
                                            } else {
                                              if (dialogCtx != null) alert(
                                                  dialogCtx,
                                                  0,
                                                  "${GlobalData.responseMessage},FAILED FOR CLOSED DO",
                                                  "error");
                                              pr?.hide();
                                            }
                                          }
                                        }
                                      },
                                      child: new Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            }
                        },
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                            color: Colors.orange.shade400,
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
