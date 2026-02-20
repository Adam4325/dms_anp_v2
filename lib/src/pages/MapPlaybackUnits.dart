import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/PinInformation.dart';
import 'package:dms_anp/src/pages/FrmPlayBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import '../flusbar.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

// Playback: delay antar titik (ms). 60000 = 1 menit per titik.
const int PLAYBACK_DELAY_MS = 1000;  // 2 menit per titik
const int PLAYBACK_CAMERA_ANIMATION_MS = 5000;  // 5 detik per perpindahan kamera
const LatLng SOURCE_LOCATION = LatLng(-6.181866111111, 106.829632777778);

class MapPlayBackUnits extends StatefulWidget {
  @override
  MapPlayBackUnitsState createState() => MapPlayBackUnitsState();
}

class MapPlayBackUnitsState extends State<MapPlayBackUnits> {
  final controller = FloatingSearchBarController();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  LocationData? currentLocation;
  LocationData? destinationLocation;
  double pinPillPosition = -170;
  List dataVehicle = [];
  List dataVehicleTemp = [];
  var isShowButtonPlayBack = true;
  var isShowToolsPlayBack = false;
  var isShowContainsSlidePanel = true;
  late Location location;
  Timer? _timer;
  String new_vhcid = "";
  String vendor_id = "";
  String vhcid = "";
  String vhcgps = "";
  double lat = 0;
  double lon = 0;
  String addr = "";
  String no_do = "";
  String ket_status_do = "";
  String driver_nm = "";
  String nopol = "";
  String gps_sn = "";
  String gps_time = "";
  int speed = 0;
  int acc = 0;
  String direction = "0";
  List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();
  //final _cnSearch = TextEditingController();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  
  //UNIT INFO
  var u_address = "";
  var u_reportname = "";
  var u_odometer = "0";
  var u_acc = "";
  var u_speed = "0";
  var u_nopol = "";
  var u_status_kendaraan = "";
  var u_report_nm = "";
  var u_gps_time = "";
  var u_statusKendaraan = "";
  var isShowUnitInfo = false;
  var isLastDataInfo = false;
  var isShowPlay = true;
  var isShowPause = false;
  var isPrevPlayBack = true;
  var index_his = 0;
  
  //PLAYBACK CONTROLS
  Set<Polyline> _polylines = {};
  Set<PolylineId> _polylineIds = {};
  List<LatLng> _polylinePoints = [];
  
  //HISTORY DATA
  Map<String, dynamic> data_list_history = {};
  var do_number = '';

