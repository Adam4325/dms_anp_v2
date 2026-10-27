import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewDetailCuti.dart';
import 'package:dms_anp/src/pages/driver/FrmAttendanceAdvanceDriver.dart';
import 'package:dms_anp/src/pages/driver/ViewApprovalAttendanceDriver.dart';
import '../../helpers/DeveloperModeGuard.dart';

final globalScaffoldKey = GlobalKey<ScaffoldState>();

class FrmAttendanceAdvance extends StatefulWidget {
  const FrmAttendanceAdvance({Key? key}) : super(key: key);

  @override
  FrmAttendanceAdvanceState createState() => FrmAttendanceAdvanceState();
}

class FrmAttendanceAdvanceState extends State<FrmAttendanceAdvance> {
  // Design Tokens (Soft Orange Pastel)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  final String BASE_URL = GlobalData.baseUrlOri;
  String androidID = "";
  List listGeofence = [];
  String address = "";
  Position? userLocation;
  String geo_id = "";
  String geo_nm = "";
  String namaKaryawan = "";
  String jamAbsen = "";
  String tglAbsen = "";
  String timeIN = "";
  String timeOUT = "";
  String duration_check_out = "";
  String dropdownvalue = 'Pilih Absensi';
  final itemsShift = ['Pilih Absensi', 'storing', 'izin', 'sakit', 'cuti'];

  final TextEditingController txtAddr = TextEditingController();
  final TextEditingController txtLonLat = TextEditingController();
  final TextEditingController txtNote = TextEditingController();
  final TextEditingController txtStartDate = TextEditingController();
  final TextEditingController txtEndDate = TextEditingController();

