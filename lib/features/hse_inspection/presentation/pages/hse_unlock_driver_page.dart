import 'package:dms_anp/features/hse_inspection/data/datasources/hse_remote_datasource.dart';
import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';

class HseUnlockDriverPage extends StatefulWidget {
  final String username;
  final HseRepository? repository;

  const HseUnlockDriverPage({
    Key? key,
    required this.username,
    this.repository,
  }) : super(key: key);

  @override
  State<HseUnlockDriverPage> createState() => HseUnlockDriverPageState();
}

class HseUnlockDriverPageState extends State<HseUnlockDriverPage> {
  late final HseRepository _repo;
  final TextEditingController _searchCtrl = TextEditingController();

  List<LockedDriverItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? HseRemoteDataSource();
    loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final list = await _repo.listLockedDrivers(
        username: widget.username,
        query: _searchCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _items = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmUnlock(LockedDriverItem item) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_open_rounded, color: HseTheme.unlockGreen, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Buka Status Driver?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda akan membuka status driver berikut menjadi Active:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HseTheme.lightOrange,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HseTheme.borderOrangeSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.drvname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: HseTheme.darkOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${item.drvid} | Cabang: ${item.cabang.isEmpty ? '-' : item.cabang}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                    ),
                    if (item.findingNo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tiket HSE: ${item.findingNo}',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: HseTheme.softDecoration(
                  label: 'Catatan Pembukaan Status (opsional)',
                  hint: 'Masukkan alasan / tindak lanjut...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: HseTheme.btnStyle(HseTheme.unlockGreen),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: const Text('Ya, Buka Status', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final msg = await _repo.unlockDriver(
        username: widget.username,
        drvid: item.drvid,
        notes: noteCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: HseTheme.unlockGreen,
        ),
      );
      await loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka status driver: $e'),
          backgroundColor: HseTheme.lockRed,
        ),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HseTheme.backgroundColor,
      child: RefreshIndicator(
        color: HseTheme.primaryOrange,
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _buildSearchBox(),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: CircularProgressIndicator(
                    color: HseTheme.primaryOrange,
                  ),
                ),
              )
            else if (_error != null)
              _buildErrorCard()
            else if (_items.isEmpty)
              _buildEmptyCard()
            else
              ..._items.map(_buildDriverCard),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (_) => loadData(),
            decoration: HseTheme.softDecoration(
              hint: 'Cari ID Driver / Nama / No SIM / Cabang...',
              prefixIcon: const Icon(Icons.search,
                  color: HseTheme.primaryOrange, size: 19),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: HseTheme.btnStyle(HseTheme.primaryOrange),
          onPressed: loadData,
          child: HseTheme.btnLabel('Cari'),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HseTheme.lockRedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _error ?? 'Terjadi kesalahan',
            style: const TextStyle(color: HseTheme.lockRed, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: HseTheme.btnStyle(HseTheme.lockRed),
            onPressed: loadData,
            child: HseTheme.btnLabel('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 42, color: HseTheme.unlockGreen),
          const SizedBox(height: 10),
          const Text(
            'Tidak ada driver terkunci',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: HseTheme.unlockGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semua driver saat ini dalam status normal / aktif.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(LockedDriverItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.lockRed.withAlpha(90), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: HseTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: HseTheme.lockRedBg,
                child: const Icon(Icons.person_pin_outlined,
                    color: HseTheme.lockRed, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.drvname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${item.drvid} • ${item.cabang.isEmpty ? '-' : item.cabang}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              HseStatusBadge(
                text: item.drvstatus.isNotEmpty ? item.drvstatus : 'TERKUNCI',
                bgColor: HseTheme.lockRedBg,
                textColor: HseTheme.lockRed,
                icon: Icons.lock_rounded,
              ),
            ],
          ),
          if (item.drvlicensenbr.isNotEmpty || item.phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.drvlicensenbr.isNotEmpty)
                  Expanded(
                    child: Text(
                      'SIM: ${item.drvlicensenbr} (${item.drvlicensetype})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                if (item.phone.isNotEmpty)
                  Text(
                    'Telp: ${item.phone}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ],
          if (item.findingNo.isNotEmpty) ...[
            const Divider(height: 18),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HseTheme.lightOrange.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Tiket: ${item.findingNo}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HseTheme.darkOrange,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.incidentDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (item.violationCategory.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${item.violationCategory} (${item.sanctionLevel})',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800),
                    ),
                  ],
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              style: HseTheme.btnStyle(HseTheme.unlockGreen),
              onPressed: () => _confirmUnlock(item),
              icon: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Buka Status Driver (Set Active)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

