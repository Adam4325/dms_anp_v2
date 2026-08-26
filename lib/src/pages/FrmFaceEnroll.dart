import 'dart:io';

import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FaceLivenessPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/services/face_enroll_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FrmFaceEnroll extends StatefulWidget {
  const FrmFaceEnroll({Key? key}) : super(key: key);

  @override
  State<FrmFaceEnroll> createState() => _FrmFaceEnrollState();
}

class _FrmFaceEnrollState extends State<FrmFaceEnroll> {
  static const Color _orange = Color(0xFFFF8C69);
  FaceEnrollStatus? _status;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await FaceEnrollService.getStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _goDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  Future<void> _startEnroll() async {
    final path = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const FaceLivenessPage(mode: FaceLivenessMode.enroll),
      ),
    );
    if (path is! String || path.isEmpty) return;
    final file = File(path);
    if (!file.existsSync()) return;
    EasyLoading.show(status: 'Mengirim enrollment...');
    try {
      await FaceEnrollService.enroll(photoFile: file);
      if (!mounted) return;
      await _load();
      alert(context, 1, 'Enrollment terkirim. Menunggu approve HRD.', 'success');
    } catch (e) {
      if (mounted) {
        alert(context, 0, e.toString(), 'error');
      }
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
        _goDashboard();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF4E6),
        appBar: AppBar(
          backgroundColor: _orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goDashboard,
          ),
          title: const Text('Enrollment Wajah',
              style: TextStyle(color: Colors.white)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null)
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_error!,
                              style: TextStyle(color: Colors.red.shade800)),
                        ),
                      ),
                    _statusCard(),
                    const SizedBox(height: 16),
                    _rulesCard(),
                    const SizedBox(height: 20),
                    if (_canEnroll())
                      ElevatedButton.icon(
                        onPressed: _startEnroll,
                        icon: const Icon(Icons.face, color: Colors.white),
                        label: const Text(
                          'Mulai Enrollment Wajah',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  bool _canEnroll() {
    final s = _status;
    if (s == null) return true;
    return s.isNone || s.isRejected;
  }

  Widget _statusCard() {
    final s = _status;
    final label = s == null
        ? 'UNKNOWN'
        : (s.isNone ? 'BELUM ENROLL' : s.status);
    Color color = Colors.grey;
    if (s != null) {
      if (s.isApproved) color = Colors.green;
      if (s.isPending) color = Colors.orange;
      if (s.isRejected) color = Colors.red;
      if (s.isNone) color = Colors.blueGrey;
    }
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Enrollment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ),
            if (s != null && s.rejectNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Catatan HRD: ${s.rejectNote}'),
            ],
            if (s != null && s.isPending) ...[
              const SizedBox(height: 10),
              const Text(
                'Menunggu approve HRD. Absensi belum bisa dipakai.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
            if (s != null && s.isApproved) ...[
              const SizedBox(height: 10),
              const Text(
                'Wajah sudah disetujui. Silakan absen dari menu Absensi.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rulesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cara enroll',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('1. Hadapkan wajah ke oval (kamera depan).'),
            Text('2. Kedipkan mata.'),
            // Text('3. Senyum sekali.'),
            Text('3. Foto dikirim otomatis ke HRD.'),
            SizedBox(height: 8),
            Text(
              'Enrollment hanya sekali. Setelah HRD approve, foto check-in tidak disimpan.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
