import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dms_anp/src/model/PinInformation.dart';
import 'package:dms_anp/src/pages/MapHistory.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
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
const LatLng SOURCE_LOCATION = LatLng(-6.181866111111, 106.829632777778);
const LatLng DEST_LOCATION = LatLng(-6.181866111111, 106.829632777778);

class MapPlayBack extends StatefulWidget {
  @override
  MapPlayBackState createState() => MapPlayBackState();
}

class MapPlayBackState extends State<MapPlayBack> with TickerProviderStateMixin {
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
  late Timer _timer;
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

  // Animation controllers
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Speed control
  double _playbackSpeed = 1.0; // 1x, 2x, 3x speed
  bool _isSpeedControlVisible = false;

  Set<Marker> _markers = <Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  final _cnSearch = TextEditingController();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  //UNIT INFO
  var u_address = "";
  var u_reportname = "";
  var u_odometer = "0";
  var u_acc = "";
  var u_speed = "0";
  var u_nopol = "";
  var u_gps_time = "";
  var u_statusKendaraan = "";
  var isShowUnitInfo = false;
  var isLastDataInfo = false;

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
    if (!mounted) return;
    setState(() {
      vhcgps = prefs.getString("pb_") ?? "";
      is_driver = prefs.getString("is_driver") ?? "";
      // String no_do = prefs.getString("do_maps") ?? "";
      // String drvid = prefs.getString("drvid") ?? "";
      // String vhcid = prefs.getString("vhcid") ?? "";
      // var do_tgl_do = prefs.getString("do_tgl_do") ?? "";
    });
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString("login_type")=="MIXER"){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ViewDashboard()));
    }else{
      setState(() {
        vhcid = "";
        vhcgps = "";
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MapHistory()));
    }

  }

  late Map<String, dynamic> data_list_history;
  var do_number = '';

  void GetStartData() async {
    await Future.delayed(Duration(seconds: 2));
    await GetHistoryPlayBack();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    do_number = prefs.getString("do_maps") ?? "";
    try {
      final data = data_list_history;
      print("data easygo");
      print(data);
      if (data != null &&
          data['Data'] != null &&
          (data['Data'] as List).isNotEmpty) {
        final item = data['Data'][0];
        updatePinOnMap(
            double.parse(item['lat'].toString()),
            double.parse(item['lon'].toString()),
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
            item['gps_sn'], double.parse(item['lat'].toString()), double.parse(item['lon'].toString()));
      } else {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0,
              (data['ResponseMessage']?.toString() ?? "Data playback kosong"),
              "error");
        }
      }
    } catch (e) {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(ctx, 0, "Gagal memulai playback: $e", "error");
      }
    }
  }

  Future<String> GetHistoryPlayBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String no_do = prefs.getString("do_maps") ?? "";
    String drvid = prefs.getString("drvid") ?? "";
    String vhcid = prefs.getString("do_vehicle_id") ??
        (prefs.getString("vhcid")?.split("/")[0] ?? "");
    vhcid = vhcid.split("/")[0];
    var do_tgl_do = prefs.getString("do_tgl_do")??"";
    DateTime now = DateTime.now();
    String currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    try {
      if (vhcid != "") {
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
        var params = {
          "start_time": do_tgl_do,
          "stop_time": currentDate,
          "lst_vehicle_id": [],
          "lstNoPOL": ["${vhcid}"],
          "page": null,
          "limit": null,
          "encrypted": 0
        };
        print("params");
        print(params);
        request.body = json.encode(params);
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          data_list_history = jsonDecode(responseBody);
        } else {
          print(response.reasonPhrase);
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
    super.initState();

    // Initialize animation controllers
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    controllerUI = FloatingSearchBarController();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });

    setSourceAndDestinationIcons();
    getShareDateSession();
    GetStartData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    // Start animations
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    controllerUI.dispose();
    super.dispose();
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
      String _no_do,
      String _statusKendaraan,
      String _report_nm,
      String _odometer) async {

    _markers.removeWhere((marker) => marker.markerId.value == _id);

    CameraPosition cPosition = CameraPosition(
      zoom: 15,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(_lat, _lon),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    if (mounted) {
      setState(() {
        var pinPosition = LatLng(_lat, _lon);
        double rotation = direction == null || direction == "" ? 0 : double.parse(direction);

        _markers.add(Marker(
            markerId: MarkerId(_id),
            onTap: () {
              setState(() {
                currentlySelectedPin = sourcePinInfo;
                pinPillPosition = 0;
                isShowToolsPlayBack = false;
              });
            },
            rotation: rotation,
            position: pinPosition,
            infoWindow: InfoWindow(title: '${_nopol}'),
            icon: sourceIcon));

        u_address = _addr;
        u_acc = int.tryParse(_acc) == 1 ? "ON" : "OFF";
        u_speed = "${_speed} Kpj";
        u_nopol = _nopol;
        u_gps_time = _gps_time;
        u_reportname = _report_nm;
        u_odometer = _odometer;
        u_statusKendaraan = _statusKendaraan;

        sourcePinInfo = PinInformation2(
            pinPath: "assets/img/driving_pin.png",
            avatarPath: "",
            addr: "${_addr}",
            no_do: _no_do,
            nopol: _nopol,
            gps_time: _gps_time,
            acc: double.tryParse(_acc) ?? 0.0,
            speed: double.tryParse(_speed) ?? 0.0,
            lat: _lat,
            lon: _lon,
            labelColor: Colors.blueAccent);
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
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
          zoom: 15,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(lastLat, lastLon),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      }
    } else {
      if (pages == "another") {
        final ctx = globalScaffoldKey.currentContext;
        if (ctx != null) {
          alert(ctx, 0, "data last update tidak ditemukan", "error");
        }
      }
    }
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

    _markers.removeWhere((marker) => marker.markerId.value == _id);

    var pinPosition = LatLng(_lat, _lon);
    double rotation = direction == null || direction == "" ? 0 : double.parse(direction);

    _markers.add(Marker(
      markerId: MarkerId('$_id'),
      position: pinPosition,
      onTap: () {
        setState(() {
          currentlySelectedPin = sourcePinInfo;
          pinPillPosition = 0;
          isShowToolsPlayBack = false;
        });
      },
      rotation: rotation,
      infoWindow: InfoWindow(title: '${_nopol}'),
      icon: sourceIcon,
    ));

    sourcePinInfo = PinInformation2(
        pinPath: "assets/img/driving_pin.png",
        avatarPath: "",
        addr: "${_addr}",
        no_do: _no_do,
        nopol: _nopol,
        gps_time: _gps_time,
        acc: double.tryParse(_acc) ?? 0.0,
        speed: double.tryParse(_speed) ?? 0.0,
        lat: _lat,
        lon: _lon,
        labelColor: Colors.blueAccent);
  }

  removeMarkerOld(String gps_sn_old) {
    if (gps_sn_old != "" && gps_sn_old != null) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == gps_sn_old);
      });
    }
  }

  var index_his = 0;
  Set<Polyline> _polylines = {};
  List<LatLng> _polylinePoints = [];
  var isShowPlay = true;
  var isShowPause = false;

  void _addInitialPolyline(String gps_sn, double lat, double lon) {
    _polylinePoints = [LatLng(lat, lon)];
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(gps_sn),
          points: _polylinePoints,
          color: Colors.blue.withOpacity(0.8),
          width: 4,
          patterns: [],
        ),
      );
    });
  }

  void _updatePolyline(String gps_sn, double lat, double lon) {
    setState(() {
      _polylinePoints.add(LatLng(lat, lon));
      _polylines = _polylines.map((polyline) {
        if (polyline.polylineId.value == gps_sn) {
          return Polyline(
            polylineId: polyline.polylineId,
            points: _polylinePoints,
            color: Colors.blue.withOpacity(0.8),
            width: 4,
            patterns: [],
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

  // Delay antar titik (ms)
  int _getPlaybackDelay() => 1000;

  Future prevStartPlayBack() async {
    setState(() {
      index_his = 0;
      isShowPlay = true;
      if (isPrevPlayBack == false) {
        isPrevPlayBack = true;
      }
    });
    if (data_list_history != null &&
        data_list_history['Data'] != null &&
        (data_list_history['Data'] as List).isNotEmpty) {
      final item = data_list_history['Data'][0];
      _removePolyline(item['gps_sn']);
      removeMarkerOld(item['gps_sn']);
      updatePinOnMap(
          double.parse(item['lat'].toString()),
          double.parse(item['lon'].toString()),
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
      _addInitialPolyline(item['gps_sn'], double.parse(item['lat'].toString()),
          double.parse(item['lon'].toString()));
      index_his = 1;
    } else {
      final ctx = globalScaffoldKey.currentContext;
      if (ctx != null) {
        alert(
            ctx,
            0,
            (data_list_history?['ResponseMessage']?.toString() ??
                "Data playback kosong"),
            "error");
      }
    }
  }

  var isPrevPlayBack = true;
  Future prevPlayBack() async {
    if (index_his == 0) return;
    if (data_list_history.length > 0) {
      if (data_list_history['Data'].length > 0) {
        index_his = index_his - 1;
        var item = data_list_history['Data'][index_his];
        if (index_his <= 1) {
          _removePolyline(item['gps_sn']);
        }
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
    if (isPrevPlayBack == false) {
      isPrevPlayBack = true;
    }

    if (data_list_history.length > 0) {
      if (index_his < data_list_history['Data'].length) {
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
    if (isLastDataInfo) {
      setState(() {
        isLastDataInfo = false;
        index_his = 0;
        if (isPrevPlayBack == false) {
          isPrevPlayBack = true;
        }
      });
      if (data_list_history != null &&
          data_list_history['Data'] != null &&
          (data_list_history['Data'] as List).isNotEmpty) {
        final item = data_list_history['Data'][0];
        _removePolyline(item['gps_sn']);
        removeMarkerOld(item['gps_sn']);
        _addInitialPolyline(item['gps_sn'],
            double.parse(item['lat'].toString()), double.parse(item['lon'].toString()));
        setState(() {
          index_his = 1;
        });
      }
    }
    if (data_list_history != null &&
        data_list_history['Data'] != null &&
        (data_list_history['Data'] as List).isNotEmpty) {
      for (var i = index_his;
      index_his < data_list_history['Data'].length;
      i++) {
        if (isShowPause == true) {
          break;
        } else {
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
          int waited = 0;
          final delayMs = _getPlaybackDelay();
          while (waited < delayMs && !isShowPause && mounted) {
            await Future.delayed(const Duration(milliseconds: 100));
            waited += 100;
          }
          index_his++;
        }
      }
      if (mounted) {
        setState(() {
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
    if (data_list_history.length > 0) {
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    CameraPosition initialCameraPosition;
    final loc = currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(loc!.latitude!, loc.longitude!),
          zoom: 15,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    } else {
      initialCameraPosition = CameraPosition(
          zoom: 15,
          bearing: CAMERA_BEARING,
          tilt: CAMERA_TILT,
          target: LatLng(-6.181866111111, 106.829632777778));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async{
        if (didPop) return;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.getString("login_type")=="MIXER"){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ViewDashboard()));
        }else{
          setState(() {
            vhcid = "";
            vhcgps = "";
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MapHistory()));
        }

      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Top Section - Map (40% of screen)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Google Map
                  Container(
                    width: double.infinity,
                    child: GoogleMap(
                      mapToolbarEnabled: false,
                      buildingsEnabled: true,
                      myLocationEnabled: isShowPlay,
                      trafficEnabled: false,
                      compassEnabled: false,
                      tiltGesturesEnabled: false,
                      markers: _markers,
                      mapType: MapType.normal,
                      polylines: _polylines,
                      initialCameraPosition: initialCameraPosition,
                      onMapCreated: onMapCreated,
                    ),
                  ),



                  // Custom AppBar
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SafeArea(
                      child: Container(
                        margin: EdgeInsets.only(top: 8, left: 16, right: 16),
                        child: Row(
                          children: [
                            _buildSoftButton(
                              icon: Icons.arrow_back_ios,
                              onPressed: () => _goBack(context),
                            ),
                            _buildSoftButton(
                              icon: Icons.speed,
                              onPressed: () {
                                setState(() {
                                  _isSpeedControlVisible = !_isSpeedControlVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 80,//
                    left: 16,
                    right: 16,
                    child: _buildPlaybackControls(),
                  ),

                  // Speed Control Panel
                  if (_isSpeedControlVisible)
                    Positioned(
                      top: 80,
                      left: 16,
                      right: 16,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, -1),
                          end: Offset(0, 0),//
                        ).animate(_slideAnimation),
                        child: SafeArea(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),//
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Playback Speed',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      '${_playbackSpeed.toStringAsFixed(1)}x',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.blue.shade400,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    thumbColor: Colors.white,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                                    overlayColor: Colors.blue.withOpacity(0.2),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                                  ),
                                  child: Slider(
                                    value: _playbackSpeed,
                                    min: 1.0,
                                    max: 3.0,
                                    divisions: 2,
                                    onChanged: (value) {
                                      setState(() {
                                        _playbackSpeed = value;
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('1x', style: TextStyle(color: Colors.grey.shade600)),
                                    Text('2x', style: TextStyle(color: Colors.grey.shade600)),
                                    Text('3x', style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVehicleHeader(),
                            SizedBox(height: 8),
                            _buildVehicleInfo(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),

            //
            SizedBox.shrink(),
        ]),
      ),
    );
  }

  Widget _buildSoftButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.grey.shade700,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: Colors.blue.shade600,
            size: 32,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u_nopol.isNotEmpty ? u_nopol : 'Loading...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  u_statusKendaraan.isNotEmpty ? u_statusKendaraan : 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: () async {
                  await prevStartPlayBack();
                },
              ),
              _buildControlButton(
                icon: Icons.fast_rewind_rounded,
                onPressed: () async {
                  await prevPlayBack();
                },
              ),
              if (isShowPlay) ...[
                _buildControlButton(
                  icon: Icons.play_arrow_rounded,
                  onPressed: () async {
                    setState(() {
                      isShowPlay = false;
                      isShowPause = false;
                    });
                    await runPlayBack();
                  },
                  isbackgroundColor: true,
                  size: 32,
                ),
              ] else ...[
                _buildControlButton(
                  icon: Icons.pause_rounded,
                  onPressed: () async {
                    setState(() {
                      isShowPlay = true;
                      isShowPause = true;
                    });
                    if (data_list_history['Data'] != null &&
                        index_his < data_list_history['Data'].length &&
                        index_his > 0) {
                      var item = data_list_history['Data'][index_his - 1];
                      final controller = await _controller.future;
                      controller.moveCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            double.parse(item['lat'].toString()),
                            double.parse(item['lon'].toString()),
                          ),
                          zoom: 15,
                          tilt: CAMERA_TILT,
                          bearing: CAMERA_BEARING,
                        ),
                      ));
                    }
                  },
                  isbackgroundColor: true,
                  size: 32,
                ),
              ],
              _buildControlButton(
                icon: Icons.fast_forward_rounded,
                onPressed: () async {
                  await nextPlayBack();
                },
              ),
              _buildControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: () async {
                  await lastPlayBack();
                  setState(() {
                    isLastDataInfo = true;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required  VoidCallback onPressed,
    bool isPrimary = false,
    double size = 24,
    isbackgroundColor = true
  }) {
    final buttonSize = isPrimary ? 64.0 : 52.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue.shade500 : Colors.white,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        boxShadow: [
          BoxShadow(
            color: isPrimary ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            blurRadius: isPrimary ? 12 : 8,
            offset: Offset(0, isPrimary ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: onPressed,
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : Colors.grey.shade700,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {//
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Information',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 6),

        // First Row - ACC & Speed
        Row(
          children: [
            Expanded(child: _buildInfoCard(
              icon: Icons.power_settings_new,
              label: "ACC",
              value: u_acc.isNotEmpty ? u_acc : 'OFF',
              color: u_acc == "ON" ? Colors.green : Colors.red,
            )),
            SizedBox(width: 10),
            Expanded(child: _buildInfoCard(
              icon: Icons.speed,
              label: "Speed",
              value: u_speed.isNotEmpty ? u_speed : '0 Kpj',
              color: Colors.blue,
            )),
          ],
        ),
        SizedBox(height: 6),

        // Second Row - GPS Time & Odometer
        Row(
          children: [
            Expanded(child: _buildInfoCard(
              icon: Icons.access_time,
              label: "GPS Time",
              value: u_gps_time.isNotEmpty ? u_gps_time : 'No Data',
              color: Colors.purple,
            )),
            SizedBox(width: 10),
            Expanded(child: _buildInfoCard(
              icon: Icons.speed,
              label: "Odometer",
              value: "${NumberFormat('0.00').format(double.parse((u_odometer == null || u_odometer == "" ? "0" : u_odometer)))} Km",
              color: Colors.orange,
            )),
          ],
        ),

        // Event Warning (if exists)
        if (u_reportname != null && u_reportname.isNotEmpty) ...[
          SizedBox(height: 6),
          _buildInfoCard(
            icon: Icons.warning_rounded,
            label: "Event",
            value: u_reportname,
            color: Colors.red,
            isFullWidth: true,
          ),
        ],

        // Address
        SizedBox(height: 6),
        _buildInfoCard(
          icon: Icons.location_on_rounded,
          label: "Address",
          value: u_address.isNotEmpty
              ? (u_address.trim().length > 50
                  ? u_address.trim().substring(0, 50) + '...'
                  : u_address.trim())
              : 'No Address',
          color: Colors.indigo,
          isFullWidth: true,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFullWidth = false,
    int? maxLines,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: maxLines ?? (isFullWidth ? 2 : 1),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
//
class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
