
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/model/PinInformation.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dms_anp/src/component/map_pin_pill.dart';
import 'dart:ui' as ui;
import '../flusbar.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(-6.181866111111, 106.829632777778);
const LatLng DEST_LOCATION = LatLng(-6.181866111111, 106.829632777778);

class TotalKm {
  double totalKm;
  double maxSpeed;
  double avgSpeed;
  double durMoving;
  double durMov2;
  String startDateCounting;

  TotalKm({
    required this.totalKm,
    required this.maxSpeed,
    required this.avgSpeed,
    required this.durMoving,
    required this.durMov2,
    required this.startDateCounting,
  });

  factory TotalKm.fromJson(Map<String, dynamic> json) {
    return TotalKm(
      totalKm: (json['total_km'] as num).toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      avgSpeed: (json['avg_speed'] as num).toDouble(),
      durMoving: (json['dur_moving'] as num).toDouble(),
      durMov2: (json['durMov2'] as num).toDouble(),
      startDateCounting: json['start_date_counting'] ?? "",
    );
  }
}

// class LiveMaps extends StatefulWidget {
//
//   @override
//   LiveMapsState createState() => LiveMapsState();
// }

class LiveMaps extends StatefulWidget {
  final String is_driver;

  const LiveMaps({super.key, required this.is_driver});

  @override
  State<LiveMaps> createState() => LiveMapsState();
}

class LiveMapsState extends State<LiveMaps> with TickerProviderStateMixin {
  final controller = FloatingSearchBarController();
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  LocationData? currentLocation;
  LocationData? destinationLocation;
  double pinPillPosition = -170;
  List dataVehicle = [];
  List dataVehicleTemp = [];
  //var is_driver = "";
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
  double speed = 0;
  double acc = 0;
  String direction = "0";
  List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();
  final _cnSearch = TextEditingController();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;

  // Animation controllers for smooth design
  late AnimationController _fadeController;
  late AnimationController _markerController;
  late Animation<double> _fadeAnimation;
  late Animation<LatLng> _markerAnimation;

  // Map controls
  bool _isTrafficEnabled = false;
  MapType _currentMapType = MapType.normal;
  bool _showMapControls = false;

  // Marker interpolation
  LatLng? _previousPosition;
  late LatLng _targetPosition;

  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(-6.181866111111, 106.829632777778),
      locationName: '',
      labelColor: Colors.grey);
  late PinInformation sourcePinInfo;
  late PinInformation destinationPinInfo;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.181866111111, 106.829632777778),
    zoom: 15,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-6.181866111111, 106.829632777778),
      tilt: 59.440717697143555,
      zoom: 15);



  void ReverseAddress() async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=38.748666&lon=-9.103002&format=json'));
    request.headers['User-Agent'] = 'DMS_ANP/1.0 (ANP Driver Management System)';
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  void getShareDateSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vhcid = prefs.getString("vhcidOPR")!;
      vhcgps = prefs.getString("vhcgps")!;
      //is_driver = prefs.getString("is_driver")!;
      print('is_driver');
      print(widget.is_driver);
    });
  }

  _goBack(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vhcid = "";
      vhcgps = "";
      prefs.setString("vhcidOPR", "");
      prefs.setString("vhcgps", "");
      prefs.setString("dlocustdonbrOPR", "");
      prefs.setString("statusDlocustdonbrOPR", "");
      prefs.setString("is_driver", "");
      prefs.setStringList("dataLast", []);
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  setUpTimedFetch() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          GetLastPosition();
        });
      }
    });
  }

  String safeGetListElement(List<String> list, int index,
      {String defaultValue = ""}) {
    if (list == null || index < 0 || index >= list.length) {
      return defaultValue;
    }
    return list[index] ?? defaultValue;
  }