  String start_date = '';
  String end_date = '';
  File? _imageProfile;
  Uint8List? _bytesImageProfile;
  var isShowAddress = false;
  String filePathImageProfile = "";
  final picker = ImagePicker();
  var status_absensi = "";
  ProgressDialog? pr;
  bool _isUpdatingPosition = false;
  var address_osm = "";
  var akses_detail = false;

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  void getPicture(String opsi) async {
    if (opsi == 'GALLERY') {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
        });
      }
    } else {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageProfile = File(pickedFile.path);
          List<int> imageBytes = _imageProfile!.readAsBytesSync();
          filePathImageProfile = base64Encode(imageBytes);
        });
      }
    }
  }

  void getProfileImage() async {
    filePathImageProfile = '';
  }

  Future getImageFromCamera(BuildContext contexs, String namaPhoto) async {
    showDialog(
      context: contexs,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.photo_camera, color: primaryOrange),
            SizedBox(width: 8),
            Text('Ambil Foto', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text("Pilih sumber pengambilan foto:"),
        actions: <Widget>[
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18.0),
            label: const Text("Kamera", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop(false);
              getPicture('CAMERA');
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 18.0),
            label: const Text("Galeri", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop(false);
              getPicture('GALLERY');
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Future getListGeofenceArea(bool isload) async {
    try {
      if (isload) {
        EasyLoading.show();
      }

      var urlData =
          "${BASE_URL}api/create_geofence_area.jsp?method=list-geofence-area-v1";
      var encoded = Uri.encodeFull(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          listGeofence = [];
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            listGeofence = List.from(decoded);
          } else if (decoded is Map && decoded.containsKey('data')) {
            final raw = decoded['data'];
            listGeofence = raw is List ? List.from(raw) : [];
          }
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
      debugPrint(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  double distance_in_meter(lat1, lon1, lat2, lon2) {
    var R = 6371000;
    var p = 0.017453292519943295;
    var dLat = (lat1 - lat2) * pi / p;
    var dLon = (lon1 - lon2) * pi / p;
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / p) * cos(lat2 * pi / p) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  bool arePointsNear(
      checkPoint_lat, checkPoint_lon, centerPoint_lat, centerPoint_lon, meter) {
    var ky = 40000 / 360;
    var kx = cos(pi * centerPoint_lat / 180.0) * ky;
    var dx = (centerPoint_lon - checkPoint_lon).abs() * kx;
    var dy = (centerPoint_lat - checkPoint_lat).abs() * ky;
    return (1000 * (sqrt(dx * dx + dy * dy))) <= meter;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 1000 * (12742 * asin(sqrt(a)));
  }

  var truslat = "0.0";
  var trusLon = "0.0";
  Future<Position?> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<String> getAddress(String? lat, String? lon) async {
    String address = "";
    if (lat == null || lon == null || lat.isEmpty || lon.isEmpty) {
      return "";
    }

    try {
      final uri = Uri.https(
        "nominatim.openstreetmap.org",
        "/reverse",
        {
          "format": "json",
          "lat": lat,
          "lon": lon,
          "zoom": "18",
          "addressdetails": "1"
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "User-Agent": "DMS_ANP/1.0 (ANP Driver Management System)",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded["display_name"] != null) {
          address = decoded["display_name"];
        }
      }
    } catch (e) {
      debugPrint("ERROR Reverse OSM: $e");
    }
    return address;
  }

  Future<String> saveAttendance(String inorout, int geo_id, String geo_nm,
      String employeeid, String lat, String lon, String addr) async {
    try {
      if (await DeveloperModeGuard.blockIfDeveloperModeEnabled(context)) {
        return "";
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var user_id = prefs.getString("name");
      if (androidID.isEmpty) {
        alert(globalScaffoldKey.currentContext!, 0,
            "IMEI ID kosong, silahkan kontak Administrator", "error");
      } else if (dropdownvalue.toString() == 'Pilih Absensi') {
        alert(globalScaffoldKey.currentContext!, 0,
            "Tipe Absensi belum dipilih", "error");
      } else if (user_id == null || user_id == "") {
        alert(globalScaffoldKey.currentContext!, 0,
            "USER ID tidak boleh kosong", "error");
      } else if ((dropdownvalue.toString() == 'cuti' ||
              dropdownvalue.toString() == 'sakit' ||
              dropdownvalue.toString() == 'izin') &&
          (txtNote.text.isEmpty)) {
        alert(globalScaffoldKey.currentContext!, 0, "Catatan tidak boleh kosong",
            "error");
      } else if ((dropdownvalue.toString() == 'cuti') &&
          (start_date.isEmpty)) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Start Date tidak boleh kosong", "error");
      } else if ((dropdownvalue.toString() == 'cuti') &&
          (end_date.isEmpty)) {
        alert(globalScaffoldKey.currentContext!, 0,
            "End Date tidak boleh kosong", "error");
      } else {
        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }

        var url_base = "";
        if (inorout == "IN" || inorout == "OUT") {
          url_base = "checkin-attendance-storing";
        } else if (inorout.toUpperCase() == "IZIN") {
          url_base = "checkin-attendance-izin";
        } else if (inorout.toUpperCase() == "SAKIT") {
          url_base = "checkin-attendance-sakit";
        } else if (inorout.toUpperCase() == "CUTI") {
          url_base = "checkin-attendance-cuti";
        }

        address_osm = await getAddress(lat.toString(), lon.toString());
        if (address_osm.isEmpty && txtAddr.text.trim().isNotEmpty) {
          address_osm = txtAddr.text.trim();
        }

        EasyLoading.show(status: 'Menyimpan absensi...');
        var data = {
          'method': inorout,
          'imeiid': androidID.toString(),
          'status_absensi': dropdownvalue.toString(),
          'geo_id': geo_id.toString(),
          'geo_nm': geo_nm,
          'is_mock': '0',
          'employeeid': "",
          'lat': lat,
          'lon': lon,
          'truslat': truslat,
          'truslon': trusLon,
          'address': address_osm,
          'userid': user_id.toUpperCase(),
          'start_date': start_date,
          'end_date': end_date,
          'company': 'AN',
          'note': txtNote.text,
          'photo': filePathImageProfile,
        };

        var encoded = Uri.encodeFull("${BASE_URL}api/${url_base}.jsp");
        Uri urlEncode = Uri.parse(encoded);
        final response = await http.post(
          urlEncode,
          body: data,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          encoding: Encoding.getByName('utf-8'),
        );

        if (EasyLoading.isShow) {
          EasyLoading.dismiss();
        }

        setState(() {
          String? message = "";
          var status_code = 100;
          var _tgl_absen = "";
          var _duration = "";
          var _timeIN = "";
          var _timeOUT = "";
          if (response.statusCode == 200) {
            final dec = json.decode(response.body);
            message = dec["message"];
            status_code = dec["status_code"] ?? 100;
            _tgl_absen = dec["tgl_absen"] ?? "";
            _duration = dec["duration"] ?? "";
            _timeIN = dec["timein"] ?? "";
            _timeOUT = dec["timeout"] ?? "";

            if (status_code == 200) {
              tglAbsen = _tgl_absen;
              duration_check_out = _duration;
              timeIN = _timeIN;
              timeOUT = _timeOUT;
              alert(globalScaffoldKey.currentContext!, 1, "${message}",
                  "success");
            } else if (status_code == 304) {
              tglAbsen = _tgl_absen;
              alert(globalScaffoldKey.currentContext!, 2, "${message}",
                  "Warning");
            } else {
              alert(
                  globalScaffoldKey.currentContext!, 0, "${message}", "error");
            }
          } else {
            message = response.reasonPhrase;
            alert(globalScaffoldKey.currentContext!, 0, "${message}", "error");
          }
        });
      }
    } catch (e) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      alert(globalScaffoldKey.currentContext!, 0, "Client, ${e}", "error");
      debugPrint(e.toString());
    }
    return "";
  }

  Future updatePosition(String inorout) async {
    if (_isUpdatingPosition) return;
    _isUpdatingPosition = true;
    if (!EasyLoading.isShow) EasyLoading.show(status: 'Mengambil lokasi & alamat...');
    try {
      if (userLocation == null) {
        _getLocation();
        return;
      }
      var address = "";
      if (listGeofence.isEmpty) {
        address = await getAddress(userLocation!.latitude.toString(),
            userLocation!.longitude.toString());
        if (mounted) setState(() => txtAddr.text = address);
        _showConfirmDialog(inorout, 0, "", address);
        return;
      }

      txtAddr.text = "";
      double radiusOld = 0.0;
      int geo_idOld = 0;
      String geo_nmOld = "";
      bool insideAny = false;

      for (var i = 0; i < listGeofence.length; i++) {
        var a = listGeofence[i];
        var radiusRaw = double.tryParse(a['radius']?.toString() ?? '') ?? 0.0;
        var radiusMeters = radiusRaw > 0 && radiusRaw < 100 ? radiusRaw * 1000 : radiusRaw;
        var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
            LatLng(double.parse(a['lat'].toString()), double.parse(a['lon'].toString())),
            LatLng(userLocation!.latitude, userLocation!.longitude));

        if (distanceBetweenPoints <= radiusMeters) {
          insideAny = true;
          if (i == 0 || radiusMeters < radiusOld) {
            radiusOld = radiusMeters;
            geo_idOld = int.parse(a['geo_id'].toString());
            geo_nmOld = (a['name'] ?? '').toString();
          }
        }
      }

      final isStoring = dropdownvalue.toString().toLowerCase() == 'storing';

      if (isStoring) {
        address = await getAddress(userLocation!.latitude.toString(),
            userLocation!.longitude.toString());
        if (address.isEmpty) address = "Alamat tidak ditemukan";
        if (mounted) setState(() => txtAddr.text = address);
        _showConfirmDialog(inorout, 0, "", address);
        return;
      }

      // Bukan storing (izin/sakit/cuti): harus di dalam geofence
      if (!insideAny) {
        if (mounted) alert(globalScaffoldKey.currentContext!, 0,
            "Anda di luar geofence. Silakan masuk area yang ditentukan.", "error");
        return;
      }
      if (mounted) setState(() => txtAddr.text = geo_nmOld);
      _showConfirmDialog(inorout, geo_idOld, geo_nmOld, address);
    } finally {
      _isUpdatingPosition = false;
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  void _showConfirmDialog(String inorout, int geo_idOld, String geo_nmOld, String address) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: primaryOrange),
            SizedBox(width: 8),
            Text('Konfirmasi Absen', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
            "Lakukan ${inorout.toUpperCase()} absensi ${dropdownvalue.toString().toUpperCase()}?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Batal", style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18.0),
            label: Text("${inorout.toUpperCase()}", style: const TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(context).pop(false);
              await saveAttendance(
                  inorout,
                  geo_idOld,
                  geo_nmOld,
                  "",
                  userLocation!.latitude.toString(),
                  userLocation!.longitude.toString(),
                  address.isEmpty ? txtAddr.text : address);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 20.0,
            onPressed: () => _goBack(context),
          ),
          centerTitle: true,
          title: const Text(
            'Attendance Advance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
        body: FrmAttendance(context),
      ),
    );
  }

  Widget FrmAttendance(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Employee Info & Profile Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x40FFB347)),
              boxShadow: const [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: lightOrange,
                  child: const Icon(Icons.badge_outlined, color: darkOrange, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaKaryawan.isNotEmpty ? namaKaryawan : 'Karyawan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: lightOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'KARYAWAN / ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: darkOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              androidID.isNotEmpty ? 'IMEI: $androidID' : '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Photo Profile Card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x59FFB347)),
              boxShadow: const [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.camera_alt_outlined, color: primaryOrange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Foto Bukti / Kehadiran",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        await getImageFromCamera(context, "PROFILE");
                      },
                      child: Container(
                        width: 170,
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          border: Border.all(color: const Color(0x73FFB347)),
                          boxShadow: const [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _imageProfile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _imageProfile!,
                                  width: 170,
                                  height: 190,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : filePathImageProfile.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      _bytesImageProfile ?? Uint8List.fromList(const []),
                                      width: 170,
                                      height: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: lightOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 32,
                                          color: primaryOrange,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Ketuk untuk foto",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Form Input Container
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x59FFB347)),
              boxShadow: const [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.assignment_outlined, color: primaryOrange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Pilihan Tipe & Formulir",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown Tipe Absensi
                      _label('Tipe Absensi'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: dropdownvalue,
                            icon: const Icon(Icons.keyboard_arrow_down, color: primaryOrange),
                            items: itemsShift.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: item == 'Pilih Absensi'
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: item == 'Pilih Absensi'
                                        ? Colors.grey.shade500
                                        : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownvalue = newValue!;
                                status_absensi = dropdownvalue;
                                akses_detail = dropdownvalue.toUpperCase() == 'CUTI';
                              });
                            },
                          ),
                        ),
                      ),

                      // Section Storing
                      if (status_absensi == "storing") ...[
                        const SizedBox(height: 16),
                        _label('Informasi Storing'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Lokasi Geofence', txtAddr.text.isNotEmpty ? txtAddr.text : '-'),
                              if (isShowAddress && address_osm.isNotEmpty)
                                _infoRow('Alamat OSM', address_osm),
                              _infoRow('Tgl Absen', tglAbsen.isNotEmpty ? tglAbsen : '-'),
                              _infoRow('Time IN', timeIN.isNotEmpty ? timeIN : '-'),
                              _infoRow('Time OUT', timeOUT.isNotEmpty ? timeOUT : '-'),
                              _infoRow('Durasi', duration_check_out.isNotEmpty ? duration_check_out : '-'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.login, color: Colors.white, size: 20),
                                label: const Text("Check IN", style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await updatePosition("IN");
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF43A047),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                                label: const Text("Check OUT", style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await updatePosition("OUT");
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Section Cuti (Date Pickers)
                      if (status_absensi == "cuti") ...[
                        const SizedBox(height: 16),
                        _label('Rentang Tanggal Cuti'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DateTimePicker(
                            dateMask: 'yyyy-MM-dd',
                            controller: txtStartDate,
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100),
                            icon: const Icon(Icons.calendar_today, color: primaryOrange, size: 20),
                            dateLabelText: 'Start Date',
                            onChanged: (val) => setState(() => start_date = val),
                            validator: (val) {
                              setState(() => start_date = val ?? '');
                              return null;
                            },
                            onSaved: (val) => setState(() => start_date = val ?? ''),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DateTimePicker(
                            dateMask: 'yyyy-MM-dd',
                            controller: txtEndDate,
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100),
                            icon: const Icon(Icons.event, color: primaryOrange, size: 20),
                            dateLabelText: 'End Date',
                            onChanged: (val) => setState(() => end_date = val),
                            validator: (val) {
                              setState(() => end_date = val ?? '');
                              return null;
                            },
                            onSaved: (val) => setState(() => end_date = val ?? ''),
                          ),
                        ),
                      ],

                      // Section Note & Submit (Izin, Sakit, Cuti)
                      if (status_absensi == "izin" ||
                          status_absensi == "sakit" ||
                          status_absensi == "cuti") ...[
                        const SizedBox(height: 16),
                        _label('Catatan / Keterangan (Wajib)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: txtNote,
                          maxLines: 2,
                          cursorColor: primaryOrange,
                          decoration: InputDecoration(
                            hintText: 'Tuliskan catatan absensi...',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: const Icon(Icons.edit_note, color: primaryOrange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: primaryOrange, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20.0),
                            label: Text(
                              "SUBMIT ${dropdownvalue.toUpperCase()}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () async {
                              address = await getAddress(
                                  userLocation?.latitude.toString(),
                                  userLocation?.longitude.toString());
                              var status = dropdownvalue.toUpperCase();
                              await saveAttendance(
                                  status,
                                  0,
                                  "",
                                  "",
                                  userLocation?.latitude.toString() ?? "0",
                                  userLocation?.longitude.toString() ?? "0",
                                  address);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],

                      // Button View Detail Cuti
                      if (akses_detail) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                            label: const Text(
                              "Lihat Detail & Persetujuan Cuti",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              if (EasyLoading.isShow) {
                                EasyLoading.dismiss();
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewDetailCuti(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.assignment_ind, color: Colors.white, size: 20),
                            label: const Text(
                              "Persetujuan Sakit & Izin Driver",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewApprovalAttendanceDriver(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: darkOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaKaryawan = prefs.getString("name") ?? "";
      androidID = prefs.getString("androidID") ?? "";
    });

    // Guard: Driver dialihkan ke FrmAttendanceAdvanceDriver
    final loginType = (prefs.getString("login_type") ?? "").toLowerCase().trim();
    final loginname = (prefs.getString("loginname") ?? "").toUpperCase().trim();
    if (loginType == 'driver' || loginname == 'DRIVER') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FrmAttendanceAdvanceDriver()),
        );
      }
    }
  }

  void GetAksesViewDetail() async {
    var isAkses = false;
    SharedPreferences sf = await SharedPreferences.getInstance();
    final username = (sf.getString("username") ?? "").toUpperCase().trim();
    final loginname = (sf.getString("loginname") ?? "").toUpperCase().trim();
    final isHR = globals.akses_pages.where((x) => x == "HR").isNotEmpty;
    final isOP = globals.akses_pages.where((x) => x == "OP").isNotEmpty;
    if (isHR || isOP || username == "ADMIN" || loginname == "ADMIN") {
      isAkses = true;
    }

    if (mounted) {
      setState(() {
        akses_detail = isAkses;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await DeveloperModeGuard.blockIfDeveloperModeEnabled(context)) {
        return;
      }
    });
    _getLocation().then((position) {
      if (mounted) {
        setState(() {
          userLocation = position;
        });
      }
    });
    getSession();
    getProfileImage();
    GetAksesViewDetail();
    getListGeofenceArea(false);
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }
}
