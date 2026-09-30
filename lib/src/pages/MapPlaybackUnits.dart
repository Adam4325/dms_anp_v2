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
import 'package:share_plus/share_plus.dart';

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
  var isShowUnitInfo = true;
  var isLastDataInfo = false;
  var isShowPlay = true;
  var isShowPause = false;
  var isPrevPlayBack = true;
  var index_his = 0;

  bool isShowPanel = true;
  int _activeTabIndex = 0; // 0 = Unit Info, 1 = Info DO
  List<dynamic> data_list_do = [];
  bool isLoadingDo = false;
  
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
    GetListDo();
    isShowUnitInfo = true;
    isShowPanel = true;
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

  void GetListDo() async {
    try {
      setState(() {
        isLoadingDo = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String no_do = prefs.getString("do_maps") ?? prefs.getString("pb_no_do") ?? "";
      String drvid = prefs.getString("drvid") ?? "";
      String rawVhc = prefs.getString("pb_vhcid") ?? prefs.getString("vhcid") ?? u_nopol;
      String vhcid = rawVhc.contains("/") ? rawVhc.split("/")[0].trim() : rawVhc.trim();
      String nopolParam = u_nopol.isNotEmpty
          ? u_nopol
          : (rawVhc.contains("/") ? rawVhc.split("/")[1].trim() : rawVhc.trim());
      var loginType = (prefs.getString("login_type") ?? "").toUpperCase();
      bool isMixer = loginType.contains("MIXER") ||
          rawVhc.toUpperCase().contains("TM") ||
          u_nopol.toUpperCase().contains("TM");

      List<dynamic> fetchedDo = [];

      // 1. Query Utama by VHCID / Nopol + hari ini ke list_order_driver.jsp
      String method = isMixer ? "get-do-byvhcid-v1-mixer" : "get-do-byvhcid-v1-non-mixer";
      String primaryUrl =
          "${GlobalData.baseUrlProd}api/do/list_order_driver.jsp?method=$method&vhcid=${Uri.encodeComponent(vhcid)}&nopol=${Uri.encodeComponent(nopolParam)}&type_driver=${Uri.encodeComponent(isMixer ? 'MIXER' : 'NON-MIXER')}";

      try {
        var response = await http
            .get(Uri.parse(primaryUrl), headers: {"Accept": "application/json"})
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          var decoded = json.decode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            fetchedDo = decoded;
          }
        }
      } catch (e) {
        print("Primary list_order_driver error: $e");
      }

      // 2. Jika belum ketemu, coba alternatif mixer / non-mixer pada list_order_driver.jsp
      if (fetchedDo.isEmpty) {
        String altMethod = isMixer ? "get-do-byvhcid-v1-non-mixer" : "get-do-byvhcid-v1-mixer";
        String altUrl =
            "${GlobalData.baseUrlProd}api/do/list_order_driver.jsp?method=$altMethod&vhcid=${Uri.encodeComponent(vhcid)}&nopol=${Uri.encodeComponent(nopolParam)}&type_driver=${Uri.encodeComponent(isMixer ? 'MIXER' : 'NON-MIXER')}";
        try {
          var response = await http
              .get(Uri.parse(altUrl), headers: {"Accept": "application/json"})
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            var decoded = json.decode(response.body);
            if (decoded is List && decoded.isNotEmpty) {
              fetchedDo = decoded;
            }
          }
        } catch (_) {}
      }

      // 3. Fallback: by DO number jika ada
      if (fetchedDo.isEmpty && no_do.isNotEmpty) {
        var urlData = isMixer
            ? "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=get-do-bynumberdo-v1&do_number=${Uri.encodeComponent(no_do)}"
            : "${GlobalData.baseUrlProd}api/do/list_order_driver.jsp?method=get-do-bynumberdo-v1&do_number=${Uri.encodeComponent(no_do)}";
        try {
          var response = await http
              .get(Uri.parse(urlData), headers: {"Accept": "application/json"})
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            var decoded = json.decode(response.body);
            if (decoded is List && decoded.isNotEmpty) {
              fetchedDo = decoded;
            }
          }
        } catch (_) {}
      }

      // 4. Fallback: lookup by vehicle / driver jika masih kosong
      if (fetchedDo.isEmpty && (vhcid.isNotEmpty || drvid.isNotEmpty)) {
        var lookupUrl = isMixer
            ? "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=lookup-list-do-driver-v1&vhcid=${Uri.encodeComponent(vhcid)}&drvid=${Uri.encodeComponent(drvid)}"
            : "${GlobalData.baseUrlProd}api/do/list_do_driver.jsp?method=lookup-list-do-driver-v1&vhcid=${Uri.encodeComponent(vhcid)}&drvid=${Uri.encodeComponent(drvid)}";
        try {
          var response = await http
              .get(Uri.parse(lookupUrl), headers: {"Accept": "application/json"})
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            var decoded = json.decode(response.body);
            if (decoded is List && decoded.isNotEmpty) {
              fetchedDo = decoded;
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          data_list_do = fetchedDo;
          isLoadingDo = false;
        });
      }
    } catch (e) {
      print("GetListDo playback error: $e");
      if (mounted) {
        setState(() {
          isLoadingDo = false;
        });
      }
    }
  }

  String _fmtTimelineDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == 'null') {
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
    if (startStr.isEmpty || startStr == 'null') {
      if (endStr.isNotEmpty && endStr != 'null') {
        return '0 detik';
      }
      return '-';
    }
    if (endStr.isEmpty || endStr == 'null') return '-';
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

  void _shareTrackingInfo(
    String plateNumber,
    String vehicleType,
    String goodsName,
    String originName,
    String destinationName,
    String statusName, {
    String? driverName,
  }) {
    String pos = u_address.isNotEmpty && u_address != "-" ? u_address : "";

    double? currentLat;
    double? currentLon;
    if (data_list_history['Data'] != null &&
        index_his < (data_list_history['Data'] as List).length &&
        index_his >= 0) {
      var item = (data_list_history['Data'] as List)[index_his];
      currentLat = double.tryParse(item['lat']?.toString() ?? '');
      currentLon = double.tryParse(item['lon']?.toString() ?? '');
    } else if (lat != 0 && lon != 0) {
      currentLat = lat;
      currentLon = lon;
    }

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

    if (pos.isEmpty) {
      if (currentLat != null && currentLon != null) {
        pos = "Koordinat ($currentLat, $currentLon)";
      } else {
        pos = destinationName.isNotEmpty && destinationName != '-' ? destinationName : "-";
      }
    }

    String dName = (driverName != null && driverName.isNotEmpty && driverName != "-")
        ? driverName
        : (driver_nm.isNotEmpty ? driver_nm : "-");
    String doNo = no_do.isNotEmpty ? no_do : (do_number.isNotEmpty ? do_number : "-");
    String nopol = plateNumber.isNotEmpty ? plateNumber : (u_nopol.isNotEmpty ? u_nopol : "-");
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

    if (currentLat != null && currentLon != null) {
      shareText += "\nMaps: https://maps.google.com/?q=$currentLat,$currentLon";
    }

    Share.share(shareText);
  }

  Widget _buildDottedDivider({double height = 1.0, Color color = const Color(0xFFCBD5E1)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Waktu\nPerjalanan",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                const SizedBox(height: 4),
                Text(
                  travelDuration,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
          ),
          Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Durasi Muat\nBarang",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                const SizedBox(height: 4),
                Text(
                  loadingDuration,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
          ),
          Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Waktu Tunggu\nBongkar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
                const SizedBox(height: 4),
                Text(
                  waitingUnloadDuration,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
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
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6EE7B7), width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else if (isDone)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Color(0xFF0284C7),
                ),
              )
            else
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
              ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: CustomPaint(
                  painter: _DashedLineVerticalPainter(color: const Color(0xFFCBD5E1)),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFF334155),
                    fontFamily: "Poppins Regular",
                  ),
                ),
                if (timestamp.isNotEmpty && timestamp != "-") ...[
                  const SizedBox(height: 2),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontFamily: "Poppins Regular",
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitInfoTabContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Address chip - full width dengan copy / tap functionality
        InkWell(
          onTap: () {
            if (u_address.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: u_address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alamat berhasil disalin'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: _buildInfoChip(
            'Address',
            u_address.isNotEmpty ? u_address : 'No Address',
            Icons.location_on,
            Colors.orange,
            isFullWidth: true,
          ),
        ),
        const SizedBox(height: 10),

        // Row untuk Nopol dan Acc
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                'Nopol',
                u_nopol.isNotEmpty ? u_nopol : '-',
                Icons.directions_car,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                'ACC',
                u_acc.isNotEmpty ? u_acc : 'OFF',
                Icons.power,
                u_acc == 'ON' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Row untuk Speed dan Odometer
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                'Speed',
                '${u_speed} km/h',
                Icons.speed,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                'Odometer',
                '${NumberFormat('0.00').format(double.tryParse(u_odometer) ?? 0.0)} Km',
                Icons.speed,
                Colors.indigo,
                isFullWidth: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // GPS Time chip - full width
        _buildInfoChip(
          'GPS Time',
          u_gps_time.isNotEmpty ? u_gps_time : '-',
          Icons.access_time,
          Colors.teal,
          isFullWidth: true,
        ),

        // Event chip - conditional
        if (u_report_nm != null && u_report_nm.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoChip(
            'Event',
            u_report_nm,
            Icons.warning,
            Colors.red,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildDoInfoTabContent() {
    if (isLoadingDo) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.orange),
              ),
              SizedBox(height: 12),
              Text(
                "Memuat data DO...",
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
              ),
            ],
          ),
        ),
      );
    }

    if (data_list_do.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 24, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Tidak ada data DO aktif",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                  fontFamily: "Poppins Regular",
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Kendaraan: ${u_nopol.isNotEmpty ? u_nopol : '-'}",
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontFamily: "Poppins Regular",
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () => GetListDo(),
                  icon: const Icon(Icons.refresh, size: 15, color: Colors.white),
                  label: const Text("Muat Ulang", style: TextStyle(fontSize: 12, color: Colors.white, fontFamily: "Poppins Regular")),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, dynamic> firstDo = data_list_do[0];
    String plateNumber = (firstDo['vehicled_id'] != null && firstDo['vehicled_id'].toString().isNotEmpty)
        ? firstDo['vehicled_id'].toString()
        : (firstDo['nopol'] != null && firstDo['nopol'].toString().isNotEmpty
            ? firstDo['nopol'].toString()
            : (u_nopol.isNotEmpty ? u_nopol : '-'));
    String vehicleType = (firstDo['type'] != null && firstDo['type'].toString().isNotEmpty)
        ? firstDo['type'].toString()
        : (plateNumber.contains('/') ? plateNumber.split('/')[1].trim() : 'Truck');
    String driverName = (firstDo['driver_nm'] != null && firstDo['driver_nm'].toString().isNotEmpty)
        ? firstDo['driver_nm'].toString()
        : (firstDo['drvname'] != null && firstDo['drvname'].toString().isNotEmpty
            ? firstDo['drvname'].toString()
            : (driver_nm.isNotEmpty ? driver_nm : '-'));

    String doNbr = (firstDo['dlocustdonbr'] != null && firstDo['dlocustdonbr'].toString().isNotEmpty)
        ? firstDo['dlocustdonbr'].toString()
        : (firstDo['do_number'] != null && firstDo['do_number'].toString().isNotEmpty
            ? firstDo['do_number'].toString()
            : (no_do.isNotEmpty ? no_do : (do_number.isNotEmpty ? do_number : '-')));

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
        : '-';
    String destinationName = (firstDo['destination'] != null && firstDo['destination'].toString().isNotEmpty)
        ? firstDo['destination'].toString()
        : (firstDo['dlocustomer'] != null && firstDo['dlocustomer'].toString().isNotEmpty
            ? firstDo['dlocustomer'].toString()
            : '-');

    final timeInLoading = firstDo["INLOADING"] ?? firstDo["inloading"];
    final timeOutLoading = firstDo["OUTLOADING"] ?? firstDo["outloading"];
    final timeOutPool = firstDo["OUTPOOL"] ?? firstDo["outpool"];
    final timeInCustomer = firstDo["INCUSTOMER"] ?? firstDo["incustomer"];
    final timeInUnloading = firstDo["INUNLOADING"] ?? firstDo["inunloading"];
    final timeOutUnloading = firstDo["OUTUNLOADING"] ?? firstDo["outunloading"];

    bool _isValidTs(dynamic val) {
      if (val == null) return false;
      String s = val.toString().trim();
      return s.isNotEmpty && s != "null" && s != "-";
    }

    bool isMixerData = _isValidTs(timeInLoading) || _isValidTs(timeOutLoading) || _isValidTs(timeOutPool);

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
        : (firstDo['tgl_do'] != null ? firstDo['tgl_do'].toString() : '');

    String timeMenujuBongkar = _fmtTimelineDate(startDest);
    String timeSelesaiMuat = _fmtTimelineDate(finishLoad);
    String timeTibaDiMuat = _fmtTimelineDate(startLoad);
    String timeMenujuMuat = _fmtTimelineDate(bujOutCombined);
    String timeTerjadwal = _fmtTimelineDate(doCombined);

    String waktuPerjalanan = _calcDuration(startDest, finishDest);
    String durasiMuat = _calcDuration(startLoad, finishLoad);
    String waktuTungguBongkar = '-';

    String currentStatus = "Terjadwal";
    if (isMixerData) {
      if (_isValidTs(timeOutUnloading)) {
        currentStatus = "Out Unloading (Selesai Bongkar)";
      } else if (_isValidTs(timeInUnloading)) {
        currentStatus = "In Unloading (Sedang Bongkar)";
      } else if (_isValidTs(timeInCustomer)) {
        currentStatus = "In Customer (Tiba di Customer)";
      } else if (_isValidTs(timeOutPool)) {
        currentStatus = "Out Pool (Menuju Customer)";
      } else if (_isValidTs(timeOutLoading)) {
        currentStatus = "Out Loading (Selesai Muat)";
      } else if (_isValidTs(timeInLoading)) {
        currentStatus = "In Loading (Mulai Muat)";
      }
    } else {
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
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header DO & Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                "DO: $doNbr",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                  fontFamily: "Poppins Regular",
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                currentStatus.length > 25 ? currentStatus.substring(0, 25) + '...' : currentStatus,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                  fontFamily: "Poppins Regular",
                ),
              ),
            ),
          ],
        ),
        _buildDottedDivider(),

        // Section 1: Barang
        if (goodsName.isNotEmpty && goodsName != '-') ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Barang",
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "Poppins Regular",
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      goodsName,
                      style: const TextStyle(
                        fontSize: 12,
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
              if (goodsQty.isNotEmpty && goodsQty != '-')
                Text(
                  goodsQty,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins Regular",
                    color: Color(0xFF1E293B),
                  ),
                ),
            ],
          ),
          _buildDottedDivider(),
        ],

        // Section 2: Alamat
        Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
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
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, size: 10, color: Colors.white),
                  ),
                  Container(width: 1.5, height: 10, color: const Color(0xFFCBD5E1)),
                  const Icon(Icons.arrow_drop_down, size: 12, color: Color(0xFF94A3B8)),
                  Container(width: 1.5, height: 10, color: const Color(0xFFCBD5E1)),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Icon(Icons.arrow_downward, size: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Muat", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: "Poppins Regular")),
                  Text(
                    originName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Text("Bongkar", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: "Poppins Regular")),
                  Text(
                    destinationName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontFamily: "Poppins Regular"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        _buildDottedDivider(),

        // Section 3: Supir & Truk
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    plateNumber.split('/')[0].trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  vehicleType,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: "Poppins Regular"),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    driverName,
                    style: const TextStyle(
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
          ],
        ),
        _buildDottedDivider(),

        // Section 4: Progress Pengiriman
        Row(
          children: const [
            Icon(Icons.speed, size: 16, color: Color(0xFF64748B)),
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
        const SizedBox(height: 8),
        _buildStatsCard(waktuPerjalanan, durasiMuat, waktuTungguBongkar),
        const SizedBox(height: 12),

        if (isMixerData) ...[
          _buildTimelineItem(
            title: "Out Unloading (Selesai Bongkar)",
            timestamp: _isValidTs(timeOutUnloading) ? timeOutUnloading.toString() : "-",
            isActive: currentStatus.contains("Out Unloading"),
            isDone: _isValidTs(timeOutUnloading),
            isLast: false,
          ),
          _buildTimelineItem(
            title: "In Unloading (Sedang Bongkar)",
            timestamp: _isValidTs(timeInUnloading) ? timeInUnloading.toString() : "-",
            isActive: currentStatus.contains("In Unloading"),
            isDone: _isValidTs(timeInUnloading),
            isLast: false,
          ),
          _buildTimelineItem(
            title: "In Customer (Tiba di Customer)",
            timestamp: _isValidTs(timeInCustomer) ? timeInCustomer.toString() : "-",
            isActive: currentStatus.contains("In Customer"),
            isDone: _isValidTs(timeInCustomer),
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Out Pool (Menuju Customer)",
            timestamp: _isValidTs(timeOutPool) ? timeOutPool.toString() : "-",
            isActive: currentStatus.contains("Out Pool"),
            isDone: _isValidTs(timeOutPool),
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Out Loading (Selesai Muat)",
            timestamp: _isValidTs(timeOutLoading) ? timeOutLoading.toString() : "-",
            isActive: currentStatus.contains("Out Loading"),
            isDone: _isValidTs(timeOutLoading),
            isLast: false,
          ),
          _buildTimelineItem(
            title: "In Loading (Mulai Muat)",
            timestamp: _isValidTs(timeInLoading) ? timeInLoading.toString() : "-",
            isActive: currentStatus.contains("In Loading"),
            isDone: _isValidTs(timeInLoading),
            isLast: true,
          ),
        ] else ...[
          _buildTimelineItem(
            title: "Menuju Tempat Bongkar",
            timestamp: timeMenujuBongkar,
            isActive: currentStatus == "Menuju Tempat Bongkar",
            isDone: finishDest.isNotEmpty || startDest.isNotEmpty,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Selesai Muat",
            timestamp: timeSelesaiMuat,
            isActive: currentStatus == "Selesai Muat",
            isDone: finishLoad.isNotEmpty,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Tiba di Muat",
            timestamp: timeTibaDiMuat,
            isActive: currentStatus == "Tiba di Muat",
            isDone: startLoad.isNotEmpty,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Menuju Tempat Muat",
            timestamp: timeMenujuMuat,
            isActive: currentStatus == "Menuju Tempat Muat",
            isDone: bujOutCombined.isNotEmpty,
            isLast: false,
          ),
          _buildTimelineItem(
            title: "Terjadwal",
            timestamp: timeTerjadwal,
            isActive: currentStatus == "Terjadwal",
            isDone: true,
            isLast: true,
          ),
        ],
        const SizedBox(height: 14),

        // Bagikan Posisi Pengiriman
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              _shareTrackingInfo(
                plateNumber,
                vehicleType,
                goodsName,
                originName,
                destinationName,
                currentStatus,
                driverName: driverName,
              );
            },
            icon: const Icon(Icons.share, size: 15, color: Colors.white),
            label: const Text(
              "Bagikan Posisi Pengiriman",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "Poppins Regular",
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
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
                          isShowPanel = true;
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
                            isShowPanel = true;
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
              // Floating toggle button when collapsed
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                bottom: isShowPanel ? -100 : (MediaQuery.of(context).padding.bottom + 16),
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
                          color: Colors.white,
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
                              _activeTabIndex == 0 ? Icons.directions_car : Icons.inventory_2_outlined,
                              size: 18,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _activeTabIndex == 0 ? "Unit Info" : "Info DO",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins Regular",
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
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

              // Sliding draggable bottom panel
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
                      maxHeight: MediaQuery.of(context).size.height * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle bar
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

                        // 2 Tabs Selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // Tab 1: Unit Info
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeTabIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _activeTabIndex == 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null,
                                      ),
                                      margin: const EdgeInsets.all(3),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 16,
                                            color: _activeTabIndex == 0 ? Colors.orange.shade700 : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Unit Info",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w500,
                                              color: _activeTabIndex == 0 ? Colors.orange.shade700 : const Color(0xFF64748B),
                                              fontFamily: "Poppins Regular",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Tab 2: Info DO
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeTabIndex = 1;
                                      });
                                      if (data_list_do.isEmpty && !isLoadingDo) {
                                        GetListDo();
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: _activeTabIndex == 1
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                )
                                              ]
                                            : null,
                                      ),
                                      margin: const EdgeInsets.all(3),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 16,
                                            color: _activeTabIndex == 1 ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Info DO",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w500,
                                              color: _activeTabIndex == 1 ? const Color(0xFF2563EB) : const Color(0xFF64748B),
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
                          ),
                        ),

                        // Tab Content (Scrollable)
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
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              child: _activeTabIndex == 0
                                  ? _buildUnitInfoTabContent()
                                  : _buildDoInfoTabContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
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