// Then update your LoadMapsfromListDo method to use it:
  void LoadMapsfromListDo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataLast = prefs.getStringList("dataLast");
    print(dataLast);

    if (widget.is_driver == "false") {
      if (dataLast != null && dataLast.length >= 13) {
        String vendorType = safeGetListElement(dataLast, 12);
        String vehicleId = safeGetListElement(dataLast, 1);

        if (vendorType == "easygo") {
          setState(() {
            vendor_id = "easygo";
            new_vhcid = "${vehicleId}/LT DP-1";
          });
        } else {
          setState(() {
            vendor_id = "izzy";
            new_vhcid = vehicleId;
          });
        }
        GetLastPosition();
        prefs.setStringList("dataLast", []);
      } else {
        print(
            "dataLast is null or incomplete. Length: ${dataLast?.length ?? 0}");
        //alert(globalScaffoldKey.currentContext!, 0, "Data tidak lengkap", "error");
      }
    } else {
      GetLastPosition();
      prefs.setStringList("dataLast", []);
    }
  }

  late FloatingSearchBarController controllerUI;

  @override
  void initState() {
    super.initState();
    _previousPosition = null;

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _markerController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    controllerUI = FloatingSearchBarController();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });

    setSourceAndDestinationIcons();
    getShareDateSession();
    GetDataVehicle();
    LoadMapsfromListDo();
    setUpTimedFetch();

    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    _fadeController.forward();
    print("widget.is_driver");
    print(widget.is_driver);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _fadeController.dispose();
    _markerController.dispose();
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
    var pinPosition = LatLng(_lat, _lon);
    _markers.removeWhere((m) => m.markerId.value == gps_sn);
    final Uint8List markerIcon8list2 =
        await getBytesFromAsset('assets/img/car02.png', 100);
    double rotation =
        direction == null || direction == "" ? 0 : double.parse(direction);
    _markers.add(Marker(
      markerId: MarkerId('$_id'),
      position: LatLng(_lat, _lon),
      onTap: () {
        setState(() {
          currentlySelectedPin = sourcePinInfo;
          pinPillPosition = 0;
        });
      },
      rotation: rotation,
      infoWindow: InfoWindow(title: '${_nopol}'),
      icon: sourceIcon,
    ));

    sourcePinInfo = PinInformation(
        locationName: "$_addr",
        location: LatLng(_lat, _lon),
        pinPath: "assets/img/driving_pin.png",
        avatarPath: "",
        no_do: _no_do,
        nopol: _nopol,
        gps_time: _gps_time,
        acc: double.parse(_acc),
        speed: double.parse(_speed),
        ket_status_do: _ketStatusDo,
        lat: _lat,
        lon: _lon,
        labelColor: Colors.blueAccent);
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
      String _ketStatusDo) async {
    LatLng newPosition = LatLng(_lat, _lon);
    final prevPos = _previousPosition;

    // Smooth marker interpolation
    if (prevPos != null) {
      _targetPosition = newPosition;
      _markerAnimation = LatLngTween(
        begin: prevPos,
        end: _targetPosition,
      ).animate(CurvedAnimation(
        parent: _markerController,
        curve: Curves.easeInOut,
      ));

      _markerAnimation.addListener(() {
        if (mounted) {
          _updateMarkerPosition(_markerAnimation.value, direction, _nopol);
        }
      });

      _markerController.reset();
      _markerController.forward();
    } else {
      _previousPosition = newPosition;
      _updateMarkerPosition(newPosition, direction, _nopol);
    }

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: newPosition,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var doIzzy = prefs.getString("dlocustdonbrOPR");
    var statusDoIzzy = prefs.getString("statusDlocustdonbrOPR");

    setState(() {
      sourcePinInfo = PinInformation(
          locationName: "$_addr",
          location: newPosition,
          pinPath: "assets/img/driving_pin.png",
          avatarPath: "",
          no_do: vendor_id == "izzy" ? doIzzy! : _no_do,
          nopol: _nopol,
          gps_time: _gps_time,
          acc: double.parse(_acc),
          speed: double.parse(_speed),
          lat: _lat,
          lon: _lon,
          ket_status_do: vendor_id == "izzy" ? statusDoIzzy! : _ketStatusDo,
          labelColor: Colors.blueAccent);
    });

    _previousPosition = newPosition;
  }

  void _updateMarkerPosition(LatLng position, String direction, String nopol) {
    if (position == null) return;

    double rotation =
        direction == null || direction == "" ? 0 : double.parse(direction);
    _markers.removeWhere((m) => m.markerId.value == gps_sn);

    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(gps_sn),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          rotation: rotation,
          position: position,
          infoWindow: InfoWindow(title: '${nopol}'),
          icon: sourceIcon));
    });
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
    print("dataLast");
    print(dataLast);

    if (dataLast != null && dataLast.length >= 13) {
      String lastGpsSn = safeGetListElement(dataLast, 0);
      print('lastGpsSn ${lastGpsSn}');
      if (lastGpsSn != "") {
        setSourceAndDestinationIcons();

        try {
          double lastLat =
              double.parse(safeGetListElement(dataLast, 7, defaultValue: "0"));
          double lastLon =
              double.parse(safeGetListElement(dataLast, 8, defaultValue: "0"));
          String lastAddr = safeGetListElement(dataLast, 4);
          String lastNopol = safeGetListElement(dataLast, 1);
          String lastGpsTime = safeGetListElement(dataLast, 2);
          String lasAcc = safeGetListElement(dataLast, 3);
          String lasSpeed = safeGetListElement(dataLast, 5);
          String lasNoDo = safeGetListElement(dataLast, 9);
          String lasKetNoDo = safeGetListElement(dataLast, 10);
          String lasDirection = safeGetListElement(dataLast, 6);
          vendor_id = safeGetListElement(dataLast, 12);
          gps_sn = lastGpsSn;

          setMapPins(
              lastLat,
              lastLon,
              lasDirection,
              gps_sn,
              lastAddr,
              lastNopol,
              lastGpsTime,
              lasAcc,
              lasSpeed,
              lasNoDo,
              lasKetNoDo,
              vendor_id);

          CameraPosition cPosition = CameraPosition(
            zoom: CAMERA_ZOOM,
            tilt: CAMERA_TILT,
            bearing: CAMERA_BEARING,
            target: LatLng(lastLat, lastLon),
          );
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
        } catch (e) {
          print("Error parsing data: $e");
          alert(globalScaffoldKey.currentContext!, 0, "Error parsing data",
              "error");
        }
      }
    } else {
      if (pages == "another") {
        alert(globalScaffoldKey.currentContext!, 0,
            "data last update tidak ditemukan", "error");
      }
      print("dataLast is null or incomplete. Length: ${dataLast?.length ?? 0}");
    }
  }

  void onMapCreatedOld(GoogleMapController controller) async {
    _controller.complete(controller);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataLast = prefs.getStringList("dataLast");
    var pages = prefs.getString("page");
    print("dataLast");
    print(dataLast);
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

  Future GetDataVehicle() async {
    try {
      Uri myUri = Uri.parse(
          "https://canvas.easygo-gps.co.id/MasterData/GetListSnANP?token=YW5kYWxhbnwxMjM0NQ==");
      var response =
          await http.post(myUri, headers: {"Accept": "application/json"});
      print(myUri);
      if (response.statusCode == 200) {
        List<dynamic> listVehicle = json.decode(response.body)['data'];
        if (listVehicle.length > 0 && listVehicle != []) {
          dataVehicle = listVehicle;
          dataVehicleTemp = listVehicle;
        }
      } else {
        alert(globalScaffoldKey.currentContext!, 2, "Error Fetching data",
            "warning");
      }
    } catch (e) {
      print("Auth Error$e");
    }
  }

  removeMarkerOld() {
    print('remove ${gps_sn}');
    if (gps_sn == "" || gps_sn != null) {
      _markers.removeWhere((m) => m.markerId.value == gps_sn);
      print('Removed ${gps_sn}');
    }
  }

  Future<void> GetLastPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String vhcid;

    if (new_vhcid == "" || new_vhcid == null) {
      vhcid = prefs.getString("vhcidOPR")!;
    } else {
      vhcid = new_vhcid;
    }

    if (widget.is_driver == 'true') {
      vhcid = prefs.getString("vhcid")!;
    }
    vhcid = vhcid.split("/")[0];
    Uri myUri;
    Map<String, String>? headers;
    String token = GlobalData.token_vts;
    if (vendor_id == "izzy") {
      myUri = Uri.parse(GlobalData.baseUrlAPICANVASE +
          "MasterData/GetLastUpdateNopolIzzy?nopol=" +
          vhcid);
      headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json"
      };
    } else {
      myUri = Uri.parse("https://vtsapi.easygo-gps.co.id/api/Report/lastposition");
      headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json",
        "token": token,
      };
    }

    Map<String, dynamic> requestBody = {
      "list_vehicle_id": [],
      "list_nopol": [vhcid],
      "list_no_aset": [],
      "status_vehicle": 0,
      "geo_code": [],
      "min_lastupdate_hour": null,
      "page": 0,
      "encrypted": 0,
      "lat": null,
      "lon": null,
      "sort_by_distance": false,
      "max_distance": null
    };

    try {
      final response = await http.post(
        myUri,
        headers: headers!,
        body: vendor_id == "izzy" ? "" : jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('Data') &&
            jsonResponse['Data'] != null &&
            jsonResponse['Data'].length > 0) {
          Map item = jsonResponse['Data'][0];

          nopol = item.containsKey("nopol") && item["nopol"] != null
              ? item["nopol"]
              : "";
          gps_time = item.containsKey("gps_time") && item["gps_time"] != null
              ? item["gps_time"]
              : "";
          gps_sn = vendor_id == "izzy"
              ? (item.containsKey("nopol") && item["nopol"] != null
                  ? item["nopol"]
                  : "")
              : (item.containsKey("gps_sn") && item["gps_sn"] != null
                  ? item["gps_sn"]
                  : "");
          addr = item.containsKey("addr") && item["addr"] != null
              ? item["addr"]
              : "";
          direction = item.containsKey("direction") && item["direction"] != null
              ? item["direction"].toString()
              : "";
          driver_nm = item.containsKey("driver_nm") && item["driver_nm"] != null
              ? item["driver_nm"]
              : "";
          no_do = item.containsKey("currentDO") && item["currentDO"] != null
              ? item["currentDO"]
              : "";
          ket_status_do = "";

          if (item.containsKey("currentStatusVehicle") &&
              item["currentStatusVehicle"] != null) {
            if (item["currentStatusVehicle"].containsKey("ket") &&
                item["currentStatusVehicle"]["ket"] != null) {
              ket_status_do = item["currentStatusVehicle"]["ket"];
            }
          }

          acc = item.containsKey("acc") && item["acc"] != null
              ? item["acc"].toDouble()
              : 0.0;
          speed = item.containsKey("speed") && item["speed"] != null
              ? item["speed"].toDouble()
              : 0.0;
          lat = item.containsKey("lat") && item["lat"] != null
              ? item["lat"].toDouble()
              : 0.0;
          lon = item.containsKey("lon") && item["lon"] != null
              ? item["lon"].toDouble()
              : 0.0;

          double totalKmYtd = 0.0;
          String startDateYtd = "";
          if (item.containsKey("totalkm_ytd") && item["totalkm_ytd"] != null) {
            if (item["totalkm_ytd"].containsKey("total_km") &&
                item["totalkm_ytd"]["total_km"] != null) {
              totalKmYtd = item["totalkm_ytd"]["total_km"].toDouble();
            }
            if (item["totalkm_ytd"].containsKey("start_date_counting") &&
                item["totalkm_ytd"]["start_date_counting"] != null) {
              startDateYtd = item["totalkm_ytd"]["start_date_counting"];
            }
          }

          double totalKmMtd = 0.0;
          String startDateMtd = "";
          if (item.containsKey("totalkm_mtd") && item["totalkm_mtd"] != null) {
            if (item["totalkm_mtd"].containsKey("total_km") &&
                item["totalkm_mtd"]["total_km"] != null) {
              totalKmMtd = item["totalkm_mtd"]["total_km"].toDouble();
            }
            if (item["totalkm_mtd"].containsKey("start_date_counting") &&
                item["totalkm_mtd"]["start_date_counting"] != null) {
              startDateMtd = item["totalkm_mtd"]["start_date_counting"];
            }
          }
          updatePinOnMap(
            lat,
            lon,
            direction,
            gps_sn,
            addr,
            nopol,
            gps_time,
            acc.toString(),
            speed.toString(),
            no_do,
            ket_status_do,
          );


          print("Nopol: $nopol");
          print("GPS Time: $gps_time");
          print("GPS SN: $gps_sn");
          print("Alamat: $addr");
          print("Arah: $direction");
          print("Driver: $driver_nm");
          print("DO No: $no_do");
          print("Status DO: $ket_status_do");
          print("ACC: $acc");
          print("Speed: $speed");
          print("Lat: $lat");
          print("Lon: $lon");
          print("KM YTD: $totalKmYtd, Start YTD: $startDateYtd");
          print("KM MTD: $totalKmMtd, Start MTD: $startDateMtd");
        } else {
          print("Data kosong / tidak ditemukan.");
        }
      } else {
        print("Gagal memuat data. Kode: ${response.statusCode}");
      }
    } catch (e) {
      print("Terjadi error saat ambil data: $e");
    }
  }


  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    late LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      print("erro");
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 17.0,
      ),
    ));
  }

  void _toggleTraffic() {
    setState(() {
      _isTrafficEnabled = !_isTrafficEnabled;
    });
  }

  void _changeMapType(MapType newMapType) {
    setState(() {
      _currentMapType = newMapType;
      _showMapControls = false;
    });
  }

  Widget _buildSoftButton({
    required Widget child,
    required VoidCallback onPressed,
    bool isActive = false,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }

  Widget _buildMapTypeItem(String title, MapType mapType, IconData icon) {
    bool isSelected = _currentMapType == mapType;
    return InkWell(
      onTap: () => _changeMapType(mapType),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
              size: 14,
            ),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
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

  ProgressDialog? pr;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    CameraPosition initialCameraPosition;
    final loc = currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(loc!.latitude!, loc.longitude!),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ViewDashboard()));
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          key: globalScaffoldKey,
          children: [
            // Google Map
            GoogleMap(
              mapToolbarEnabled: false,
              buildingsEnabled: true,
              myLocationEnabled: true,
              trafficEnabled: _isTrafficEnabled,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              markers: Set<Marker>.of(_markers),
              mapType: _currentMapType,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: onMapCreated,
              onTap: (LatLng location) {
                setState(() {
                  pinPillPosition = -170;
                  _showMapControls = false;
                });
              },
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: _buildSoftButton(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    onPressed: () => _goBack(context),
                  ),
                ),
              ),
            ),


            // Map Controls (Right side)
            Positioned(
              right: 16,
              top: 80,
              bottom: widget.is_driver == 'false' ? 120 : 80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Map Type Selector
                    if (_showMapControls)
                      Container(
                        width: 120,
                        constraints: BoxConstraints(maxHeight: 200),
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Map Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildMapTypeItem(
                                  'Normal', MapType.normal, Icons.map),
                              SizedBox(height: 4),
                              _buildMapTypeItem('Satellite', MapType.satellite,
                                  Icons.satellite_outlined),
                              SizedBox(height: 4),
                              _buildMapTypeItem(
                                  'Hybrid', MapType.hybrid, Icons.layers),
                              SizedBox(height: 4),
                              _buildMapTypeItem(
                                  'Terrain', MapType.terrain, Icons.terrain),
                            ],
                          ),
                        ),
                      ),

                    // Control Buttons
                    Column(
                      children: [
                        // Map Type Button
                        _buildSoftButton(
                          child: Icon(
                            Icons.layers,
                            color: _showMapControls
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _showMapControls = !_showMapControls;
                            });
                          },
                          isActive: _showMapControls,
                        ),
                        SizedBox(height: 12),

                        // Traffic Button
                        _buildSoftButton(
                          child: Icon(
                            Icons.traffic,
                            color: _isTrafficEnabled
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                            size: 22,
                          ),
                          onPressed: _toggleTraffic,
                          isActive: _isTrafficEnabled,
                        ),
                        SizedBox(height: 12),

                        // Current Location Button (only for non-driver)
                        if (widget.is_driver == 'false')
                          _buildSoftButton(
                            child: Icon(
                              Icons.my_location,
                              color: Colors.grey.shade700,
                              size: 22,
                            ),
                            onPressed: _currentLocation,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Custom Pin Information Panel
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: pinPillPosition,
              left: 16,
              right: 16,
              child: pinPillPosition < -100
                  ? SizedBox.shrink()
                  : Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentlySelectedPin != null
                                          ? (currentlySelectedPin.nopol ??
                                              'Unknown')
                                          : 'Unknown',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      currentlySelectedPin != null
                                          ? (currentlySelectedPin
                                                  .ket_status_do ??
                                              'No Status')
                                          : 'No Status',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    pinPillPosition = -170;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Vehicle Info Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  'Speed',
                                  currentlySelectedPin != null
                                      ? '${currentlySelectedPin.speed ?? 0} km/h'
                                      : '0 km/h',
                                  Icons.speed,
                                  Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoChip(
                                  'ACC',
                                  currentlySelectedPin != null
                                      ? (currentlySelectedPin.acc == 1
                                          ? 'ON'
                                          : 'OFF')
                                      : 'OFF',
                                  Icons.power_settings_new,
                                  currentlySelectedPin != null &&
                                          currentlySelectedPin.acc == 1
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // GPS Time
                          _buildInfoChip(
                            'GPS Time',
                            currentlySelectedPin != null
                                ? (currentlySelectedPin.gps_time ?? 'No Data')
                                : 'No Data',
                            Icons.access_time,
                            Colors.purple,
                            isFullWidth: true,
                          ),
                          SizedBox(height: 8),

                          // Address
                          _buildInfoChip(
                            'Location',
                            currentlySelectedPin != null
                                ? (currentlySelectedPin.locationName ??
                                    'Unknown Location')
                                : 'Unknown Location',
                            Icons.location_on,
                            Colors.orange,
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ),
            ),

            // Search Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: searchBarUI(),
            ),
          ],
        ),
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
    if (widget.is_driver == 'false') {
      final maxHeight = MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top + 8) -
          24.0;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: FloatingSearchBar(
        controller: controllerUI,
        hint: 'Search Vehicle...',
        openAxisAlignment: 0.0,
        openWidth: 600,
        axisAlignment: 0.0,
        scrollPadding: EdgeInsets.only(top: 16, bottom: 20),
        elevation: 8.0,
        borderRadius: BorderRadius.circular(16),
        physics: BouncingScrollPhysics(),
        backgroundColor: Colors.white.withOpacity(0.95),
        onQueryChanged: (query) {
          print('search data vehicle');
          if (query == "" || query == null) {
            dataVehicle = dataVehicleTemp;
          } else {
            var dt = dataVehicle
                .where((element) => element['car_plate']
                    .toString()
                    .toLowerCase()
                    .contains(query.toString().toLowerCase()))
                .toList();
            if (dt != null && dt.length > 0) {
              setState(() {
                dataVehicle = dt;
              });
            } else {
              dataVehicle = dataVehicleTemp;
            }
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
              icon: Icon(Icons.directions_car,
                  color: Theme.of(context).primaryColor),
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
            borderRadius: BorderRadius.circular(16.0),
            child: Material(
              color: Colors.white,
              elevation: 8,
              child: _buildListView(context),
            ),
          );
        },
      ),
    );
    } else {
      return Container();
    }
  }

  final List<int> colorCodes = <int>[600, 500, 100];

  Widget _buildListView(BuildContext ctx) {
    return Container(
        height: 350,
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding:
                const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
            itemCount: dataVehicle == null ? 0 : dataVehicle.length,
            itemBuilder: (context, index) {
              return _builListVehicle(ctx, dataVehicle[index], index);
            }));
  }

  Widget _builListVehicle(BuildContext ctx, dynamic item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              pinPillPosition = -170;
            });
            new_vhcid = item['car_plate'].toString();
            vendor_id = item['vendor'].toString();
            print('Klik Data search');
            removeMarkerOld();
            GetLastPosition();
            print(item['car_plate'].toString());
            controllerUI.close();
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item["car_plate"]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${item["group_name"]}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Tween for LatLng interpolation
class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    if (begin == null || end == null) {
      return begin ?? end ?? LatLng(0, 0);
    }
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}

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
