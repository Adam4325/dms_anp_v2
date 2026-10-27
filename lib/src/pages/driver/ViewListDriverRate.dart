import 'dart:async';
import 'dart:convert';

import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/globals.dart' as globals;
import 'package:dms_anp/src/flusbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewListDriverRate extends StatefulWidget {
  const ViewListDriverRate({Key? key}) : super(key: key);

  @override
  _ViewListDriverRateState createState() => _ViewListDriverRateState();
}

class _ViewListDriverRateState extends State<ViewListDriverRate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Color Palette (Orange Theme consistent with DMS ANP)
  final Color primaryOrange = const Color(0xFFFF8A50);
  final Color darkOrange = const Color(0xFFE65100);
  final Color lightOrange = const Color(0xFFFFF0E6);
  final Color accentOrange = const Color(0xFFFF7043);
  final Color bgGrey = const Color(0xFFF8FAFC);

  bool _isLoading = true;
  bool _hasAccess = false;
  String _username = '';
  List<dynamic> _allDrivers = [];
  List<dynamic> _filteredDrivers = [];

  String _searchQuery = '';
  String _selectedSort = 'name'; // 'name', 'highest', 'lowest', 'rated'

  int _totalDrivers = 0;
  int _totalRatedDrivers = 0;
  double _overallAvgRating = 0.0;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _checkAdminAccessAndLoad();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _checkAksesOp() {
    return globals.akses_pages.any((x) => x == 'OP');
  }

  Future<void> _checkAdminAccessAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _username = (prefs.getString('username') ?? '').trim();
    final aksesList = prefs.getStringList('akses_pages') ?? [];
    if (globals.akses_pages.isEmpty) {
      globals.akses_pages = aksesList;
    }

    final bool isAdmin = _username.toUpperCase() == 'ADMIN' || _checkAksesOp();

    if (!isAdmin) {
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

    await _fetchDriverList();
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
          'Menu List Driver & Rating hanya dapat dibuka oleh Admin.',
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

  Future<void> _fetchDriverList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String sortParam =
          (_selectedSort == 'rated') ? 'highest' : _selectedSort;
      final String url =
          '${GlobalData.baseUrl}api/driver/list_driver_rate.jsp?search=${Uri.encodeComponent(_searchQuery)}&sort=$sortParam';

      debugPrint('Fetching List Driver Rate: $url');
      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map &&
            (decoded['status_code'] == 200 ||
                decoded['status_code'] == '200')) {
          final List<dynamic> data = decoded['data'] ?? [];

          int ratedCount = 0;
          double totalRateSum = 0;
          for (var item in data) {
            final double rate = (item['avg_rate'] is num)
                ? (item['avg_rate'] as num).toDouble()
                : double.tryParse(item['avg_rate']?.toString() ?? '0') ?? 0.0;
            if (rate > 0) {
              ratedCount++;
              totalRateSum += rate;
            }
          }

          final double globalAvg =
              ratedCount > 0 ? (totalRateSum / ratedCount) : 0.0;

          if (mounted) {
            setState(() {
              _allDrivers = data;
              _totalDrivers = data.length;
              _totalRatedDrivers = ratedCount;
              _overallAvgRating = globalAvg;
              _applyLocalFilter();
              _isLoading = false;
            });
          }
        } else {
          _showError(decoded['message'] ?? 'Gagal mengambil data driver');
        }
      } else {
        _showError('Server error (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetchDriverList: $e');
      _showError('Gagal memuat list driver: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyLocalFilter() {
    List<dynamic> list = List.from(_allDrivers);

    if (_selectedSort == 'rated') {
      list = list.where((item) {
        final double rate = (item['avg_rate'] is num)
            ? (item['avg_rate'] as num).toDouble()
            : double.tryParse(item['avg_rate']?.toString() ?? '0') ?? 0.0;
        return rate > 0;
      }).toList();
    }

    list.sort((a, b) {
      final double rateA = (a['avg_rate'] is num)
          ? (a['avg_rate'] as num).toDouble()
          : double.tryParse(a['avg_rate']?.toString() ?? '0') ?? 0.0;
      final double rateB = (b['avg_rate'] is num)
          ? (b['avg_rate'] as num).toDouble()
          : double.tryParse(b['avg_rate']?.toString() ?? '0') ?? 0.0;

      final int totalA = (a['total_rate'] is num)
          ? (a['total_rate'] as num).toInt()
          : int.tryParse(a['total_rate']?.toString() ?? '0') ?? 0;
      final int totalB = (b['total_rate'] is num)
          ? (b['total_rate'] as num).toInt()
          : int.tryParse(b['total_rate']?.toString() ?? '0') ?? 0;

      final String nameA = (a['drvname'] ?? '').toString();
      final String nameB = (b['drvname'] ?? '').toString();

      final bool hasA = totalA > 0;
      final bool hasB = totalB > 0;

      if (_selectedSort == 'highest' || _selectedSort == 'rated') {
        if (hasA && !hasB) return -1;
        if (!hasA && hasB) return 1;
        if (hasA && hasB) {
          final cmpRate = rateB.compareTo(rateA); // rating tertinggi duluan
          if (cmpRate != 0) return cmpRate;
          final cmpTotal = totalB.compareTo(totalA);
          if (cmpTotal != 0) return cmpTotal;
        }
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      } else if (_selectedSort == 'lowest') {
        if (hasA && !hasB) return -1; // bernilai rating duluan
        if (!hasA && hasB) return 1;
        if (hasA && hasB) {
          final cmpRate = rateA.compareTo(rateB); // rating terkecil duluan
          if (cmpRate != 0) return cmpRate;
          final cmpTotal = totalB.compareTo(totalA);
          if (cmpTotal != 0) return cmpTotal;
        }
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      } else {
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      }
    });

    _filteredDrivers = list;
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = value.trim();
      });
      _fetchDriverList();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    alert(context, 0, msg, "error");
  }

  Widget _buildStarRow(int starCount, double avgRate,
      {int totalRate = 0, double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            (totalRate > 0 && i <= starCount) ? Icons.star : Icons.star_border,
            size: size,
            color: (totalRate > 0 && i <= starCount)
                ? Colors.amber
                : Colors.grey.shade400,
          ),
        const SizedBox(width: 6),
        Text(
          totalRate > 0 ? avgRate.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.bold,
            color: totalRate > 0 ? Colors.amber.shade800 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, darkOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.people_alt, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Status Active',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_totalDrivers Driver',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _overallAvgRating > 0
                          ? _overallAvgRating.toStringAsFixed(1)
                          : '0.0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sudah Dinilai: $_totalRatedDrivers driver',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                'Belum Dinilai: ${_totalDrivers - _totalRatedDrivers} driver',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'name', 'label': 'Nama (A-Z)'},
      {'key': 'highest', 'label': 'Rating Tertinggi'},
      {'key': 'lowest', 'label': 'Rating Terendah'},
      {'key': 'rated', 'label': 'Sudah Dinilai'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedSort == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
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
              pressElevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryOrange : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSort = f['key']!;
                    _applyLocalFilter();
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> item) {
    final String drvid = (item['drvid'] ?? '').toString();
    final String drvname = (item['drvname'] ?? '').toString();
    final String phone = (item['phone'] ?? '').toString();
    final String city = (item['city'] ?? '').toString();

    final double avgRate = (item['avg_rate'] is num)
        ? (item['avg_rate'] as num).toDouble()
        : double.tryParse(item['avg_rate']?.toString() ?? '0') ?? 0.0;

    final int starCount = (item['star_count'] is num)
        ? (item['star_count'] as num).toInt()
        : int.tryParse(item['star_count']?.toString() ?? '0') ?? 0;

    final int totalRate = (item['total_rate'] is num)
        ? (item['total_rate'] as num).toInt()
        : int.tryParse(item['total_rate']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: totalRate > 0
              ? Colors.amber.withValues(alpha: 0.35)
              : Colors.grey.shade200,
          width: totalRate > 0 ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDriverDetailSheet(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        totalRate > 0 ? Colors.amber.shade50 : lightOrange,
                    child: Icon(
                      Icons.person,
                      color:
                          totalRate > 0 ? Colors.amber.shade800 : primaryOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drvname.isEmpty ? '-' : drvname,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            drvid,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalRate > 0) //
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            avgRate.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RATING DRIVER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildStarRow(starCount, avgRate,
                          totalRate: totalRate, size: 17),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL REVIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalRate > 0 ? '$totalRate ulasan' : 'Belum ada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: totalRate > 0
                              ? Colors.black87
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (phone.isNotEmpty || city.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      Icon(Icons.phone, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (city.isNotEmpty) ...[
                      Icon(Icons.location_on,
                          size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDetailSheet(Map<String, dynamic> item) {
    final String drvid = (item['drvid'] ?? '').toString();
    final String drvname = (item['drvname'] ?? '').toString();
    final String phone = (item['phone'] ?? '').toString();
    final String city = (item['city'] ?? '').toString();

    final double avgRate = (item['avg_rate'] is num)
        ? (item['avg_rate'] as num).toDouble()
        : double.tryParse(item['avg_rate']?.toString() ?? '0') ?? 0.0;

    final int starCount = (item['star_count'] is num)
        ? (item['star_count'] as num).toInt()
        : int.tryParse(item['star_count']?.toString() ?? '0') ?? 0;

    final int totalRate = (item['total_rate'] is num)
        ? (item['total_rate'] as num).toInt()
        : int.tryParse(item['total_rate']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).padding.bottom + 20),
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: lightOrange,
                    child: Icon(Icons.person, color: primaryOrange, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drvname,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: $drvid',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'RATA-RATA RATING DRIVER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      avgRate > 0 ? avgRate.toStringAsFixed(1) : '0.0',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStarRow(starCount, avgRate,
                        totalRate: totalRate, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      totalRate > 0
                          ? 'Diberikan oleh $totalRate pelanggan'
                          : 'Belum ada pelanggan yang memberi rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailItem(
                  Icons.phone, 'Nomor HP', phone.isNotEmpty ? phone : '-'),
              _buildDetailItem(Icons.location_city, 'Kota / Wilayah',
                  city.isNotEmpty ? city : '-'),
              _buildDetailItem(
                  Icons.verified, 'Status', 'Active (Driver Aktif)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAccess && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('List Driver'),
          backgroundColor: primaryOrange,
        ),
        body: const Center(
          child: Text('Akses terbatas untuk Administrator.'),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          'List Driver & Rating',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDriverList,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryOrange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari Nama Driver / DRVID...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.clear,
                          size: 18, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
          _buildSummaryCard(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryOrange),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Memuat data driver & rating...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : _filteredDrivers.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _fetchDriverList,
                        color: primaryOrange,
                        child: ListView(
                          children: [
                            const SizedBox(height: 60),
                            Icon(Icons.person_search,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada driver sesuai pencarian "$_searchQuery"'
                                    : 'Tidak ada data driver aktif',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchDriverList,
                        color: primaryOrange,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                          itemCount: _filteredDrivers.length,
                          itemBuilder: (ctx, index) {
                            final item =
                                _filteredDrivers[index] as Map<String, dynamic>;
                            return _buildDriverCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
