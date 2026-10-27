import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/FrmCloseVehicle.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flusbar.dart';

class ViewListDo extends StatefulWidget {
  const ViewListDo({Key? key}) : super(key: key);

  @override
  _ViewListDoState createState() => _ViewListDoState();
}

class _ViewListDoState extends State<ViewListDo> {
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> globalScaffoldKey2 = GlobalKey<ScaffoldState>();

  // ==========================================
  // PALET WARNA TEMA (SOFT ORANGE PASTEL)
  // Sesuai .agents/rules/form-redesign-template.md
  // ==========================================
  final Color primaryOrange = const Color(0xFFFF8C69); // Tombol utama & aksen
  final Color lightOrange = const Color(0xFFFFF4E6); // Background header card
  final Color accentOrange = const Color(0xFFFFB347); // Border card & aksen sekunder
  final Color darkOrange = const Color(0xFFE07B39); // Teks header & aksen tegas
  final Color backgroundColor = const Color(0xFFFFFAF5); // Background halaman
  final Color cardColor = const Color(0xFFFFF8F0); // Background container card
  final Color shadowColor = const Color(0x20FF8C69); // Soft shadow bernuansa hangat

  List data = [];
  bool _isLoading = false;
  String status_code = "";
  String txtAddr = "";
  String message = "";
  Position? userLocation;
  LocationData? currentLocation;
  Location? location;
  double _lat = 0.0;
  double _lon = 0.0;
  bool _serviceEnabled = true;
  bool _isisMock = false;
  String androidID = "";
  List listGeofence = [];
  String address = "";

  String _driverId = "";
  String _locId = "";

