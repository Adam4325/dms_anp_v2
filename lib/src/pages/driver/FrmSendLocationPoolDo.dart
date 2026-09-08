import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/pages/driver/ViewMapTransitDo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FrmSendLocationPoolDo extends StatefulWidget {
  final bool isCsAdmin;
  final List<dynamic>? doList;
  final String? initialDoNumber;

  const FrmSendLocationPoolDo({
    Key? key,
    this.isCsAdmin = false,
    this.doList,
    this.initialDoNumber,
  }) : super(key: key);

  @override
  _FrmSendLocationPoolDoState createState() => _FrmSendLocationPoolDoState();
}

class _FrmSendLocationPoolDoState extends State<FrmSendLocationPoolDo>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Session user
  String _drvid = "";
  String _username = "";
  bool _isCsAdminUser = false;

  // DO List from Dashboard / API
  List<dynamic> _activeDoList = [];
  String? _selectedDoNumber;
  bool _isLoadingDoList = false;
  bool _isManualDoInput = false;

  // Form controllers (Kirim Lokasi)
  final TextEditingController _wonumberController = TextEditingController();
  final TextEditingController _namaPoolController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Position? _currentPosition;
  bool _isLocating = false;
  bool _isFetchingAddress = false;

  // List data
  List<Map<String, dynamic>> _listRequests = [];
  bool _isLoadingList = false;
  String _searchKeyword = "";
  String _statusFilter = "approved"; // CS & ADMIN default approved
  final TextEditingController _searchController = TextEditingController();

  // Non-Tera Soft Pastel Theme
  final Color primaryOrange = const Color(0xFFFF8C69);
  final Color lightOrange = const Color(0xFFFFF4E6);
  final Color accentOrange = const Color(0xFFFFB347);
  final Color darkOrange = const Color(0xFFE07B39);
  final Color backgroundColor = const Color(0xFFFFFAF5);
  final Color cardColor = const Color(0xFFFFF8F0);
  final Color shadowColor = const Color(0x20FF8C69);

  @override
  void initState() {
    super.initState();
    _isCsAdminUser = widget.isCsAdmin;
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialDoNumber != null && widget.initialDoNumber!.trim().isNotEmpty) {
      _wonumberController.text = widget.initialDoNumber!.trim();
      _selectedDoNumber = widget.initialDoNumber!.trim();
    }
    _initData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wonumberController.dispose();
    _namaPoolController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _drvid = prefs.getString("drvid") ?? "";
      _username = prefs.getString("username") ?? "";

      // Otomatis deteksi akses CS/Admin jika tidak dioper secara eksplisit
      if (!_isCsAdminUser) {
        final accessList = prefs.getStringList("akses_pages") ?? [];
        _isCsAdminUser = _username.toUpperCase() == "ADMIN" ||
            accessList.contains("CS") ||
            accessList.contains("OP");
      }
      if (_isCsAdminUser) {
        _statusFilter = "approved";
      }
    });

    if (!_isCsAdminUser) {
      // Driver: hanya Send Location
      if (widget.doList != null && widget.doList!.isNotEmpty) {
        _activeDoList = List.from(widget.doList!);
        _selectActiveDoDefault();
      } else {
        _fetchActiveDoList();
      }
      _getCurrentLocation();
    } else {
      // ADMIN & CS: hanya lihat list & maps
      _fetchListRequests();
    }
  }

  void _selectActiveDoDefault() {
    if (_activeDoList.isEmpty) return;
    // Jika sudah ada initialDoNumber, cari yang cocok
    if (_selectedDoNumber != null && _selectedDoNumber!.isNotEmpty) {
      for (final item in _activeDoList) {
        final doNum = (item['do_number'] ?? '').toString().trim();
        if (doNum == _selectedDoNumber) {
          _applySelectedDoItem(item);
          return;
        }
      }
    }
    // Default ambil item DO pertama
    for (final item in _activeDoList) {
      final doNum = (item['do_number'] ?? '').toString().trim();
      if (doNum.isNotEmpty) {
        _applySelectedDoItem(item);
        break;
      }
    }
  }

  void _applySelectedDoItem(dynamic item) {
    final doNum = (item['do_number'] ?? '').toString().trim();
    final dest = (item['destination'] ?? '').toString().trim();
    setState(() {
      _selectedDoNumber = doNum;
      _wonumberController.text = doNum;
      if (_namaPoolController.text.isEmpty && dest.isNotEmpty) {
        _namaPoolController.text = dest;
      }
    });
  }

  Future<void> _fetchActiveDoList() async {
    setState(() => _isLoadingDoList = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String drvid = prefs.getString("drvid") ?? "";
      final String vhcid = prefs.getString("vhcid") ?? "";
      final String loginType = prefs.getString("login_type") ?? "";
      final String url = loginType == "MIXER"
          ? "${GlobalData.baseUrlProd}api/do_mixer/list_do_driver_mixer.jsp?method=lookup-list-do-driver-v1&vhcid=$vhcid&drvid=$drvid"
          : "${GlobalData.baseUrlProd}api/do/list_do_driver.jsp?method=lookup-list-do-driver-v1&vhcid=$vhcid&drvid=$drvid";

      final response = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List && mounted) {
          setState(() {
            _activeDoList = decoded;
            _selectActiveDoDefault();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching DO list in FrmSendLocationPoolDo: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDoList = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocating = false;
        });
        _fetchAddressFromOsm(position.latitude, position.longitude);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _fetchAddressFromOsm(double lat, double lon) async {
    setState(() {
      _isFetchingAddress = true;
    });
    try {
      final String url = "https://nominatim.openstreetmap.org/reverse"
          "?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1";
      final resp = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'DMS_ANP/1.0 (ANP Driver Management System)',
      }).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final dynamic data = json.decode(resp.body);
        if (data is Map && data['display_name'] != null) {
          final String addr = data['display_name'].toString();
          if (mounted && addr.isNotEmpty) {
            setState(() {
              _addressController.text = addr;
              _isFetchingAddress = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      print("OSM address error: $e");
    }
    if (mounted) {
      setState(() {
        _isFetchingAddress = false;
      });
    }
  }

  InputDecoration softDecoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
    );
  }

  ButtonStyle ntBtnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _fetchListRequests() async {
    setState(() {
      _isLoadingList = true;
    });

    try {
      final String baseUrl =
          "${GlobalData.baseUrlOri}mobile/api/driver/send_location_pool_do.jsp";
      final params = <String, String>{
        "method": "list_location",
      };

      if (_isCsAdminUser) {
        params["is_admin_cs"] = "1";
        if (_statusFilter != "all") {
          params["status"] = _statusFilter;
        }
      } else {
        params["drvid"] = _drvid;
        // Driver lihat list yang diajukan (bisa filter approved jika diinginkan)
        if (_statusFilter == "approved") {
          params["only_approved"] = "1";
        }
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: {"Accept": "application/json"}).timeout(
              const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> rawList = [];
        if (decoded is Map && decoded['data'] is List) {
          rawList = decoded['data'];
        } else if (decoded is List) {
          rawList = decoded;
        }

        final List<Map<String, dynamic>> items = [];
        for (var item in rawList) {
          if (item is Map) {
            items.add(Map<String, dynamic>.from(item));
          }
        }

        if (mounted) {
          setState(() {
            _listRequests = items;
            _isLoadingList = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingList = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingList = false;
        });
      }
    }
  }

  Future<void> _submitSendLocation() async {
    final wonumber = _wonumberController.text.trim();
    final namaPool = _namaPoolController.text.trim();

    if (wonumber.isEmpty) {
      alert(context, 2, "No. DO (wonumber) wajib diisi!", "warning");
      return;
    }
    if (namaPool.isEmpty) {
      alert(context, 2, "Nama Pool / Lokasi Transit wajib diisi!", "warning");
      return;
    }
    if (_currentPosition == null) {
      alert(context, 0, "GPS belum terdeteksi. Silakan Refresh GPS.", "error");
      await _getCurrentLocation();
      return;
    }

    EasyLoading.show(status: "Mengirim Lokasi Transit DO...");
    try {
      final String baseUrl =
          "${GlobalData.baseUrlOri}mobile/api/driver/send_location_pool_do.jsp";
      final params = <String, String>{
        "method": "send_location",
        "wonumber": wonumber,
        "drvid": _drvid,
        "nama_pool": namaPool,
        "lat": _currentPosition!.latitude.toString(),
        "lon": _currentPosition!.longitude.toString(),
        "address": _addressController.text.trim(),
        "created_user": _username.isNotEmpty ? _username : _drvid,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: {"Accept": "application/json"}).timeout(
              const Duration(seconds: 15));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (_) {}

      final int statusCode = decoded is Map && decoded['status_code'] != null
          ? int.tryParse(decoded['status_code'].toString()) ?? response.statusCode
          : response.statusCode;

      final String message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : (response.statusCode == 200
              ? "Lokasi DO berhasil dikirim"
              : "Gagal mengirim data (${response.statusCode})");

      if (response.statusCode == 200) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text("Berhasil Dikirim!"),
                ],
              ),
              content: const Text(
                "Lokasi transit DO Anda berhasil dikirim.\n\nMenunggu approval CS/ADMIN sebelum dapat digunakan untuk absensi geofence.",
              ),
              actions: [
                ElevatedButton(
                  style: ntBtnStyle(primaryOrange),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _goBack();
                  },
                  child: const Text("Kembali ke Dashboard"),
                ),
              ],
            ),
          );
        }
      } else {
        alert(context, 0, message, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(context, 0, "Terjadi kesalahan: $e", "error");
    }
  }

  Future<void> _approveLocation(int id, String wonumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        title: Text(
          "Konfirmasi Approval",
          style: TextStyle(color: darkOrange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin menyetujui lokasi transit untuk DO $wonumber?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ntBtnStyle(primaryOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Setujui"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: "Memproses Approval...");
    try {
      final String baseUrl =
          "${GlobalData.baseUrlOri}mobile/api/driver/send_location_pool_do.jsp";
      final params = <String, String>{
        "method": "approve_location",
        "id": id.toString(),
        "updated_user": _username.isNotEmpty ? _username : "ADMIN",
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: {"Accept": "application/json"}).timeout(
              const Duration(seconds: 15));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      if (response.statusCode == 200) {
        if (mounted) {
          alert(context, 1, "Lokasi transit DO berhasil disetujui!", "success");
          _fetchListRequests();
        }
      } else {
        alert(context, 0, "Gagal menyetujui data (${response.statusCode})",
            "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(context, 0, "Terjadi kesalahan: $e", "error");
    }
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        key: globalScaffoldKey,
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isCsAdminUser
                  ? _buildListRequestsTab()
                  : _buildSendLocationTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: lightOrange,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: darkOrange, size: 20),
                onPressed: _goBack,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCsAdminUser
                          ? "Daftar Lokasi Transit DO"
                          : "Send Location Transit DO",
                      style: TextStyle(
                        color: darkOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _isCsAdminUser
                          ? "Pemeriksaan Lokasi & View Maps (${_username.isNotEmpty ? _username : 'CS/ADMIN'})"
                          : "Driver (${_drvid.isNotEmpty ? _drvid : 'Driver'})",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCsAdminUser)
                IconButton(
                  tooltip: "Refresh Data",
                  icon: Icon(Icons.refresh, color: darkOrange),
                  onPressed: _fetchListRequests,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoSelector() {
    dynamic selectedDoItem;
    if (_selectedDoNumber != null && _selectedDoNumber!.isNotEmpty) {
      for (final item in _activeDoList) {
        if ((item['do_number'] ?? '').toString().trim() == _selectedDoNumber) {
          selectedDoItem = item;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nomor DO / Work Order (wonumber)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (_activeDoList.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    _isManualDoInput = !_isManualDoInput;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        _isManualDoInput ? Icons.list_alt : Icons.edit,
                        size: 14,
                        color: darkOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isManualDoInput ? "Pilih dari Jadwal DO" : "Ketik Manual",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: darkOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        if (!_isManualDoInput && _activeDoList.isNotEmpty) ...[
          // Dropdown pemilih DO dari Jadwal
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedDoNumber != null &&
                        _activeDoList.any((it) =>
                            (it['do_number'] ?? '').toString().trim() ==
                            _selectedDoNumber)
                    ? _selectedDoNumber
                    : null,
                hint: Text(
                  "Pilih Nomor DO dari Jadwal",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: primaryOrange),
                items: [
                  ..._activeDoList.map((item) {
                    final String doNum =
                        (item['do_number'] ?? '').toString().trim();
                    final String dest =
                        (item['destination'] ?? '').toString().trim();
                    return DropdownMenuItem<String>(
                      value: doNum,
                      child: Text(
                        dest.isNotEmpty ? "$doNum ($dest)" : doNum,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  const DropdownMenuItem<String>(
                    value: "__MANUAL__",
                    child: Text(
                      "✏️ Input Nomor DO Lainnya (Manual)",
                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val == "__MANUAL__") {
                    setState(() {
                      _isManualDoInput = true;
                    });
                  } else if (val != null) {
                    for (final item in _activeDoList) {
                      if ((item['do_number'] ?? '').toString().trim() == val) {
                        _applySelectedDoItem(item);
                        break;
                      }
                    }
                  }
                },
              ),
            ),
          ),

          // Preview Card Detail DO terpilih (mengacu ViewDashboard.dart baris 3467)
          if (selectedDoItem != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentOrange.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          selectedDoItem['do_number'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        selectedDoItem['tgl_do'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if ((selectedDoItem['origin'] ?? '').toString().isNotEmpty)
                    Text(
                      'From: ${selectedDoItem['origin']}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                  if ((selectedDoItem['destination'] ?? '')
                      .toString()
                      .isNotEmpty)
                    Text(
                      'To: ${selectedDoItem['destination']}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          ],
        ] else ...[
          // Manual input TextField
          TextField(
            controller: _wonumberController,
            onChanged: (val) {
              setState(() {
                _selectedDoNumber = val.trim();
              });
            },
            decoration: softDecoration(
              hint: "Contoh: DO-123456 / WO-2026-001",
              prefixIcon:
                  Icon(Icons.receipt, color: primaryOrange, size: 20),
            ),
          ),
          if (_isLoadingDoList)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Memuat daftar DO...",
                style: TextStyle(fontSize: 11, color: primaryOrange),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSendLocationTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _getCurrentLocation();
      },
      color: primaryOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentOrange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: darkOrange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Kirimkan lokasi terkini Anda bersama nomor DO saat berada di luar geofence pool resmi. Setelah disetujui CS/ADMIN, Anda dapat melakukan absensi di lokasi ini.",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Form Koordinat Transit",
                    style: TextStyle(
                      color: darkOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // GPS Coordinates Box
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.my_location,
                                    color: primaryOrange, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Lokasi GPS Saat Ini",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _isLocating ? null : _getCurrentLocation,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: _isLocating
                                    ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  primaryOrange),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Icon(Icons.refresh,
                                              size: 14, color: darkOrange),
                                          const SizedBox(width: 2),
                                          Text(
                                            "Refresh",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: darkOrange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_currentPosition != null) ...[
                          Text(
                            "Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ] else ...[
                          Text(
                            _isLocating
                                ? "Sedang mengambil koordinat GPS..."
                                : "GPS belum terdeteksi. Silakan klik Refresh.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input No. DO / wonumber dari Jadwal (data_list_do)
                  _buildDoSelector(),
                  const SizedBox(height: 14),

                  // Input Nama Pool / Lokasi
                  Text(
                    "Nama Pool / Keterangan Lokasi",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _namaPoolController,
                    decoration: softDecoration(
                      hint: "Contoh: Pool Transit Cilegon / Proyek X",
                      prefixIcon: Icon(Icons.business,
                          color: primaryOrange, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Alamat Terdeteksi (OpenStreetMap)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Alamat Lokasi (OpenStreetMap)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_isFetchingAddress)
                        Text(
                          "Mencari alamat...",
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: primaryOrange,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: softDecoration(
                      hint: "Alamat otomatis dari OSM (bisa disesuaikan)...",
                      prefixIcon: Icon(Icons.location_city,
                          color: primaryOrange, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ntBtnStyle(primaryOrange),
                      onPressed: _submitSendLocation,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text(
                        "Kirim Lokasi Transit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListRequestsTab() {
    // Filter by search keyword
    final filtered = _listRequests.where((item) {
      final wonbr = (item['wonumber'] ?? '').toString().toLowerCase();
      final pool = (item['nama_pool'] ?? '').toString().toLowerCase();
      final drv = (item['drvid'] ?? '').toString().toLowerCase();
      final kw = _searchKeyword.toLowerCase();
      return wonbr.contains(kw) || pool.contains(kw) || drv.contains(kw);
    }).toList();

    return Column(
      children: [
        // Search & Filter Toolbar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchKeyword = val;
                  });
                },
                decoration: softDecoration(
                  hint: "Cari No. DO, Driver, atau Nama Pool...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchKeyword.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchKeyword = "";
                            });
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Semua", "all"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Menunggu Approval", "pending"),
                    const SizedBox(width: 8),
                    _buildFilterChip("Disetujui", "approved"),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchListRequests,
            color: primaryOrange,
            child: _isLoadingList
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(primaryOrange),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada data permohonan lokasi transit",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(filtered[index]);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      selected: isSelected,
      selectedColor: primaryOrange,
      backgroundColor: Colors.grey.shade100,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _statusFilter = value;
          });
          _fetchListRequests();
        }
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> item) {
    final int id = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
    final String wonumber = item['wonumber']?.toString() ?? '';
    final String drvid = item['drvid']?.toString() ?? '';
    final String namaPool = item['nama_pool']?.toString() ?? '';
    final String lat = item['lat']?.toString() ?? '';
    final String lon = item['lon']?.toString() ?? '';
    final int isApproved =
        int.tryParse(item['is_approved']?.toString() ?? '0') ?? 0;
    final String createdDt = item['created_datetime']?.toString() ?? '';
    final String updatedUser = item['updated_user']?.toString() ?? '';
    final String address = item['address']?.toString() ?? '';

    final bool approved = isApproved == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: approved
              ? Colors.green.shade200
              : accentOrange.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: DO Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  wonumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkOrange,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: approved ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        approved ? Colors.green.shade300 : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      approved ? Icons.check_circle : Icons.hourglass_top,
                      size: 13,
                      color: approved
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      approved ? "Disetujui" : "Menunggu Approval",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: approved
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Detail Driver & Pool
          if (drvid.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.person_pin, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  "Driver ID: $drvid",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  namaPool.isNotEmpty ? namaPool : "Lokasi Transit",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.navigation, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                "Lat: $lat | Lon: $lon",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (createdDt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  "Tgl: $createdDt",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
          if (address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.home_work_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],

          // Footer info / Action Button
          // Action Buttons: View Lokasi di Maps & Approve
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewMapTransitDo(
                          itemTransit: item,
                          isCsAdmin: _isCsAdminUser,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text(
                    "View Lokasi di Maps",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!approved && _isCsAdminUser) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ntBtnStyle(Colors.green.shade600),
                  onPressed: () => _approveLocation(id, wonumber),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text(
                    "Approve",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          if (approved && updatedUser.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.verified_user, size: 13, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  "Disetujui oleh: $updatedUser",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
