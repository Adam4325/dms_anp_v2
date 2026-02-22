import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dms_anp/src/Color/color_constants.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/MapPlayBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'ViewDashboard.dart';
import 'dart:ui' as ui;

/*
Title:GoogleMapScreen
Purpose:GoogleMapScreen
Created By:Kalpesh Khandla
*/

class MapHistoryMixer extends StatefulWidget {
  MapHistoryMixer({Key? key}) : super(key: key);

  @override
  MapHistoryMixerState createState() => MapHistoryMixerState();
}

class MapHistoryMixerState extends State<MapHistoryMixer> {
  var heigntValue = 0.0;
  late double height, width;
  double heightTemp = 0;
  int amountTxt = 390;
  var index_his = 0;
  List<Marker> _markers_his = <Marker>[];
  double CAMERA_TILT = 0;
  double CAMERA_BEARING = 30;
  LatLng SOURCE_LOCATION = LatLng(-6.181866111111, 106.829632777778);
  LatLng DEST_LOCATION = LatLng(-6.181866111111, 106.829632777778);
  double CAMERA_ZOOM = 16;
  Completer<GoogleMapController> _controller_his = Completer();

  String orderNo = "";
  String restaurantName = "";
  String addressTxt = "";
  late GoogleMapController mapController;

  double _originLatitude = 23.0284, _originLongitude = 72.5068;

  double _destLatitude = 23.1013, _destLongitude = 72.5407;

  late Marker his_marker;
  LatLng currentPosition = LatLng(37.7749, -122.4194);
  double direction = 45.0; // Example direction in degrees

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  // List<LatLng> polylineCoordinates = [
  //   LatLng(23.0284, 72.5068),
  //   LatLng(23.0504, 72.4991),
  //   LatLng(23.1013, 72.5407),
  // ];

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints(apiKey: 'AIzaSyD2TFCSTdbRTmvblF1WYhGxfNMZtbseMQo');
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  String googleAPiKey = "AIzaSyD2TFCSTdbRTmvblF1WYhGxfNMZtbseMQo";
  String origin = "";
  String destination = "";
  String driver_nm = "";
  String vehicled_id = "";
  String info_windows = "";
  var isShowPanel = false;
  var gps_time = '';
  var engine_acc = '';
  var isShowButtonPlayBack = true;
  var isShowToolsPlayBack = false;
  var isShowContainsSlidePanel = true;

