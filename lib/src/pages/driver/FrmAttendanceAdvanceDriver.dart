import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/Provider.dart';
import '../../flusbar.dart';
import '../../Helper/globals.dart' as globals;
import '../ViewDashboard.dart';
import 'ViewApprovalAttendanceDriver.dart';
import '../../../helpers/DeveloperModeGuard.dart';

/// Halaman Absen Advance Khusus Driver (Attendance Advance Driver).
/// ATURAN KETAT:
/// - Hanya mengizinkan tipe 'IZIN' dan 'SAKIT'.
/// - Opsi 'STORING' dan 'CUTI' DIHAPUS TOTAL dari antarmuka driver.
/// - Validasi frontend mengunci payload hanya ke 'IZIN' dan 'SAKIT'.
class FrmAttendanceAdvanceDriver extends StatefulWidget {
  const FrmAttendanceAdvanceDriver({Key? key}) : super(key: key);

  @override
  State<FrmAttendanceAdvanceDriver> createState() =>
      _FrmAttendanceAdvanceDriverState();
}

class _FrmAttendanceAdvanceDriverState extends State<FrmAttendanceAdvanceDriver>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Design Tokens (Soft Orange Pastel)
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);

  // Driver Session Info
  String namaDriver = '';
  String driverId = '';
  String androidID = '';
  String username = '';
  bool _isOpOrAdmin = false;

  // Form State (HANYA 'IZIN' atau 'SAKIT')
  String _selectedType = 'IZIN'; // Default: IZIN
  final List<String> _allowedTypes = const ['IZIN', 'SAKIT'];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isRange = false;

  final TextEditingController _txtNote = TextEditingController();
  final TextEditingController _txtAddress = TextEditingController();

  File? _imageFile;
  String _imageBase64 = '';
  final ImagePicker _picker = ImagePicker();

  Position? _currentPosition;
  bool _isLoadingLocation = false;

  // History State
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoadingHistory = false;
  String _filterStatus = 'ALL'; // ALL, PENDING, APPROVED, REJECTED
  String _filterType = 'ALL'; // ALL, IZIN, SAKIT
  final TextEditingController _txtSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await DeveloperModeGuard.blockIfDeveloperModeEnabled(context)) {
        return;
      }
    });
    // Pastikan tidak ada overlay loading EasyLoading yang tertinggal dari dashboard
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadHistory();
      }
    });

    _loadSession().then((_) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      _getCurrentLocation();
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txtNote.dispose();
    _txtAddress.dispose();
    _txtSearch.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString('username') ?? '';
    final aksesList = prefs.getStringList('akses_pages') ?? [];
    if (globals.akses_pages.isEmpty) {
      globals.akses_pages = aksesList;
    }
    final isOp = globals.akses_pages.any((x) => x == 'OP') ||
        u.toUpperCase() == 'ADMIN';

    setState(() {
      namaDriver = prefs.getString('name') ?? 'Driver';
      driverId = prefs.getString('drvid') ?? prefs.getString('userid') ?? '';
      androidID = prefs.getString('androidID') ?? '';
      username = u;
      _isOpOrAdmin = isOp;
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() => _currentPosition = pos);

      // Reverse geocoding OSM
      final addr = await _reverseGeocodeOSM(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _txtAddress.text = addr;
        });
      }
    } catch (e) {
      debugPrint('Error get location: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<String> _reverseGeocodeOSM(double lat, double lon) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'lat': lat.toString(),
        'lon': lon.toString(),
        'zoom': '18',
        'addressdetails': '1',
      });
      final res = await http.get(uri, headers: {
        'User-Agent': 'DMS_ANP/1.0 (ANP Driver Attendance)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['display_name'] != null) {
          return decoded['display_name'].toString();
        }
      }
    } catch (e) {
      debugPrint('OSM error: $e');
    }
    return '';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 60);
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _imageFile = file;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error pick image: $e');
      if (mounted) {
        alert(_scaffoldKey.currentContext ?? context, 0,
            'Gagal mengambil foto: $e', 'error');
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedType == 'SAKIT'
                      ? 'Foto Surat Keterangan Dokter'
                      : 'Lampirkan Bukti Dokumen',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedType == 'SAKIT'
                      ? 'Ambil foto surat dokter yang jelas dan dapat dibaca'
                      : 'Pilih sumber gambar dokumen dari Kamera atau Galeri',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: const Text('Kamera'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                        style: _btnStyle(primaryOrange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon:
                            const Icon(Icons.photo_library_outlined, size: 20),
                        label: const Text('Galeri'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                        style: _btnStyle(accentOrange),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime.now().subtract(const Duration(days: 30));
    final lastDate = DateTime.now().add(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          if (picked.isBefore(_startDate)) {
            alert(_scaffoldKey.currentContext ?? context, 0,
                'Tanggal selesai tidak boleh sebelum tanggal mulai', 'warning');
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  // Submit Handler dengan Validasi Ketat Driver
  Future<void> _submitAttendanceDriver() async {
    if (await DeveloperModeGuard.blockIfDeveloperModeEnabled(context)) {
      return;
    }
    // 1. Strict Validation: Tipe hanya boleh IZIN atau SAKIT
    final typeUpper = _selectedType.toUpperCase().trim();
    if (!_allowedTypes.contains(typeUpper)) {
      alert(
          _scaffoldKey.currentContext ?? context,
          0,
          'Tipe pengajuan driver tidak valid. Hanya diizinkan Izin dan Sakit.',
          'error');
      return;
    }

    // 2. Validasi Catatan (Wajib untuk Sakit dan Izin)
    final note = _txtNote.text.trim();
    if (note.isEmpty) {
      alert(_scaffoldKey.currentContext ?? context, 0,
          'Catatan / Keterangan wajib diisi.', 'error'); //
      return;
    }
    if (note.length < 3) {
      alert(
          _scaffoldKey.currentContext ?? context,
          0,
          'Catatan terlalu singkat. Tuliskan keterangan dengan jelas.',
          'error');
      return;
    }

    // 3. Validasi Foto Surat Keterangan Dokter (Wajib untuk SAKIT, izin tidak perlu)
    if (typeUpper == 'SAKIT') {
      if (_imageFile == null || _imageBase64.isEmpty) {
        alert(
          _scaffoldKey.currentContext ?? context,
          0,
          'Foto gambar surat dari keterangan dokter wajib dilampirkan untuk pengajuan SAKIT.',
          'error',
        );
        return;
      }
    }

    // 4. Validasi Tanggal
    if (_isRange && _endDate.isBefore(_startDate)) {
      alert(_scaffoldKey.currentContext ?? context, 0,
          'Tanggal selesai tidak boleh sebelum tanggal mulai.', 'error');
      return;
    }

    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endDateStr =
        _isRange ? DateFormat('yyyy-MM-dd').format(_endDate) : startDateStr;

    // 5. Konfirmasi Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: primaryOrange),
            SizedBox(width: 8),
            Text('Konfirmasi Pengajuan', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin mengajukan $typeUpper?'),
            const SizedBox(height: 8),
            Text(
              'Tanggal: $startDateStr' +
                  (_isRange && startDateStr != endDateStr
                      ? ' s/d $endDateStr'
                      : ''),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: darkOrange),
            ),
            const SizedBox(height: 4),
            Text('Catatan: $note',
                style: TextStyle(color: Colors.grey.shade700)),
            if (typeUpper == 'SAKIT') ...[
              const SizedBox(height: 6),
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Surat Dokter: Terlampir',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: _btnStyle(primaryOrange),
            child: const Text('Ya, Kirim'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: 'Mengirim pengajuan $typeUpper...');

    try {
      final lat = _currentPosition?.latitude.toString() ?? '0.0';
      final lon = _currentPosition?.longitude.toString() ?? '0.0';
      final address = _txtAddress.text.trim();

      // Endpoint driver terpisah sesuai instruksi
      final urlEndpoint = typeUpper == 'SAKIT'
          ? '${GlobalData.baseUrlOri}api/checkin-driver-attendance-sakit.jsp'
          : '${GlobalData.baseUrlOri}api/checkin-driver-attendance-izin.jsp';

      final fullNote = _isRange && startDateStr != endDateStr
          ? '[$startDateStr s/d $endDateStr] $note'
          : note;

      final bodyPayload = {
        'method': typeUpper,
        'imeiid': androidID,
        'status_absensi': typeUpper.toLowerCase(),
        'geo_id': '0',
        'geo_nm': 'MOBILE DRIVER',
        'is_mock': '0',
        'employeeid': driverId,
        'lat': lat,
        'lon': lon,
        'truslat': lat,
        'truslon': lon,
        'address': address,
        'userid': (namaDriver.isNotEmpty ? namaDriver : username).toUpperCase(),
        'start_date': startDateStr,
        'end_date': endDateStr,
        'company': 'AN',
        'note': fullNote,
        'photo': _imageBase64,
      };

      debugPrint('POST URL: $urlEndpoint');
      debugPrint('PAYLOAD: $bodyPayload');

      final response = await http.post(
        Uri.parse(urlEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyPayload,
        encoding: Encoding.getByName('utf-8'),
      );

      if (EasyLoading.isShow) EasyLoading.dismiss();

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final statusCode = decoded['status_code'];
        final message = decoded['message'] ?? 'Pengajuan berhasil dikirim';

        if (statusCode == 200) {
          alert(_scaffoldKey.currentContext ?? context, 1, message, 'success');
          _resetForm();
          _loadHistory();
          // Pindah ke tab riwayat
          _tabController.animateTo(1);
        } else if (statusCode == 304) {
          alert(_scaffoldKey.currentContext ?? context, 2, message, 'warning');
        } else {
          alert(_scaffoldKey.currentContext ?? context, 0, message, 'error');
        }
      } else {
        alert(_scaffoldKey.currentContext ?? context, 0,
            'Gagal mengirim pengajuan (${response.statusCode})', 'error');
      }
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      debugPrint('Error submit attendance driver: $e');
      alert(_scaffoldKey.currentContext ?? context, 0,
          'Terjadi kesalahan pengiriman: $e', 'error');
    }
  }

  void _resetForm() {
    setState(() {
      _selectedType = 'IZIN';
      _txtNote.clear();
      _imageFile = null;
      _imageBase64 = '';
      _isRange = false;
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    });
  }

  // Load Riwayat Driver
  Future<void> _loadHistory() async {
    if (_isLoadingHistory) return;
    setState(() => _isLoadingHistory = true);

    try {
      final queryParams = {
        'method': 'list-history',
        'imeiid': androidID,
        'drvid': driverId,
        'status': _filterStatus,
        'tipe': _filterType,
        'search': _txtSearch.text.trim(),
      };

      final uri = Uri.parse(
        '${GlobalData.baseUrlOri}api/get_history_driver_attendance_advance.jsp',
      ).replace(queryParameters: queryParams);

      debugPrint('Get History Driver: $uri');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          // Hanya izinkan IZIN dan SAKIT (filter safety di sisi client juga)
          final filtered = decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .where((item) {
            final tipe = (item['tipe'] ?? '').toString().toUpperCase();
            return tipe == 'IZIN' || tipe == 'SAKIT';
          }).toList();

          if (mounted) {
            setState(() {
              _historyList = filtered;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewDashboard()),
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ViewDashboard()),
              );
            },
          ),
          title: const Text(
            'Absen Advance Driver',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            if (_isOpOrAdmin)
              IconButton(
                icon: const Icon(Icons.assignment_turned_in),
                tooltip: 'Persetujuan Sakit & Izin Driver',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ViewApprovalAttendanceDriver(),
                    ),
                  );
                },
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(
                icon: Icon(Icons.assignment_add, size: 20),
                text: 'Form Pengajuan',
              ),
              Tab(
                icon: Icon(Icons.history, size: 20),
                text: 'Riwayat Absen',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFormTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: FORM PENGAJUAN DRIVER =================
  Widget _buildFormTab() {
    final dateFormat = DateFormat('dd MMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        children: [
          // Header Card Info Driver
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
                  child: const Icon(Icons.person, color: darkOrange, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaDriver.isNotEmpty ? namaDriver : 'Driver ANP',
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
                              'DRIVER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: darkOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            driverId.isNotEmpty ? 'ID: $driverId' : '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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

          // Main Form Card
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit_calendar_outlined,
                          color: primaryOrange, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formulir Absensi Driver',
                              style: TextStyle(
                                color: darkOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Pilih Izin atau Sakit untuk pengajuan absensi',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Pilihan Tipe Absensi: HANYA IZIN & SAKIT
                      _label('Tipe Pengajuan Absen'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeCard(
                              title: 'Izin',
                              subtitle: 'Kepentingan pribadi / keluarga',
                              icon: Icons.event_note_outlined,
                              isSelected: _selectedType == 'IZIN',
                              onTap: () {
                                setState(() {
                                  _selectedType = 'IZIN';
                                  // Izin tidak memerlukan foto surat dokter
                                  _imageFile = null;
                                  _imageBase64 = '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeCard(
                              title: 'Sakit',
                              subtitle: 'Kondisi medis / surat dokter',
                              icon: Icons.medical_services_outlined,
                              isSelected: _selectedType == 'SAKIT',
                              onTap: () =>
                                  setState(() => _selectedType = 'SAKIT'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 2. Rentang Tanggal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _label('Tanggal Absen'),
                          Row(
                            children: [
                              Text(
                                'Lebih dari 1 hari',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Switch(
                                value: _isRange,
                                activeColor: primaryOrange,
                                onChanged: (val) {
                                  setState(() {
                                    _isRange = val;
                                    if (!_isRange) _endDate = _startDate;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      if (!_isRange) ...[
                        // Single Date Picker
                        InkWell(
                          onTap: () => _selectDate(isStart: true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: primaryOrange, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dateFormat.format(_startDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Date Range (Start & End)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(isStart: true),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mulai',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dateFormat.format(_startDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.arrow_forward,
                                  color: primaryOrange, size: 18),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(isStart: false),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selesai',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dateFormat.format(_endDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 18),

                      // 3. Catatan / Alasan (Wajib untuk dua-duanya)
                      Row(
                        children: [
                          _label('Catatan / Keterangan (Wajib)'),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _txtNote,
                        maxLines: 3,
                        cursorColor: primaryOrange,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                        decoration: _softDecoration(
                          hint: _selectedType == 'SAKIT'
                              ? 'Tuliskan diagnosa atau keluhan sakit dokter (Wajib)...'
                              : 'Tuliskan alasan / keperluan izin tidak masuk kerja (Wajib)...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 36),
                            child: Icon(Icons.edit_note,
                                color: primaryOrange, size: 22),
                          ),
                        ),
                      ),

                      // 4. Upload Foto Surat Keterangan Dokter (HANYA SAKIT, IZIN TIDAK PERLU)
                      if (_selectedType == 'SAKIT') ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _label('Foto Surat Keterangan Dokter (Wajib)'),
                            const SizedBox(width: 4),
                            const Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildPhotoUploadSection(),
                      ],

                      const SizedBox(height: 18),

                      // 5. Lokasi Terdeteksi (GPS)
                      _buildLocationSection(),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: Text(
                            'KIRIM PENGAJUAN ${_selectedType.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          onPressed: _submitAttendanceDriver,
                          style: _btnStyle(primaryOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? lightOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? darkOrange : Colors.grey.shade600,
                  size: 22,
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: primaryOrange, size: 18)
                else
                  Icon(Icons.radio_button_unchecked,
                      color: Colors.grey.shade400, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? darkOrange : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    if (_imageFile != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade400, width: 1.5),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _imageFile!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Surat Dokter Terlampir',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Foto surat keterangan dokter siap dikirim',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      InkWell(
                        onTap: _showImagePickerSheet,
                        child: const Text(
                          'Ganti Foto',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => setState(() {
                          _imageFile = null;
                          _imageBase64 = '';
                        }),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _showImagePickerSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryOrange,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  color: primaryOrange, size: 26),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unggah Foto Surat Keterangan Dokter (Wajib)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkOrange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk untuk foto surat dokter via Kamera atau Galeri',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
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
            children: [
              const Icon(Icons.location_on, color: primaryOrange, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Lokasi Driver (GPS)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isLoadingLocation)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                  ),
                )
              else
                InkWell(
                  onTap: _getCurrentLocation,
                  child: const Text(
                    'Perbarui',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _txtAddress.text.isNotEmpty
                ? _txtAddress.text
                : (_currentPosition != null
                    ? 'Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}'
                    : 'Mengambil lokasi...'),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: RIWAYAT ABSENSI DRIVER =================
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _loadHistory,
      child: Column(
        children: [
          // Filter Chips Container
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            color: backgroundColor,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _txtSearch,
                  cursorColor: primaryOrange,
                  decoration: _softDecoration(
                    hint: 'Cari catatan atau tanggal...',
                    prefixIcon: const Icon(Icons.search,
                        color: primaryOrange, size: 20),
                    suffixIcon: _txtSearch.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _txtSearch.clear();
                              _loadHistory();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadHistory(),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua Status', 'ALL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'PENDING'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Approved', 'APPROVED'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', 'REJECTED'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Tipe Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeFilterChip('Semua Tipe', 'ALL'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Izin', 'IZIN'),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Sakit', 'SAKIT'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List Riwayat
          Expanded(
            child: _isLoadingHistory
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                    ),
                  )
                : _historyList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
                        itemCount: _historyList.length,
                        itemBuilder: (ctx, index) {
                          final item = _historyList[index];
                          return _buildHistoryCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterStatus = value);
          _loadHistory();
        }
      },
      selectedColor: primaryOrange,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? primaryOrange : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterType = value);
          _loadHistory();
        }
      },
      selectedColor: accentOrange,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? accentOrange : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final tipe = (item['tipe'] ?? 'IZIN').toString().toUpperCase();
    final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
    final logdate = item['logdate'] ?? '';
    final note = item['note'] ?? '';
    final createdDt = item['created_datetime'] ?? '';

    Color statusColor;
    Color statusBgColor;
    String statusLabel;

    if (status == 'APPROVED') {
      statusColor = const Color(0xFF2E7D32);
      statusBgColor = const Color(0xFFE8F5E9);
      statusLabel = 'Approved';
    } else if (status == 'REJECTED') {
      statusColor = const Color(0xFFC62828);
      statusBgColor = const Color(0xFFFFEBEE);
      statusLabel = 'Rejected';
    } else {
      statusColor = const Color(0xFFE65100);
      statusBgColor = const Color(0xFFFFF3E0);
      statusLabel = 'Pending';
    }

    final isSakit = tipe == 'SAKIT';
    final tipeColor =
        isSakit ? const Color(0xFFD84315) : const Color(0xFF1565C0);
    final tipeBg = isSakit ? const Color(0xFFFBE9E7) : const Color(0xFFE3F2FD);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFB347)),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailSheet(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Tipe Badge + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tipeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSakit
                              ? Icons.medical_services_outlined
                              : Icons.event_note,
                          size: 14,
                          color: tipeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tipe,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tipeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
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
              const SizedBox(height: 10),

              // Tanggal Absen
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: primaryOrange),
                  const SizedBox(width: 6),
                  Text(
                    'Tanggal: $logdate',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Catatan
              if (note.toString().isNotEmpty)
                Text(
                  note.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Footer: Waktu Pengajuan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    createdDt.toString().isNotEmpty
                        ? 'Diajukan: $createdDt'
                        : '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(Map<String, dynamic> item) {
    final tipe = (item['tipe'] ?? 'IZIN').toString().toUpperCase();
    final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
    final logdate = item['logdate'] ?? '-';
    final note = item['note'] ?? '-';
    final createdDt = item['created_datetime'] ?? '-';
    final drvName = item['drvname'] ?? namaDriver;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Absen $tipe',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkOrange,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'APPROVED'
                          ? const Color(0xFFE8F5E9)
                          : (status == 'REJECTED'
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFFFF3E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == 'APPROVED'
                            ? const Color(0xFF2E7D32)
                            : (status == 'REJECTED'
                                ? const Color(0xFFC62828)
                                : const Color(0xFFE65100)),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _detailRow('Driver', drvName.toString()),
              const SizedBox(height: 8),
              _detailRow('Tipe Absensi', tipe),
              const SizedBox(height: 8),
              _detailRow('Tanggal Absen', logdate.toString()),
              const SizedBox(height: 8),
              _detailRow('Waktu Pengajuan', createdDt.toString()),
              const SizedBox(height: 12),
              const Text(
                'Catatan / Keterangan:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.toString(),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: _btnStyle(primaryOrange),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat absen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pengajuan izin atau sakit Anda akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
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

  InputDecoration _softDecoration({
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryOrange, width: 2),
      ),
    );
  }

  ButtonStyle _btnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
