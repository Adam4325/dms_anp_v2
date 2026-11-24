import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:dms_anp/src/widgets/simple_paginator.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'ApprovedDailyCheckScreenP2H.dart';
import 'DailyCheckScreenP2H.dart';

class ListDriverInspeksiV2 extends StatefulWidget {
  @override
  _ListDriverInspeksiV2State createState() => _ListDriverInspeksiV2State();
}

class _ListDriverInspeksiV2State extends State<ListDriverInspeksiV2> {
  final GlobalKey<PaginatorState> paginatorGlobalKey = GlobalKey();
  final GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();

  String _searchText = "";
  String username = "";
  String userid = "";
  String locid = "";

  // MD Palette
  static const Color primaryOrange = Color(0xFFFF8A50);
  static const Color darkOrange = Color(0xFFE65100);
  static const Color scaffoldBg = Color(0xFFF8FAFC);

  final TextEditingController _txtSearch = TextEditingController();

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  void _onSearchSubmit() {
    setState(() {
      _searchText = _txtSearch.text.trim();
    });
    paginatorGlobalKey.currentState?.changeState(
      pageLoadFuture: sendDriverDataRequest,
      resetState: true,
    );
  }

  void _onSearchReset() {
    setState(() {
      _searchText = "";
      _txtSearch.clear();
    });
    paginatorGlobalKey.currentState?.changeState(
      pageLoadFuture: sendDriverDataRequest,
      resetState: true,
    );
  }

