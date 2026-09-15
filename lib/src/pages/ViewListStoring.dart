import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/ViewMaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../flusbar.dart';

class ViewListStoring extends StatefulWidget {
  @override
  _ViewListStoringState createState() => _ViewListStoringState();
}

class _ViewListStoringState extends State<ViewListStoring> {
  // Theme Palette
  static const Color primaryOrange = Color(0xFFFF8A50);
  static const Color darkOrange = Color(0xFFE65100);

  GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> data = [];

  List<dynamic> get _filteredData {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return data;

    return data.where((item) {
      final reqnbr = item['reqnbr']?.toString().toLowerCase() ?? '';
      final vhcid = item['vhcid']?.toString().toLowerCase() ?? '';
      final drvname = item['drvname']?.toString().toLowerCase() ?? '';
      final notes = item['notes']?.toString().toLowerCase() ?? '';
      final locid = item['locid']?.toString().toLowerCase() ?? '';
      return reqnbr.contains(keyword) ||
          vhcid.contains(keyword) ||
          drvname.contains(keyword) ||
          notes.contains(keyword) ||
          locid.contains(keyword);
    }).toList();
  }

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  var _isLoading = false;
  Future<void> getJSONData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Memuat data...');

    try {
      final url = "${GlobalData.baseUrl}api/list_storing.jsp?method=list-storing";
      final Uri myUri = Uri.parse(url);
      final response = await http
          .get(myUri, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          setState(() {
            data = decoded;
            _isLoading = false;
          });
          if (data.isEmpty && mounted) {
            alert(globalScaffoldKey.currentContext ?? context, 2,
                "Tidak ada data storing aktif", "warning");
          }
        } else {
          setState(() {
            data = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
        alert(globalScaffoldKey.currentContext ?? context, 0,
            "Gagal memuat data (${response.statusCode})", "error");
      }
    } catch (e) {
      print("Error getJSONData: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        alert(globalScaffoldKey.currentContext ?? context, 0,
            "Koneksi bermasalah: $e", "error");
      }
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> CloseData(String reqnbr, String vhcid, String status) async {
    final reqnbrParam = reqnbr.trim();
    final vhcidParam = vhcid.trim();
    final statusParam = status.trim();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = (prefs.getString("username") ?? "").trim();
    if (userid.isEmpty) {
      userid = (prefs.getString("androidID") ?? "").trim();
    }
    if (userid.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "USER ID / IMEI ID tidak boleh kosong", "warning");
      return "Failed";
    }
    if (reqnbrParam.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "Req NBR tidak boleh kosong", "warning");
      return "Failed";
    }
    if (vhcidParam.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "VHCID tidak boleh kosong", "warning");
      return "Failed";
    }
    if (statusParam.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "Status tidak boleh kosong", "warning");
      return "Failed";
    }

    EasyLoading.show(status: 'Memproses...');
    try {
      Uri myUri = Uri.parse("${GlobalData.baseUrl}api/list_storing.jsp").replace(
        queryParameters: {
          "method": "close-data-storing",
          "reqnbr": reqnbrParam,
          "vhcid": vhcidParam,
          "userid": userid,
          "status": statusParam,
        },
      );

      var response = await http
          .get(myUri, headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        alert(globalScaffoldKey.currentContext ?? context, 0,
            "SERVER ERROR (${response.statusCode})", "Failed");
        return "Failed";
      }

      var jsonData = json.decode(response.body);
      var statusCode = int.tryParse(jsonData['status_code'].toString()) ?? 500;
      if (statusCode == 200) {
        alert(globalScaffoldKey.currentContext ?? context, 1,
            jsonData['message'] ?? "Berhasil diperbarui", "Success");
        await getJSONData();
      } else {
        alert(globalScaffoldKey.currentContext ?? context, 0,
            jsonData['message'] ?? "Gagal memproses data", "Failed");
      }
    } catch (e) {
      print("CloseData error: $e");
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "Terjadi kesalahan: $e", "error");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
    return "Successfull";
  }

  void _showLocationOptions(dynamic item) {
    final rawLatLon = (item['latlon'] ?? '').toString();
    final parts =
        rawLatLon.split(',').where((s) => s.trim().isNotEmpty).toList();

    String lat = '';
    String lon = '';
    if (parts.length >= 2) {
      lat = parts[0].trim();
      lon = parts[1].trim();
    }

    if (lat.isEmpty || lon.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "Data koordinat (Latitude / Longitude) tidak ditemukan", "error");
      return;
    }

    final vhcid = (item['vhcid'] ?? '-').toString();
    final reqnbr = (item['reqnbr'] ?? '-').toString();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on_rounded,
                          color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Storing ($vhcid)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Req: $reqnbr • ($lat, $lon)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Option 1: Buka di ViewMaps Aplikasi
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_rounded,
                        color: darkOrange, size: 20),
                  ),
                  title: const Text(
                    'Buka di Peta Internal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Lihat rute dan armada pada peta aplikasi DMS',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString("view_lat", lat);
                    await prefs.setString("view_lon", lon);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ViewMaps()),
                    );
                  },
                ),

                // Option 2: Buka di Google Maps
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.near_me_rounded,
                        color: Colors.green.shade700, size: 20),
                  ),
                  title: const Text(
                    'Buka di Google Maps',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Navigasi langsung menggunakan Google Maps',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final url =
                        'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Share.share(url);
                    }
                  },
                ),

                // Option 3: Bagikan Link
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.share_rounded,
                        color: Colors.purple.shade700, size: 20),
                  ),
                  title: const Text(
                    'Bagikan Link Koordinat',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kirim tautan koordinat via WhatsApp / Pesan',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.share(
                        'https://www.google.com/maps?q=$lat,$lon&t=m&hl=en');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAction(dynamic item, String actionType) async {
    final reqnbr = (item['reqnbr'] ?? '').toString();
    final vhcid = (item['vhcid'] ?? '').toString();
    final isClose = actionType == 'CLOSE';

    if (reqnbr.isEmpty) {
      alert(globalScaffoldKey.currentContext ?? context, 0,
          "Data Req Number tidak valid", "error");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isClose ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isClose ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isClose ? Colors.green.shade700 : Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isClose ? 'Konfirmasi Proses' : 'Konfirmasi Batal',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isClose
                  ? 'Apakah Anda yakin ingin menyelesaikan / memproses data storing ini?'
                  : 'Apakah Anda yakin ingin membatalkan laporan storing ini?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('No. Request:',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      Text(reqnbr,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Armada / VHCID:',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      Text(vhcid,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text('Batal',
                style: TextStyle(
                    color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClose ? Colors.green.shade600 : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              isClose ? 'Ya, Selesaikan' : 'Ya, Batalkan',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CloseData(reqnbr, vhcid, actionType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
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
                'List Storing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Monitoring Kendala Armada',
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
              onPressed: getJSONData,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar & Stats Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Req NBR, Nopol, Driver, atau Lokasi...',
                      hintStyle:
                          TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: primaryOrange, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.cancel_rounded,
                                  color: Colors.grey.shade400, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
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
                            child: Row(
                              children: [
                                const Icon(Icons.assignment_outlined,
                                    size: 14, color: darkOrange),
                                const SizedBox(width: 4),
                                Text(
                                  '${filteredData.length} Laporan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: darkOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              'hasil filter pencarian',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: getJSONData,
                        child: Text(
                          'Tarik untuk refresh',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: getJSONData,
                child: filteredData.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: primaryOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.assignment_turned_in_outlined,
                                size: 40,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              _searchController.text.isNotEmpty
                                  ? 'Data tidak ditemukan'
                                  : 'Tidak ada data storing aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              _searchController.text.isNotEmpty
                                  ? 'Coba gunakan kata kunci nomor request atau armada lainnya.'
                                  : 'Saat ini seluruh laporan storing kendaraan telah tertangani.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_searchController.text.isNotEmpty)
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear_all_rounded,
                                    size: 18),
                                label: const Text('Reset Pencarian'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryOrange,
                                  side:
                                      const BorderSide(color: primaryOrange),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          return _buildStoringCard(
                              filteredData[index], index);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoringCard(dynamic item, int index) {
    final reqnbr = (item['reqnbr'] ?? '-').toString();
    final reqDatetime = (item['req_datetime'] ?? '-').toString();
    final vhcid = (item['vhcid'] ?? '-').toString();
    final drvname = (item['drvname'] ?? '-').toString();
    final notes = (item['notes'] ?? '').toString().trim();
    final locid = (item['locid'] ?? '-').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Req NBR & Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.build_circle_rounded,
                      color: darkOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reqnbr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reqDatetime,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'STORING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5)),

          // Body Info: VHCID, Driver, Lokasi
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Armada Tag
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined,
                                size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                vhcid,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF263238),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Lokasi Tag
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locid,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Driver Name
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Driver: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Expanded(
                      child: Text(
                        drvname,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Notes / Catatan Kendala
                if (notes.isNotEmpty && notes != 'null') ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5)),

          // Actions Bar: [Maps] [Batal] [Proses]
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Button Maps
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLocationOptions(item),
                    icon: Icon(Icons.map_outlined,
                        size: 16, color: Colors.blue.shade700),
                    label: Text(
                      'Peta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.blue.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Button Batal
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmAction(item, 'CANCEL'),
                    icon: Icon(Icons.close_rounded,
                        size: 16, color: Colors.red.shade700),
                    label: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Button Proses
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAction(item, 'CLOSE'),
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'Proses',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
