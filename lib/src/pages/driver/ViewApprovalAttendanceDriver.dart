import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';

class ViewApprovalAttendanceDriver extends StatefulWidget {
  const ViewApprovalAttendanceDriver({Key? key}) : super(key: key);

  @override
  State<ViewApprovalAttendanceDriver> createState() =>
      _ViewApprovalAttendanceDriverState();
}

class _ViewApprovalAttendanceDriverState
    extends State<ViewApprovalAttendanceDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Soft Orange Pastel Theme Tokens
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color shadowColor = Color(0x20FF8C69);

  bool _isLoading = true;
  bool _hasAccess = false;
  String _username = '';

  List<dynamic> _allData = [];
  Map<String, dynamic> _summary = {
    'pending': 0,
    'approved': 0,
    'rejected': 0,
    'total': 0,
  };

  String _selectedStatus = 'PENDING'; // PENDING, APPROVED, REJECTED, ALL
  String _selectedTipe = 'ALL'; // ALL, SAKIT, IZIN
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _checkAccessAndLoad();
  }

  @override
  void dispose() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _checkAksesOp() {
    return globals.akses_pages.any((x) => x == 'OP');
  }

  Future<void> _checkAccessAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _username = (prefs.getString('username') ?? '').trim();
    final aksesList = prefs.getStringList('akses_pages') ?? [];
    if (globals.akses_pages.isEmpty) {
      globals.akses_pages = aksesList;
    }

    final bool isOpOrAdmin =
        _username.toUpperCase() == 'ADMIN' || _checkAksesOp();

    if (!isOpOrAdmin) {
      setState(() {
        _hasAccess = false;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAccessDeniedDialog();
      });
      return;
    }

    setState(() {
      _hasAccess = true;
    });

    await _fetchData();
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.gpp_bad, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'Akses Ditolak',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Halaman Persetujuan Absensi Driver hanya dapat diakses oleh OP dan ADMIN.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String url =
          '${GlobalData.baseUrl}api/absensi/list_approval_driver_attendance.jsp'
          '?status=$_selectedStatus&tipe=$_selectedTipe&search=${Uri.encodeComponent(_searchQuery)}';

      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map &&
            (decoded['status_code'] == 200 ||
                decoded['status_code'] == '200')) {
          if (mounted) {
            setState(() {
              _allData = decoded['data'] ?? [];
              if (decoded['summary'] is Map) {
                _summary = Map<String, dynamic>.from(decoded['summary']);
              }
              _isLoading = false;
            });
          }
        } else {
          _showError(decoded['message'] ?? 'Gagal mengambil data persetujuan');
        }
      } else {
        _showError('Server error (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error _fetchData: $e');
      _showError('Gagal memuat data persetujuan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = value.trim();
      });
      _fetchData();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    alert(context, 0, msg, "error");
  }

  Future<void> _processApproval(
      Map<String, dynamic> item, String action) async {
    final String id = item['id']?.toString() ?? '';
    final String drvname = item['drvname']?.toString() ?? item['drvid'] ?? '';
    final String actionText = action == 'APPROVED' ? 'menyetujui' : 'menolak';

    EasyLoading.show(status: 'Memproses...');
    try {
      final String url =
          '${GlobalData.baseUrl}api/absensi/approve_driver_attendance.jsp';

      final response = await http.post(Uri.parse(url), body: {
        'id_access': id,
        'action': action,
        'userid': _username.isNotEmpty ? _username : 'ADMIN',
      }).timeout(const Duration(seconds: 15));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map &&
            (decoded['status_code'] == 200 ||
                decoded['status_code'] == '200')) {
          alert(context, 1,
              'Berhasil $actionText pengajuan driver $drvname', 'success');
          _fetchData();
        } else {
          alert(context, 0, decoded['message'] ?? 'Gagal memproses', 'error');
        }
      } else {
        alert(context, 0, 'Server error (${response.statusCode})', 'error');
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(context, 0, 'Terjadi kesalahan: $e', 'error');
    }
  }

  void _confirmAction(Map<String, dynamic> item, String action) {
    final bool isApprove = action == 'APPROVED';
    final String drvname = item['drvname']?.toString() ?? item['drvid'] ?? '';
    final String tipe = item['tipe']?.toString() ?? '';
    final String logdate = item['logdate']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.highlight_off,
              color: isApprove ? Colors.green : Colors.red,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Setujui Pengajuan' : 'Tolak Pengajuan',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin ${isApprove ? "MENYETUJUI" : "MENOLAK"} pengajuan berikut?',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x59FFB347)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver: $drvname',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Tipe: $tipe  |  Tanggal: $logdate',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _processApproval(item, action);
            },
            child: Text(
              isApprove ? 'Ya, Setujui' : 'Ya, Tolak',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuratDokterDialog(String photoName, String drvname) {
    final String photoUrl =
        '${GlobalData.baseUrlOri}uploads/surat_dokter/$photoName';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined,
                      color: primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Surat Dokter - $drvname',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkOrange,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                          color: primaryOrange),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.broken_image_outlined,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Gagal memuat gambar surat dokter',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child:
                    const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAccess) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          title: const Text('Persetujuan Absensi Driver'),
        ),
        body: const Center(child: Text('Memeriksa akses...')),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Persetujuan Absen Driver',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Summary Card
          _buildSummaryCard(),

          // 2. Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari Nama Driver, DRVID, Catatan...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: primaryOrange, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryOrange, width: 1.5),
                ),
              ),
            ),
          ),

          // 3. Status Filter Chips
          _buildStatusFilterChips(),

          // 4. List Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryOrange))
                : _allData.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: _allData.length,
                          itemBuilder: (ctx, idx) =>
                              _buildApprovalCard(_allData[idx]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final int pending = _summary['pending'] ?? 0;
    final int approved = _summary['approved'] ?? 0;
    final int rejected = _summary['rejected'] ?? 0;
    final int total = _summary['total'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryOrange, darkOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_ind,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persetujuan Sakit & Izin Driver',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$total Total Pengajuan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$pending Menunggu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryPill('Pending', pending, Colors.amberAccent),
              _buildSummaryPill('Disetujui', approved, Colors.lightGreenAccent),
              _buildSummaryPill('Ditolak', rejected, Colors.redAccent.shade100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterChips() {
    final statusList = [
      {'key': 'PENDING', 'label': 'Menunggu'},
      {'key': 'APPROVED', 'label': 'Disetujui'},
      {'key': 'REJECTED', 'label': 'Ditolak'},
      {'key': 'ALL', 'label': 'Semua'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: statusList.map((st) {
          final isSelected = _selectedStatus == st['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                st['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryOrange,
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? primaryOrange : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = st['key']!;
                  });
                  _fetchData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    final String drvid = item['drvid']?.toString() ?? '';
    final String drvname = item['drvname']?.toString() ?? drvid;
    final String tipe = item['tipe']?.toString() ?? '-';
    final String logdate = item['logdate']?.toString() ?? '';
    final String logtime = item['logtime']?.toString() ?? '';
    final String note = item['note']?.toString() ?? '-';
    final String status = item['status']?.toString() ?? 'PENDING';
    final String photoName = item['photo_name']?.toString() ?? '';
    final String updatedUser = item['updated_user']?.toString() ?? '';
    final String updatedDt = item['updated_datetime']?.toString() ?? '';

    final bool isPending = status == 'PENDING';
    final bool isSakit = tipe == 'SAKIT';

    Color statusColor;
    String statusLabel;
    if (status == 'APPROVED') {
      statusColor = Colors.green;
      statusLabel = 'DISETUJUI';
    } else if (status == 'REJECTED') {
      statusColor = Colors.red;
      statusLabel = 'DITOLAK';
    } else {
      statusColor = Colors.orange.shade700;
      statusLabel = 'MENUNGGU';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? const Color(0x73FFB347)
              : Colors.grey.shade200,
          width: isPending ? 1.4 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isSakit
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  child: Icon(
                    isSakit
                        ? Icons.medical_services_outlined
                        : Icons.event_note_outlined,
                    color: isSakit ? Colors.red.shade700 : Colors.blue.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drvname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        drvid,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildRow('Jenis Absensi', tipe, isBadge: true, isSakit: isSakit),
                _buildRow('Tanggal & Jam', '$logdate  ${logtime.isNotEmpty ? "($logtime)" : ""}'),
                _buildRow('Catatan', note.isNotEmpty ? note : '-'),
                if (!isPending && updatedUser.isNotEmpty)
                  _buildRow('Diproses Oleh', '$updatedUser ($updatedDt)'),

                // Surat Dokter Button if present
                if (photoName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showSuratDokterDialog(photoName, drvname),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0ED),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.photo_outlined,
                              size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lampiran Surat Dokter: $photoName',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.open_in_new,
                              size: 16, color: Colors.red.shade700),
                        ],
                      ),
                    ),
                  ),
                ],

                // Action Buttons for PENDING
                if (isPending) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          label: const Text('Tolak',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _confirmAction(item, 'REJECTED'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: const Text('Setujui',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _confirmAction(item, 'APPROVED'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBadge = false, bool isSakit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isBadge
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSakit
                              ? Colors.red.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSakit
                                ? Colors.red.shade300
                                : Colors.blue.shade300,
                          ),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSakit
                                ? Colors.red.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 48, color: primaryOrange),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tidak Ada Pengajuan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Belum ada data absensi driver untuk filter status yang dipilih.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              label: const Text('Segarkan', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _fetchData,
            ),
          ],
        ),
      ),
    );
  }
}
