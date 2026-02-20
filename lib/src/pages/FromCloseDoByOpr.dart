import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Theme/app_theme.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewImageDo.dart';
import 'package:dms_anp/src/pages/ViewListDo.dart';
import 'package:dms_anp/src/pages/ViewListDoOpr.dart';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';

import '../../helpers/GpsSecurityChecker.dart';
import 'PageMessageResponse.dart';

class FrmCloseDoByOpr extends StatefulWidget {
  // List Data;
  // int ITId;
  // FrmCloseVehicle({this.Data, this.ITId});
  @override
  _FrmCloseDoByOprState createState() => _FrmCloseDoByOprState();
}

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class _FrmCloseDoByOprState extends State<FrmCloseDoByOpr> {
  late SharedPreferences prefs;
  String imageDo = "";
  String noImageImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';
  String noImage =
      'iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAANlBMVEXu7u64uLjx8fHt7e21tbXQ0NC9vb3ExMTm5ubj4+O5ubnIyMjq6urf39/MzMzBwcHU1NTZ2dmQfkM8AAAE2klEQVR4nO2Y2bLrKAxFwxCPePr/n21JYBvnJLeruq5zHnqtl3gAzEZCEnk8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgK3jv62t/eXN98KbZtfOncd8O6C/8dwH/yjOO4RH26zh05XnaxiiMa/fao5fHzzLLGKfyNCxxrZfnubfZSf28SM/hOYXSvmIJf1PTlWcc1vPaNVmQn9oY3TC4GBt5ffl+H90++yRasyzfNxdJaYlLqu79ZgM656Ib9RuhdRX3KnTD5I/rrND3w/n1V2NUCifp7ENW4Nx4SvKbDDBVnVZXDyh9wlI/WdSPblIpqlxMLwpN4LC07WKrvl56nArFFV3MRk+j2+2vhFGGbQ+vDfoVsVQrI9rnRIwqbHfme23oYln9XaHNb5mS90m89TL1WmHw8rLsvq6RYfqzja3MYdNJb5ute/hHty6z9lAbxi9FmtMRd4W9zqe3r/pOZ1LHkMqGyexgzaZYN/Orjbrfe5W/9OUumfCs8EZhB9l/8mSKQi8e57Z9drr+w3uFfWNLoa3U6m7OzcTj9Lm4QTai38wPyhjFH0+FNzpopdA5XeFd4T5vIy21v10UbtbTdqldNftCiEWjxJohxxo/a48Xe9Veep86RVWpsy3doTBplDhWVs0T67B4Klyj2DdqlJiyJ+S5iySN/21+lcNmCUhn1g9npBl/pNy/rtD2Wpt2hTrd8VhYC5hvFQbx5sHikLYZzlAj3hs3v+6b2aJQHq8bLMGPdbaIp7/cpjBNOofZnwrj/Krw3C2HQvXfeZGXXq6iNiubV7Ul02nbW7erpM1QxOqGveTD5gs21Hwt81s/K/RvFHYakKTSm72s0KCTz72S+qf8yk9zKrSQ0jUWZHeFuWQb7rdhdjNJ8e5QaF6aq5X5k5dKu2bq5E6SQxwf41582XPZbFPp2JWwGbQwaNvhUPi9SKNespweo5GmKirbM05cFJpT95Lr4jTGYdMcWDKHDPNc1/VZfEGK7GOLShHRVArv1XZV2DeHQh9zjAjFsfYgeVUYVMmSVOfYaHsznbwPsfjfMd4lW3S/o1AivEaboWT8I1pqA1fvykdlwxxyOyvQ5nyxmmm1RnCldtdYo8G5yY4efkuhYpWWXecZ5apt1ZnW2/BQmHJRqjW37TcNqDJ1+RlKCNEBteTVqk3q3Dzgr3mpcBTZSc9uwyaVdzfr9Md350MLJJoe7GD0yMeLNpkvtF1v6Dh9Kdtkb/YSVfTZa6S5vfJWVaoh5VhaPNbtVojLNV/tCjWQaDzSvGe77Kndw3zmRU1CFpXD0x254We2uP2Mf2ZcEVaut3ieTpv+usK7QjWQvRmzG5ueSQPTMaCGr2iL9zwH1HPU43oCvvmMH8+aYj2upyaWkDh3Ly5UFKZFlt6bsvKHxaRFzJqLMiMfIM2gYWuyRhnWTqOaQr5zxl+l8j1yn38eVbDvVz17b+HHFunkqC5G6CR5r1bqhGXLL/TJLL2mo8+kYzxsE+QB223Kmy7MbcWdZ/z6b78Qfvyb+KGHPzrq1H78QfjaNtSv86e+92/in/i0sKF+9SfvCrnp3WdcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+B/xD/alJ5yRngQVAAAAAElFTkSuQmCC';

  late File _image;
  String filePathImage = "";
  late CameraController controller;
  late List cameras;
  late int selectedCameraIdx;
  String? imagePath;
  String _text = "TEXT";
  late Timer _timer;
  TextEditingController txtKM = new TextEditingController();
  TextEditingController txtQty = new TextEditingController();
  TextEditingController txtKMOld = new TextEditingController();
  GlobalKey<ScaffoldState> scafoldGlobal = new GlobalKey<ScaffoldState>();
  String status_code = "";
  String message = "";
  Geolocator geolocator = Geolocator();
  late Position userLocation;
  String _dlocustdonbr = "";
  String _bujnbr = "";
  String _advbujnbr = "";
  String _vhcid = "";
  String _odometer = "";
  String _origin = "";
  String _origin_name = "";
  String _destination = "";
  String _destination_name = "";
  String _cpyid = "";
  String _tarifuom = "";
  String _qty = "";
  String _locid = "";
  String _userid = "";
  //String _lat = "0";
  //String _lon = "0";
  String _geo_code = "0";
  String _out_km = "0";

  Future<String> closeDo2(
      String dlocustdonbr,
      String bujnbr,
      String advbujnbr,
      String vhcid,
      String odometer,
      String origin,
      String destination,
      String cpyid,
      String tarifuom,
      String qty,
      String locid,
      String lat,
      String lon,
      String geo_code,
      String photo) async {
    pr?.show();
    try {
      Map data = {
        'method': 'close',
        'dlocustdonbr': dlocustdonbr,
        'bujnbr': bujnbr,
        'advbujnbr': advbujnbr,
        'vhcid': vhcid,
        'origin': origin,
        'destination': destination,
        'cpyid': cpyid,
        'tarifuom': tarifuom,
        'qty': qty,
        'locid': locid,
        'lat': lat,
        'lon': lon,
        'geo_code': geo_code,
        'photo': ""
      };
      print(json.encode(data));
      try {
        var dio = Dio();
        Response response = await dio.post(
          "${GlobalData.baseUrl}api/close_do_by_op_new.jsp?}",
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
              final ctx = globalScaffoldKey.currentContext;
              if (ctx != null) {
                alert(ctx, 0, GlobalData.responseMessage, "error");
              }
            }
          });
          //EasyLoading.dismiss();
        } else {
          status_code = '100';
          print("Error during connection to server");
          pr?.hide();
        }
      } on DioError catch (e) {
        print(e);
        pr?.hide();
        status_code = '100';
        return status_code;
      }

      //var response = await http.post(myUri, body: json.encode(data),headers: {"Content-Type": "application/json"});
    } catch (e) {
      status_code = '100';
      print("Error during converting to ${e}");
      alert(context, 0, "error ,${e}", "error");
    }
    pr?.hide();
    return status_code;
  }

  Future<String?> closeDo(
      String dlocustdonbr,
      String bujnbr,
      String advbujnbr,
      String vhcid,
      String odometer,
      String origin,
      String destination,
      String cpyid,
      String tarifuom,
      String qty,
      String locid,
      String lat,
      String lon,
      String geo_code,
      String userid,
      String photo) async {
    pr?.show();
    try {
      String _photo =
          photo != null && photo != "" ? photo.toString().trim() : "";
      var urlData =
          "${GlobalData.baseUrl}api/close_do_by_op_new.jsp?method=close&dlocustdonbr=" +
              dlocustdonbr +
              "&bujnbr=" +
              bujnbr +
              "&advbujnbr=" +
              advbujnbr +
              "&vhcid=" +
              vhcid +
              "&odometer=" +
              odometer +
              "&origin=" +
              origin +
              "&destination=" +
              destination +
              "&cpyid=" +
              cpyid +
              "&tarifuom=" +
              tarifuom +
              "&qty=" +
              qty +
              "&locid=" +
              locid +
              "&lat=" +
              lat +
              "&lon=" +
              lon +
              "&geo_code=" +
              geo_code +
              "&userod=" +
              userid +
              "&photo=" +
              photo;

      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      print(urlData);
      var response = await http.get(myUri, headers: {
        "Accept": "application/json",
        "Content-type": "application/json; charset=UTF-8"
      });

      setState(() {
        // Get the JSON data
        status_code = json.decode(response.body)["status_code"];
        message = json.decode(response.body)["message"];
        //print(message);
        if (status_code != null && status_code == "200") {
          //alert(context, 0, message.toString(), "success");
          GlobalData.responseMessage = message;
        } else {
          //alert(context, 0, message.toString(), "error");
          GlobalData.responseMessage = message;
        }
      });
      pr?.hide();
      return status_code;
    } catch (e) {
      print(e);
      pr?.hide();
      alert(context, 0, "error ,${e}", "error");
    }
  }

  bool isNumeric(String? s) {
    if (s == null || s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> _read() async {
    final ctx = globalScaffoldKey.currentContext;
    if (ctx != null) {
      alert(
        ctx,
        2,
        "Fitur OCR tidak tersedia di versi ini.\nSilakan input KM secara manual.",
        "warning",
      );
    }
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future getShareDateSession() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _userid = prefs.getString("username") ?? '';
      _dlocustdonbr = prefs.getString("dlocustdonbrOPR") ?? '';
      _bujnbr = prefs.getString("bujnbrOPR") ?? '';
      _advbujnbr = prefs.getString("advbujnbrOPR") ?? '';
      _vhcid = prefs.getString("vhcidOPR") ?? '';
      _odometer = prefs.getString("odometerOPR") ?? '';
      _origin = prefs.getString("originOPR") ?? '';
      _origin_name = prefs.getString("origin_nameOPR") ?? '';
      _destination = prefs.getString("destinationOPR") ?? '';
      _destination_name = prefs.getString("destination_nameOPR") ?? '';
      _cpyid = prefs.getString("cpyid") ?? '';
      _tarifuom = prefs.getString("tarifuomOPR") ?? "";
      _qty = prefs.getString("qtyOPR") ?? "";
      _locid = prefs.getString("locidOPR") ?? "";
      _out_km = prefs.getString("odometerOutOPR") ?? "";
      // if (prefs.getString("imageDo") != null &&
      //     prefs.getString("imageDo") != "") {
      //   imageDo = prefs.getString("imageDo");
      // }
      txtKMOld.text = prefs.getString("odometerOutOPR") ?? '';
    });
    //print(GlobalData.loginname);
  }

  @override
  void initState() {
    //configLoading();
    _getLocation().then((position) {
      userLocation = position;
    });
    getShareDateSession();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewListDoOpr()));
  }

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image.readAsBytesSync();
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
    pr = new ProgressDialog(context, isDismissible: true);

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
              _goBack(context);
            },
          ),
          //backgroundColor: Colors.transparent,
          //elevation: 0.0,
          centerTitle: true,
          title: Text('Form Close DO')),
      body: Container(
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

  Widget _getViewImage(BuildContext context) {
    if (filePathImage == null || filePathImage == '') {
      filePathImage =
          imageDo != "" && imageDo != null ? imageDo : noImageImageBase64;
    } else {
      filePathImage =
          imageDo != "" && imageDo != null ? imageDo : filePathImage;
    }

    print("BASE64 ${prefs.getString('imageDo')}");
    Uint8List bytes = base64Decode(filePathImage);
    return InkWell(
        onTap: () async {
          if (filePathImage != null && filePathImage != "") {
            //SharedPreferences prefsImage = await SharedPreferences.getInstance();
            setState(() {
              prefs.setString("imageDO", filePathImage);
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
              child: new Image.memory(bytes, fit: BoxFit.cover, height: 150)),
        ));
  }

  Widget _getContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
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
                    title: Text("NOPOL: ${_vhcid}"),
                    subtitle: Text("LOCID: ${_locid}"),
                  ),
                  ListTile(
                    title: Text("BUJNBR: ${_bujnbr}"),
                    subtitle: Text("DLODONBR: ${_dlocustdonbr}"),
                  ),
                  ListTile(
                    title: Text("ORIGIN - DESTINATION"),
                    subtitle: Text("${_origin_name} - ${_destination_name}"),
                  ),
                  ListTile(
                    title: Text("OUT KM"),
                    subtitle: Text("${_out_km}"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: txtKM,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        hintText: "SET KM",
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 11, top: 0, right: 5),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: txtQty,
                      keyboardType: TextInputType.number,
                      decoration: new InputDecoration(
                        hintText: "SET QTY",
                        fillColor: Colors.black12,
                        filled: true,
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 5, bottom: 11, top: 0, right: 5),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 5, right: 20, bottom: 0),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          label: Text("Set KM"),
                          onPressed: () {
                            _read();
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
                            Icons.save,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          label: Text("Submit"),
                          onPressed: () async {
                            String lat = "";
                            String lon = "";
                            String speed = "";
                            if (lon == null && lat == null) {
                              alert(
                                  context,
                                  0,
                                  "Coordinate/Lokasi tidak di temukan,silahkan aktifkan GPS nya terlebih dahulu",
                                  "warning");
                            } else {
                              final ctx = globalScaffoldKey.currentContext;
                              if (ctx != null) {
                                await showDialog(
                                  context: ctx,
                                  builder: (context) => new AlertDialog(
                                    title: new Text('Information'),
                                    content: new Text(
                                        'Close DO ${GlobalData.frmDloDoNumber}'),
                                    actions: <Widget>[
                                      // ignore: deprecated_member_use
                                      ElevatedButton(
                                        child: Text("No"),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.grey,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      ElevatedButton(
                                        child: Text("Yes"),
                                        onPressed: () async {
                                          if (_dlocustdonbr == null ||
                                              _dlocustdonbr == "") {
                                            final ctx = globalScaffoldKey
                                                .currentContext;
                                            if (ctx != null) {
                                              alert(
                                                  ctx,
                                                  2,
                                                  "DLOCUSTDONUMBER tidak boleh kosong",
                                                  "warning");
                                            }
                                          } else if (txtKM.value.text == null ||
                                              _dlocustdonbr == "") {
                                            final ctx = globalScaffoldKey
                                                .currentContext;
                                            if (ctx != null) {
                                              alert(
                                                  ctx,
                                                  2,
                                                  "KM tidak boleh kosong",
                                                  "warning");
                                            }
                                          } else if (txtQty.value.text ==
                                                  null ||
                                              _dlocustdonbr == "") {
                                            final ctx = globalScaffoldKey
                                                .currentContext;
                                            if (ctx != null) {
                                              alert(
                                                  ctx,
                                                  2,
                                                  "QTY tidak boleh kosong",
                                                  "warning");
                                            }
                                          } else {
                                            // Navigator.of(context,
                                            //         rootNavigator: true)
                                            //     .pop();
                                            final ctx = globalScaffoldKey
                                                .currentContext;
                                            if (ctx != null) {
                                              Navigator.of(ctx).pop(false);
                                            }

                                            // Cek keamanan GPS sebelum submit close DO
                                            var gpsResult = await GpsSecurityChecker.checkGpsSecurity();
                                            if (gpsResult["isFake"] == true) {
                                              final fakeReason = gpsResult["reason"] ?? "";
                                              final fakeCtx = globalScaffoldKey.currentContext;
                                              if (fakeCtx != null) {
                                                alert(fakeCtx, 0, "FAKE GPS terdeteksi: $fakeReason", "error");
                                              }
                                              return;
                                            }

                                            var scode = await closeDo(
                                                _dlocustdonbr,
                                                _bujnbr,
                                                _advbujnbr,
                                                _vhcid,
                                                txtKM.value.text,
                                                _origin,
                                                _destination,
                                                "AN",
                                                _tarifuom,
                                                txtQty.value.text,
                                                _locid,
                                                lat,
                                                lon,
                                                _geo_code,
                                                _userid,
                                                "");

                                            if (scode != null &&
                                                scode == "200") {
                                              print("SCODE : " + scode);
                                              SharedPreferences resPreps =
                                                  await SharedPreferences
                                                      .getInstance();
                                              resPreps.setString("route_pages",
                                                  "view_list_do_opr");
                                              resPreps.setString(
                                                  "route_pages_message",
                                                  GlobalData.responseMessage);
                                              //SHOW ALERT SUCCESS
                                              final ctx = globalScaffoldKey
                                                  .currentContext;
                                              if (ctx != null) {
                                                await showDialog(
                                                  context: ctx,
                                                  builder: (context) =>
                                                      new AlertDialog(
                                                    title:
                                                        new Text('Information'),
                                                    content: new Text(
                                                        "${GlobalData.responseMessage}"),
                                                    actions: <Widget>[
                                                      new TextButton(
                                                        onPressed: () async {
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ViewListDoOpr()));
                                                        },
                                                        child: new Text('Ok'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                //END ALERT SUCCESS
                                              }
                                            } else {
                                              final ctx = globalScaffoldKey
                                                  .currentContext;
                                              if (ctx != null) {
                                                alert(
                                                    ctx,
                                                    0,
                                                    "${GlobalData.responseMessage},FAILED FOR CLOSED DO",
                                                    "error");
                                              }
                                              pr?.hide();
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Colors.blue,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 0),
                                            textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              textStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        )),
                      ])),
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
                            color: Colors.blue,
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

/*


http://apps.tuluatas.com:8085/cemindo/mobile/api/close_do.jsp?method=close_do&dlocustdonumber=DO03-IDQ191201708&vhcid=B%209205%20KYW&drvid=1222-09.2013.13.12.70&userid=Suningrat&locid=CGD-ANP&geo_code=PT.%20DGU%20-%20CIGUDEG&lat=-6.6059378&lon=106.7732955&photo=_9j_4Wr6RXhpZgAASUkqAAgAAAAMAAABBAABAAAAABIAAAEBBAABAAAAUAgAAA8BAgAIAAAAngAAABABAgAJAAAApgAAABIBAwABAAAABgAAABoBBQABAAAA0gAAABsBBQABAAAA2gAAACgBAwABAAAAAgAAADEBAgAOAAAAsAAAADIBAgAUAAAAvgAAABMCAwABAAAAAQAAAGmHBAABAAAA4gAAAKwCAABzYW1zdW5nAFNNLUEzMDVGAABBMzA1RkREVTZDVUUxADIwMjE6MDY6MTggMDU6NTg6NTYASAAAAAEAAABIAAAAAQAAABoAmoIFAAEAAABgAgAAnYIFAAEAAABYAgAAIogDAAEAAAACAAAAJ4gDAAEAAAD6AAAAAJAHAAQAAAAwMjIwA5ACABQAAAAgAgAABJACABQAAAA0AgAAEJACAAcAAABIAgAAEZACAAcAAABQAgAAAZIFAAEAAABoAgAAApIFAAEAAABwAgAAA5IKAAEAAAB4AgAABJIKAAEAAACAAgAABZIFAAEAAACIAgAAB5IDAAEAAAACAAAACZIDAAEAAAAAAAAACpIFAAEAAACYAgAAAaADAAEAAAABAAAAAqAEAAEAAAAAEgAAA6AEAAEAAABQCAAAAqQDAAEAAAAAAAAAA6QDAAEAAAAAAAAABKQFAAEAAACQAgAABaQDAAEAAAAaAAAABqQDAAEAAAAAAAAAIKQCAAwAAACgAgAAAAAAADIwMjE6MDY6MTggMDU6N
 */
