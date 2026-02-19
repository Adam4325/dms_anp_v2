import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ListInventoryMaint.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/maintenance/ViewListWoDetailMCN.dart';
import 'package:dms_anp/src/pages/po/PoDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import '../../flusbar.dart';

class ViewListWoMcByForeMan extends StatefulWidget {

  @override
  _ViewListWoMcByForeManState createState() => _ViewListWoMcByForeManState();
}

class _ViewListWoMcByForeManState extends State<ViewListWoMcByForeMan> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey2 = GlobalKey<ScaffoldState>();
  GlobalKey globalScaffoldKey3 = GlobalKey<ScaffoldState>();

  TextEditingController txtSearchList = TextEditingController();
  var listDetail = [];
  var DummylistDetail = [];
  List<dynamic> data = [];
  String status_code = "";
  String message = "";

  Future<String> getJSONData({String search = ""}) async {
    EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid") ?? "";
    String locid = prefs.getString("locid") ?? "";
    String mechanicid = prefs.getString("mechanicid") ?? "";
    print(drvid);
    var url = "";
    url =
        "${GlobalData.baseUrl}api/maintenance/list_wo_start_foreman.jsp?method=list-wo&is_barcode=0&locid=" +
            locid +
            "&mechanicid=" +
            mechanicid +
            "&search=${search}";
    Uri myUri = Uri.parse(url);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      var responseData = json.decode(response.body);
      data = responseData["data"] ?? [];
      // print(data);
      if (data.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 2,
            "Anda tidak mempunyai data Work Order", "warning");
      }
    });
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    return "Successfull";
  }

  Future<String> getJSONDataBarcode(dynamic value, String wonumber) async {
    //EasyLoading.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String drvid = prefs.getString("drvid") ?? "";
    String locid = prefs.getString("locid") ?? "";
    String mechanicid = prefs.getString("mechanicid") ?? "";
    print(drvid);
    var url = "";
    setState(() {
      url =
          "${GlobalData.baseUrl}api/maintenance/list_wo_start.jsp?method=list-wo&is_barcode=1&wonumber=${wonumber}&locid=" +
              locid +
              "&mechanicid=" +
              mechanicid;
    });
    Uri myUri = Uri.parse(url);
    print(myUri.toString());
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      // Get the JSON data
      var responseData = json.decode(response.body);
      var datas = responseData["data"] ?? [];
      // print(data);
      if (datas.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 2,
            "Anda tidak mempunyai data Work Order", "warning");
      } else {
        if (datas[0]['wodwonbr'] == value['wodwonbr']) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600),
                  SizedBox(width: 8),
                  Text('Information',
                      style: TextStyle(color: Colors.orange.shade800)),
                ],
              ),
              content: Text("Start Worked Order " + wonumber + "?"),
              actions: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18.0,
                  ),
                  label: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        } else {
          alert(globalScaffoldKey.currentContext!, 2,
              "Scan Wo Number tidak sama", "warning");
        }
      }
    });
    //EasyLoading.dismiss();
    return "Successfull";
  }

  _goBack(BuildContext context) {
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => SubMenuMaintenance()));

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: true);

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        return false;
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
            backgroundColor: Colors.orange.shade700,
            elevation: 2,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            centerTitle: true,
            title: Text('Mechanic List WO',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18))),
        body: Container(
          key: globalScaffoldKey2,
          margin: const EdgeInsets.only(top: 5.0),
          constraints: BoxConstraints.expand(),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Stack(
            children: <Widget>[
              _buildListView(context)
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController txtSearch = new TextEditingController();
  Widget _buildListView(BuildContext context) {
    return RefreshIndicator(
      color: Colors.orange.shade600,
      onRefresh: () =>
          getJSONData(), // dipanggil tanpa search saat pull to refresh
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: txtSearch,
              decoration: InputDecoration(
                hintText: 'Cari Work Order/Nopol...',
                //prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.orange),
                  onPressed: () {
                    print(txtSearch.text);
                    if(txtSearch.text==null || txtSearch.text=="") return;
                    getJSONData(search: txtSearch.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // List data dari API
          ListView.builder(
            physics:
                NeverScrollableScrollPhysics(), // biar bisa discroll bareng RefreshIndicator
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _buildDMSMenuMCN(data[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListViewOLd(BuildContext context) {
    return RefreshIndicator(
        color: Colors.orange.shade600,
        onRefresh: getJSONData,
        child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: data.length,
            itemBuilder: (context, index) {
              //_controllers[index] = new TextEditingController();
              return _buildDMSMenuMCN(data[index], index);
            }));
  }

  String scanResult = '';
  String global_wo_number = '';
  String dglobal_wo_number = '';
  String geofence_name = "";
  var geo_id_area = 0;
  Position? userLocation;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = false;
  String androidID = "";
  List<dynamic> listGeofence = [];
  String txtAddr = "";

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${GlobalData.baseUrlOri}api/create_geofence_area_p2h.jsp?method=list-geofence-area-v1";
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
          var radius = double.parse(a['radius'].toString() ?? "0");
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lat']?.toString() ?? "0"),
                  double.parse(a['lon']?.toString() ?? "0")),
              LatLng(userLocation!.latitude, userLocation!.longitude));
          //print('distanceBetweenPoints ${distanceBetweenPoints} meter ${distanceBetweenPoints / 1000} KM');
          //if (distanceBetweenPoints >= radius) {
          //FOR DEV
          txtAddr = "";
          if (distanceBetweenPoints <= radius) {
            if (i == 0) {
              radiusOld = radius;
              geo_idOld = int.tryParse(a['geo_id']?.toString() ?? "0") ?? 0;
              geo_id_area = int.tryParse(a['geo_id']?.toString() ?? "0") ?? 0;
              geo_nmOld = a['name']?.toString() ?? "";
            } else {
              if (radiusOld < radius) {
                radius = radiusOld;
                geo_idOld = int.tryParse(a['geo_id']?.toString() ?? "0") ?? 0;
                geo_id_area = int.tryParse(a['geo_id']?.toString() ?? "0") ?? 0;
                geo_nmOld = a['name']?.toString() ?? "";
              }
            }
          }
        }

        if (geo_nmOld.isNotEmpty) {
          setState(() {
            txtAddr = "INGEO";
            print("valid geo_nmOld ${geo_nmOld}");
            isValid = true;
            geofence_name = geo_nmOld;
          });
        } else {
          setState(() {
            txtAddr = "OUTGEO";
            print("not valid geo_nmOld ${geo_nmOld}");
            geofence_name = "";
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

  Future<Position?> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      try {
        isMock = await TrustLocation.isMockLocation;
      } catch (e) {
        print('TrustLocation isMockLocation check error: $e');
        isMock = false;
      }
      TrustLocation.start(5);

      /// the stream getter where others can listen to.
      TrustLocation.onChange.listen((values) => {
            print(
                'TrustLocation ${values.latitude} ${values.longitude} ${values.isMockLocation}'),
            truslat = values.latitude.toString(),
            trusLon = values.longitude.toString()
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

  Future scanQRCodeWO(dynamic value) async {
    // TODO: Migrate to mobile_scanner - qrscan deprecated
    alert(globalScaffoldKey.currentContext!, 2,
        "Fitur scan QR perlu migrasi ke mobile_scanner", "warning");

    // global_wo_number = 'ANWO22004762';
    // getJSONDataBarcode(value, global_wo_number);
  }

  Widget _buildDMSMenuMCNOld(dynamic item, int index) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 220.0,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.orange.shade300),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange.shade50, Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.orange.shade600, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("WOD WONUMBER : ${item['wodwonbr'].toString() ?? '-'}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("NOPOL : ${item['vhcid']?.toString() ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 13)),
                        Text(
                            "WOD REQ NUMBER : ${item['wodsvcrreqnbr']?.toString() ?? '-'}",
                            style:
                                TextStyle(color: Colors.black87, fontSize: 13)),
                        Text(
                            "WORKED BY : ${item['wodworkeddby']?.toString() ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 13)),
                        Text(
                            "WOD START TIME : ${item['wodstartdatetime']?.toString() ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 12)),
                        Text(
                            "WOD END TIME : ${item['wodenddatetime']?.toString() ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 12)),
                        Text(
                            "WOD NOTES : ${item['wodnotes']?.toString() ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 12)),
                      ]),
                ],
              ),
            )
          ],
        ));
  }

  var mechanicID;
  List<Map<String, dynamic>> lstMechanicID = [];
  TextEditingController txtNotesStart = TextEditingController();
  TextEditingController txtWorkedByStart = TextEditingController();
  TextEditingController txtWorkedByIdStart = TextEditingController();
  TextEditingController txtWorkedByIdStop = TextEditingController();
  TextEditingController txtWorkedByStop = TextEditingController();
  TextEditingController txtNotesStop = TextEditingController();
  final List<String> options = [
    'WAITTING PART',
    'ISTIRAHAT',
    'PINDAH TUGAS',
    'FINISH'
  ];
  String selectedStopValue = "WAITTING PART";

  Future CreateStartStop(
      bool isload,
      String notes,
      String event_name,
      String wonumber,
      String srnumber,
      String id_detail,
      String tblname) async {
    try {
      //notes="TEST";
      EasyLoading.show();
      var a = await updatePosition("IM");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("username") ?? "";
      var mechanic_id = prefs.getString("mechanicid") ?? "";
      var urlBase = "";
      String lat = userLocation?.latitude?.toString() ?? "";
      String lon = userLocation?.longitude?.toString() ?? "";
      print(geo_id_area);
      print(geofence_name);
      //print("id_detail ${id_detail} , tblname ${tblname}");
      if (int.tryParse(id_detail) != null &&
          int.parse(id_detail) <= 0 &&
          tblname == 'HEADER') {
        urlBase =
            "${GlobalData.baseUrl}api/maintenance/sr/create_or_update_mcn.jsp?method=create-start-stop-v2&wonumber=${wonumber}&srnumber=${srnumber}&event_name=${event_name}&mechanic_id=${mechanic_id}&notes=${notes}&mcid=${mechanicID}&userid=${userid.toUpperCase()}&lat=${lat}&lon=${lon}&geo_nm=${geofence_name}&geo_id=${geo_id_area}";
      } else if (int.tryParse(id_detail) != null &&
          int.parse(id_detail) > 0 &&
          tblname == 'DETAIL') {
        urlBase =
            "${GlobalData.baseUrl}api/maintenance/sr/create_or_update_mcn.jsp?method=create-start-stop-detail-v2&id_detail=${id_detail}&tblname=${tblname}&wonumber=${wonumber}&srnumber=${srnumber}&event_name=${event_name}&mechanic_id=${mechanic_id}&notes=${notes}&mcid=${mechanicID}&userid=${userid.toUpperCase()}&lat=${lat}&lon=${lon}&geo_nm=${geofence_name}&geo_id=${geo_id_area}";
      } else if (int.tryParse(id_detail) != null &&
          int.parse(id_detail) <= 0 &&
          tblname == 'DETAIL') {
        urlBase =
            "${GlobalData.baseUrl}api/maintenance/sr/create_or_update_mcn.jsp?method=ccreate-start-stop-detail-mc-tambahan-v2&id_detail=${id_detail}&tblname=${tblname}&wonumber=${wonumber}&srnumber=${srnumber}&event_name=${event_name}&mechanic_id=${mechanic_id}&notes=${notes}&mcid=${mechanicID}&userid=${userid.toUpperCase()}&lat=${lat}&lon=${lon}&geo_nm=${geofence_name}&geo_id=${geo_id_area}";
      }
      var urlData = urlBase;

      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData["status_code"] == 200) {
          if (event_name == 'start') {
            setState(() {
              txtWorkedByIdStart.text = '';
              txtWorkedByStart.text = '';
              txtNotesStart.text = '';
            });
          }

          if (event_name == 'stop') {
            setState(() {
              txtWorkedByIdStop.text = '';
              txtWorkedByStop.text = '';
              txtNotesStop.text = '';
              selectedStopValue = "SELECT";
            });
          }
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          await Future.delayed(Duration(milliseconds: 1));
          await showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  SizedBox(width: 8),
                  Text('Success', style: TextStyle(color: Colors.green.shade800)),
                ],
              ),
              content: Text(responseData["message"]?.toString() ?? ""),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    getJSONData();
                  },
                  child:
                      Text('Ok', style: TextStyle(color: Colors.orange.shade700)),
                ),
              ],
            ),
          );
        } else {
          print(responseData["status_code"]);
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
          await Future.delayed(Duration(milliseconds: 1));
          await showDialog(
            context: globalScaffoldKey.currentContext!,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600),
                  SizedBox(width: 8),
                  Text('Alert', style: TextStyle(color: Colors.orange.shade800)),
                ],
              ),
              content: Text(responseData["message"]?.toString() ?? ""),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child:
                      Text('Ok', style: TextStyle(color: Colors.orange.shade700)),
                ),
              ],
            ),
          );
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal create start/ stop",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, create start/ stop",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> getListMechanicID(String wonumber) async {
    String status = "";
    var urlData =
        "${GlobalData.baseUrl}api/maintenance/sr/list_mechanicid.jsp?method=list-mechanicid&wonumber=${wonumber}";
    print(urlData);
    var encoded = Uri.encodeFull(urlData);
    Uri myUri = Uri.parse(encoded);
    print(encoded);
    var response =
        await http.get(myUri, headers: {"Accept": "application/json"});

    setState(() {
      var data = json.decode(response.body);
      if (data != null && data.length > 0) {
        lstMechanicID = (jsonDecode(response.body) as List)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList();
      }
    });
    return status;
  }

  Widget _buildDListDetail(dynamic item, int index) {
    var parsedDate = item["start_date"] != "null" && item["start_date"] != null
        ? DateTime.parse(item["start_date"])
        : null;
    var parsedDateEnd = item["stop_date"] != "null" && item["stop_date"] != null
        ? DateTime.parse(item["stop_date"])
        : null;
    String _startDate = parsedDate != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(parsedDate)
        : "";
    String _endDate = parsedDateEnd != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(parsedDateEnd)
        : "";
    print(_startDate);
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          Container(
            //padding: EdgeInsets.only(bottom: 20),
            width: MediaQuery.of(globalScaffoldKey.currentContext!).size.width,
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: Container(
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  "WO Number : ${item['wodwonbr']?.toString() ?? '-'}",
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Wrap(children: <Widget>[
                    _buildDetailRow(
                        "Mechanic Name", item['mcnname']?.toString() ?? '-'),
                    _buildDetailRow("Vhcid", item['vhcid']?.toString() ?? '-'),
                    _buildDetailRow(
                        "Notes", item['wolnotes']?.toString() ?? '-'),
                    _buildDetailRow("Start Date", _startDate),
                    _buildDetailRow("Stop Date", _endDate),
                    _buildDetailRow(
                        "Dur Tgl", item['dur_tgl']?.toString() ?? '-'),
                    _buildDetailRow(
                        "Dur. Time", item['dur_time']?.toString() ?? '-'),
                    _buildDetailRow(
                        "Vhtype", item['vhttype']?.toString() ?? '-'),
                  ]),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.black87, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future getListDetail(bool isload, String search, String mcnid,
      String wodwonbr, BuildContext context) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData = search.isEmpty
          ? "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list-detail-wo-by-mcn&mcnid=${mcnid}&wodwonbr=${wodwonbr}"
          : "${GlobalData.baseUrl}api/maintenance/sr/refferencce_mcn.jsp?method=list-detail-wo-by-mcn&search=${search}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listDetail = (jsonDecode(response.body) as List)
              .map((dynamic e) => e as Map<String, dynamic>)
              .toList();
          print('loaded ban tms ${listDetail.length}');
          DummylistDetail = listDetail;
        });
        if (listDetail.length > 0) {
          showDialog(
              context: globalScaffoldKey.currentContext!,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.list_alt, color: Colors.orange.shade600),
                      SizedBox(width: 8),
                      Text('List Detail',
                          style: TextStyle(color: Colors.orange.shade800)),
                    ],
                  ),
                  content: setupAlertDialoadContainerDetail(context),
                );
              });
        } else {
          alert(globalScaffoldKey.currentContext!, 2,
              "Tidak ada yang ditemukan!", "Warning");
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data detail",
            "error");
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data ban",
          "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Widget setupAlertDialoadContainerDetail(BuildContext context) {
    return SingleChildScrollView(
      //shrinkWrap: true,
      padding: EdgeInsets.all(2.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height *
                  0.6, // Change as per your requirement
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(2.0),
                  itemCount: listDetail.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDListDetail(listDetail[index], index);
                  }))
        ],
      ),
    );
  }

  Widget _buildDMSMenuMCN(dynamic value, int index) {
    //print(value["drvid"]);
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.orange.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 6.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        children: <Widget>[
          Container(
            padding:
                EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8),
            child: RepaintBoundary(
                //key: globalScaffoldKey3,
                child: QrImageView(
              data: value['wodwonbr']?.toString() ?? "",
              size: 0.4 * MediaQuery.of(context).size.height - 100,
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.orange.shade800,
              ),
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.orange.shade800,
              ),
            )),
          ),
          Container(
            padding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 10),
            //child: Text("${value['wodwonbr']}")
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              width: 1.0, color: Colors.orange.shade200))),
                  child: Icon(Icons.build, color: Colors.orange.shade600, size: 28),
                ),
                title: Text(
                  "WOD WONUMBER: ${value['wodwonbr']?.toString() ?? '-'}",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Wrap(children: <Widget>[
                    _buildInfoRow("NOPOL", value['vhcid']?.toString() ?? '-'),
                    _buildInfoRow("LOCID", value['locid']?.toString() ?? '-'),
                    _buildInfoRow("WOD REQ NUMBER",
                        value['wodsvcrreqnbr']?.toString() ?? '-'),
                    _buildInfoRow(
                        "WORKED BY", value['wodworkeddby']?.toString() ?? '-'),
                    _buildInfoRow("WOD START TIME",
                        value['wodstartdatetime']?.toString() ?? '-'),
                    _buildInfoRow("WOD END TIME",
                        value['wodenddatetime']?.toString() ?? '-'),
                    _buildInfoRow(
                        "WOD NOTES", value['wodnotes']?.toString() ?? '-'),
                    _buildInfoRow(
                        "IS DETAIL",
                        value['tblname']?.toString() == 'DETAIL'
                            ? 'YES (${value["id_detail"]?.toString() ?? ""})'
                            : '-'),
                  ]),
                ),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  label: Text("List Detail Inventory"),
                  onPressed: () async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListInventoryMaint(
                                widget_wodnumber: value['wodwonbr'],
                                widget_inv_trx_type: "-",
                                widget_from_ware_house: value['locid'],
                                widget_formen: "true")));
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 3.0,
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ))
              ])),
          // Container(
          //     margin: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16),
          //     child: Row(children: <Widget>[
          //       if (value['sr_typeid']?.toString() == 'STORING') ...[
          //         Expanded(
          //             child: ElevatedButton.icon(
          //               icon: Icon(
          //                 Icons.pin_drop,
          //                 color: Colors.white,
          //                 size: 20.0,
          //               ),
          //               label: Text("View Maps"),
          //               onPressed: () async {
          //                 print('View Maps');
          //                 print(value['latlon']);
          //                 var arrData = value['latlon']?.toString().split(",") ?? [];
          //                 if (arrData.length > 0) {
          //                   print(arrData[1]);
          //                   print(arrData[2]);
          //                   showDialog(
          //                     context: globalScaffoldKey.currentContext!,
          //                     builder: (context) => AlertDialog(
          //                       backgroundColor: Theme.of(context).colorScheme.onPrimary,
          //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //                       title: Row(
          //                         children: [
          //                           Icon(Icons.location_on, color: Colors.orange.shade600),
          //                           SizedBox(width: 8),
          //                           Text('Information', style: TextStyle(color: Colors.orange.shade800)),
          //                         ],
          //                       ),
          //                       content: Text("Location Maps"),
          //                       actions: <Widget>[
          //                         TextButton(
          //                             onPressed: () async {
          //                               Navigator.of(globalScaffoldKey.currentContext!)
          //                                   .pop(false);
          //                               SharedPreferences prefs =
          //                               await SharedPreferences.getInstance();
          //                               setState(() {
          //                                 prefs.setString("view_lat", arrData[1]);
          //                                 prefs.setString("view_lon", arrData[2]);
          //                               });
          //                               Navigator.pushReplacement(
          //                                   context,
          //                                   MaterialPageRoute(
          //                                       builder: (context) => ViewMaps()));
          //                             },
          //                             child: Text('Tetap disini', style: TextStyle(color: Colors.grey.shade600))),
          //                         ElevatedButton(
          //                           onPressed: () async {
          //                             //_tabController.animateTo(0);
          //                             Navigator.of(globalScaffoldKey.currentContext!)
          //                                 .pop(false);
          //                             Share.share('https://www.google.com/maps?q=${arrData[1]},${arrData[2]}&amp;t=m&amp;hl=en');
          //                           },
          //                           style: ElevatedButton.styleFrom(
          //                             backgroundColor: Colors.orange.shade600,
          //                             onbackgroundColor: Colors.white,
          //                             shape: RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(8),
          //                             ),
          //                           ),
          //                           child: Text('Share link'),
          //                         ),
          //                       ],
          //                     ),
          //                   );
          //                 } else {
          //                   alert(
          //                       globalScaffoldKey.currentContext!,
          //                       0,
          //                       "Data latitude/ longitude tidak di temukan",
          //                       "error");
          //                 }
          //               },
          //               style: ElevatedButton.styleFrom(
          //                   elevation: 3.0,
          //                   backgroundColor: Colors.blue.shade600,
          //                   onbackgroundColor: Colors.white,
          //                   padding:
          //                   EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //                   textStyle: TextStyle(
          //                       fontSize: 13, fontWeight: FontWeight.w600)),
          //             ))
          //       ],
          //       if (value['sr_typeid']?.toString() == 'STORING') ...[SizedBox(width: 12)],
          //       Expanded(
          //           child: ElevatedButton.icon(
          //             icon: Icon(
          //               Icons.menu,
          //               color: Colors.white,
          //               size: 20.0,
          //             ),
          //             label: Text("Detail"),
          //             onPressed: () async {
          //               print('Detail');
          //               SharedPreferences prefs =
          //               await SharedPreferences.getInstance();
          //               var mcnid = prefs.getString("mechanicid") ?? "";
          //               await getListDetail(
          //                   true, '', mcnid, value['wodwonbr']?.toString() ?? "", context);
          //             },
          //             style: ElevatedButton.styleFrom(
          //                 elevation: 3.0,
          //                 backgroundColor: Colors.green.shade600,
          //                 onbackgroundColor: Colors.white,
          //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //                 textStyle:
          //                 TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          //           )),
          //     ]))
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text("$label:",
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.black87, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mechanicID = prefs.getString("mechanicid") ?? "";
    print('mechanicID ${mechanicID}');
  }

  @override
  void initState() {
    getJSONData();
    getSession();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _getLocation().then((position) {
      userLocation = position;
    });
    if (options.isNotEmpty) {
      selectedStopValue = options[0]; // Default to the first option
    }
    getListGeofenceArea(false);
    super.initState();
  }

  @override
  void dispose() {
    txtSearchList.dispose();
    txtNotesStart.dispose();
    txtWorkedByStart.dispose();
    txtWorkedByIdStart.dispose();
    txtWorkedByIdStop.dispose();
    txtWorkedByStop.dispose();
    txtNotesStop.dispose();
    super.dispose();
  }
}
