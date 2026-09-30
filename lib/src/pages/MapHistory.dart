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
import 'package:share_plus/share_plus.dart';
import 'ViewDashboard.dart';
import 'dart:ui' as ui;

/*
Title:GoogleMapScreen
Purpose:GoogleMapScreen
Created By:Kalpesh Khandla
*/

class MapHistory extends StatefulWidget {
  MapHistory({Key? key}) : super(key: key);

  @override
  MapHistoryState createState() => MapHistoryState();
}

class MapHistoryState extends State<MapHistory> {
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

  String orderNo = "4578178";
  String restaurantName = "FoodiePie Restaurants";
  String addressTxt = "B-2024, Silver Corner, Ahmedabad";
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
  String nopol_plate = "";
  String cpy_name = "";
  String info_windows = "";
  var isShowPanel = true;
  var gps_time = '';
  var engine_acc = '';
  var isShowButtonPlayBack = true;
  var isShowToolsPlayBack = false;
  var isShowContainsSlidePanel = true;

  bool isShowInfoWindow = false;
  String infoWindowTitle = "";
  String infoWindowSubtitle = "";
  String infoWindowAddress = "";
  String infoWindowTime = "";
  String infoWindowType = "";
  LatLng? infoWindowLatLng;

  String currentAddress = "";
  double? currentLat;
  double? currentLon;
  String currentGpsTime = "";

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
    // if(data_list_history.length>0){
    //   print(data_list_history['Data']);
    //   for(var i=0;i<data_list_history['Data'].length;i++){
    //     index_his = i;
    //     var item = data_list_history['Data'][i];
    //     updatePinOnMap(double.parse(item['lat']),double.parse(item['lon']),item['direction'],item['gps_sn'],item['addr'],item['nopol'],item['gps_time'],item['acc'],item['speed'],item['gps_sn']);
    //   }
    //   index_his = 0;
    // }
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
            setState(() {
              infoWindowType = 'vehicle';
              infoWindowTitle = "Posisi Truk";
              infoWindowSubtitle = _nopol.isNotEmpty ? _nopol : (vehicled_id.isNotEmpty ? vehicled_id : "-");
              infoWindowAddress = _addr.isNotEmpty ? _addr : "-";
              infoWindowTime = _gps_time.isNotEmpty ? _gps_time : "";
              infoWindowLatLng = pinPosition;
              isShowInfoWindow = true;
            });
            try {
              controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(pinPosition.latitude - 0.003, pinPosition.longitude),
                  zoom: 15.0,
                ),
              ));
            } catch (e) {
              print(e);
            }
          },
          rotation: rotation, //(rotation * (math.pi / 180) * -1),
          position: pinPosition,
          infoWindow: InfoWindow.noText,
          icon: sourceIcon
      ));

      // setState(() {
      //   sourcePinInfo = PinInformation(
      //       locationName: "$addr",
      //       location: LatLng(_lat, _lon), //SOURCE_LOCATION,
      //       pinPath: "assets/img/driving_pin.png",
      //       avatarPath: "",
      //       nopol: _nopol,
      //       gps_time: _gps_time,
      //       acc: int.parse(_acc),
      //       speed: int.parse(_speed),
      //       lat: _lat,
      //       lon:_lon,
      //       labelColor: Colors.blueAccent);
      // });
    });
  }

  Future<String> GetHistoryPlayBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String no_do = prefs.getString("do_maps")!;
    String drvid = prefs.getString("drvid")!;
    //String vhcid = prefs.getString("vhcid")!;
    String vhcid = prefs.getString("vhcid") ??
        (prefs.getString("do_vehicle_id")?.split("/")[0] ?? "");
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String no_do = prefs.getString("do_maps") ?? "";
      String drvid = prefs.getString("drvid") ?? "";
      String vhcid = prefs.getString("vhcid") ?? "";
      var do_tgl_do = prefs.getString("do_tgl_do") ?? "";
      vehicled_id = prefs.getString("do_vehicle_id") ?? "";
      origin = prefs.getString("do_origin") ?? "";
      destination = prefs.getString("do_destination") ?? "";
      driver_nm = prefs.getString("do_driver_nm") ?? "";
      nopol_plate = prefs.getString("do_nopol_plate") ?? "";
      cpy_name = prefs.getString("do_cpy_name") ?? "";
      orderNo = no_do;
      var loginType = prefs.getString("login_type") ?? "";
      var urlData =
          loginType == "MIXER"
              ? "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=get-do-bynumberdo-v1&do_number=${no_do}"
              : "${GlobalData.baseUrlProd}api/do/list_do_driver.jsp?method=get-do-bynumberdo-v1&do_number=${no_do}";
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

  String _fmtTimelineDate(String dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return '-';
    }
    try {
      DateTime dt = DateTime.parse(dateStr.replaceAll('/', '-'));
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();
      String hour = dt.hour.toString().padLeft(2, '0');
      String min = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year ($hour:$min)';
    } catch (e) {
      return dateStr;
    }
  }

  String _calcDuration(String startStr, String endStr) {
    if (startStr == null || startStr.isEmpty || startStr == 'null') {
      if (endStr != null && endStr.isNotEmpty && endStr != 'null') {
        return '0 detik';
      }
      return '-';
    }
    if (endStr == null || endStr.isEmpty || endStr == 'null') return '-';
    try {
      DateTime s = DateTime.parse(startStr.replaceAll('/', '-'));
      DateTime e = DateTime.parse(endStr.replaceAll('/', '-'));
      Duration d = e.difference(s);
      if (d.inSeconds <= 0) return '0 detik';
      if (d.inHours > 0) {
        int mins = d.inMinutes.remainder(60);
        return '${d.inHours} jam ${mins > 0 ? '$mins menit' : ''}';
      }
      if (d.inMinutes > 0) {
        return '${d.inMinutes} menit';
      }
      return '${d.inSeconds} detik';
    } catch (e) {
      return '-';
    }
  }

  Future<void> _shareTrackingInfo(
    String plateNumber,
    String vehicleType,
    String goodsName,
    String originName,
    String destinationName,
    String statusName, {
    String? driverName,
  }) async {
    if (currentLat == null || currentAddress.isEmpty || currentAddress == "-") {
      try {
        EasyLoading.show(status: 'Mengambil posisi GPS...');
        await GetLastPosition(plateNumber);
      } finally {
        if (EasyLoading.isShow) EasyLoading.dismiss();
      }
    }

    String pos = currentAddress.isNotEmpty && currentAddress != "-"
        ? currentAddress
        : (infoWindowAddress.isNotEmpty && infoWindowAddress != "-"
            ? infoWindowAddress
            : (info_windows.isNotEmpty && info_windows != "-" ? info_windows : ""));

    double? lat = currentLat;
    double? lon = currentLon;
    if (lat == null || lon == null) {
      if (polylineCoordinates.isNotEmpty) {
        lat = polylineCoordinates.last.latitude;
        lon = polylineCoordinates.last.longitude;
      }
    }

    // Jika alamat GPS belum didapat, gunakan lokasi berdasarkan status tahapan DO
    if (pos.isEmpty || pos == "-") {
      String stLower = statusName.toLowerCase();
      if (stLower.contains("bongkar") || stLower.contains("tujuan") || stLower.contains("customer")) {
        pos = destinationName.isNotEmpty && destinationName != '-' ? destinationName : originName;
      } else if (stLower.contains("muat") || stLower.contains("loading") || stLower.contains("pool")) {
        pos = originName.isNotEmpty && originName != '-' ? originName : destinationName;
      } else {
        pos = destinationName.isNotEmpty && destinationName != '-' ? destinationName : (originName.isNotEmpty && originName != '-' ? originName : "");
      }
    }

    // Fallback koordinat jika GPS belum terhubung: geocode nama kota/lokasi
    if (lat == null || lon == null) {
      try {
        String targetLoc = destinationName.isNotEmpty && destinationName != '-' ? destinationName : originName;
        String cleanLoc = targetLoc.contains("-") ? targetLoc.split("-").last.trim() : targetLoc.trim();
        if (cleanLoc.isNotEmpty) {
          var geoUri = Uri.parse("https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cleanLoc + ', Indonesia')}&format=json&limit=1");
          var geoResp = await http.get(geoUri, headers: {'User-Agent': 'DMS_ANP_Mobile/1.0'}).timeout(const Duration(seconds: 3));
          if (geoResp.statusCode == 200) {
            var geoList = jsonDecode(geoResp.body);
            if (geoList is List && geoList.isNotEmpty) {
              lat = double.tryParse(geoList[0]['lat']?.toString() ?? '');
              lon = double.tryParse(geoList[0]['lon']?.toString() ?? '');
            }
          }
        }
      } catch (_) {}
    }

    if (pos.isEmpty) {
      if (lat != null && lon != null) {
        pos = "Koordinat ($lat, $lon)";
      } else {
        pos = destinationName.isNotEmpty && destinationName != '-' ? destinationName : "-";
      }
    }

    String dName = (driverName != null && driverName.isNotEmpty && driverName != "-")
        ? driverName
        : (driver_nm.isNotEmpty ? driver_nm : "-");
    String doNo = orderNo.isNotEmpty ? orderNo : "-";
    String nopol = plateNumber.isNotEmpty ? plateNumber : (vehicled_id.isNotEmpty ? vehicled_id : "-");
    String type = vehicleType.isNotEmpty ? vehicleType : "Truck";

    String shareText = "Informasi Pengiriman DMS ANP:\n"
        "No. DO: $doNo\n"
        + (goodsName.isNotEmpty && goodsName != '-' ? "Barang: $goodsName\n" : "") +
        "Nopol: $nopol ($type)\n"
        "Driver: $dName\n"
        "Muat: $originName\n"
        "Bongkar: $destinationName\n"
        "Status: $statusName\n"
        "Posisi: $pos";

    if (lat != null && lon != null) {
      shareText += "\nMaps: https://maps.google.com/?q=$lat,$lon";
    }

    Share.share(shareText);
  }

  Future<void> GetLastPosition([String? forcedPlate]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String vhcid = prefs.getString("vhcid") ?? "";
      String nopolPlate = prefs.getString("do_nopol_plate") ?? "";
      String rawVeh = prefs.getString("do_vehicle_id") ?? vehicled_id;
      String doNopol = prefs.getString("do_nopol") ?? "";

      Set<String> candidates = {};
      void addVariants(String s) {
        if (s.isEmpty || s == "-" || s == "null") return;
        candidates.add(s.trim());
        candidates.add(s.replaceAll(" ", "").trim());
      }

      if (forcedPlate != null && forcedPlate.isNotEmpty) {
        String p = forcedPlate;
        if (p.contains("(")) p = p.split("(")[0].trim();
        addVariants(p);
      }
      addVariants(nopolPlate);
      addVariants(vhcid);
      addVariants(doNopol);
      if (rawVeh.contains("/")) {
        addVariants(rawVeh.split("/")[0].trim());
        addVariants(rawVeh.split("/")[1].trim());
      } else {
        addVariants(rawVeh);
      }

      String cleanPlate = nopolPlate.isNotEmpty
          ? nopolPlate
          : (forcedPlate != null && !forcedPlate.contains("/") ? forcedPlate : "");
      String cleanVhc = rawVeh.contains("/") ? rawVeh.split("/")[0].trim() : (vhcid.isNotEmpty ? vhcid : "");
      if (cleanPlate.isNotEmpty && cleanVhc.isNotEmpty) {
        addVariants("$cleanPlate/$cleanVhc");
        addVariants("$cleanPlate / $cleanVhc");
        addVariants("$cleanVhc/$cleanPlate");
      }

      if (candidates.isEmpty) return;

      var myUri = Uri.parse("https://vtsapi.easygo-gps.co.id/api/Report/lastposition");
      var headers = <String, String>{
        "accept": "application/json",
        "Content-Type": "application/json",
        "token": "9C1CDA30C0D5405682C40C0B00FED742",
      };
      var body = jsonEncode({
        "list_vehicle_id": [],
        "list_nopol": candidates.toList(),
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
      });

      final response = await http.post(myUri, headers: headers, body: body).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['Data'] is List && (decoded['Data'] as List).isNotEmpty) {
          final item = decoded['Data'][0];
          setState(() {
            currentLat = double.tryParse(item['lat']?.toString() ?? '');
            currentLon = double.tryParse(item['lon']?.toString() ?? '');
            currentAddress = (item['addr'] ?? item['address'] ?? '').toString();
            currentGpsTime = (item['gps_time'] ?? '').toString();
            info_windows = currentAddress;
            infoWindowAddress = currentAddress;
            gps_time = currentGpsTime;
          });
        }
      }
    } catch (e) {
      print("GetLastPosition error: $e");
    }
  }

  Widget _buildDottedDivider({double height = 1.0, Color color = const Color(0xFFCBD5E1)}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _DashedLineHorizontalPainter(color: color),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String travelDuration, String loadingDuration, String waitingUnloadDuration) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Waktu\nPerjalanan",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                SizedBox(height: 6),
                Text(
                  travelDuration,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
          ),
          Container(height: 36, width: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Durasi Muat\nBarang",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                SizedBox(height: 6),
                Text(
                  loadingDuration,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
          ),
          Container(height: 36, width: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Waktu Tunggu\nBongkar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                SizedBox(height: 6),
                Text(
                  waitingUnloadDuration,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    String title = '',
    String timestamp = '',
    bool isActive = false,
    bool isDone = true,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF6EE7B7), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else if (isDone)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 13,
                  color: Color(0xFF0284C7),
                ),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                ),
              ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                margin: EdgeInsets.symmetric(vertical: 2),
                child: CustomPaint(
                  painter: _DashedLineVerticalPainter(color: Color(0xFFCBD5E1)),
                ),
              ),
          ],
        ),
        SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? Color(0xFF0F172A) : Color(0xFF334155),
                    fontFamily: "Poppins Regular",
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: "Poppins Regular",
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProgressModal(
    BuildContext context,
    String vehicleInfo,
    String plateNumber,
    String driverName,
    String travelDuration,
    String loadingDuration,
    String waitingUnloadDuration,
    String timeTerjadwal,
    String timeMenujuMuat,
    String timeTibaMuat,
    String timeSelesaiMuat,
    String timeMenujuBongkar,
    String goodsName,
    String originName,
    String destinationName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  plateNumber,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vehicleInfo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    fontFamily: "Poppins Regular",
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                              ),
                              SizedBox(width: 8),
                              Text(
                                driverName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  fontFamily: "Poppins Regular",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                _buildDottedDivider(),
                Row(
                  children: [
                    Icon(Icons.speed, size: 18, color: Color(0xFF64748B)),
                    SizedBox(width: 8),
                    Text(
                      "Progress Pengiriman",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                        fontFamily: "Poppins Regular",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildStatsCard(travelDuration, loadingDuration, waitingUnloadDuration),
                SizedBox(height: 20),
                _buildTimelineItem(
                  title: "Menuju Tempat Bongkar",
                  timestamp: timeMenujuBongkar,
                  isActive: true,
                  isDone: true,
                ),
                _buildTimelineItem(
                  title: "Selesai Muat",
                  timestamp: timeSelesaiMuat,
                  isActive: false,
                  isDone: true,
                ),
                _buildTimelineItem(
                  title: "Tiba di Muat",
                  timestamp: timeTibaMuat,
                  isActive: false,
                  isDone: true,
                ),
                _buildTimelineItem(
                  title: "Menuju Tempat Muat",
                  timestamp: timeMenujuMuat,
                  isActive: false,
                  isDone: true,
                ),
                _buildTimelineItem(
                  title: "Terjadwal",
                  timestamp: timeTerjadwal,
                  isActive: false,
                  isDone: true,
                  isLast: true,
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.share, size: 16, color: Colors.white),
                    label: Text(
                      "Bagikan Posisi Pengiriman",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: "Poppins Regular",
                      ),
                    ),
                    onPressed: () {
                      String currentStatusModal = "Terjadwal";
                      if (timeMenujuBongkar.isNotEmpty && timeMenujuBongkar != "-") {
                        currentStatusModal = "Menuju Tempat Bongkar";
                      } else if (timeSelesaiMuat.isNotEmpty && timeSelesaiMuat != "-") {
                        currentStatusModal = "Selesai Muat";
                      } else if (timeTibaMuat.isNotEmpty && timeTibaMuat != "-") {
                        currentStatusModal = "Tiba di Muat";
                      } else if (timeMenujuMuat.isNotEmpty && timeMenujuMuat != "-") {
                        currentStatusModal = "Menuju Tempat Muat";
                      }
                      _shareTrackingInfo(
                        plateNumber,
                        vehicleInfo,
                        goodsName,
                        originName,
                        destinationName,
                        currentStatusModal,
                        driverName: driverName,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF22C55E),
                      elevation: 0,
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
      },
    );
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
    Set<String> histCandidates = {};
    String nopolPlate = prefs.getString("do_nopol_plate") ?? "";
    String vhcid = prefs.getString("vhcid") ?? "";
    String doNopol = prefs.getString("do_nopol") ?? "";
    void addHistVariants(String s) {
      if (s.isEmpty || s == "-" || s == "null") return;
      histCandidates.add(s.trim());
      histCandidates.add(s.replaceAll(" ", "").trim());
    }
    addHistVariants(nopolPlate);
    addHistVariants(vhcid);
    addHistVariants(doNopol);
    if (vehicled_id.contains("/")) {
      addHistVariants(vehicled_id.split("/")[0].trim());
      addHistVariants(vehicled_id.split("/")[1].trim());
    } else {
      addHistVariants(vehicled_id);
    }
    String cleanPlate = nopolPlate.isNotEmpty ? nopolPlate : "";
    String cleanVhc = vehicled_id.contains("/") ? vehicled_id.split("/")[0].trim() : (vhcid.isNotEmpty ? vhcid : "");
    if (cleanPlate.isNotEmpty && cleanVhc.isNotEmpty) {
      addHistVariants("$cleanPlate/$cleanVhc");
      addHistVariants("$cleanPlate / $cleanVhc");
      addHistVariants("$cleanVhc/$cleanPlate");
    }
    if (histCandidates.isEmpty) histCandidates.add(vehicled_id);

    var request = http.Request('POST',
        Uri.parse('https://vtsapi.easygo-gps.co.id/api/report/historydata'));
    request.body = json.encode({
      "start_time": do_tgl_do,
      "stop_time": date_now,
      "lst_vehicle_id": [],
      "lstNoPOL": histCandidates.toList(),
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
            final lastPoint = result_history.last;
            setState(() {
              if (currentAddress.isEmpty) {
                currentAddress = (lastPoint['address'] ?? lastPoint['addr'] ?? '').toString();
                info_windows = currentAddress;
              }
              if (currentLat == null) {
                currentLat = double.tryParse(lastPoint['lat']?.toString() ?? '');
              }
              if (currentLon == null) {
                currentLon = double.tryParse(lastPoint['lon']?.toString() ?? '');
              }
              if (currentGpsTime.isEmpty) {
                currentGpsTime = (lastPoint['gps_time'] ?? '').toString();
                gps_time = currentGpsTime;
              }
            });
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
        String type = marker.markerId.value;
        String title = "";
        String subtitle = "";
        String address = "";
        String time = "";

        if (type == 'origin') {
          title = "Titik Muat (Start)";
          subtitle = origin.isNotEmpty ? origin : "-";
          address = (result_history != null && result_history.isNotEmpty && result_history[0]['address'] != null)
              ? result_history[0]['address'].toString()
              : origin;
          time = (result_history != null && result_history.isNotEmpty && result_history[0]['gps_time'] != null)
              ? result_history[0]['gps_time'].toString()
              : "";
        } else if (type == 'destination') {
          title = "Titik Bongkar (Finish)";
          subtitle = destination.isNotEmpty ? destination : "-";
          address = (result_history != null && result_history.isNotEmpty && result_history[result_history.length - 1]['address'] != null)
              ? result_history[result_history.length - 1]['address'].toString()
              : destination;
          time = (result_history != null && result_history.isNotEmpty && result_history[result_history.length - 1]['gps_time'] != null)
              ? result_history[result_history.length - 1]['gps_time'].toString()
              : "";
        } else {
          title = "Posisi Truk";
          subtitle = vehicled_id.isNotEmpty ? vehicled_id : "-";
          address = info_windows.isNotEmpty ? info_windows : "-";
          time = gps_time.isNotEmpty ? gps_time : "";
        }

        LatLng markerPos = LatLng(marker.position.latitude, marker.position.longitude);
        setState(() {
          infoWindowType = type;
          infoWindowTitle = title;
          infoWindowSubtitle = subtitle;
          infoWindowAddress = address;
          infoWindowTime = time;
          infoWindowLatLng = markerPos;
          isShowInfoWindow = true;
        });

        try {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(markerPos.latitude - 0.003, markerPos.longitude),
              zoom: 15.0,
            ),
          ));
        } catch (e) {
          print(e);
        }
      },
      position: LatLng(marker.position.latitude, marker.position.longitude),
      icon: marker.icon,
      infoWindow: InfoWindow.noText,
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
      orderNo = no_do != null ? no_do : "";

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


      // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      //     googleAPiKey,
      //     PointLatLng(polylineCoordinates[0].latitude,
      //         polylineCoordinates[0].longitude),
      //     PointLatLng(
      //         polylineCoordinates[polylineCoordinates.length - 1].latitude,
      //         polylineCoordinates[polylineCoordinates.length - 1].longitude),
      //     travelMode: TravelMode.driving,
      //     wayPoints: [
      //       PolylineWayPoint(
      //         location: "Jakarta",
      //       ),
      //     ]);
      print('result.points ${result.points}');
      print(result);
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      //else{
      //   mapController.moveCamera(CameraUpdate.newLatLngBounds(
      //       LatLngBounds(
      //           southwest: LatLng(polylineCoordinates[0].latitude, polylineCoordinates[0].longitude),
      //           northeast: LatLng(polylineCoordinates[0].latitude, polylineCoordinates[0].longitude)),
      //       100));
      //   // print(polylineCoordinates[0].latitude);
      //   // print(polylineCoordinates[0].longitude);
      // }
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
    super.initState();
    GetHistory();
    GetListDo();
    GetLastPosition();
    isShowPanel = true;
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

    Map<String, dynamic> firstDo = (data_list_do != null && data_list_do.isNotEmpty)
        ? data_list_do[0]
        : <String, dynamic>{};

    String plateNumber = (firstDo['vehicled_id'] != null && firstDo['vehicled_id'].toString().isNotEmpty)
        ? firstDo['vehicled_id'].toString()
        : (nopol_plate.isNotEmpty ? nopol_plate : (vehicled_id != null && vehicled_id.isNotEmpty ? vehicled_id : '-'));
    String companyName = (firstDo['cpy_name'] != null && firstDo['cpy_name'].toString().isNotEmpty)
        ? firstDo['cpy_name'].toString()
        : (cpy_name.isNotEmpty ? cpy_name : 'Andalan Nusa Pratama');
    String vehicleType = (firstDo['type'] != null && firstDo['type'].toString().isNotEmpty)
        ? firstDo['type'].toString()
        : 'TR BL-1';
    String vehicleInfo = '$companyName  $vehicleType';
    String driverName = (firstDo['driver_nm'] != null && firstDo['driver_nm'].toString().isNotEmpty)
        ? firstDo['driver_nm'].toString()
        : (driver_nm != null && driver_nm.isNotEmpty ? driver_nm : '-');

    String goodsName = (firstDo['item_nm'] != null && firstDo['item_nm'].toString().isNotEmpty)
        ? firstDo['item_nm'].toString()
        : (firstDo['dloitem'] != null && firstDo['dloitem'].toString().isNotEmpty
            ? firstDo['dloitem'].toString()
            : '-');
    String qtyVal = (firstDo['bujitemqty'] != null && firstDo['bujitemqty'].toString().isNotEmpty)
        ? firstDo['bujitemqty'].toString()
        : (firstDo['dloitemqty'] != null && firstDo['dloitemqty'].toString().isNotEmpty
            ? firstDo['dloitemqty'].toString()
            : '');
    String uomVal = (firstDo['dloitemuom'] != null && firstDo['dloitemuom'].toString().isNotEmpty)
        ? firstDo['dloitemuom'].toString()
        : (firstDo['uom'] != null && firstDo['uom'].toString().isNotEmpty
            ? firstDo['uom'].toString()
            : '');
    String goodsQty = (qtyVal.isNotEmpty && uomVal.isNotEmpty)
        ? '$qtyVal $uomVal'
        : (qtyVal.isNotEmpty ? qtyVal : (uomVal.isNotEmpty ? uomVal : '-'));

    String originName = (firstDo['origin'] != null && firstDo['origin'].toString().isNotEmpty)
        ? firstDo['origin'].toString()
        : (origin.isNotEmpty ? origin : '-');
    String originCity = (firstDo['origincity'] != null && firstDo['origincity'].toString().isNotEmpty)
        ? firstDo['origincity'].toString()
        : '';
    String destinationName = (firstDo['destination'] != null && firstDo['destination'].toString().isNotEmpty)
        ? firstDo['destination'].toString()
        : (destination.isNotEmpty ? destination : (firstDo['dlocustomer'] != null && firstDo['dlocustomer'].toString().isNotEmpty ? firstDo['dlocustomer'].toString() : '-'));
    String destinationCity = (firstDo['destinationcity'] != null && firstDo['destinationcity'].toString().isNotEmpty)
        ? firstDo['destinationcity'].toString()
        : '';

    String startDest = firstDo['startdestination'] != null ? firstDo['startdestination'].toString() : '';
    String finishDest = firstDo['finishdestination'] != null ? firstDo['finishdestination'].toString() : '';
    String startLoad = firstDo['startloading'] != null ? firstDo['startloading'].toString() : '';
    String finishLoad = firstDo['finishloading'] != null ? firstDo['finishloading'].toString() : '';

    String bujOutDate = firstDo['bujoutdate'] != null ? firstDo['bujoutdate'].toString() : '';
    String bujOutTime = firstDo['bujouttime'] != null ? firstDo['bujouttime'].toString() : '';
    String bujOutCombined = (bujOutDate.isNotEmpty && bujOutTime.isNotEmpty)
        ? '$bujOutDate $bujOutTime'
        : (bujOutDate.isNotEmpty ? bujOutDate : '');

    String doDate = firstDo['dodate'] != null ? firstDo['dodate'].toString() : '';
    String doTime = firstDo['dotime'] != null ? firstDo['dotime'].toString() : '';
    String doCombined = (doDate.isNotEmpty && doTime.isNotEmpty)
        ? '$doDate $doTime'
        : (doDate.isNotEmpty ? doDate : '');

    String timeMenujuBongkar = _fmtTimelineDate(startDest);
    String timeSelesaiMuat = _fmtTimelineDate(finishLoad);
    String timeTibaDiMuat = _fmtTimelineDate(startLoad);
    String timeMenujuMuat = _fmtTimelineDate(bujOutCombined);
    String timeTerjadwal = _fmtTimelineDate(doCombined);

    String waktuPerjalanan = _calcDuration(startDest, finishDest);
    String durasiMuat = _calcDuration(startLoad, finishLoad);
    String waktuTungguBongkar = '-';

    String currentStatus = "Terjadwal";
    if (finishDest.isNotEmpty && finishDest != "-") {
      currentStatus = "Selesai Bongkar";
    } else if (startDest.isNotEmpty && startDest != "-") {
      currentStatus = "Menuju Tempat Bongkar";
    } else if (finishLoad.isNotEmpty && finishLoad != "-") {
      currentStatus = "Selesai Muat";
    } else if (startLoad.isNotEmpty && startLoad != "-") {
      currentStatus = "Tiba di Muat";
    } else if (bujOutCombined.isNotEmpty && bujOutCombined != "-") {
      currentStatus = "Menuju Tempat Muat";
    }

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
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(-6.181866111111, 106.829632777778),
                      zoom: 12,
                    ),
                    myLocationEnabled: true,
                    tiltGesturesEnabled: true,
                    compassEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    onTap: (LatLng latLng) {
                      if (isShowInfoWindow) {
                        setState(() {
                          isShowInfoWindow = false;
                        });
                      }
                    },
                    onMapCreated: _onMapCreated,
                    markers: Set<Marker>.of(markers.values),
                    polylines: Set<Polyline>.of(polylines.values),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {
                      _goBack(context);
                    },
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
                // Modern Floating InfoWindow Card
                _buildCustomInfoWindow(),
                // Floating pill button to re-open panel when hidden
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  left: 0,
                  right: 0,
                  bottom: isShowPanel ? -100 : 20,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isShowPanel = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: ColorConstants.kWhiteColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 18,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Info Pengiriman",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins Regular",
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_up,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Sliding bottom panel
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  left: 0,
                  right: 0,
                  bottom: isShowPanel ? 0 : -MediaQuery.of(context).size.height,
                  child: IgnorePointer(
                    ignoring: !isShowPanel,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.kWhiteColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header bar with drag handle and close button (matching Gambar 3)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (details) {
                              if (details.primaryDelta != null && details.primaryDelta! > 5) {
                                setState(() {
                                  isShowPanel = false;
                                });
                              }
                            },
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity != null && details.primaryVelocity! > 80) {
                                setState(() {
                                  isShowPanel = false;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCBD5E1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isShowPanel = false;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is OverscrollNotification && notification.overscroll < -8) {
                                  setState(() {
                                    isShowPanel = false;
                                  });
                                  return true;
                                }
                                if (notification is ScrollUpdateNotification &&
                                    notification.metrics.pixels <= 0 &&
                                    (notification.scrollDelta ?? 0) < -12) {
                                  setState(() {
                                    isShowPanel = false;
                                  });
                                  return true;
                                }
                                return false;
                              },
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(isShowContainsSlidePanel)...[
                            // Section 1: Barang
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Barang",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        goodsName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  goodsQty,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins Regular",
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            _buildDottedDivider(),
                            // Section 2: Alamat
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                                SizedBox(width: 4),
                                Text(
                                  "Alamat",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Poppins Regular",
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2, right: 10),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2563EB),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.arrow_upward, size: 11, color: Colors.white),
                                      ),
                                      Container(
                                        width: 1.5,
                                        height: 12,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                      Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF94A3B8)),
                                      Container(
                                        width: 1.5,
                                        height: 12,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Icon(Icons.arrow_downward, size: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Muat",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                      Text(
                                        originName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (originCity.isNotEmpty)
                                        Text(
                                          originCity,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: "Poppins Regular",
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Bongkar",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                      Text(
                                        destinationName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins Regular",
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (destinationCity.isNotEmpty)
                                        Text(
                                          destinationCity,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: "Poppins Regular",
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _buildDottedDivider(),
                            // Section 3: Supir & Truk
                            InkWell(
                              onTap: () {
                                _showProgressModal(
                                  context,
                                  vehicleInfo,
                                  plateNumber,
                                  driverName,
                                  waktuPerjalanan,
                                  durasiMuat,
                                  waktuTungguBongkar,
                                  timeTerjadwal,
                                  timeMenujuMuat,
                                  timeTibaDiMuat,
                                  timeSelesaiMuat,
                                  timeMenujuBongkar,
                                  goodsName,
                                  originName,
                                  destinationName,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF64748B)),
                                          SizedBox(width: 4),
                                          Text(
                                            "Supir & Truk",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: "Poppins Regular",
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          plateNumber,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              companyName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Poppins Regular",
                                                color: Color(0xFF1E293B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              vehicleType,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: "Poppins Regular",
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE2E8F0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.person, size: 18, color: Color(0xFF64748B)),
                                      ),
                                      SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          driverName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Poppins Regular",
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildDottedDivider(),
                            // Section 4: Progress Pengiriman
                            Row(
                              children: [
                                Icon(Icons.speed, size: 18, color: Color(0xFF64748B)),
                                SizedBox(width: 6),
                                Text(
                                  "Progress Pengiriman",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins Regular",
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildStatsCard(waktuPerjalanan, durasiMuat, waktuTungguBongkar),
                            SizedBox(height: 14),
                            _buildTimelineItem(
                              title: "Menuju Tempat Bongkar",
                              timestamp: timeMenujuBongkar,
                              isActive: true,
                              isDone: true,
                              isLast: false,
                            ),
                            _buildTimelineItem(
                              title: "Selesai Muat",
                              timestamp: timeSelesaiMuat,
                              isActive: false,
                              isDone: true,
                              isLast: false,
                            ),
                            _buildTimelineItem(
                              title: "Tiba di Muat",
                              timestamp: timeTibaDiMuat,
                              isActive: false,
                              isDone: true,
                              isLast: false,
                            ),
                            _buildTimelineItem(
                              title: "Menuju Tempat Muat",
                              timestamp: timeMenujuMuat,
                              isActive: false,
                              isDone: true,
                              isLast: false,
                            ),
                            _buildTimelineItem(
                              title: "Terjadwal",
                              timestamp: timeTerjadwal,
                              isActive: false,
                              isDone: true,
                              isLast: true,
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _shareTrackingInfo(
                                    plateNumber,
                                    vehicleInfo,
                                    goodsName,
                                    originName,
                                    destinationName,
                                    currentStatus,
                                    driverName: driverName,
                                  );
                                },
                                icon: Icon(Icons.share, size: 16, color: Colors.white),
                                label: Text(
                                  "Bagikan Posisi Pengiriman",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: "Poppins Regular",
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF22C55E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                            if (isShowButtonPlayBack) ...[
                              SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () {
                                    EasyLoading.show();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => MapPlayBack()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade400,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Run Playback',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins Regular",
                                    ),
                                  ),
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
                                    color: Colors.grey.shade200,
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
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
          ),
        ));
  }

  Widget _buildCustomInfoWindow() {
    Color badgeBgColor;
    Color badgeTextColor;
    Color badgeBorderColor;
    IconData badgeIcon;

    if (infoWindowType == 'origin') {
      badgeBgColor = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF1D4ED8);
      badgeBorderColor = const Color(0xFFBFDBFE);
      badgeIcon = Icons.arrow_upward_rounded;
    } else if (infoWindowType == 'destination') {
      badgeBgColor = const Color(0xFFFEF2F2);
      badgeTextColor = const Color(0xFFDC2626);
      badgeBorderColor = const Color(0xFFFECACA);
      badgeIcon = Icons.arrow_downward_rounded;
    } else {
      badgeBgColor = const Color(0xFFECFDF5);
      badgeTextColor = const Color(0xFF059669);
      badgeBorderColor = const Color(0xFFA7F3D0);
      badgeIcon = Icons.local_shipping_rounded;
    }

    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        offset: isShowInfoWindow ? Offset.zero : const Offset(0, -0.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isShowInfoWindow ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !isShowInfoWindow,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1F0F172A),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0x0A0F172A),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top colored accent indicator
                    Center(
                      child: Container(
                        width: 36,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: badgeTextColor.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Header Row: Badge & Circular Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: badgeBorderColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 14, color: badgeTextColor),
                              const SizedBox(width: 6),
                              Text(
                                infoWindowTitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: badgeTextColor,
                                  letterSpacing: 0.3,
                                  fontFamily: "Poppins Regular",
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isShowInfoWindow = false;
                            });
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    // Main Title / Name
                    if (infoWindowSubtitle.isNotEmpty && infoWindowSubtitle != "-") ...[
                      const SizedBox(height: 10),
                      Text(
                        infoWindowSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: "Poppins Regular",
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Address Row with location pin box
                    if (infoWindowAddress.isNotEmpty && infoWindowAddress != infoWindowSubtitle) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                            ),
                            child: const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              infoWindowAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                                fontFamily: "Poppins Regular",
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // GPS Time Row
                    if (infoWindowTime.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            "Update GPS: $infoWindowTime",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontFamily: "Poppins Regular",
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Action Buttons Row
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      height: 1,
                      color: const Color(0xFFF1F5F9),
                    ),
                    Row(
                      children: [
                        if (infoWindowLatLng != null)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (infoWindowLatLng != null) {
                                  mapController.animateCamera(CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(infoWindowLatLng!.latitude - 0.003, infoWindowLatLng!.longitude),
                                      zoom: 16.0,
                                    ),
                                  ));
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.my_location_rounded, size: 14, color: Color(0xFF475569)),
                                    SizedBox(width: 6),
                                    Text(
                                      "Fokus Lokasi",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                        fontFamily: "Poppins Regular",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              String copyText = infoWindowAddress.isNotEmpty && infoWindowAddress != "-"
                                  ? infoWindowAddress
                                  : infoWindowSubtitle;
                              if (copyText.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: copyText));
                                EasyLoading.showToast("Alamat disalin!");
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: badgeBorderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.copy_rounded, size: 13, color: badgeTextColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Salin Alamat",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: badgeTextColor,
                                      fontFamily: "Poppins Regular",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedLineVerticalPainter extends CustomPainter {
  final Color color;
  _DashedLineVerticalPainter({this.color = const Color(0xFFCBD5E1)});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DashedLineHorizontalPainter extends CustomPainter {
  final Color color;
  _DashedLineHorizontalPainter({this.color = const Color(0xFFCBD5E1)});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

