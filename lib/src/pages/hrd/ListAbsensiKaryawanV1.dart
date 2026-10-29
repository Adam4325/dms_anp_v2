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
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _dataList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryOrange = Color(0xFFFF6600);
  static const Color accentOrange = Color(0xFFFF8533);
  static const Color lightOrange = Color(0xFFFFF3EB);

  String get _title {
    final t = widget.method.toLowerCase();
    if (t == 'storing') return 'List - Storing';
    if (t == 'hadir') return 'List - Hadir';
    if (t == 'sakit') return 'List - Sakit';
    if (t == 'izin') return 'List - Izin';
    if (t == 'cuti') return 'List - Cuti';
    return 'List - Presensi';
  }

  String _formatDateHeader(DateTime d) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewDashboard()),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String kryid = prefs.getString('kryid') ?? '';

      if (kryid.isEmpty || kryid == 'null') {
        if (mounted) {
          alert(globalScaffoldKey.currentContext!, 0, 'KryID tidak ditemukan', 'error');
        }
        setState(() => _isLoading = false);
        return;
      }

      String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final method = widget.method.toLowerCase();
      String url = '${GlobalData.baseUrl}api/hrd/list_hadir_karyawan.jsp'
          '?method=list-$method'
          '&kryid=$kryid'
          '&logdate=$dateStr'
          '&currentDate=$dateStr'
          '&company=AN';

      debugPrint('Fetching URL_ABSEN: $url');
      Uri myUri = Uri.parse(url);
      var response = await http.get(myUri, headers: {"Accept": "application/json"}).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        String status = (decoded['status_code'] ?? '').toString();
        if (status == '200' && decoded['data'] != null) {
          List raw = decoded['data'] is List ? decoded['data'] : [];
          _dataList = raw.map((e) {
            if (e is Map) {
              return Map<String, dynamic>.from(e);
            }
            return <String, dynamic>{};
          }).toList();
          setState(() {});
        } else {
          _dataList = [];
          setState(() {});
        }
      } else {
        if (mounted) alert(globalScaffoldKey.currentContext!, 0, 'Gagal memuat data presensi', 'error');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        alert(globalScaffoldKey.currentContext!, 0, 'Terjadi kesalahan: $e', 'error');
      }
      debugPrint('Error fetch data: $e');
    }
    if (EasyLoading.isShow) EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_searchQuery.trim().isEmpty) return _dataList;
    final q = _searchQuery.trim().toLowerCase();
    return _dataList.where((item) {
      final name = (item['kryname'] ?? '').toString().toLowerCase();
      final divisi = (item['divisi'] ?? '').toString().toLowerCase();
      final company = (item['krycompany'] ?? '').toString().toLowerCase();
      final lokasi = (item['name'] ?? '').toString().toLowerCase();
      return name.contains(q) || divisi.contains(q) || company.contains(q) || lokasi.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredData;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack(context);
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, accentOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33FF6600),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: () => _goBack(context),
                      tooltip: 'Kembali',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            _formatDateHeader(_selectedDate),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: _pickDate,
                      tooltip: 'Ganti Tanggal',
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: _fetchData,
                      tooltip: 'Muat Ulang',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter & KPI Summary Header
            _buildTopSummaryBar(filtered.length),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryOrange),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: primaryOrange,
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) => _buildItemCard(filtered[index]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSummaryBar(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryOrange.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 14, color: primaryOrange),
                        const SizedBox(width: 5),
                        Text(
                          '$count Karyawan',
                          style: const TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(
                        _formatDateHeader(_selectedDate),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Search Input
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Cari nama karyawan, divisi, atau lokasi...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final String name = (item['kryname'] ?? '-').toString().trim();
    final String divisi = (item['divisi'] ?? '').toString().trim();
    final String company = (item['krycompany'] ?? '').toString().trim();
    final String statusKaryawan = (item['krystatus'] ?? 'Active').toString().trim();
    final String lokasi = (item['name'] ?? '').toString().trim();

    final String dateIn = (item['logdatein'] ?? '').toString().trim();
    final String timeIn = (item['logtimein'] ?? '').toString().trim();
    final String dateOut = (item['logdateout'] ?? '').toString().trim();
    final String timeOut = (item['logtimeout'] ?? '').toString().trim();
    final String durasi = (item['durasitime'] ?? '').toString().trim();
    final String selisihJam = (item['selisihjam'] ?? '').toString().trim();
    final String durasiHari = (item['durasihari'] ?? '').toString().trim();
    final String status = (item['status'] ?? '').toString().trim();

    final bool isActive = statusKaryawan.toLowerCase() == 'active';
    final bool hasClockOut = timeOut.isNotEmpty && timeOut != 'null' && timeOut != '-';

    // Inisial avatar
    String initials = 'K';
    if (name.isNotEmpty && name != '-') {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6600).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profil & Status Header
            Row(
              children: [
                // Inisial Avatar Bulat
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A50), Color(0xFFFF6600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6600).withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (divisi.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                divisi,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          if (divisi.isNotEmpty && company.isNotEmpty)
                            const SizedBox(width: 6),
                          if (company.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                company,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? const Color(0xFF81C784) : Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        size: 11.5,
                        color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusKaryawan.isNotEmpty ? statusKaryawan : 'Active',
                        style: TextStyle(
                          color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Schedule Box: Clock-In vs Clock-Out
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Clock In
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.login_rounded, size: 13, color: Color(0xFF16A34A)),
                            SizedBox(width: 4),
                            Text(
                              'JAM MASUK',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeIn.isNotEmpty ? timeIn : '-',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (dateIn.isNotEmpty)
                          Text(
                            dateIn,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Divider / Durasi Center Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryOrange.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: primaryOrange),
                        const SizedBox(height: 2),
                        Text(
                          durasi.isNotEmpty ? durasi : 'Durasi',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Clock Out
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'JAM PULANG',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEA580C),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.logout_rounded, size: 13, color: hasClockOut ? const Color(0xFFEA580C) : Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasClockOut ? timeOut : 'Belum Pulang',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: hasClockOut ? const Color(0xFF0F172A) : Colors.grey.shade500,
                          ),
                        ),
                        if (dateOut.isNotEmpty && hasClockOut)
                          Text(
                            dateOut,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3. Location & Footer Information
            Row(
              children: [
                if (lokasi.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: primaryOrange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (status.isNotEmpty && status != 'null')
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300, width: 0.8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (durasiHari.isNotEmpty && durasiHari != '0')
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Text(
                      '$durasiHari Hari',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (selisihJam.isNotEmpty && selisihJam != '0')
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'Selisih $selisihJam Jam',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: lightOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  size: 36,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak Ada Data Presensi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Belum ada catatan presensi untuk tanggal ini.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 2,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Muat Ulang', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _fetchData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