  @override
  void initState() {
    super.initState();
    getJSONData();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getJSONData() async {
    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Memuat data DO...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String drvid = prefs.getString("drvid") ?? "";
      String locid = prefs.getString("locid") ?? "";

      setState(() {
        _driverId = drvid;
        _locId = locid;
      });

      print("getJSONData drvid: $drvid, locid: $locid");
      Uri myUri = Uri.parse(
          "${GlobalData.baseUrl}api/do/list_do_new_driver.jsp?method=list_do_driver&driverid=" +
              drvid +
              "&locid=" +
              locid);
      print("myUri: $myUri");

      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final raw = decoded["data"];
        setState(() {
          data = raw != null && raw is List ? raw : [];
        });

        if (data.isEmpty && mounted && globalScaffoldKey.currentContext != null) {
          alert(globalScaffoldKey.currentContext!, 0,
              "Anda tidak mempunyai data DO aktif", "info");
        }
      } else {
        if (mounted && globalScaffoldKey.currentContext != null) {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal memuat DO (${response.statusCode})", "error");
        }
      }
    } catch (e) {
      print("Error getJSONData: $e");
      if (mounted && globalScaffoldKey.currentContext != null) {
        alert(globalScaffoldKey.currentContext!, 0,
            "Terjadi kesalahan saat memuat data DO: $e", "error");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return "Successfull";
  }

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  // ==========================================
  // HELPER DESIGN SYSTEM (GAYA NON-TERA)
  // ==========================================

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget ntBtnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  AlertDialog ntAlertDialog({
    required String title,
    required Widget content,
    List<Widget> actions = const <Widget>[],
  }) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: cardColor,
      titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Text(
        title,
        style: TextStyle(
          color: darkOrange,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  Widget _ntListCard({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
    Widget? actions,
    bool compact = false,
  }) {
    final m = compact ? 8.0 : 12.0;
    final v = compact ? 4.0 : 6.0;
    final r = compact ? 10.0 : 14.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: m, vertical: v),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: const Color(0x73FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: compact ? 4 : 8,
            offset: Offset(0, compact ? 1 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Card
          Container(
            width: double.infinity,
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r),
                topRight: Radius.circular(r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 13 : 14.5,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          // Baris-baris Data Key-Value
          Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
          // Tombol Aksi Bawah jika ada
          if (actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: actions,
            ),
        ],
      ),
    );
  }

  Widget _kv(
    String label,
    String value, {
    bool dense = false,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 2.5 : 4.0),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(125),
          1: FixedColumnWidth(16),
          2: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          TableRow(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                ":",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: dense ? 11.5 : 12.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade900,
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: valueWeight ?? FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _kvDialog(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGIC & API TERIMA DO
  // ==========================================

  Future<String?> CreateDoDiTerima(String drvid, String no_do) async {
    String noDo_Diterima = "";
    try {
      if (!EasyLoading.isShow) {
        EasyLoading.show(status: 'Memproses DO...');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String imeiid = (prefs.getString("androidID") ?? prefs.getString("imeiid") ?? "").trim();

      var urlData =
          "${GlobalData.baseUrl}api/do/do_diterima_v2.jsp?method=create-do_diterima&drvid=${drvid}&no_do=${no_do}&imeiid=${imeiid}";
      var encoded = Uri.encodeFull(urlData);
      print(urlData);
      Uri myUri = Uri.parse(encoded);
      var response =
          await http.get(myUri, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        var resBody = jsonDecode(response.body);
        int statusCode = resBody["status_code"] is int
            ? resBody["status_code"]
            : int.tryParse(resBody["status_code"]?.toString() ?? "0") ?? 0;
        String message = resBody["message"]?.toString() ?? "";
        if (statusCode == 200) {
          setState(() {
            noDo_Diterima = resBody["no_do"]?.toString() ?? "";
          });
        } else {
          if (mounted && globalScaffoldKey.currentContext != null) {
            alert(globalScaffoldKey.currentContext!, 0,
                message.isNotEmpty ? message : "Gagal terima DO ($statusCode)", "error");
          }
        }
      } else {
        if (mounted && globalScaffoldKey.currentContext != null) {
          alert(globalScaffoldKey.currentContext!, 0,
              "Gagal load data do diterima (${response.statusCode})", "error");
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      return noDo_Diterima;
    } catch (e) {
      if (mounted && globalScaffoldKey.currentContext != null) {
        alert(globalScaffoldKey.currentContext!, 0, "Client, Load do diterima: $e",
            "error");
      }
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      return null;
    }
  }

  Future<void> _confirmTerimaDo(dynamic value) async {
    final String doNumber = (value['dlodonumber'] ?? '-').toString();
    final String nopol = (value['vhcid'] ?? '-').toString();
    final String doCust = (value['dlodetaildonumber'] ?? '-').toString();
    final String origin = (value['dloorigin'] ?? '-').toString();
    final String destination = (value['dlodestination'] ?? '-').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => ntAlertDialog(
        title: 'Konfirmasi Terima DO',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin menerima Surat Jalan (DO) berikut?',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x73FFB347)),
              ),
              child: Column(
                children: [
                  _kvDialog('No. DO', doNumber),
                  _kvDialog('NOPOL', nopol),
                  _kvDialog('Cust. DO', doCust),
                  _kvDialog('Asal', origin),
                  _kvDialog('Tujuan', destination),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ntBtnStyle(primaryOrange),
            child: ntBtnLabel('Ya, Terima DO'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _executeTerimaDo(value);
    }
  }

  Future<void> _executeTerimaDo(dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var no_do = await CreateDoDiTerima(
        value['driverid'], value['dlodetaildonumber']);
    GlobalData.frmDloDoNumber = value['dlodetaildonumber'];
    print(value);

    if (no_do != null && no_do != "") {
      setState(() {
        prefs.setString("vhcid_new", value['vhcid'] ?? '');
        prefs.setString("drvid_new", value['driverid'] ?? '');
        prefs.setString("dloorigin", value['dloorigin'] ?? '');
        prefs.setString("dlodestination", value['dlodestination'] ?? '');
        prefs.setString("dlodetaildonumber", value['dlodetaildonumber'] ?? '');
        prefs.setString("bujnumber", value['dlodonumber'] ?? '');
        prefs.setString("koordinat_tujuan", value['koordinat_tujuan'] ?? '');
        print(prefs.getString("bujnumber"));
        print(value['dlodonumber']);
        prefs.remove("submit_bujnumber");
      });

      Timer(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FrmCloseVehicle()),
        );
      });
    }
  }

  // ==========================================
  // GEOFENCE & LOCATION SUPPORT
  // ==========================================

  Future updatePosition(String inorout) async {
    print(androidID.toString());
    print(userLocation);
    if (userLocation != null) {
      final loc = userLocation!;
      print(loc);
      if (listGeofence.isNotEmpty) {
        var radiusOld = 0.0;
        var geo_nmOld = "";
        for (var i = 0; i < listGeofence.length; i++) {
          var a = listGeofence[i];
          var radius = double.parse(a['radius'].toString());
          var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
              LatLng(double.parse(a['lon'].toString()), double.parse(a['lat'].toString())),
              LatLng(loc.longitude, loc.latitude));
          print(
              'distanceBetweenPoints $distanceBetweenPoints meter ${distanceBetweenPoints / 1000} KM');
          if (distanceBetweenPoints <= radius) {
            if (i == 0 || radiusOld < radius) {
              radiusOld = radius;
              geo_nmOld = a['name']?.toString() ?? "";
            }
          }
        }

        if (geo_nmOld.isNotEmpty) {
          setState(() {
            txtAddr = "INGEO";
          });
        } else {
          setState(() {
            txtAddr = "OUTGEO";
          });
        }
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
    var _permissionGranted = await location!.hasPermission();
    _serviceEnabled = await location!.serviceEnabled();
    print('_permissionGranted');
    print(_permissionGranted);
    print(_serviceEnabled);
    if (_permissionGranted != PermissionStatus.granted || !_serviceEnabled) {
      _permissionGranted = await location!.requestPermission();
      _serviceEnabled = await location!.requestService();
    } else {
      print('null location');
    }

    location!.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      _isisMock = currentLocation?.isMock ?? false;
      _lat = currentLocation?.latitude ?? 0;
      _lon = currentLocation?.longitude ?? 0;
      print('loc: $_lat, $_lon, mock: $_isisMock');
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
          listGeofence = (jsonDecode(response.body) as List).toList();
        });
      } else {
        if (mounted && globalScaffoldKey.currentContext != null) {
          alert(globalScaffoldKey.currentContext!, 0, "Gagal load data geofence",
              "error");
        }
      }
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    } catch (e) {
      if (mounted && globalScaffoldKey.currentContext != null) {
        alert(globalScaffoldKey.currentContext!, 0, "Client, Load data geofence",
            "error");
      }
      print(e.toString());
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  // ==========================================
  // WIDGETS
  // ==========================================

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x59FFB347)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: primaryOrange,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Penugasan DO',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Periksa detail surat jalan dan konfirmasi penerimaan di bawah ini.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                if (_driverId.isNotEmpty || _locId.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'ID: ${_driverId.isNotEmpty ? _driverId : '-'}${_locId.isNotEmpty ? ' • Loc: $_locId' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: darkOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x73FFB347)),
            ),
            child: Text(
              '${data.length} DO',
              style: TextStyle(
                color: darkOrange,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: getJSONData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: lightOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x73FFB347)),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 40,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Tidak Ada Data DO',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saat ini tidak ada Surat Jalan (DO) aktif untuk penugasan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: getJSONData,
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                  label: ntBtnLabel('Muat Ulang'),
                  style: ntBtnStyle(primaryOrange),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDMSMenuDO(BuildContext context, dynamic value, int index) {
    final String doNumber = (value['dlodonumber'] ?? '-').toString();
    final String nopol = (value['vhcid'] ?? '-').toString();
    final String driverId = (value['driverid'] ?? '-').toString();
    final String locid = (value['locid'] ?? '-').toString();
    final String doCust = (value['dlodetaildonumber'] ?? '-').toString();
    final String origin = (value['dloorigin'] ?? '-').toString();
    final String destination = (value['dlodestination'] ?? '-').toString();
    final dynamic rawKoord = value['koordinat_tujuan'];
    final String koordinat = (rawKoord == null ||
            rawKoord.toString() == 'null' ||
            rawKoord.toString().trim().isEmpty)
        ? '-'
        : rawKoord.toString();

    return _ntListCard(
      title: 'DO NUMBER : $doNumber',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x73FFB347)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_rounded, size: 14, color: primaryOrange),
            const SizedBox(width: 4),
            Text(
              nopol,
              style: TextStyle(
                color: darkOrange,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      rows: [
        _kv('NOPOL', nopol),
        _kv('Driver ID', driverId),
        _kv('LOCID', locid),
        _kv('DO CUST. NUMBER', doCust),
        _kv('ORIGIN', origin),
        _kv('KOORDINAT TUJUAN', koordinat),
        _kv('DESTINATION', destination),
      ],
      actions: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.save_rounded,
            color: Colors.white,
            size: 18,
          ),
          label: ntBtnLabel('DO DiTerima'),
          style: ntBtnStyle(primaryOrange),
          onPressed: () => _confirmTerimaDo(value),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    if (data.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: getJSONData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24, top: 4),
        itemCount: data.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard();
          }
          final itemIndex = index - 1;
          return _buildDMSMenuDO(context, data[itemIndex], itemIndex);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () => _goBack(context),
          ),
          title: const Text(
            'Form List DO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Muat Ulang',
              onPressed: getJSONData,
            ),
          ],
        ),
        body: Container(
          key: globalScaffoldKey2,
          constraints: const BoxConstraints.expand(),
          color: backgroundColor,
          child: _buildListView(context),
        ),
      ),
    );
  }
}
