import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms_anp/src/flusbar.dart';
import 'package:dms_anp/src/pages/ViewDashboard.dart';
import 'package:dms_anp/src/services/face_enroll_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ListApvFaceEnroll extends StatefulWidget {
  const ListApvFaceEnroll({Key? key}) : super(key: key);

  @override
  State<ListApvFaceEnroll> createState() => _ListApvFaceEnrollState();
}

class _ListApvFaceEnrollState extends State<ListApvFaceEnroll> {
  static const Color _orange = Color(0xFFFF8C69);
  final TextEditingController _searchCtrl = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;
  String _filter = 'ALL';
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (EasyLoading.isShow) EasyLoading.dismiss();
    _future = FaceEnrollService.list(status: _filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewDashboard()),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = FaceEnrollService.list(status: _filter, q: _query);
    });
  }

  void _applySearch(String value) {
    _query = value.trim();
    _refresh();
  }

  List<Map<String, dynamic>> _localFilter(List<Map<String, dynamic>> data) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return data;
    return data.where((e) {
      final name = (e['namakry'] ?? '').toString().toLowerCase();
      final kry = (e['kryid'] ?? '').toString().toLowerCase();
      final user = (e['username'] ?? '').toString().toLowerCase();
      return name.contains(q) || kry.contains(q) || user.contains(q);
    }).toList();
  }

  Future<void> _approve(Map<String, dynamic> item) async {
    final id = int.tryParse('${item['id'] ?? 0}') ?? 0;
    if (id <= 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve wajah?'),
        content: Text('Setujui enrollment ${item['namakry'] ?? ''}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: 'Approve...');
    try {
      await FaceEnrollService.approve(id);
      if (mounted) {
        alert(context, 1, 'Enrollment disetujui', 'success');
        await _refresh();
      }
    } catch (e) {
      if (mounted) alert(context, 0, e.toString(), 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _reject(Map<String, dynamic> item) async {
    final id = int.tryParse('${item['id'] ?? 0}') ?? 0;
    if (id <= 0) return;
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject wajah?'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            hintText: 'Alasan reject',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: 'Reject...');
    try {
      await FaceEnrollService.reject(id, noteCtrl.text.trim());
      if (mounted) {
        alert(context, 1, 'Enrollment ditolak', 'success');
        await _refresh();
      }
    } catch (e) {
      if (mounted) alert(context, 0, e.toString(), 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = int.tryParse('${item['id'] ?? 0}') ?? 0;
    if (id <= 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus enrollment?'),
        content: Text(
          'Hapus permanen data wajah ${item['namakry'] ?? ''} '
          '(${item['kryid'] ?? ''})?\n\n'
          'Foto dan baris DB dihapus. Karyawan bisa enroll ulang.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: 'Menghapus...');
    try {
      await FaceEnrollService.delete(id);
      if (mounted) {
        alert(context, 1, 'Data dihapus. Karyawan bisa enroll ulang.', 'success');
        await _refresh();
      }
    } catch (e) {
      if (mounted) alert(context, 0, e.toString(), 'error');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  void _previewPhoto(String url, String name) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 200,
                  child: Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        backgroundColor: const Color(0xFFFFF4E6),
        appBar: AppBar(
          backgroundColor: _orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          title: const Text('Apv. Wajah',
              style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            _searchBox(),
            _filterChips(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text('Gagal load: ${snapshot.error}')),
                        ],
                      );
                    }
                    final data = _localFilter(snapshot.data ?? []);
                    if (data.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Tidak ada data enrollment')),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: data.length,
                      itemBuilder: (context, i) => _card(data[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}),
        onSubmitted: _applySearch,
        decoration: InputDecoration(
          hintText: 'Cari nama, KRYID, atau username',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isEmpty
              ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _applySearch(_searchCtrl.text),
                )
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applySearch('');
                  },
                ),
          filled: true,
          fillColor: const Color(0xFFFFF4E6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    final items = const [
      ('ALL', 'Semua'),
      ('PENDING', 'Pending'),
      ('APPROVED', 'Approved'),
      ('REJECTED', 'Rejected'),
    ];
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((e) {
            final selected = _filter == e.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.$2),
                selected: selected,
                selectedColor: _orange,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  setState(() {
                    _filter = e.$1;
                    _future = FaceEnrollService.list(status: _filter, q: _query);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toUpperCase();
    final photo = (item['photo_abs'] ?? '').toString();
    final pending = status == 'PENDING';
    final name = item['namakry']?.toString() ?? '-';
    Color badge = Colors.orange;
    if (status == 'APPROVED') badge = Colors.green;
    if (status == 'REJECTED') badge = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _previewPhoto(photo, name),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: photo.isEmpty
                        ? Container(
                            width: 92,
                            height: 112,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 40),
                          )
                        : CachedNetworkImage(
                            imageUrl: photo,
                            width: 92,
                            height: 112,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 92,
                              height: 112,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 92,
                              height: 112,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('KRYID: ${item['kryid'] ?? '-'}',
                          style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      Text('User: ${item['username'] ?? '-'}',
                          style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      if ((item['created_at'] ?? '').toString().isNotEmpty)
                        Text('Enroll: ${item['created_at']}',
                            style: const TextStyle(color: Colors.black45, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badge.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                color: badge, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((item['reject_note'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Catatan: ${item['reject_note']}',
                  style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 10),
            if (pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _reject(item),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approve(item),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Approve',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _delete(item),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _delete(item),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete (enroll ulang)',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