  PinInformation2 currentlySelectedPin = PinInformation2(
      pinPath: '',
      avatarPath: '',
      addr: '',
      labelColor: Colors.grey);
  late PinInformation2 sourcePinInfo;
  late PinInformation2 destinationPinInfo;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.181866111111, 106.829632777778),
    zoom: 15,
  );

  var is_driver = "";

  void getShareDateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vhcgps = prefs.getString("pb_") ?? "";
      is_driver = prefs.getString("is_driver") ?? "";
    });
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vhcid = "";
      vhcgps = "";
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FrmPlayBack()));
  }

  setUpTimedFetch() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          //GetLastPosition();
        });
      }
    });
  }

  void GetStartData() async {
    await Future.delayed(Duration(seconds: 2));
    await GetHistoryPlayBack();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data_list_history.isNotEmpty) {
      if (data_list_history['Data'] != null && data_list_history['Data'].length > 0) {
        print("data_list_history['Data']");
        print(data_list_history['Data']);
        var item = data_list_history['Data'][0];
        try{
          do_number = "";
          updatePinOnMap(
              double.parse(item['lat']),
              double.parse(item['lon']),
              item['direction'],
              item['gps_sn'],
              item['address'],
              item['nopol'],
              item['gps_time'],
              item['acc'],
              item['speed'],
              do_number,
              item['statusKendaraan'],
              item['report_nm'],
              item['odometer']);
          _addInitialPolyline(item['gps_sn'], double.parse(item['lat']),
              double.parse(item['lon']));
        }catch($e){
          alert(globalScaffoldKey.currentContext!, 0,
              data_list_history['ResponseMessage'], "error");
        }
      }else{
        alert(globalScaffoldKey.currentContext!, 0,
            data_list_history['ResponseMessage'], "error");
      }
    }
  }

  Future<String> GetHistoryPlayBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String vhcid = prefs.getString("pb_vhcid")!;
    var start_date = prefs.getString("pb_start_date");
    var end_date = prefs.getString("pb_end_date");

    print(start_date);
    try {
      if (vhcid != null && vhcid != "") {
        if (!EasyLoading.isShow) {
          EasyLoading.show();
        }
        var headers = {
          'token': '9C1CDA30C0D5405682C40C0B00FED742',
          'Content-Type': 'application/json'
        };
        var request = http.Request(
            'POST',
            Uri.parse(
                'https://vtsapi.easygo-gps.co.id/api/ANDALANNUSAPRATAMA/historydata'));
        request.body = json.encode({
          "start_time": start_date,
          "stop_time": end_date,
          "lst_vehicle_id": [],
          "lstNoPOL": ["${vhcid}"],
          "page": null,
          "limit": null,
          "encrypted": 0
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          data_list_history = jsonDecode(responseBody);
        } else {
          print(response.reasonPhrase);
          print('error');
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      print("Auth Error $e");
    }
    return "";
  }

  late FloatingSearchBarController controllerUI;
  @override
  void initState() {
    controllerUI = FloatingSearchBarController();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });

    setSourceAndDestinationIcons();
    getShareDateSession();
    GetStartData();
    GetDataVehicle();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    controllerUI.dispose();
    super.dispose();
  }

  void setMapPins(
      double _lat,
      double _lon,
      String direction,
      String _id,
      String _addr,
      String _nopol,
      String _gps_time,
      String _acc,
      String _speed,
      String _no_do,
      String _ketStatusDo,
      String vendorID) async {

    setState(() {
      var pinPosition = LatLng(_lat, _lon);
      _markers.removeWhere((m) => m.markerId.value == _id);

      // Direction rotation handling (Same as LiveMaps.dart)
      double rotation = 0;
      if (direction != null && direction != "") {
        try {
          rotation = double.parse(direction);
        } catch (e) {
          rotation = 0;
        }
      }

      // Add marker with same design as LiveMaps.dart
      _markers.add(Marker(
        markerId: MarkerId('$_id'),
        position: LatLng(_lat, _lon),
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
            isShowToolsPlayBack = false;
          });
        },
        rotation: rotation, // Same rotation logic as LiveMaps.dart
        infoWindow: InfoWindow(title: '${_nopol}'),
        icon: sourceIcon ?? BitmapDescriptor.defaultMarker, // Same icon as LiveMaps.dart
      ));

      // PinInformation2 setup (keeping existing structure but matching LiveMaps design)
      sourcePinInfo = PinInformation2(
          pinPath: "assets/img/driving_pin.png", // Same pinPath as LiveMaps.dart
          avatarPath: "",
          addr: "${_addr}",
          no_do: _no_do,
          nopol: _nopol,
          gps_time: _gps_time,
          acc: double.tryParse(_acc) ?? 0.0,
          speed: double.tryParse(_speed) ?? 0.0,
          lat: _lat,
          lon: _lon,
          labelColor: Colors.blueAccent); // Same labelColor as LiveMaps.dart
    });
  }

  Future<void> updatePinOnMap(
      double _lat,
      double _lon,
      String direction,
      String _id,
      String _addr,
      String _nopol,
      String _gps_time,
      String _acc,
      String _speed,
      String _no_do,
      String _statusKendaraan,
      String _report_nm,
      String _odometer,
      {int? cameraAnimationMs}) async {

    // Camera position setup (Same zoom logic as LiveMaps.dart)
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM, // Use same camera zoom as LiveMaps.dart
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(_lat, _lon),
    );

    final GoogleMapController controller = await _controller.future;
    final duration = cameraAnimationMs != null
        ? Duration(milliseconds: cameraAnimationMs)
        : null;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(cPosition),
      duration: duration,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        var pinPosition = LatLng(_lat, _lon);

        // Direction rotation handling (Same as LiveMaps.dart)
        double rotation = 0;
        if (direction != null && direction != "") {
          try {
            rotation = double.parse(direction);
          } catch (e) {
            rotation = 0;
          }
        }

        // Add marker with same design as LiveMaps.dart
        _markers.add(Marker(
            markerId: MarkerId(_id),
            onTap: () {
              setState(() {
                currentlySelectedPin = sourcePinInfo;
                pinPillPosition = 0;
                isShowToolsPlayBack = false;
              });
            },
            rotation: rotation, // Same rotation logic as LiveMaps.dart
            position: pinPosition,
            infoWindow: InfoWindow(title: '${_nopol}'),
            icon: sourceIcon ?? BitmapDescriptor.defaultMarker // Same icon as LiveMaps.dart
        ));

        // Update variables (keeping existing structure)
        if (mounted) {
          setState(() {
            u_address = _addr;
            u_acc = int.tryParse(_acc) == 1 ? "ON" : "OFF";
            u_speed = _speed;
            u_gps_time = _gps_time;
            u_nopol = _nopol;
            u_status_kendaraan = _statusKendaraan;
            u_report_nm = _report_nm;
            u_odometer = _odometer;

            // PinInformation2 setup (matching LiveMaps design)
            sourcePinInfo = PinInformation2(
                pinPath: "assets/img/driving_pin.png", // Same pinPath as LiveMaps.dart
                avatarPath: "",
                addr: "${_addr}",
                no_do: _no_do,
                nopol: _nopol,
                gps_time: _gps_time,
                acc: double.tryParse(_acc) ?? 0.0,
                speed: double.tryParse(_speed) ?? 0.0,
                lat: _lat,
                lon: _lon,
                labelColor: Colors.blueAccent); // Same labelColor as LiveMaps.dart
          });
        }
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }


  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/img/car02.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/img/destination_map_marker.png');
  }


  void onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataLast = prefs.getStringList("dataLast");
    var pages = prefs.getString("page");
    if (dataLast != null && dataLast.length > 0) {
      var lastGpsSn = dataLast[0].toString();
      print('lastGpsSn ${lastGpsSn}');
      if (lastGpsSn != "") {
        setSourceAndDestinationIcons();
        double lastLat = double.parse(dataLast[7]);
        double lastLon = double.parse(dataLast[8]);
        var lastAddr = dataLast[4].toString();
        var lastNopol = dataLast[1].toString();
        var lastGpsTime = dataLast[2].toString();
        var lasAcc = dataLast[3].toString();
        var lasSpeed = dataLast[5].toString();
        var lasNoDo = dataLast[9].toString();
        var lasKetNoDo = dataLast[10].toString();
        var lasDirection = dataLast[6].toString();
        vendor_id = dataLast[12].toString();
        
        gps_sn = lastGpsSn;
        setMapPins(lastLat, lastLon, lasDirection, gps_sn, lastAddr, lastNopol,
            lastGpsTime, lasAcc, lasSpeed, lasNoDo, lasKetNoDo, vendor_id);
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(lastLat, lastLon),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      }
    } else {
      if (pages == "another") {
        alert(globalScaffoldKey.currentContext!, 0,
            "data last update tidak ditemukan", "error");
      }
    }
  }

  removeMarkerOld(String gps_sn_old) {
    print('remove ${gps_sn_old}');
    if (gps_sn_old != null && gps_sn_old != "") {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == gps_sn_old);
        print('Removed ${gps_sn_old}');
        print(_markers);
      });
    }
  }

  void _addInitialPolyline(String gps_sn, double lat, double lon) {
    _polylinePoints = [LatLng(lat, lon)];
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(gps_sn),
          points: _polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void _updatePolyline(String gps_sn, double lat, double lon) {
    setState(() {
      _polylinePoints.add(LatLng(lat, lon));
      _polylines = _polylines.map((polyline) {
        if (polyline.polylineId.value == gps_sn) {
          print('update ${gps_sn}');
          return Polyline(
            polylineId: polyline.polylineId,
            points: _polylinePoints,
            color: Colors.blue,
            width: 5,
          );
        }
        return polyline;
      }).toSet();
    });
  }

  void _removePolyline(String index) {
    setState(() {
      _polylines.removeWhere((polyline) => polyline.polylineId.value == index);
    });
  }

  Future prevStartPlayBack() async {
    print('prev start');
    setState(() {
      index_his = 0;
      isShowPlay = true;
      if (isPrevPlayBack == false) {
        isPrevPlayBack = true;
      }
    });
    var item = data_list_history['Data'][0];

    if (item != null) {
      _removePolyline(item['gps_sn']);
      removeMarkerOld(item['gps_sn']);
      updatePinOnMap(
          double.parse(item['lat']),
          double.parse(item['lon']),
          item['direction'],
          item['gps_sn'],
          item['address'],
          item['nopol'],
          item['gps_time'],
          item['acc'],
          item['speed'],
          do_number,
          item['statusKendaraan'],
          item['report_nm'],
          item['odometer']);
      _addInitialPolyline(
          item['gps_sn'], double.parse(item['lat']), double.parse(item['lon']));
      index_his = 1;
    }
  }

  Future prevPlayBack() async {
    print(' < index_his ${index_his}');
    if (index_his == 0) return;
    if (data_list_history.isNotEmpty) {
      if (data_list_history['Data'] != null && data_list_history['Data'].length > 0) {
        index_his = index_his - 1;
        var item = data_list_history['Data'][index_his];
        if (index_his <= 1) {
          _removePolyline(item['gps_sn']);
        }
        print('back to last');
        if (isPrevPlayBack) {
          removeMarkerOld(item['gps_sn']);
          isPrevPlayBack = false;
        }

        updatePinOnMap(
            double.parse(item['lat']),
            double.parse(item['lon']),
            item['direction'],
            item['gps_sn'],
            item['address'],
            item['nopol'],
            item['gps_time'],
            item['acc'],
            item['speed'],
            do_number,
            item['statusKendaraan'],
            item['report_nm'],
            item['odometer']);
      }
    }
  }

  Future nextPlayBack() async {
    print('index_his ${index_his}');
    print(isShowPlay);
    if (isPrevPlayBack == false) {
      isPrevPlayBack = true;
    }

    if (data_list_history.isNotEmpty) {
      if (data_list_history['Data'] != null && index_his < data_list_history['Data'].length) {
        var item = data_list_history['Data'][index_his];
        updatePinOnMap(
            double.parse(item['lat']),
            double.parse(item['lon']),
            item['direction'],
            item['gps_sn'],
            item['address'],
            item['nopol'],
            item['gps_time'],
            item['acc'],
            item['speed'],
            do_number,
            item['statusKendaraan'],
            item['report_nm'],
            item['odometer']);
        _updatePolyline(item['gps_sn'], double.parse(item['lat']),
            double.parse(item['lon']));
        index_his++;
      }
    }
  }

  Future runPlayBack() async {
    print("runPlayBack isShowPause=$isShowPause index_his=$index_his");
    if (isLastDataInfo) {
      setState(() {
        isLastDataInfo = false;
        index_his = 0;
        if (isPrevPlayBack == false) {
          isPrevPlayBack = true;
        }
      });
      var item = data_list_history['Data'][0];
      _removePolyline(item['gps_sn']);
      removeMarkerOld(item['gps_sn']);
      _addInitialPolyline(
          item['gps_sn'], double.parse(item['lat']), double.parse(item['lon']));
      setState(() {
        index_his = 1;
      });
    }
    if (data_list_history.isNotEmpty &&
        data_list_history['Data'] != null &&
        data_list_history['Data'].length > 0) {
      final dataList = data_list_history['Data'] as List;
      while (index_his < dataList.length && mounted) {
        if (isShowPause) break;
        var item = dataList[index_his];
        await updatePinOnMap(
            double.parse(item['lat'].toString()),
            double.parse(item['lon'].toString()),
            item['direction']?.toString() ?? '0',
            item['gps_sn']?.toString() ?? '',
            item['address']?.toString() ?? '',
            item['nopol']?.toString() ?? '',
            item['gps_time']?.toString() ?? '',
            item['acc']?.toString() ?? '0',
            item['speed']?.toString() ?? '0',
            do_number,
            item['statusKendaraan']?.toString() ?? '',
            item['report_nm']?.toString() ?? '',
            item['odometer']?.toString() ?? '0',
            cameraAnimationMs: PLAYBACK_CAMERA_ANIMATION_MS);
        _updatePolyline(item['gps_sn']?.toString() ?? '',
            double.parse(item['lat'].toString()),
            double.parse(item['lon'].toString()));
        index_his++;
        if (isShowPause) break;
        int waited = 0;
        while (waited < PLAYBACK_DELAY_MS && !isShowPause && mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          waited += 100;
        }
      }
      if (index_his >= dataList.length && mounted) {
        setState(() {
          isLastDataInfo = true;
          isShowPlay = true;
          isShowPause = true;
        });
      }
    }
  }

  Future lastPlayBack() async {
    if (isPrevPlayBack == false) {
      setState(() {
        isPrevPlayBack = true;
      });
    }
    if (data_list_history.isNotEmpty) {
      if (data_list_history['Data'] != null) {
        for (var i = index_his;
        index_his < data_list_history['Data'].length;
        i++) {
          var item = data_list_history['Data'][i];
          updatePinOnMap(
              double.parse(item['lat']),
              double.parse(item['lon']),
              item['direction'],
              item['gps_sn'],
              item['address'],
              item['nopol'],
              item['gps_time'],
              item['acc'],
              item['speed'],
              do_number,
              item['statusKendaraan'],
              item['report_nm'],
              item['odometer']);
          _updatePolyline(item['gps_sn'], double.parse(item['lat']),
              double.parse(item['lon']));
          index_his++;
        }
      }
    }
  }

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData? currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    if (currentLocation != null) {
      final lat = currentLocation!.latitude ?? 0.0;
      final lon = currentLocation!.longitude ?? 0.0;
      if (lat != 0.0 || lon != 0.0) {
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(lat, lon),
            zoom: 17.0,
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    CameraPosition initialCameraPosition;
    if (currentLocation != null) {
      final lat = currentLocation!.latitude ?? 0.0;
      final lon = currentLocation!.longitude ?? 0.0;
      if (lat != 0.0 || lon != 0.0) {
        initialCameraPosition = CameraPosition(
            target: LatLng(lat, lon),
            zoom: CAMERA_ZOOM,
            tilt: CAMERA_TILT,
            bearing: CAMERA_BEARING);
      } else {
        initialCameraPosition = CameraPosition(
            zoom: CAMERA_ZOOM,
            bearing: CAMERA_BEARING,
            tilt: CAMERA_TILT,
            target: LatLng(-6.181866111111, 106.829632777778));
      }
    } else {
      initialCameraPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING,
          tilt: CAMERA_TILT,
          target: LatLng(-6.181866111111, 106.829632777778)
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FrmPlayBack()));
      },
      child: Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
            backgroundColor: Colors.orange,
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),
            elevation: 0.0,
            centerTitle: true,
            title: Text('Playback', style: TextStyle(color: Colors.white))),
        body: Stack(
          key: globalScaffoldKey,
          clipBehavior: Clip.none,
          children: [
            GoogleMap(
              mapToolbarEnabled: true,
              buildingsEnabled: true,
              myLocationEnabled: isShowPlay,
              trafficEnabled: false,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.normal,
              polylines: Set<Polyline>.of(_polylines),
              initialCameraPosition: initialCameraPosition,
              onMapCreated: onMapCreated,
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_previous_sharp,
                          size: 20,
                          color: Colors.orange,
                        ),
                        onPressed: () async {
                          await prevStartPlayBack();
                          print('IconButton pressed!');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.fast_rewind,
                          size: 20,
                          color: Colors.orange,
                        ),
                        onPressed: () async {
                          await prevPlayBack();
                          print('IconButton pressed! prev');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  if (isShowPlay) ...[
                    InkWell(
                      onTap: () async {
                        setState(() {
                          isShowPlay = false;
                          isShowPause = false;
                          isShowUnitInfo = true;
                        });
                        await runPlayBack();
                        if (mounted) setState(() {});
                        print('play! isShowPause $isShowPause');
                      },
                      child: Container(
                        width: 40,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 24,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5)
                  ],
                  if (!isShowPlay) ...[
                    InkWell(
                      onTap: () async {
                        setState(() {
                          isShowPlay = true;
                          isShowPause = true;
                        });
                        if (data_list_history['Data'] != null &&
                            index_his > 0 &&
                            index_his <= (data_list_history['Data'] as List).length) {
                          var item = (data_list_history['Data'] as List)[index_his - 1];
                          final mapController = await _controller.future;
                          mapController.moveCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                double.parse(item['lat'].toString()),
                                double.parse(item['lon'].toString()),
                              ),
                              zoom: CAMERA_ZOOM,
                              tilt: CAMERA_TILT,
                              bearing: CAMERA_BEARING,
                            ),
                          ));
                        }
                        print('Pause pressed!');
                      },
                      child: Container(
                        width: 40,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.pause,
                            size: 24,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    )
                  ],
                  SizedBox(width: 5),
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.fast_forward,
                          size: 20,
                          color: Colors.orange,
                        ),
                        onPressed: () async {
                          await nextPlayBack();
                          setState(() {
                            print(index_his);
                          });
                          print('IconButton pressed next!');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.skip_next_sharp,
                          size: 20,
                          color: Colors.orange,
                        ),
                        onPressed: () async {
                          await lastPlayBack();
                          setState(() {
                            isShowUnitInfo = true;
                            isLastDataInfo = true;
                          });
                          print('IconButton pressed! last ');
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (isShowUnitInfo) ...[
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        blurRadius: 15,
                        offset: Offset(0, 5),
                        color: Colors.grey.withOpacity(0.3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Address chip - full width dengan onTap functionality
                      InkWell(
                        onTap: () {
                          // Share location functionality
                        },
                        child: _buildInfoChip(
                            'Address',
                            u_address,
                            Icons.location_on,
                            Colors.orange,
                            isFullWidth: true
                        ),
                      ),

                      SizedBox(height: 12),

                      // Row untuk Nopol dan Acc
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                                'Nopol',
                                u_nopol,
                                Icons.directions_car,
                                Colors.blue
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                                'ACC',
                                u_acc,
                                Icons.power,
                                u_acc == 'ON' ? Colors.green : Colors.red
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Row untuk Speed dan GPS Time
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                                'Speed',
                                '${u_speed} km/h',
                                Icons.speed,
                                Colors.purple
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                                'GPS Time',
                                u_gps_time,
                                Icons.access_time,
                                Colors.teal
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Odometer chip - full width
                      _buildInfoChip(
                          'Odometer',
                          '${NumberFormat('0.00').format(double.tryParse(u_odometer) ?? 0.0)} Km',
                          Icons.speed,
                          Colors.indigo,
                          isFullWidth: true
                      ),

                      // Event chip - conditional
                      if (u_report_nm != null && u_report_nm != "") ...[
                        SizedBox(height: 8),
                        _buildInfoChip(
                            'Event',
                            u_report_nm,
                            Icons.warning,
                            Colors.red,
                            isFullWidth: true
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildInfoChip(String label, String value, IconData icon, Color color,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: isFullWidth ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300.0,
      width: 300.0,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Gujarat, India'),
          );
        },
      ),
    );
  }

  Widget searchBarUI() {
    if (is_driver == 'false') {
      return FloatingSearchBar(
        controller: controllerUI,
        hint: 'Search.....',
        openAxisAlignment: 0.0,
        openWidth: 600,
        axisAlignment: 0.0,
        scrollPadding: EdgeInsets.only(top: 16, bottom: 20),
        elevation: 4.0,
        physics: BouncingScrollPhysics(),
        onQueryChanged: (query) {
          if (query == null || query.isEmpty) {
            setState(() => dataVehicle = List.from(dataVehicleTemp));
          } else {
            final q = query.toLowerCase();
            var dt = dataVehicleTemp
                .where((e) =>
                    _getVehiclePlate(e).toLowerCase().contains(q) ||
                    _getVehicleId(e).toLowerCase().contains(q) ||
                    _getDriverName(e).toLowerCase().contains(q))
                .toList();
            setState(() => dataVehicle = dt);
          }
        },
        transitionCurve: Curves.easeInOut,
        transitionDuration: Duration(milliseconds: 500),
        transition: CircularFloatingSearchBarTransition(),
        debounceDelay: Duration(milliseconds: 500),
        actions: [
          FloatingSearchBarAction(
            showIfOpened: false,
            child: CircularButton(
              icon: Icon(Icons.car_rental),
              onPressed: () {
                setState(() {
                  dataVehicle = dataVehicleTemp;
                  print(dataVehicle);
                  controllerUI.close();
                });
              },
            ),
          ),
          FloatingSearchBarAction.searchToClear(
            showIfClosed: false,
          ),
        ],
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Material(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dataVehicle.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item = dataVehicle[index];
                        return ListTile(
                          title: Text(_getVehiclePlate(item)),
                          subtitle: Text(_getDriverName(item).isEmpty
                              ? 'ID: ${_getVehicleId(item)}'
                              : _getDriverName(item)),
                          onTap: () {
                            setState(() {
                              vhcid = _getVehicleId(item);
                              vhcgps = _getGpsSn(item);
                              new_vhcid = _getVehicleId(item).isNotEmpty
                                  ? _getVehicleId(item)
                                  : _getVehiclePlate(item);
                              vendor_id = _getVendorId(item);
                            });
                            controllerUI.close();
                            GetLastPosition();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  String _getVehiclePlate(dynamic item) =>
      (item['car_plate'] ?? item['title'] ?? item['nopol'] ?? '').toString();
  String _getVehicleId(dynamic item) =>
      (item['vhcid'] ?? item['value'] ?? '').toString();
  String _getDriverName(dynamic item) =>
      (item['driver_name'] ?? item['driver_nm'] ?? '').toString();
  String _getGpsSn(dynamic item) =>
      (item['gps_sn'] ?? '').toString();
  String _getVendorId(dynamic item) =>
      (item['vendor_id'] ?? item['vendor'] ?? '').toString();

  void GetDataVehicle() async {
    try {
      String urlData = "${GlobalData.baseUrl}api/gt/list_vehicle.jsp?method=lookup-vehicle-v1";
      String encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});

      if (!mounted) return;
      setState(() {
        if (response.statusCode == 200) {
          var decoded = jsonDecode(response.body);
          List rawList = decoded is List
              ? decoded
              : (decoded is Map && decoded['data'] != null)
                  ? decoded['data'] as List
                  : (decoded is Map && decoded['Data'] != null)
                      ? decoded['Data'] as List
                      : [];
          dataVehicle = rawList
              .map((dynamic e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
              .where((m) => m.isNotEmpty)
              .toList();
          dataVehicleTemp = List.from(dataVehicle);
        } else {
          alert(globalScaffoldKey.currentContext!, 0, "Gagal load data vehicle", "error");
        }
      });
    } catch (e) {
      if (mounted) {
        alert(globalScaffoldKey.currentContext!, 0, "Client, Load data vehicle", "error");
      }
      print(e.toString());
    }
  }

  void GetLastPosition() async {
    try {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      EasyLoading.show();

      String urlData = "${GlobalData.baseUrl}api/gt/last_position.jsp?method=last-position-v1&vhcid=$new_vhcid";
      print(urlData);
      Uri myUri = Uri.parse(urlData);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          lat = double.tryParse(data['lat'].toString()) ?? 0.0;
          lon = double.tryParse(data['lon'].toString()) ?? 0.0;
          addr = data['addr'].toString();
          no_do = data['no_do'].toString();
          ket_status_do = data['ket_status_do'].toString();
          driver_nm = data['driver_nm'].toString();
          nopol = data['nopol'].toString();
          gps_sn = data['gps_sn'].toString();
          gps_time = data['gps_time'].toString();
          speed = int.tryParse(data['speed'].toString()) ?? 0;
          acc = int.tryParse(data['acc'].toString()) ?? 0;
          direction = data['direction'].toString();
        });
        setMapPins(lat, lon, direction, new_vhcid, addr, nopol, gps_time, acc.toString(), speed.toString(), no_do, ket_status_do, vendor_id);
      } else {
        alert(globalScaffoldKey.currentContext!, 0, "Gagal load data position", "error");
      }
      
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      alert(globalScaffoldKey.currentContext!, 0, "Client, Load data position", "error");
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

}
