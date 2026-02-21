import 'package:dms_anp/src/Color/hex_color.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../flusbar.dart';
import 'FrmCloseVehicleMixer.dart';

class ViewListDoMixer extends StatefulWidget {
  @override
  _ViewListDoMixerState createState() => _ViewListDoMixerState();
}

class _ViewListDoMixerState extends State<ViewListDoMixer> {//
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  List data = [];
  String status_code = "";
  String txtAddr = "";
  String message = "";
  late Position userLocation;
  late LocationData currentLocation;
  late Location location;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = false;
  String androidID = "";
  List listGeofence = [];
  String address = "";

  Future<String> getJSONData() async {
    EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid")!;
    String locid = prefs.getString("locid")!;
    print(drvid);
    Uri myUri = Uri.parse(
        "${GlobalData.baseUrl}api/do_mixer/list_do_mixer.jsp?method=list_do_driver&driverid=" +
            drvid.toString() +
            "&locid=" +
            locid.toString());
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      final raw = json.decode(response.body)["data"];
      data = raw != null && raw is List ? raw : [];
      print(data);
      if (data.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Anda tidak mempunyai data DO", "error");
      }
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            centerTitle: true,//
            title: Text('Form List DO Mixer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        body: new Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: new BoxConstraints.expand(),
          //color: new Color(0xFF736AB7),
          color: HexColor("#ffffff"),
          child: new Stack(
            children: <Widget>[
              _buildListView(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
        onRefresh: getJSONData,
        child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildDMSMenuDO(context, data[index], index);
            }));
  }

  Future updatePosition(String inorout) async {
    print(androidID.toString());
    print(userLocation);
    if (userLocation != null) {
      print(userLocation);
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
              LatLng(userLocation.longitude, userLocation.latitude));
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

        if (geo_nmOld != "" && geo_nmOld != null) {
          setState(() {
            txtAddr = "INGEO";
            isValid = true;
          });
        } else {
          setState(() {
            txtAddr = "OUTGEO";
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
      _isisMock = currentLocation.isMock!;
      //print("currentLocation.latitude ${currentLocation.latitude}");
      //print("currentLocation.longitude ${currentLocation.longitude}");
      _lat = currentLocation.latitude ?? 0;
      _lon = currentLocation.longitude ?? 0;
      //print('change location');
    });
  }

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrlOri}api/create_geofence_area.jsp?method=list-geofence-area-v1";
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

  Future<String?> CreateDoDiTerima(String drvid, String no_do) async {
    String noDo_Diterima = "";
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrl}api/do_mixer/do_diterima_mixer.jsp?method=create-do_diterima&drvid=${drvid}&no_do=${no_do}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          int status_code = jsonDecode(response.body)["status_code"];
          if (status_code == 200) {
            noDo_Diterima = jsonDecode(response.body)["no_do"];
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
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load do diterima",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget _buildDMSMenuDO(BuildContext context, dynamic value, int index) {
    //print(value["drvid"]);
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.black45))),
                  child: Icon(Icons.settings_applications, color: Colors.black),
                ),
                title: Text(
                  "DO NUMBER : ${value['dlodonumber']}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(children: <Widget>[
                  Text("NOPOL: ${value['vhcid']} ${value['driverid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("LOCID: ${value['locid']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("DO CUST. NUMBER: ${value['dlodetaildonumber']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("ORIGIN: ${value['dloorigin']}",
                      style: TextStyle(color: Colors.black)),
                  Divider(
                    color: Colors.transparent,
                    height: 0,
                  ),
                  Text("DESTINATION: ${value['dlodestination']}",
                      style: TextStyle(color: Colors.black)),
                ]),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Color.fromRGBO(230, 232, 238, .9)),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new ElevatedButton.icon(
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          label: Text("DO DiTerima"),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var no_do = await CreateDoDiTerima(value['driverid'], value['dlodetaildonumber']);//value['dlodetaildonumber']
                            GlobalData.frmDloDoNumber = value['dlodetaildonumber'];
                            print(value);
                            //var no_do="CG/LB7/DUM-ANP/04/25/1067013";
                            if (no_do != null && no_do != "") {
                              setState(() {
                                prefs.setString("vhcid_new", value['vhcid']);
                                prefs.setString("drvid_new", value['driverid']);
                                prefs.setString("dloorigin", value['dloorigin']);
                                prefs.setString("dlodestination", value['dlodestination']);
                                prefs.setString("dlodetaildonumber",value['dlodetaildonumber']);
                                prefs.setString("bujnumber", value['dlodonumber']);
                                print(prefs.getString("bujnumber"));
                                print(value['dlodonumber']);
                                prefs.remove("submit_bujnumber");



                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  });
                              Timer(Duration(seconds: 1), () {
                                // 5s over, navigate to a new page
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FrmCloseVehicleMixer()));
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.orange.shade400,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              textStyle: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    this.getJSONData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
    //EasyLoading.init();
    //configLoading();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