  List<dynamic> data_list_do = [];
  late Map<String, dynamic> data_list_history;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
    await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void runPlayBack(){
    print("markers.values ${markers.values}");
    if(markers!=null){
      markers.remove((key, value) => value.markerId == "origin");
      markers.remove((key, value) => value.markerId == "destination");
    }
    print("PRINT ${markers}");
  }
  void updatePinOnMap(
      double _lat,
      double _lon,
      String direction,
      String _id,
      String _addr,
      String _nopol,
      String _gps_time,
      String _acc,
      String _speed,
      String gps_sn) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(_lat, _lon),
    );
    print('update position');
    final GoogleMapController controller = await _controller_his.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    final Uint8List markerIcon8list =  await getBytesFromAsset('assets/img/car02.png', 100);
    setState(() {
      // updated position
      var pinPosition = LatLng(_lat, _lon);

      //sourcePinInfo.location = pinPosition;
      //_markers.removeWhere((m) => m.markerId.value == gps_sn);

      double rotation =
      direction == null || direction == "" ? 0 : double.parse(direction);
      //markers
      // _addMarker(
      //   LatLng(_lat,_lon),
      //   gps_sn,
      //     sourceIcon,
      // );
      _markers_his.add(Marker(
          markerId: MarkerId(gps_sn),
          onTap: () {
            // setState(() {
            //   currentlySelectedPin = sourcePinInfo;
            //   pinPillPosition = 0;
            // });
          },
          rotation: rotation, //(rotation * (math.pi / 180) * -1),
          position: pinPosition,
          infoWindow: InfoWindow(title: '${_nopol}'), // updated position
          icon: sourceIcon
        //icon: BitmapDescriptor.fromBytes(markerIcon8list)
      ));

    });
  }

  Future<String> GetHistoryPlayBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String no_do = prefs.getString("do_maps")!;
    String drvid = prefs.getString("drvid")!;
    String vhcid = prefs.getString("vhcid")!;
    var do_tgl_do = prefs.getString("do_tgl_do");
    DateTime now = DateTime.now(); // Current date and time
    String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    //token 9C1CDA30C0D5405682C40C0B00FED742
    print(do_tgl_do);
    print(currentDate);
    try {
      if (vhcid != null && vhcid != "") {
        if(!EasyLoading.isShow){
          EasyLoading.show();
        }
        var headers = {
          'token': '9C1CDA30C0D5405682C40C0B00FED742',
          'Content-Type': 'application/json'
        };
        var request = http.Request('POST', Uri.parse('https://vtsapi.easygo-gps.co.id/api/ANDALANNUSAPRATAMA/historydata'));
        request.body = json.encode({
          "start_time": do_tgl_do,
          "stop_time": currentDate,
          "lst_vehicle_id": [],
          "lstNoPOL": [
            "${vhcid}"
          ],
          "page": null,
          "limit": null,
          "encrypted": 0
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          data_list_history = jsonDecode(responseBody);
          print(data_list_history);
          print(data_list_history[0]);
        }
        else {
          print(response.reasonPhrase);
          print('error');
        }
      }
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
    } catch (e) {
      if(EasyLoading.isShow){
        EasyLoading.dismiss();
      }
      print("Auth Error $e");
    }
    return "";
  }

  void GetListDo() async {
    try {
      final JsonDecoder _decoder = new JsonDecoder();
      var prefs = await SharedPreferences.getInstance();
      String no_do = prefs.getString("do_maps")!;
      String drvid = prefs.getString("drvid")!;
      String vhcid = prefs.getString("vhcid")!;
      var do_tgl_do = prefs.getString("do_tgl_do")!;
      vehicled_id = prefs.getString("do_vehicle_id")!;
      origin = prefs.getString("do_origin")!;
      destination = prefs.getString("do_destination")!;
      driver_nm = prefs.getString("do_driver_nm")!;//
      var urlData =
          "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=lookup-list-do-driver-v1&drvid=${drvid}";
      Uri myUri = Uri.parse(urlData);
      print(myUri.toString());
      var response =
      await http.get(myUri, headers: {"Accept": "application/json"});
      setState(() {
        if (response.statusCode == 200) {
          data_list_do = json.decode(response.body);
        }
        print("data_list_do");
        print(data_list_do);
      });
    } catch (e) {
      print(e);
    }
  }

  // void GetHistoryDo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var no_do = prefs.get("do_maps");
  //   origin = prefs.get("do_origin");
  //   destination = prefs.get("do_destination");
  //   driver_nm = prefs.get("do_driver_nm");
  //   vehicled_id = prefs.get("do_vehicled_id");
  //
  //   var headers = {
  //     'Authorization': '9C1CDA30C0D5405682C40C0B00FED742',
  //     'token': '9C1CDA30C0D5405682C40C0B00FED742',
  //     'Content-Type': 'application/json'
  //   };
  //   var request = http.Request('POST',
  //       Uri.parse('https://vtsapi.easygo-gps.co.id/api/do_v1/history_data'));
  //   request.body = json.encode({
  //     "no_do": no_do //"DO15-IDC240500036"
  //   });
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  List<dynamic> result_history = [];
  void GetHistory() async {
    await Future.delayed(Duration(seconds: 5));
    if (EasyLoading.isShow == false) {
      EasyLoading.show();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    var date_now = ("${formattedDate}");
    print(date_now);
    var no_do = prefs.getString("do_maps");
    var do_tgl_do = prefs.getString("do_tgl_do");
    vehicled_id = prefs.getString("do_vehicle_id")!;
    origin = prefs.getString("do_origin")!;
    destination = prefs.getString("do_destination")!;
    driver_nm = prefs.getString("do_driver_nm")!;
    var headers = {
      'Authorization': '9C1CDA30C0D5405682C40C0B00FED742',
      'token': '9C1CDA30C0D5405682C40C0B00FED742',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('https://vtsapi.easygo-gps.co.id/api/report/historydata'));
    request.body = json.encode({
      "start_time": do_tgl_do,
      "stop_time": date_now,
      "lst_vehicle_id": [],
      "lstNoPOL": [vehicled_id],
      "page": null,
      "limit": null,
      "encrypted": 0
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print("response ${response.statusCode},text ${response.reasonPhrase}");
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var result = json.decode(res);
      print(result);
      if (result != null) {
        if (result['ResponseCode'] == 1) {
          result_history = result['Data'];
          if (result_history != null && result_history.length > 0) {
            print(result_history.length);
            print(result_history);
            _getPolyline();
            // print("polylineCoordinates");
            // print(polylineCoordinates);
            if (polylineCoordinates != null && polylineCoordinates.length > 0) {
              print(
                  "polylineCoordinates[polylineCoordinates.length - 1].latitude");
              print(
                  polylineCoordinates[polylineCoordinates.length - 1].latitude);
              print(polylineCoordinates[polylineCoordinates.length - 1]
                  .longitude);
              _addMarker(
                LatLng(polylineCoordinates[0].latitude,
                    polylineCoordinates[0].longitude),
                "origin",
                BitmapDescriptor.defaultMarker,
              );

              _addMarker(
                LatLng(
                    polylineCoordinates[polylineCoordinates.length - 1]
                        .latitude,
                    polylineCoordinates[polylineCoordinates.length - 1]
                        .longitude),
                "destination",
                BitmapDescriptor.defaultMarker,
              );
            }
          }
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } else {
      print(response.reasonPhrase);
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _controller_his.complete(controller);
  }

  _addPolyLine() {
    print(polylineCoordinates);
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      visible: true,
      color: ColorConstants.kBlueColor.withOpacity(0.5),
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;

    updateMarker(markerId);
  }

  updateMarker(id) async {
    Uri myUri = Uri.parse("http://maps.google.com/mapfiles/ms/micons/blue.png");
    Uri myUri2 =
        Uri.parse("http://maps.google.com/mapfiles/ms/micons/blue.png");
    var request = await http.get(myUri);
    var request2 = await http.get(myUri2);
    var bytes = request.bodyBytes;
    var bytes2 = request2.bodyBytes;
    var dataBytes;
    var dataBytes2;
    setState(() {
      dataBytes = bytes;
      dataBytes2 = bytes2;
    });
    final marker =
        markers.values.toList().firstWhere((item) => item.markerId == id);

    Marker _marker = Marker(
      markerId: marker.markerId,
      onTap: () {
        // print(marker.markerId);
        // print(marker.markerId.value);
        // if(marker.markerId.value=='origin'){
        //   print('origin');
        //   setState(() {
        //     info_windows=result_history!=null && result_history.length>0?result_history[0]['address']:origin;
        //   });
        // }else if(marker.markerId.value=='destination'){
        //   print('destination');
        //   setState(() {
        //     info_windows=result_history!=null && result_history.length>0?result_history[result_history.length-1]['address']:destination;
        //   });
        // }
        if (isShowPanel == false) {
          setState(() {
            isShowPanel = true;
          });
        } else {
          setState(() {
            isShowPanel = false;
          });
        }
      },
      position: LatLng(marker.position.latitude, marker.position.longitude),
      //icon: marker.icon,

      // icon: marker.markerId.value == 'origin' &&
      //    result_history != null? BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List()):BitmapDescriptor.fromBytes(dataBytes2.buffer.asUint8List()),
      infoWindow: InfoWindow(
          title: marker.markerId.value == 'origin' &&
                  result_history != null &&
                  result_history.length > 0
              ? "(Start)"
              : (marker.markerId.value == 'destination' &&
                      result_history != null &&
                      result_history.length > 0
                  ? "(Finish)".toString()
                  : 'No Address'),
          snippet: marker.markerId.value == 'origin' &&
                  result_history != null &&
                  result_history.length > 0
              ? "Address: " +
                  result_history[0]['address'].toString() +
                  "\n" +
                  ",GPS Time " +
                  result_history[0]['gps_time'].toString()
              : (marker.markerId.value == 'destination' &&
                      result_history != null &&
                      result_history.length > 0
                  ? "Address: " +
                      result_history[result_history.length - 1]['address'] +
                      "\n" +
                      ",GPS Time " +
                      result_history[result_history.length - 1]['gps_time']
                          .toString()
                          .toString()
                  : 'No Address')),
    );

    setState(() {
      //the marker is identified by the markerId and not with the index of the list
      markers[id] = _marker;
    });
    // mapController
    //   ..animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //       target: LatLng(marker.position.latitude, marker.position.longitude),
    //       zoom: 11.0)));
  }

  _getPolyline() async {
    if (result_history != null && result_history.length > 0) {
      for (var i = 0; i < result_history.length; i++) {
        var lat = double.parse(result_history[i]['lat']);
        var lon = double.parse(result_history[i]['lon']);
        print("ke-${i}, lat : ${lat}, lon: ${lon}");
        polylineCoordinates.add(LatLng(lat, lon));
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var no_do = prefs.getString("do_maps");
      orderNo = no_do!;

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          //proxy: googleAPiKey,
          origin: PointLatLng(
            polylineCoordinates.first.latitude,
            polylineCoordinates.first.longitude,
          ),
          destination: PointLatLng(
            polylineCoordinates.last.latitude,
            polylineCoordinates.last.longitude,
          ),
          mode: TravelMode.driving,
          wayPoints: [
            PolylineWayPoint(location: "Jakarta"),
          ],
        ),
      );

      print('result.points ${result.points}');
      print(result);
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      var p = polylineCoordinates;
      double minLat = p.first.latitude;
      double minLong = p.first.longitude;
      double maxLat = p.first.latitude;
      double maxLong = p.first.longitude;
      p.forEach((point) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      });
      mapController.moveCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(minLat, minLong),
              northeast: LatLng(maxLat, maxLong)),
          14));
      _addPolyLine();
    }
  }

  void updateMarkerPositionAndRotation() {
    setState(() {
      // Example: Update position and direction
      currentPosition = LatLng(37.7756, -122.4184); // New position
      direction = 135.0; // New direction in degrees

      // Update marker with new position and direction
      his_marker = his_marker.copyWith(
        positionParam: currentPosition,
        rotationParam: direction,
      );
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetHistory();
    GetListDo();
    isShowPanel = false;
    his_marker = Marker(
      markerId: MarkerId('Marker001'),
      position: currentPosition,
      rotation: direction,
    );
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("do_maps", "");
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime(2024, 7, 16);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    heightTemp = height;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ViewDashboard()));
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          // appBar: AppBar(
          //     backgroundColor: Colors.transparent,
          //     leading: IconButton(
          //       color: Colors.black,
          //       icon: Icon(Icons.arrow_back),
          //       iconSize: 20.0,
          //       onPressed: () {
          //         _goBack(context);
          //       },
          //     ),
          //     elevation: 0.0,
          //     centerTitle: true,
          //     title: Text('Maps History', style: TextStyle(color: Colors.black))),
          body: SafeArea(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-6.181866111111, 106.829632777778),
                    zoom: 12,
                  ),
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                GestureDetector(
                  onTap: () {
                    _goBack(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 15,
                    ),
                    child: Container(
                      height: 60,
                      width: 50,
                      decoration: BoxDecoration(
                        color: ColorConstants.kWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: ColorConstants.kBlackColor,
                      ),
                    ),
                  ),
                ),
                if (isShowPanel) ...[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: null,
                      margin: const EdgeInsets.only(
                        bottom: 5
                      ),
                      padding: const EdgeInsets.all(
                          10
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.kWhiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20.0),
                          topRight: const Radius.circular(20.0),
                          bottomRight: const Radius.circular(20.0),
                          bottomLeft: const Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 20,
                        ),
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(isShowContainsSlidePanel)...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NO DO: $orderNo"
                                      "\nNOPOL: $vehicled_id"
                                      "\nDRIVER: $driver_nm",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontSize: 14,
                                    fontFamily: "Poppins Regular",
                                    color: ColorConstants.kTextColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                              color: ColorConstants.kGreyTextColor
                                  .withOpacity(0.2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(//
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("JOB" + (
                                        result_history != null &&
                                            result_history.length > 0
                                            ? "\nOrigin: " +
                                            origin +
                                            "\nDestination: " +
                                            destination:''),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          fontSize: 12,
                                          fontFamily: "Poppins Regular",
                                          color: ColorConstants.kTextColor,
                                        ),
                                        overflow: TextOverflow.ellipsis),
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["inloading"] != null &&
                                        data_list_do[0]["inloading"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["status_do_mixer"] == "CLOSE" &&
                                        (data_list_do[0]["tgl_do"] != null &&
                                            data_list_do[0]["tgl_do"].toString().isNotEmpty)) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["status_do_mixer"] == "CLOSE" &&
                                        (data_list_do[0]["tgl_do"] != null &&
                                            data_list_do[0]["tgl_do"].toString().isNotEmpty)) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Close",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["status_do_mixer"] == "CLOSE"
                                                  ? "${data_list_do[0]["tgl_do"]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["status_do_mixer"] == "CLOSE"
                                                  ? "${data_list_do[0]["time_do"]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Status selesai",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["inloading"] != null &&
                                        data_list_do[0]["inloading"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("In Loading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["inloading"] != null
                                                  ? "${data_list_do[0]["inloading"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["inloading"] != null
                                                  ? "${data_list_do[0]["inloading"].toString().split(' ').length > 1 ? data_list_do[0]["inloading"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Kendaraan masuk area plant, mulai muat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),//
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outloading"] != null &&
                                        data_list_do[0]["outloading"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outloading"] != null &&
                                        data_list_do[0]["outloading"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Out Loading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outloading"] != null
                                                  ? "${data_list_do[0]["outloading"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outloading"] != null
                                                  ? "${data_list_do[0]["outloading"].toString().split(' ').length > 1 ? data_list_do[0]["outloading"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Muat selesai, kendaraan keluar area loading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outpool"] != null &&
                                        data_list_do[0]["outpool"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outpool"] != null &&
                                        data_list_do[0]["outpool"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Out Pool",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outpool"] != null
                                                  ? "${data_list_do[0]["outpool"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outpool"] != null
                                                  ? "${data_list_do[0]["outpool"].toString().split(' ').length > 1 ? data_list_do[0]["outpool"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Kendaraan keluar pool menuju customer",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["incustomer"] != null &&
                                        data_list_do[0]["incustomer"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["incustomer"] != null &&
                                        data_list_do[0]["incustomer"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("In Customer",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["incustomer"] != null
                                                  ? "${data_list_do[0]["incustomer"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["incustomer"] != null
                                                  ? "${data_list_do[0]["incustomer"].toString().split(' ').length > 1 ? data_list_do[0]["incustomer"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Kendaraan tiba di lokasi customer",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["inunloading"] != null &&
                                        data_list_do[0]["inunloading"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["inunloading"] != null &&
                                        data_list_do[0]["inunloading"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("In Unloading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["inunloading"] != null
                                                  ? "${data_list_do[0]["inunloading"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["inunloading"] != null
                                                  ? "${data_list_do[0]["inunloading"].toString().split(' ').length > 1 ? data_list_do[0]["inunloading"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Mulai bongkar muatan",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outunloading"] != null &&
                                        data_list_do[0]["outunloading"].toString().isNotEmpty) ...[
                                      SizedBox(height: 15),
                                    ],
                                    if (data_list_do.isNotEmpty &&
                                        data_list_do[0]["outunloading"] != null &&
                                        data_list_do[0]["outunloading"].toString().isNotEmpty) ...[
                                      Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Out Unloading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outunloading"] != null
                                                  ? "${data_list_do[0]["outunloading"].toString().split(' ')[0]}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(Icons.access_time, size: 14, color: Colors.redAccent),
                                            SizedBox(width: 6),
                                            Text(
                                              data_list_do.isNotEmpty && data_list_do[0]["outunloading"] != null
                                                  ? "${data_list_do[0]["outunloading"].toString().split(' ').length > 1 ? data_list_do[0]["outunloading"].toString().split(' ')[1] : ''}"
                                                  : "",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontSize: 12,
                                                    fontFamily: "Poppins Regular",
                                                    color: ColorConstants.kTextColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text("Bongkar selesai, kendaraan keluar area unloading",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: "Poppins Regular",
                                                  color: ColorConstants.kTextColor,
                                                ),
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      ),
                                    ],
                                  ],
                                ),
                                ),
                              ],
                            )],
                            if(isShowButtonPlayBack)...[
                            Container(
                              padding: EdgeInsets.all(2),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:<Widget>[
                                    if(isShowToolsPlayBack)...[
                                     Expanded(child:  ElevatedButton(
                                       onPressed: () async{
                                         print('Search');
                                         await GetHistoryPlayBack();
                                       },
                                       child: Text("Search"),
                                     ),
                                     ),
                                      SizedBox(width: 10)],
                                    Expanded(child:  ElevatedButton(
                                      onPressed: () {
                                        EasyLoading.show();
                                        Navigator.pushReplacement(
                                            context, MaterialPageRoute(builder: (context) => MapPlayBack()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade400,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(isShowContainsSlidePanel?'Run Playback':'close',style: TextStyle(color:Colors.white)),
                                    ))
                                  ]
                              ),
                            ),
                            ],
                            if(isShowToolsPlayBack)...[
                            Container( //PLAYBACK
                              padding: const EdgeInsets.all(
                                5
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 35,
                                    color: Colors.deepOrangeAccent,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.fast_rewind,
                                          size: 20, // Size of the icon
                                        ),
                                        onPressed: () {
                                          // Handle button press
                                          print('IconButton pressed!');
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 35,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.skip_previous_sharp,
                                          size: 20, // Size of the icon
                                        ),
                                        onPressed: () {
                                          // Handle button press
                                          print('IconButton pressed!');
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    onTap: (){
                                      runPlayBack();
                                      print('play!');
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 35,
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            print("Play pressed");
                                          },
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 35,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.pause,
                                          size: 20, // Size of the icon
                                        ),
                                        onPressed: () {
                                          // Handle button press
                                          print('IconButton pressed!');
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 35,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.skip_next_sharp,
                                          size: 20, // Size of the icon
                                        ),
                                        onPressed: () {
                                          // Handle button press
                                          print('IconButton pressed!');
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 35,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.fast_forward,
                                          size: 20, // Size of the icon
                                        ),
                                        onPressed: () {
                                          // Handle button press
                                          print('IconButton pressed!');
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )],
                          ],
                        )),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ));
  }
}
