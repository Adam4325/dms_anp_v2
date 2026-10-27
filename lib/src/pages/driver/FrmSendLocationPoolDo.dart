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

  // Approved Transit Pools for reuse across drivers
  List<Map<String, dynamic>> _approvedPools = [];
  Map<String, dynamic>? _nearbyApprovedPool;
  Map<String, dynamic>? _selectedApprovedPool;
  bool _isLoadingApprovedPools = false;

  // List data
  List<Map<String, dynamic>> _listRequests = [];
  bool _isLoadingList = false;
  String _searchKeyword = "";
  String _statusFilter = "pending"; // Default Menunggu Approval
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
        _statusFilter = "pending";
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
        _fetchApprovedTransitPools(position.latitude, position.longitude);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _fetchApprovedTransitPools(double lat, double lon) async {
    setState(() => _isLoadingApprovedPools = true);
    try {
      final String baseUrl =
          "${GlobalData.baseUrlOri}mobile/api/driver/send_location_pool_do.jsp";
      final params = <String, String>{
        "method": "list_approved_transit",
        "drvid": _drvid,
        "lat": lat.toString(),
        "lon": lon.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: {"Accept": "application/json"}).timeout(
              const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> raw = [];
        if (decoded is Map && decoded['data'] is List) {
          raw = decoded['data'];
        } else if (decoded is List) {
          raw = decoded;
        }

        final List<Map<String, dynamic>> items = [];
        Map<String, dynamic>? nearest;
        double minDistance = double.infinity;

        for (var it in raw) {
          if (it is Map) {
            final m = Map<String, dynamic>.from(it);
            items.add(m);

            final dist =
                double.tryParse(m['distance_meters']?.toString() ?? '-1') ?? -1;
            if (dist >= 0 && dist <= 500 && dist < minDistance) {
              minDistance = dist;
              nearest = m;
            }
          }
        }

        if (mounted) {
          setState(() {
            _approvedPools = items;
            _nearbyApprovedPool = nearest;
            _isLoadingApprovedPools = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching approved pools: $e");
    } finally {
      if (mounted) setState(() => _isLoadingApprovedPools = false);
    }
  }

  void _applyApprovedPool(Map<String, dynamic> pool) {
    setState(() {
      _selectedApprovedPool = pool;
      _namaPoolController.text = (pool['nama_pool'] ?? '').toString();
      _addressController.text = (pool['address'] ?? '').toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Titik resmi '${pool['nama_pool']}' dipilih! No DO akan langsung aktif.",
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showApprovedPoolsPicker() {
    String search = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _approvedPools.where((p) {
              final name = (p['nama_pool'] ?? '').toString().toLowerCase();
              final addr = (p['address'] ?? '').toString().toLowerCase();
              final q = search.toLowerCase();
              return name.contains(q) || addr.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green.shade600, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Pilih Titik Transit yang Sudah Disetujui",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TextField(
                      decoration: softDecoration(
                        hint: "Cari nama pool atau alamat...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          search = val;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              _approvedPools.isEmpty
                                  ? "Belum ada titik transit yang disetujui"
                                  : "Tidak ada titik yang cocok dengan pencarian",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final p = filtered[idx];
                              final poolName = p['nama_pool'] ?? 'Transit';
                              final addr = p['address'] ?? '';
                              final distMeters = p['distance_meters'];
                              final isSelected = _selectedApprovedPool != null &&
                                  _selectedApprovedPool!['id'] == p['id'];

                              return ListTile(
                                tileColor: isSelected ? lightOrange : null,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryOrange.withOpacity(0.2)
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.place,
                                    color: isSelected ? primaryOrange : Colors.green.shade700,
                                    size: 22,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        poolName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? darkOrange : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    if (distMeters != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: accentOrange.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          distMeters < 1000
                                              ? "~${distMeters}m"
                                              : "~${(distMeters / 1000.0).toStringAsFixed(1)}km",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: darkOrange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  addr.isNotEmpty ? addr : "Koordinat: ${p['lat']}, ${p['lon']}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: primaryOrange)
                                    : const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _applyApprovedPool(p);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNearbyApprovedPoolBanner() {
    if (_nearbyApprovedPool == null && _selectedApprovedPool == null) {
      return const SizedBox.shrink();
    }

    final pool = _selectedApprovedPool ?? _nearbyApprovedPool!;
    final poolName = (pool['nama_pool'] ?? '').toString();
    final address = (pool['address'] ?? '').toString();
    final dist = pool['distance_meters'];
    final isSelected = _selectedApprovedPool != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? Colors.green.shade400 : Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSelected
                      ? "Titik Resmi Terpilih (Langsung Aktif)"
                      : "Titik Resmi Ditemukan di Sekitar Anda!",
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (dist != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    dist < 1000 ? "~${dist}m" : "~${(dist / 1000.0).toStringAsFixed(1)}km",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            poolName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (!isSelected)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _applyApprovedPool(pool),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      "Gunakan Titik Ini untuk DO Saya",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Titik aktif! Pilih No. DO di bawah lalu kirim.",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedApprovedPool = null;
                      _namaPoolController.clear();
                    });
                  },
                  child: Text(
                    "Batal",
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
            final m = Map<String, dynamic>.from(item);
            final statusStr = (m['status'] ?? '').toString().toUpperCase();
            final isAppr = (m['is_approved'] ?? '').toString();
            if (_statusFilter != 'cancel') {
              if (statusStr == 'CANCEL' ||
                  statusStr == 'CANCELLED' ||
                  isAppr == '2' ||
                  isAppr == '-1') {
                continue;
              }
            }
            items.add(m);
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

  Future<void> _showOverlapConflictDialog(
      Map<String, dynamic> conflict, String serverMsg) async {
    final String poolName = (conflict['nama_pool'] ?? 'Transit').toString();
    final String address = (conflict['address'] ?? '').toString();
    final String woRef = (conflict['wonumber'] ?? '').toString();
    final String drvRef = (conflict['drvid'] ?? '').toString();
    final num distMeters =
        num.tryParse(conflict['distance_meters']?.toString() ?? '0') ?? 0;
    final num existRadius =
        num.tryParse(conflict['existing_radius']?.toString() ?? '1000') ?? 1000;
    final String relation = (conflict['relation'] ?? '').toString();

    final bool isDiDalam = relation == "DI_DALAM" || distMeters <= existRadius;

    final String headline = isDiDalam
        ? "Koordinat di Dalam Geofence Lain"
        : "Radius Koordinat Beririsan (Overlap)";

    final String relationDesc = isDiDalam
        ? "Titik yang diajukan berjarak ${distMeters}m dari pusat '$poolName' (berada di dalam radius geofence ${existRadius}m)."
        : "Jarak antar titik adalah ${distMeters}m, sehingga radius geofence titik baru beririsan dengan radius geofence titik '$poolName'.";

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Icon(
                        Icons.not_listed_location_outlined,
                        color: Colors.red.shade700,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDiDalam
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDiDalam
                                  ? "DI DALAM GEOFENCE"
                                  : "RADIUS BERIRISAN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDiDalam
                                    ? Colors.red.shade800
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            headline,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  relationDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.place, color: darkOrange, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              poolName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: darkOrange,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              "Resmi",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Jarak ke Titik:",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          Text(
                            "$distMeters meter",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("DO Pembuat:",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          Text(
                            "$woRef ${drvRef.isNotEmpty ? '($drvRef)' : ''}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified,
                          size: 18, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Anda tidak perlu membuat titik baru! Cukup gunakan titik resmi '$poolName' ini. No DO Anda akan langsung aktif tanpa perlu menunggu approval baru.",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade900,
                              height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        "Gunakan Titik Ini & Kirim Sekarang",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _applyApprovedPool(conflict);
                        _submitSendLocation();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Batal / Ubah Posisi Koordinat",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

      if (_selectedApprovedPool != null && _selectedApprovedPool!['id'] != null) {
        params["reuse_transit_id"] = _selectedApprovedPool!['id'].toString();
      }

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

      final bool isAutoApproved = decoded is Map &&
          (decoded['is_auto_approved'] == true ||
              decoded['is_auto_approved']?.toString() == 'true');

      if (statusCode == 200) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isAutoApproved ? Icons.verified : Icons.check_circle,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(isAutoApproved ? "Langsung Disetujui!" : "Berhasil Dikirim!"),
                ],
              ),
              content: Text(
                isAutoApproved
                    ? "$message\n\nNomor DO Anda ($wonumber) telah aktif. Anda dapat langsung melakukan absensi di lokasi ini tanpa perlu menunggu persetujuan baru!"
                    : "Lokasi transit DO Anda berhasil dikirim.\n\nMenunggu approval CS/ADMIN sebelum dapat digunakan untuk absensi geofence.",
              ),
              actions: [
                ElevatedButton(
                  style: ntBtnStyle(isAutoApproved ? Colors.green.shade700 : primaryOrange),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _goBack();
                  },
                  child: Text(isAutoApproved
                      ? "Ke Dashboard / Absensi"
                      : "Kembali ke Dashboard"),
                ),
              ],
            ),
          );
        }
      } else if (statusCode == 409 ||
          (decoded is Map && decoded['error_type'] == 'OVERLAPPING_GEOFENCE')) {
        final conflictData = decoded is Map && decoded['conflict_data'] is Map
            ? Map<String, dynamic>.from(decoded['conflict_data'])
            : null;
        if (mounted && conflictData != null) {
          await _showOverlapConflictDialog(conflictData, message);
        } else {
          alert(context, 0, message, "error");
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
        dynamic decoded;
        try {
          decoded = json.decode(response.body);
        } catch (_) {}
        final String errMsg = decoded is Map && decoded['message'] != null
            ? decoded['message'].toString()
            : "Gagal menyetujui data (${response.statusCode})";
        alert(context, 0, errMsg, "error");
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      alert(context, 0, "Terjadi kesalahan: $e", "error");
    }
  }

  Future<void> _cancelLocation(int id, String wonumber) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 22),
            const SizedBox(width: 8),
            Text(
              "Batalkan Approval Lokasi",
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin membatalkan lokasi transit untuk DO $wonumber?\n\nData ini akan dipindahkan ke tab 'Dibatalkan' dan dinonaktifkan dari master geofence.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Tidak / Kembali",
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ntBtnStyle(Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: "Memproses Pembatalan...");
    try {
      final String baseUrl =
          "${GlobalData.baseUrlOri}mobile/api/driver/send_location_pool_do.jsp";
      final params = <String, String>{
        "method": "cancel_location",
        "id": id.toString(),
        "updated_user": _username.isNotEmpty ? _username : "ADMIN",
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: {"Accept": "application/json"}).timeout(
              const Duration(seconds: 25));

      if (EasyLoading.isShow) EasyLoading.dismiss();

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (_) {}

      final String message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : (response.statusCode == 200
              ? "Lokasi transit DO berhasil dibatalkan dan dinonaktifkan dari master geofence"
              : "Gagal membatalkan data (${response.statusCode})");

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listRequests.removeWhere((item) =>
                item['id']?.toString() == id.toString() ||
                (wonumber.isNotEmpty && item['wonumber']?.toString() == wonumber));
          });
          alert(context, 1, message, "success");
          await _fetchListRequests();
        }
      } else {
        alert(context, 0, message, "error");
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
                      "Kirimkan lokasi terkini Anda bersama nomor DO saat berada di luar geofence pool resmi. Jika titik sudah pernah disetujui sebelumnya, lokasi akan langsung aktif untuk absensi.",
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

            // Card Banner Titik Resmi Terdekat yang Sudah Diapprove
            _buildNearbyApprovedPoolBanner(),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nama Pool / Keterangan Lokasi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_isLoadingApprovedPools)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            "Memuat titik...",
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: primaryOrange,
                            ),
                          ),
                        )
                      else if (_approvedPools.isNotEmpty)
                        InkWell(
                          onTap: _showApprovedPoolsPicker,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.saved_search, size: 15, color: darkOrange),
                                const SizedBox(width: 4),
                                Text(
                                  "Pilih Titik Resmi (${_approvedPools.length})",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
    // Filter by search keyword & status
    final filtered = _listRequests.where((item) {
      final wonbr = (item['wonumber'] ?? '').toString().toLowerCase();
      final pool = (item['nama_pool'] ?? '').toString().toLowerCase();
      final drv = (item['drvid'] ?? '').toString().toLowerCase();
      final kw = _searchKeyword.toLowerCase();
      final matchKw = wonbr.contains(kw) || pool.contains(kw) || drv.contains(kw);
      if (!matchKw) return false;

      final int isApproved =
          int.tryParse(item['is_approved']?.toString() ?? '0') ?? 0;
      final String statusStr = item['status']?.toString().toUpperCase() ?? '';
      final bool approved = isApproved == 1 || statusStr == 'APPROVED';
      final bool isCancelled = isApproved == 2 ||
          isApproved == -1 ||
          statusStr == 'CANCEL' ||
          statusStr == 'CANCELLED';
      final bool isPending = !approved && !isCancelled;

      if (_statusFilter == "pending") {
        return isPending;
      } else if (_statusFilter == "approved") {
        return approved;
      } else if (_statusFilter == "cancel") {
        return isCancelled;
      }
      return !isCancelled;
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
                    const SizedBox(width: 8),
                    _buildFilterChip("Dibatalkan", "cancel"),
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
    final String statusStr = item['status']?.toString().toUpperCase() ?? '';
    final String createdDt = item['created_datetime']?.toString() ?? '';
    final String updatedUser = item['updated_user']?.toString() ?? '';
    final String address = item['address']?.toString() ?? '';

    final bool approved = isApproved == 1 || statusStr == 'APPROVED';
    final bool isCancelled = isApproved == 2 ||
        isApproved == -1 ||
        statusStr == 'CANCEL' ||
        statusStr == 'CANCELLED';
    final bool isPending = !approved && !isCancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: approved
              ? Colors.green.shade300
              : isCancelled
                  ? Colors.red.shade300
                  : accentOrange.withOpacity(0.4),
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
                  color: approved
                      ? Colors.green.shade50
                      : isCancelled
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: approved
                        ? Colors.green.shade300
                        : isCancelled
                            ? Colors.red.shade300
                            : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      approved
                          ? Icons.check_circle
                          : isCancelled
                              ? Icons.cancel_outlined
                              : Icons.hourglass_top,
                      size: 13,
                      color: approved
                          ? Colors.green.shade700
                          : isCancelled
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      approved
                          ? "Disetujui"
                          : isCancelled
                              ? "Dibatalkan"
                              : "Menunggu Approval",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: approved
                            ? Colors.green.shade700
                            : isCancelled
                                ? Colors.red.shade700
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

          // Action Buttons: View Lokasi di Maps & Action Decision (Approve / Cancel)
          const Divider(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isPending && _isCsAdminUser) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ntBtnStyle(Colors.red.shade600),
                    onPressed: () => _cancelLocation(id, wonumber),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ntBtnStyle(Colors.green.shade600),
                    onPressed: () => _approveLocation(id, wonumber),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      "Approve",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (approved && _isCsAdminUser) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _cancelLocation(id, wonumber),
                icon: const Icon(Icons.close, size: 15),
                label: const Text(
                  "Batalkan Approval (Cancel)",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          if (approved && updatedUser.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.verified_user,
                    size: 13, color: Colors.green.shade600),
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
          if (isCancelled && updatedUser.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.cancel_outlined,
                    size: 13, color: Colors.red.shade600),
                const SizedBox(width: 4),
                Text(
                  "Dibatalkan oleh: $updatedUser",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
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
