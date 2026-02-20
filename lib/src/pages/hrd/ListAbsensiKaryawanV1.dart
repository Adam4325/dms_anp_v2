import 'dart:convert';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListAbsensiKaryawanV1 extends StatefulWidget {
  final String method; // storing, hadir, sakit, izin, cuti

  const ListAbsensiKaryawanV1({Key? key, required this.method}) : super(key: key);

  @override
  State<ListAbsensiKaryawanV1> createState() => _ListAbsensiKaryawanV1State();
}

class _ListAbsensiKaryawanV1State extends State<ListAbsensiKaryawanV1> {
  GlobalKey globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _dataList = [];
  bool _isLoading = true;

  static const Color primaryOrange = Color(0xFFFF8A50);
  static const Color accentOrange = Color(0xFFFF7043);

  String get _title {
    final t = widget.method.toLowerCase();
    if (t == 'storing') return 'List - Storing';
    if (t == 'hadir') return 'List - Hadir';
    if (t == 'sakit') return 'List - Sakit';
    if (t == 'izin') return 'List - Izin';
    if (t == 'cuti') return 'List - Cuti';
    return 'List Data';
  }

  void _goBack(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ViewDashboard()));
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String kryid = prefs.getString('kryid') ?? '';
      //kryid = '956ad8eab460883e ';

      if (kryid.isEmpty) {
        if (mounted) alert(globalScaffoldKey.currentContext!, 0, 'KryID tidak ditemukan', 'error');
        setState(() => _isLoading = false);
        return;
      }
      if (kryid=='null') {
        if (mounted) alert(globalScaffoldKey.currentContext!, 0, 'KryID null', 'error');
        setState(() => _isLoading = false);
        return;
      }

      //String today = '2026-02-01';//DateFormat('yyyy-MM-dd').format(DateTime.now());
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final method = widget.method.toLowerCase();
      print('method ${method}');
      String url = '${GlobalData.baseUrl}api/hrd/list_hadir_karyawan.jsp'
          '?method=list-$method'
          '&kryid=$kryid'
          '&logdate=$today'
          '&currentDate=$today'
          '&company=AN';

      print('URL_ABSEN $url');
      Uri myUri = Uri.parse(url);
      var response = await http.get(myUri, headers: {"Accept": "application/json"});

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        String status = (decoded['status_code'] ?? '').toString();
        if (status == '200' && decoded['data'] != null) {
          List raw = decoded['data'] is List ? decoded['data'] : [];
          _dataList = raw.map((e) {
            if (e is Map) {
              return {
                'kryname': (e['kryname'] ?? '').toString(),
                'logdatein': (e['logdatein'] ?? '').toString(),
                'logtimein': (e['logtimein'] ?? '').toString(),
                'logdateout': (e['logdateout'] ?? '').toString(),
                'logtimeout': (e['logtimeout'] ?? '').toString(),
                'durasitime': (e['durasitime'] ?? '').toString(),
                'status': (e['status'] ?? '').toString(),
                'divisi': (e['divisi'] ?? '').toString(),
                'krycompany': (e['krycompany'] ?? '').toString(),
                'krystatus': (e['krystatus'] ?? '').toString(),
                'name': (e['name'] ?? '').toString(),
                'durasihari': (e['durasihari'] ?? '').toString(),
                'selisihjam': (e['selisihjam'] ?? '').toString(),
              };
            }
            return <String, dynamic>{};
          }).toList();
          setState(() {});
        } else {
          _dataList = [];
          setState(() {});
        }
      } else {
        if (mounted) alert(globalScaffoldKey.currentContext!, 0, 'Gagal load data', 'error');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) alert(globalScaffoldKey.currentContext!, 0, 'Terjadi kesalahan: $e', 'error');
      print(e);
    }
    if (EasyLoading.isShow) EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _goBack(context),
          ),
          centerTitle: true,
          title: Text(_title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          elevation: 0,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : RefreshIndicator(
                onRefresh: _fetchData,
                color: primaryOrange,
                child: _dataList.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: 80),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                                SizedBox(height: 16),
                                Text('Tidak ada data', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) => _buildItemCard(_dataList[index]),
                      ),
              ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: primaryOrange.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person, color: primaryOrange, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['kryname'] ?? '-',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                      ),
                      if ((item['divisi'] ?? '').toString().isNotEmpty)
                        Text(
                          item['divisi'],
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: primaryOrange.withOpacity(0.2)),
            SizedBox(height: 8),
            _buildRow('Log Date In', item['logdatein']),
            _buildRow('Log Time In', item['logtimein']),
            _buildRow('Log Date Out', item['logdateout']),
            _buildRow('Log Time Out', item['logtimeout']),
            if ((item['durasitime'] ?? '').toString().isNotEmpty) _buildRow('Durasi', item['durasitime']),
            if ((item['status'] ?? '').toString().isNotEmpty) _buildRow('Status', item['status']),
            _buildRow('Divisi', item['divisi']),
            _buildRow('Company', item['krycompany']),
            _buildRow('Status Karyawan', item['krystatus']),
            _buildRow('Lokasi', item['name']),
            if ((item['durasihari'] ?? '').toString().isNotEmpty) _buildRow('Durasi Hari', item['durasihari']),
            if ((item['selisihjam'] ?? '').toString().isNotEmpty) _buildRow('Selisih Jam', item['selisihjam']),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
