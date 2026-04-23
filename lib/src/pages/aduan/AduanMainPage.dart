import 'package:dms_anp/src/model/AduanItem.dart';
import 'package:dms_anp/src/services/AduanService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modul Aduan: DRIVER/KARYAWAN kirim; HR/HD/ADMIN (username/akses + entry di DMS_ADUAN_STAFF_NOTIFY di server) tinjau & tutup.
class AduanMainPage extends StatefulWidget {
  @override
  _AduanMainPageState createState() => _AduanMainPageState();
}

class _AduanMainPageState extends State<AduanMainPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _pesanController = TextEditingController();
  List<AduanItem> _mine = [];
  List<AduanItem> _open = [];
  bool _loadingMine = false;
  bool _loadingOpen = false;

  String _username = '';
  String _loginname = '';
  String _statusK = '';
  String _drvid = '';
  String _kryid = '';

  bool _canSubmit = false;
  bool _canHandle = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _username = p.getString('username') ?? '';
      _loginname = p.getString('loginname') ?? '';
      _statusK = (p.getString('status_karyawan') ?? '').trim().toUpperCase();
      _drvid = p.getString('drvid') ?? '';
      _kryid = p.getString('kryid') ?? '';
      _canSubmit = _statusK == 'DRIVER' || _statusK == 'KARYAWAN';
      _canHandle = _isHandlerFromPrefs(p);
      _tabController?.dispose();
      _tabController = null;
      if (_canSubmit && _canHandle) {
        _tabController = TabController(length: 2, vsync: this);
      }
    });
    if (_canSubmit) {
      _refreshMine();
    }
    if (_canHandle) {
      _refreshOpen();
    }
  }

  bool _isHandlerFromPrefs(SharedPreferences p) {
    final u = (p.getString('username') ?? '').trim();
    if (u.toUpperCase() == 'ADMIN') {
      return true;
    }
    final akses = p.getStringList('akses_pages') ?? [];
    return akses.contains('HR') || akses.contains('HD');
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> _refreshMine() async {
    if (!_canSubmit) {
      return;
    }
    setState(() => _loadingMine = true);
    try {
      final list = await AduanService.listMine(
        username: _username,
        statusKaryawan: _statusK,
        drvid: _drvid,
        kryid: _kryid,
      );
      if (mounted) {
        setState(() {
          _mine = list;
          _loadingMine = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMine = false);
      }
    }
  }

  Future<void> _refreshOpen() async {
    if (!_canHandle) {
      return;
    }
    setState(() => _loadingOpen = true);
    try {
      final list = await AduanService.listOpen(_username);
      if (mounted) {
        setState(() {
          _open = list;
          _loadingOpen = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingOpen = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat aduan: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    final text = _pesanController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi aduan terlebih dahulu')),
      );
      return;
    }
    EasyLoading.show(status: 'Mengirim...');
    final err = await AduanService.create(
      username: _username,
      statusKaryawan: _statusK,
      drvid: _drvid,
      kryid: _kryid,
      loginname: _loginname,
      pesan: text,
    );
    EasyLoading.dismiss();
    if (!mounted) {
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    _pesanController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aduan terkirim')),
    );
    _refreshMine();
  }

  Future<void> _confirmClose(AduanItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tutup aduan'),
        content: const Text('Tutup aduan ini? Akan disembunyikan dari daftar terbuka.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Tutup')),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    EasyLoading.show(status: 'Menutup...');
    final err = await AduanService.close(username: _username, id: item.id);
    EasyLoading.dismiss();
    if (!mounted) {
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aduan ditutup')),
    );
    _refreshOpen();
  }

  Widget _buildSubmitPanel() {
    return RefreshIndicator(
      onRefresh: _refreshMine,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _pesanController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Isi aduan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Kirim aduan'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Aduan saya', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingMine)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else if (_mine.isEmpty)
            const Text('Belum ada riwayat', style: TextStyle(color: Colors.grey))
          else
            ..._mine.map(
              (e) => Card(
                child: ListTile(
                  title: Text(e.pesan, maxLines: 4, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${e.status} · ${e.createdAt ?? ""}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffPanel() {
    if (_loadingOpen) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_open.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Tidak ada aduan terbuka',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshOpen,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _open.length,
        itemBuilder: (c, i) {
          final e = _open[i];
          return Card(
            child: ListTile(
              isThreeLine: true,
              title: Text(
                e.pesan,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Oleh: ${e.submitterUsername} (${e.submitterLoginname ?? "-"}) · ${e.createdAt ?? ""}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () => _confirmClose(e),
                tooltip: 'Tutup',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canSubmit && !_canHandle) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aduan')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Anda tidak memiliki akses modul Aduan.'),
          ),
        ),
      );
    }

    if (_canSubmit && _canHandle && _tabController != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Aduan'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Kirim'),
              Tab(text: 'Tinjau'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSubmitPanel(),
            _buildStaffPanel(),
          ],
        ),
      );
    }

    if (_canSubmit) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aduan')),
        body: _buildSubmitPanel(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aduan (HR/HD)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOpen,
          ),
        ],
      ),
      body: _buildStaffPanel(),
    );
  }
}
