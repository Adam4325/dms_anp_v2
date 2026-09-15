import 'dart:io';

import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/FaceLivenessPage.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/services/face_enroll_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';

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
  File? _localPhotoFile;

  @override
  void initState() {
    super.initState();
    _load();
    _checkLocalDraft();
  }

  Future<void> _checkLocalDraft() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final draft = File('${appDir.path}/draft_face_enroll.jpg');
      if (draft.existsSync() && draft.lengthSync() > 0) {
        if (mounted) {
          setState(() {
            _localPhotoFile = draft;
          });
        }
      }
    } catch (_) {}
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

    // Simpan ke file draft lokal di HP
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localDraft = File('${appDir.path}/draft_face_enroll.jpg');
      await file.copy(localDraft.path);
      try {
        await file.delete();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _localPhotoFile = localDraft;
      });
      alert(context, 1, 'Foto berhasil disimpan di HP. Silakan periksa atau foto ulang sebelum kirim.', 'success');
    } catch (e) {
      if (mounted) {
        alert(context, 0, 'Gagal menyimpan draft foto: $e', 'error');
      }
    }
  }

  Future<void> _submitEnroll() async {
    if (_localPhotoFile == null || !_localPhotoFile!.existsSync()) {
      alert(context, 0, 'Silakan ambil foto wajah terlebih dahulu.', 'error');
      return;
    }
    EasyLoading.show(status: 'Mengirim enrollment ke HRD...');
    try {
      await FaceEnrollService.enroll(photoFile: _localPhotoFile!);
      if (!mounted) return;
      // Hapus draft lokal setelah berhasil dikirim
      try {
        await _localPhotoFile!.delete();
        setState(() {
          _localPhotoFile = null;
        });
      } catch (_) {}
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
                    if (_canEnroll()) ...[
                      if (_localPhotoFile != null &&
                          _localPhotoFile!.existsSync()) ...[
                        _localPhotoPreviewCard(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _startEnroll,
                                icon: const Icon(Icons.refresh, color: _orange),
                                label: const Text(
                                  'Foto Ulang',
                                  style: TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: _orange, width: 1.5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _submitEnroll,
                                icon: const Icon(Icons.cloud_upload,
                                    color: Colors.white),
                                label: const Text(
                                  'Kirim ke HRD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _orange,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _startEnroll,
                          icon: const Icon(Icons.face, color: Colors.white),
                          label: const Text(
                            'Mulai Ambil Foto Wajah',
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
                    ],
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

  Widget _localPhotoPreviewCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Foto Draft Tersimpan di HP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'DRAFT LOKAL',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 140,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border.all(color: _orange, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(
                  _localPhotoFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Foto ini sudah tersimpan di perangkat (offline). Periksa kejelasan foto wajah Anda. Jika kurang pas atau buram, silakan tekan "Foto Ulang". Jika sudah sesuai, tekan "Kirim ke HRD".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
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
            Text('2. Kedipkan mata perlahan (tunggu hitungan mundur).'),
            Text('3. Tinjau foto. Anda bebas mengulang foto jika kurang pas.'),
            Text('4. Klik "Kirim ke HRD" untuk pengajuan persetujuan.'),
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
