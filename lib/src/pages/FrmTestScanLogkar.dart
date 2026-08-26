import 'dart:convert';

import 'package:dms_anp/helpers/GpsSecurityChecker.dart';
import 'package:dms_anp/src/Helper/Provider.dart';
import 'package:dms_anp/src/Helper/logkar_api_service.dart';
import 'package:dms_anp/src/Helper/scanner_helper.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class FrmTestScanLogkar extends StatefulWidget {
  const FrmTestScanLogkar({Key? key}) : super(key: key);

  @override
  State<FrmTestScanLogkar> createState() => _FrmTestScanLogkarState();
}

class _MixerDriver {
  final String drvid;
  final String name;
  final String phone;
  final String username;

  const _MixerDriver({
    required this.drvid,
    required this.name,
    required this.phone,
    required this.username,
  });

  factory _MixerDriver.fromJson(Map<String, dynamic> map) {
    return _MixerDriver(
      drvid: (map['drvid'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
    );
  }

  String get label {
    if (name.isEmpty) return drvid;
    return '$name ($drvid)';
  }
}

class _FrmTestScanLogkarState extends State<FrmTestScanLogkar> {
  static const Color _orange = Color(0xFFFF8C69);

  List<_MixerDriver> _drivers = [];
  _MixerDriver? _selected;
  bool _loadingList = true;
  String? _listError;
  String _resultMessage = '';
  bool? _resultOk;
  String _lastQr = '';

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    _loadDrivers();
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  Future<void> _loadDrivers({String q = ''}) async {
    setState(() {
      _loadingList = true;
      _listError = null;
    });
    try {
      final uri = Uri.parse(
        '${GlobalData.baseUrlProd}api/absensi/list_mixer_driver.jsp',
      ).replace(queryParameters: {
        'method': 'list',
        'q': q,
      });
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      final root = json.decode(response.body);
      if (root is! Map<String, dynamic>) {
        throw Exception('Response list tidak valid');
      }
      final code = root['status_code']?.toString() ?? '';
      if (code != '200') {
        throw Exception((root['message'] ?? 'Gagal load driver').toString());
      }
      final data = root['data'];
      final items = <_MixerDriver>[];
      if (data is List) {
        for (final e in data) {
          if (e is Map) {
            items.add(_MixerDriver.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _drivers = items;
        _loadingList = false;
        if (_selected != null) {
          final keep = items.where((d) => d.drvid == _selected!.drvid);
          _selected = keep.isEmpty ? null : keep.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingList = false;
        _listError = e.toString();
      });
    }
  }

  Future<void> _scanAndSend() async {
    final driver = _selected;
    if (driver == null) {
      setState(() {
        _resultOk = false;
        _resultMessage = 'Pilih driver mixer dulu.';
      });
      return;
    }
    if (driver.phone.trim().isEmpty) {
      setState(() {
        _resultOk = false;
        _resultMessage = 'Phone driver kosong. Tidak bisa kirim ke Logkar.';
      });
      return;
    }

    final qrData = await openQrScanner(context);
    if (!mounted) return;
    if (qrData == null || qrData.trim().isEmpty) {
      setState(() {
        _resultOk = false;
        _resultMessage = 'Scan QR dibatalkan.';
        _lastQr = '';
      });
      return;
    }

    EasyLoading.show(status: 'Kirim ke Logkar...');
    try {
      final gpsResult = await GpsSecurityChecker.checkGpsSecurity();
      final lat = (gpsResult['latitude'] ?? 0).toString();
      final lon = (gpsResult['longitude'] ?? 0).toString();
      final result = await LogkarApiService.checkInMotiveTm(
        driverPhone: driver.phone,
        qrData: qrData.trim(),
        latitude: lat,
        longitude: lon,
      );
      if (!mounted) return;
      setState(() {
        _lastQr = qrData.trim();
        _resultOk = result.ok;
        _resultMessage = result.ok
            ? (result.message.isNotEmpty
                ? result.message
                : 'Sukses check-in Motive TM.')
            : (result.message.isNotEmpty
                ? result.message
                : 'Gagal check-in Motive TM.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastQr = qrData.trim();
        _resultOk = false;
        _resultMessage = 'Gagal kirim ke Logkar: $e';
      });
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
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
        backgroundColor: const Color(0xFFFFF4E6),
        appBar: AppBar(
          backgroundColor: _orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          title: const Text('Test Scan', style: TextStyle(color: Colors.white)),
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadDrivers(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih driver mixer',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone terisi otomatis dari driver yang dipilih, lalu dikirim ke Logkar.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      if (_loadingList)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_listError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_listError!,
                                style: const TextStyle(color: Colors.red)),
                            TextButton(
                              onPressed: () => _loadDrivers(),
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        )
                      else
                        Autocomplete<_MixerDriver>(
                          displayStringForOption: (d) => d.label,
                          optionsBuilder: (text) {
                            final q = text.text.trim().toLowerCase();
                            if (q.isEmpty) {
                              return _drivers;
                            }
                            return _drivers.where((d) {
                              return d.name.toLowerCase().contains(q) ||
                                  d.drvid.toLowerCase().contains(q) ||
                                  d.phone.toLowerCase().contains(q) ||
                                  d.username.toLowerCase().contains(q);
                            });
                          },
                          onSelected: (d) {
                            setState(() {
                              _selected = d;
                              _resultMessage = '';
                              _resultOk = null;
                              _lastQr = '';
                            });
                          },
                          fieldViewBuilder:
                              (context, controller, focus, onSubmit) {
                            return TextField(
                              controller: controller,
                              focusNode: focus,
                              decoration: InputDecoration(
                                hintText: 'Cari nama / DRVID / phone',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: const Color(0xFFFFF4E6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      _readonlyField('Driver', _selected?.name ?? '-'),
                      _readonlyField('DRVID', _selected?.drvid ?? '-'),
                      _readonlyField('Username', _selected?.username ?? '-'),
                      _readonlyField(
                          'Phone (otomatis)',
                          _selected?.phone.isEmpty == true
                              ? '-'
                              : (_selected?.phone ?? '-')),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _scanAndSend,
                          icon: const Icon(Icons.qr_code_scanner,
                              color: Colors.white),
                          label: const Text(
                            'Scan Attendance Logkar',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (_resultMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_resultOk == true
                                    ? Colors.green
                                    : Colors.red)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _resultOk == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _resultOk == true ? 'Sukses' : 'Gagal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _resultOk == true
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(_resultMessage),
                              if (_lastQr.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'QR: $_lastQr',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