  void getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
      userid = prefs.getString("name") ?? "";
      locid = prefs.getString("locid") ?? "";
    });
  }

  @override
  void initState() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    getSession();
    _txtSearch.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _txtSearch.dispose();
    super.dispose();
  }

  bool getAkses(dynamic akses) {
    if (globals.akses_pages == null) return false;
    return globals.akses_pages.any((x) => x == akses);
  }

  Color _getStatusBg(String status) {
    switch (status.trim().toUpperCase()) {
      case 'ONGOING':
        return const Color(0xFFE0F2FE); // Soft Blue
      case 'SERVICE':
        return const Color(0xFFFEF3C7); // Soft Amber
      case 'CLOSE':
        return const Color(0xFFF1F5F9); // Soft Grey
      default:
        return const Color(0xFFDCFCE7); // Soft Green
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.trim().toUpperCase()) {
      case 'ONGOING':
        return const Color(0xFF0369A1);
      case 'SERVICE':
        return const Color(0xFFD97706);
      case 'CLOSE':
        return const Color(0xFF475569);
      default:
        return const Color(0xFF16A34A);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.trim().toUpperCase()) {
      case 'ONGOING':
        return Icons.play_circle_outline_rounded;
      case 'SERVICE':
        return Icons.build_circle_outlined;
      case 'CLOSE':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
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
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => _goBack(context),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, darkOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: const Column(
            children: [
              Text(
                'List Vehicle P2H',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Monitoring Kelayakan & Verifikasi Armada',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Muat Ulang',
              onPressed: () {
                paginatorGlobalKey.currentState?.changeState(
                  pageLoadFuture: sendDriverDataRequest,
                  resetState: true,
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar Header (MD3 Card)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _txtSearch,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearchSubmit(),
                    decoration: InputDecoration(
                      hintText: 'Cari Nopol, Driver, atau Cabang...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: primaryOrange,
                        size: 22,
                      ),
                      suffixIcon: _txtSearch.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                              onPressed: _onSearchReset,
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: primaryOrange, width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      if (val.isEmpty && _searchText.isNotEmpty) {
                        _onSearchReset();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.directions_car_filled_outlined,
                                    size: 13, color: darkOrange),
                                SizedBox(width: 4),
                                Text(
                                  'Daftar Armada',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: darkOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_searchText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Hasil pencarian: "$_searchText"',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          paginatorGlobalKey.currentState?.changeState(
                            pageLoadFuture: sendDriverDataRequest,
                            resetState: true,
                          );
                        },
                        child: Text(
                          'Tarik untuk refresh',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Paginator List
            Expanded(
              child: Paginator.listView(
                key: paginatorGlobalKey,
                pageLoadFuture: sendDriverDataRequest,
                pageItemsGetter: listItemsGetter,
                listItemBuilder: listItemBuilder,
                loadingWidgetBuilder: loadingWidgetMaker,
                errorWidgetBuilder: errorWidgetMaker,
                emptyListWidgetBuilder: emptyListWidgetMaker,
                totalItemsGetter: totalPagesGetter,
                pageErrorChecker: pageErrorChecker,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DriverDataVehicle> sendDriverDataRequest(int page) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var loginname = sharedPreferences.getString("loginname") ?? "";
    var currentUsername = sharedPreferences.getString("username") ?? "";

    try {
      String url = Uri.encodeFull(
          '${GlobalData.baseUrlOri}api/vehicle/list_vehiclev2.jsp?method=list-vehicle-v2&loginname=$loginname&username=$currentUsername&page=$page&search=' +
              _searchText);
      Uri myUri = Uri.parse(url);
      http.Response response = await http.get(myUri);
      return DriverDataVehicle.fromResponse(response);
    } catch (e) {
      print("sendDriverDataRequest error: $e");
      if (e is IOException) {
        alert(context, 2, "Koneksi internet bermasalah.", "warning");
        return DriverDataVehicle.withError('Koneksi internet bermasalah.');
      } else {
        alert(context, 2, "Gagal memuat data kendaraan.", "warning");
        return DriverDataVehicle.withError('Gagal memuat data kendaraan.');
      }
    }
  }

  List<dynamic> listItemsGetter(dynamic data) {
    final vehicleData = data as DriverDataVehicle;
    List<Map<String, dynamic>> list = [];
    for (var value in vehicleData.vehicledatas) {
      String vhcdefaultdriver = value['vhcdefaultdriver'] == null ||
              value['vhcdefaultdriver'].toString() == 'null'
          ? ""
          : value['vhcdefaultdriver'].toString();
      String drvname = value['drvname'] == null ||
              value['drvname'].toString() == 'null'
          ? ""
          : value['drvname'].toString();

      String? vhcdate = value['vhcdate'] == null ||
              value['vhcdate'].toString() == 'null'
          ? null
          : value['vhcdate'].toString();

      list.add({
        "p2hnumber": value['p2hnumber'] ?? "",
        "vhcid": value['vhcid'] ?? "",
        "vhttype": value['vhttype'] ?? "",
        "vhcnopol": value['vhcnopol'] ?? "-",
        "locid": value['locid'] ?? "-",
        "vhcdefaultdriver": vhcdefaultdriver,
        "status": value['status'] ?? "-",
        "vhckm": value['vhckm']?.toString() ?? "0",
        "drvname": drvname,
        "vhcdate": vhcdate,
      });
    }
    return list;
  }

  Widget listItemBuilder(dynamic value, int index) {
    final String nopol = value['vhcnopol']?.toString() ?? '-';
    final String vhttype = value['vhttype']?.toString() ?? '';
    final String status = value['status']?.toString() ?? '-';
    final String drvname = value['drvname']?.toString() ?? '';
    final String vhckm = value['vhckm']?.toString() ?? '0';
    final String locid = value['locid']?.toString() ?? '-';

    final Color statusBg = _getStatusBg(status);
    final Color statusTextColor = _getStatusTextColor(status);
    final IconData statusIcon = _getStatusIcon(status);

    final bool canVerify = globals.inspeksi_name == 'new_inspeksi' &&
        (getAkses("OP") || username == 'ADMIN' || username == 'NURIZKI');
    final bool canSelect = !getAkses("OPR") || username == 'ADMIN';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon, Nopol, Type, Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vehicle Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: darkOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Nopol & Type & Cabang
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nopol,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vhttype.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Text(
                                vhttype,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              locid,
                              style: TextStyle(
                                fontSize: 12,
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

                // Status Badge Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusTextColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusTextColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Driver & Kilometer Info Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Driver Info
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DRIVER",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                drvname.isNotEmpty ? drvname : "-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider Line
                  Container(
                    width: 1,
                    height: 26,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // Kilometer Info
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "KILOMETER",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              "$vhckm KM",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
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

            // Action Buttons
            if (canVerify) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.verified_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "Verifikasi P2H",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  onPressed: () async {
                    globals.p2hNumber = value['p2hnumber'];
                    globals.p2hVhcid = value['vhcid'];
                    globals.p2hVhclocid = value['locid'];
                    globals.p2hVhcdate = value['vhcdate'];
                    globals.p2hVhckm = value['vhckm'] == null ||
                            value['vhckm'] == "null" ||
                            value['vhckm'] == ""
                        ? 0.0
                        : double.tryParse(value['vhckm'].toString()) ?? 0.0;
                    globals.p2hVhcdefaultdriver = value['vhcdefaultdriver'];

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApprovedDailyCheckScreenP2H(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: darkOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (canSelect) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: darkOrange,
                    size: 18,
                  ),
                  label: const Text(
                    "Pilih Kendaraan",
                    style: TextStyle(
                      color: darkOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    globals.p2hVhcid = value['vhcid'];
                    globals.p2hVhclocid = value['locid'];
                    globals.p2hVhcdate = value['vhcdate'];
                    globals.p2hVhckm = value['vhckm'] == null ||
                            value['vhckm'] == "null" ||
                            value['vhckm'] == ""
                        ? 0.0
                        : double.tryParse(value['vhckm'].toString()) ?? 0.0;
                    globals.p2hVhcdefaultdriver = value['vhcdefaultdriver'];

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyCheckScreenP2H(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: darkOrange, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: const CircularProgressIndicator(color: primaryOrange),
    );
  }

  Widget errorWidgetMaker(dynamic data, VoidCallback retry) {
    final vehicleDatas = data as DriverDataVehicle;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 32, color: Colors.red.shade600),
            ),
            const SizedBox(height: 14),
            Text(
              vehicleDatas.errorMessage.isNotEmpty
                  ? vehicleDatas.errorMessage
                  : "Terjadi kesalahan saat memuat data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryOrange,
                side: const BorderSide(color: primaryOrange),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyListWidgetMaker(dynamic data) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_outlined,
                size: 36,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchText.isNotEmpty
                  ? 'Kendaraan Tidak Ditemukan'
                  : 'Tidak ada data kendaraan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchText.isNotEmpty
                  ? 'Coba gunakan kata kunci nopol atau nama driver lainnya.'
                  : 'Saat ini belum ada data kendaraan P2H yang tersedia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchText.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _onSearchReset,
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Reset Pencarian'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: const BorderSide(color: primaryOrange),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int totalPagesGetter(dynamic data) {
    return (data as DriverDataVehicle).total;
  }

  bool pageErrorChecker(dynamic data) {
    return (data as DriverDataVehicle).statusCode != 200;
  }
}

class DriverDataVehicle {
  late List<dynamic> vehicledatas;
  late int statusCode;
  late String errorMessage;
  late int total;
  late int nItems;

  DriverDataVehicle.fromResponse(http.Response response) {
    statusCode = response.statusCode;
    errorMessage = '';
    try {
      List jsonData = json.decode(response.body);
      vehicledatas = jsonData.length > 1 ? (jsonData[1] ?? []) : [];
      total = jsonData.isNotEmpty && jsonData[0] is Map
          ? (jsonData[0]['total'] ?? 0)
          : 0;
      nItems = vehicledatas.length;
    } catch (e) {
      statusCode = 500;
      errorMessage = 'Format response tidak sesuai';
      vehicledatas = [];
      total = 0;
      nItems = 0;
    }
  }

  DriverDataVehicle.withError(String errMsg) {
    statusCode = 0;
    errorMessage = errMsg;
    vehicledatas = [];
    total = 0;
    nItems = 0;
  }
}
