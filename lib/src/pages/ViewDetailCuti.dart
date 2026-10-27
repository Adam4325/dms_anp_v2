import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FrmAttendanceAdvance.dart';

class ViewDetailCuti extends StatefulWidget {
  const ViewDetailCuti({Key? key}) : super(key: key);

  @override
  State<ViewDetailCuti> createState() => _ViewDetailCutiState();
}

class _ViewDetailCutiState extends State<ViewDetailCuti> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Soft Orange Pastel Theme Tokens (form-redesign-template.md)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color shadowColor = Color(0x20FF8C69);

  List<Map<String, dynamic>> _dataList = [];
  List<Map<String, dynamic>> _filteredDataList = [];
  List<Map<String, dynamic>> _dataListDetail = [];

  // Map: id_access -> 'approved' or 'rejected'
  final Map<String, String> _decisions = {};

  bool _isLoading = true;
  bool _isDetail = true; // true = List Karyawan, false = Detail Tanggal
  String _employeeid = '';
  String _kryname = '';
  String _cabang = '';
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Pastikan tidak ada overlay loading EasyLoading yang tertinggal saat membuka halaman
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _fetchListKaryawan(true);
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

  void _goBack() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (!_isDetail) {
      setState(() {
        _isDetail = true;
        _employeeid = '';
        _kryname = '';
        _cabang = '';
        _decisions.clear();
      });
      _fetchListKaryawan(false);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FrmAttendanceAdvance()),
      );
    }
  }

  Future<void> _fetchListKaryawan(bool showLoading) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final String url =
          "${GlobalData.baseUrl}api/absensi/get_list_cuti.jsp?method=list-cuti-absensi&search=";
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json"
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final list = decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          if (mounted) {
            setState(() {
              _dataList = list;
              _applySearchFilter();
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _dataList = [];
            _filteredDataList = [];
            _isLoading = false;
          });
        }
      } else {
        _showError("Gagal load data list cuti (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error _fetchListKaryawan: $e");
      _showError("Gagal memuat list cuti: $e");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDetailCuti(String kryId, String kryName, String cabang) async {
    EasyLoading.show(status: 'Memuat detail...');
    try {
      final String url =
          "${GlobalData.baseUrl}api/absensi/get_list_cuti.jsp?method=list-cuti-absensi-detail&search=$kryId";
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json"
      }).timeout(const Duration(seconds: 15));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          final list = decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          setState(() {
            _employeeid = kryId;
            _kryname = kryName;
            _cabang = cabang;
            _dataListDetail = list;
            _decisions.clear();
            // Default semua ke approved untuk kemudahan review
            for (var item in list) {
              final idAcc = item['id_access']?.toString() ?? '';
              if (idAcc.isNotEmpty) {
                _decisions[idAcc] = 'approved';
              }
            }
            _isDetail = false;
          });
        } else {
          _showError("Data detail cuti tidak ditemukan");
        }
      } else {
        _showError("Gagal memuat detail (${response.statusCode})");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      _showError("Gagal memuat detail: $e");
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredDataList = List.from(_dataList);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredDataList = _dataList.where((item) {
        final nama = (item['nama'] ?? '').toString().toLowerCase();
        final kryid = (item['kryid'] ?? '').toString().toLowerCase();
        final cabang = (item['cabang'] ?? '').toString().toLowerCase();
        return nama.contains(q) || kryid.contains(q) || cabang.contains(q);
      }).toList();
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = val.trim();
        _applySearchFilter();
      });
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    alert(context, 0, msg, "error");
  }

  void _setAllDecisions(String decision) {
    setState(() {
      for (var item in _dataListDetail) {
        final idAcc = item['id_access']?.toString() ?? '';
        if (idAcc.isNotEmpty) {
          _decisions[idAcc] = decision;
        }
      }
    });
  }

  Future<void> _submitApproval() async {
    // Validasi apakah semua tanggal sudah dipilih
    for (var item in _dataListDetail) {
      final idAcc = item['id_access']?.toString() ?? '';
      if (!_decisions.containsKey(idAcc) || _decisions[idAcc]!.isEmpty) {
        alert(context, 0, "Semua tanggal cuti wajib ditentukan statusnya", "error");
        return;
      }
    }

    final List<String> listPayload = [];
    _decisions.forEach((idAcc, dec) {
      listPayload.add("$dec$idAcc");
    });

    if (listPayload.isEmpty) {
      alert(context, 0, "Tidak ada data yang dipilih", "error");
      return;
    }

    // Dialog Konfirmasi
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: primaryOrange, size: 26),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Persetujuan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Simpan keputusan untuk ${_decisions.length} tanggal pengajuan cuti $_kryname?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _executeSubmit(listPayload);
            },
            child: const Text('Ya, Simpan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSubmit(List<String> listPayload) async {
    EasyLoading.show(status: 'Menyimpan persetujuan...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userid = prefs.getString("username") ?? "ADMIN";
      final strIdAccess = listPayload.join(",");

      final uri = Uri.parse("${GlobalData.baseUrl}api/absensi/approved_or_rejected.jsp").replace(
        queryParameters: {
          'method': 'approved-cuti-v1',
          'employeeid': _employeeid,
          'userid': userid,
          'id_access': strIdAccess,
        },
      );

      final response = await http.get(uri, headers: {
        "Accept": "application/json"
      }).timeout(const Duration(seconds: 15));

      debugPrint("[ViewDetailCuti] Submit URI: $uri");
      debugPrint("[ViewDetailCuti] Response (${response.statusCode}): ${response.body}");

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final dynamic dec = jsonDecode(response.body);
        final int statusCode = dec["status_code"] is int
            ? dec["status_code"]
            : int.tryParse(dec["status_code"]?.toString() ?? "100") ?? 100;
        final String message = dec["message"] ?? "Proses selesai";

        if (statusCode == 200) {
          alert(context, 1, message, "success");
          setState(() {
            _isDetail = true;
            _employeeid = '';
            _kryname = '';
            _cabang = '';
            _decisions.clear();
          });
          _fetchListKaryawan(true);
        } else {
          alert(context, 0, message, "error");
        }
      } else {
        alert(context, 0, "Gagal submit persetujuan (${response.statusCode})", "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(context, 0, "Terjadi kesalahan: $e", "error");
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          centerTitle: true,
          title: Text(
            _isDetail ? 'Persetujuan Cuti Karyawan' : 'Detail: $_kryname',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Segarkan',
              onPressed: () {
                if (_isDetail) {
                  _fetchListKaryawan(true);
                } else {
                  _fetchDetailCuti(_employeeid, _kryname, _cabang);
                }
              },
            ),
          ],
        ),
        body: _isDetail ? _buildListKaryawanTab() : _buildDetailDatesTab(),
        bottomNavigationBar: !_isDetail ? _buildDetailBottomBar() : null,
      ),
    );
  }

  // ================= VIEW 1: LIST KARYAWAN PENGAJUAN CUTI =================
  Widget _buildListKaryawanTab() {
    return Column(
      children: [
        // Summary Card
        _buildSummaryHeader(),

        // Search Field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari Nama, KRYID, atau Cabang...',
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

        // List View
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryOrange))
              : _filteredDataList.isEmpty
                  ? _buildEmptyState("Tidak ada permohonan cuti karyawan yang menunggu persetujuan.")
                  : RefreshIndicator(
                      color: primaryOrange,
                      onRefresh: () => _fetchListKaryawan(false),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: _filteredDataList.length,
                        itemBuilder: (ctx, idx) =>
                            _buildKaryawanCard(_filteredDataList[idx]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pending_actions, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antrean Persetujuan Cuti',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_dataList.length} Karyawan Menunggu',
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'PENDING',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaryawanCard(Map<String, dynamic> item) {
    final String kryid = item['kryid']?.toString() ?? '';
    final String nama = item['nama']?.toString() ?? kryid;
    final String startDate = item['start_date']?.toString() ?? '';
    final String endDate = item['end_date']?.toString() ?? '';
    final String total = item['total']?.toString() ?? '1';
    final String cabang = item['cabang']?.toString() ?? '-';
    final String lastcuti = item['lastcuti']?.toString() ?? '-';
    final String nextcuti = item['nextcuti']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x73FFB347), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                  backgroundColor: const Color(0xFFFFD1B3),
                  child: Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : 'K',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        kryid,
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
                    color: primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryOrange, width: 1),
                  ),
                  child: Text(
                    '$total Hari',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow('Periode Cuti', '$startDate s/d $endDate'),
                _buildInfoRow('Cabang', cabang),
                _buildInfoRow('Last Cuti / Next Cuti', '$lastcuti  /  $nextcuti'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.rule_folder_outlined,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'Lihat Tanggal & Proses Approval',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _fetchDetailCuti(kryid, nama, cabang),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= VIEW 2: DETAIL TANGGAL CUTI PERSONAL =================
  Widget _buildDetailDatesTab() {
    return Column(
      children: [
        // Employee Summary Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightOrange,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x73FFB347)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin, color: primaryOrange, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _kryname,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$_employeeid • $_cabang',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_dataListDetail.length} Tanggal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: darkOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.done_all, size: 14, color: Colors.green),
                      label: const Text('Setujui Semua',
                          style: TextStyle(color: Colors.green, fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => _setAllDecisions('approved'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 14, color: Colors.red),
                      label: const Text('Tolak Semua',
                          style: TextStyle(color: Colors.red, fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => _setAllDecisions('rejected'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List Dates
        Expanded(
          child: _dataListDetail.isEmpty
              ? _buildEmptyState("Tidak ada tanggal cuti yang ditemukan.")
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: _dataListDetail.length,
                  itemBuilder: (ctx, idx) =>
                      _buildDateCard(_dataListDetail[idx]),
                ),
        ),
      ],
    );
  }

  Widget _buildDateCard(Map<String, dynamic> item) {
    final String idAccess = item['id_access']?.toString() ?? '';
    final String cutiDate = item['cuti_date']?.toString() ?? '';
    final String currentDecision = _decisions[idAccess] ?? 'approved';

    final bool isApproved = currentDecision == 'approved';
    final bool isRejected = currentDecision == 'rejected';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved
              ? Colors.green.shade200
              : Colors.red.shade200,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isApproved ? Colors.green.shade50 : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              size: 18,
              color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cutiDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'ID Access: $idAccess',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Toggle choices
          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _decisions[idAccess] = 'approved';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isApproved ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check,
                          size: 14,
                          color: isApproved ? Colors.white : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Setujui',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  setState(() {
                    _decisions[idAccess] = 'rejected';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRejected ? Colors.red : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRejected ? Colors.red : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.close,
                          size: 14,
                          color: isRejected ? Colors.white : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isRejected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  setState(() {
                    _isDetail = true;
                    _employeeid = '';
                    _kryname = '';
                    _decisions.clear();
                  });
                },
                child: const Text('Kembali',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, size: 18, color: Colors.white),
                label: const Text(
                  'Kirim Persetujuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _submitApproval,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
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
          const SizedBox(width: 8),
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

  Widget _buildEmptyState(String msg) {
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
              child: const Icon(Icons.beach_access_outlined,
                  size: 48, color: primaryOrange),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tidak Ada Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
