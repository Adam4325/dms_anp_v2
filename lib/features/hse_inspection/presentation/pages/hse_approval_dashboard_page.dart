import 'package:dms_anp/features/hse_inspection/data/datasources/hse_remote_datasource.dart';
import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/pages/hse_finding_detail_page.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';

class HseApprovalDashboardPage extends StatefulWidget {
  final String username;
  final bool isOpOnly;
  final bool isHdOnly;
  final HseRepository? repository;

  const HseApprovalDashboardPage({
    Key? key,
    required this.username,
    required this.isOpOnly,
    this.isHdOnly = false,
    this.repository,
  }) : super(key: key);

  @override
  State<HseApprovalDashboardPage> createState() =>
      HseApprovalDashboardPageState();
}

class HseApprovalDashboardPageState extends State<HseApprovalDashboardPage> {
  late final HseRepository _repo;
  final TextEditingController _searchCtrl = TextEditingController();

  HseSummaryModel _summary = const HseSummaryModel();
  List<HseFindingItem> _items = [];
  bool _loading = true;
  String? _error;

  late String _statusFilter;
  String _entityFilter = 'ALL';

  List<String> get _availableEntityFilters {
    if (widget.isHdOnly) {
      return const [HseEntityType.karyawan];
    }
    if (widget.isOpOnly) {
      return const ['ALL', HseEntityType.driver, HseEntityType.mobil];
    }
    return const ['ALL', ...HseEntityType.all];
  }

  String _entityFilterLabel(String ent) {
    if (ent == 'ALL') {
      return widget.isOpOnly ? 'Semua (Driver & Unit)' : 'Semua Entitas';
    }
    return HseEntityType.label(ent);
  }

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? HseRemoteDataSource();
    _statusFilter = 'ALL';
    _entityFilter = widget.isHdOnly ? HseEntityType.karyawan : 'ALL';
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
      final result = await _repo.listFindings(
        username: widget.username,
        statusFlow: _statusFilter,
        entityType: _entityFilter,
        query: _searchCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _summary = result.summary;
        _items = result.items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDetail(HseFindingItem item) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => HseFindingDetailPage(
          initialItem: item,
          username: widget.username,
          repository: _repo,
        ),
      ),
    );
    if (updated == true) {
      await loadData();
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
            if (widget.isOpOnly) _buildOpBanner(),
            _buildKpiRow(),
            const SizedBox(height: 12),
            _buildSearchAndFilters(),
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
              ..._items.map(_buildFindingCard),
          ],
        ),
      ),
    );
  }

  Widget _buildOpBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: HseTheme.waitAmberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HseTheme.waitAmber.withAlpha(80)),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified_user_outlined,
              color: HseTheme.waitAmber, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode Role OPR: Anda dapat melakukan Approve (Set Status BP) temuan ONGOING serta Final Approval pembuka kunci (Active) untuk DRIVER dan MOBIL.',
              style: TextStyle(
                color: HseTheme.waitAmber,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    Widget chip(String key, String label, int count, Color color) {
      final selected = _statusFilter == key;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _statusFilter = key);
          loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(110)),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int totalAll = _summary.totalOngoing +
        _summary.totalBp +
        _summary.totalWaitingShe +
        _summary.totalWaitingFinal +
        _summary.totalComplete;

    return Row(
      children: [
        Expanded(
          child: chip(
            'ALL',
            'All',
            totalAll,
            Colors.blueGrey,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: chip('ONGOING', 'Ongoing', _summary.totalOngoing, HseTheme.darkOrange),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: chip('BP', 'Approved', _summary.totalBp, HseTheme.lockRed),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: chip('COMPLETE', 'Selesai', _summary.totalComplete, HseTheme.unlockGreen),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.borderOrangeSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => loadData(),
                  decoration: HseTheme.softDecoration(
                    hint: 'Cari Tiket / ID / Nama / Nopol...',
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
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableEntityFilters.map((ent) {
                final selected = _entityFilter == ent;
                final label = _entityFilterLabel(ent);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: HseTheme.primaryOrange,
                    backgroundColor: HseTheme.lightOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : HseTheme.darkOrange,
                    ),
                    onSelected: (_) {
                      setState(() => _entityFilter = ent);
                      loadData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
          Text(_error!, style: const TextStyle(color: HseTheme.lockRed)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: HseTheme.btnStyle(HseTheme.primaryOrange),
            onPressed: loadData,
            child: HseTheme.btnLabel('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 40, color: HseTheme.primaryOrange),
          const SizedBox(height: 8),
          Text(
            'Belum ada data temuan pada filter "$_statusFilter".',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(HseFindingItem item) {
    final needsAction = item.canApproveBp ||
        item.canRepair ||
        item.canVerifyShe ||
        item.canFinalApprove;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: needsAction
                ? HseTheme.primaryOrange
                : (item.isLocked
                    ? HseTheme.lockRed.withAlpha(80)
                    : Colors.grey.shade200),
            width: needsAction ? 1.5 : 1,
          ),
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
                Text(
                  item.findingNo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: HseTheme.darkOrange,
                  ),
                ),
                const Spacer(),
                HseStatusBadge.fromStatusFlow(item.statusFlow, item.isLocked),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(HseTheme.entityIcon(item.entityType),
                    color: HseTheme.primaryOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.entityName} (${item.entityId})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.violationCategory} • ${item.sanctionLevel}',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                HseStatusBadge(
                  text: item.entityType,
                  bgColor: HseTheme.lightOrange,
                  textColor: HseTheme.darkOrange,
                ),
                if (item.entityMasterStatus.isNotEmpty)
                  HseStatusBadge(
                    text: 'Master: ${item.entityMasterStatus}',
                    bgColor: (item.entityMasterStatus == 'BP' ||
                            item.entityMasterStatus == 'BLOCKED')
                        ? HseTheme.lockRedBg
                        : Colors.grey.shade100,
                    textColor: (item.entityMasterStatus == 'BP' ||
                            item.entityMasterStatus == 'BLOCKED')
                        ? HseTheme.lockRed
                        : Colors.grey.shade700,
                  ),
                HseStatusBadge(
                  text: 'Final: ${item.finalApproverRole}',
                  bgColor: Colors.grey.shade100,
                  textColor: Colors.grey.shade700,
                ),
              ],
            ),
            if (needsAction) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: HseTheme.lightOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined,
                        size: 16, color: HseTheme.darkOrange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.canApproveBp
                            ? 'Tap untuk Approve'
                            : item.canFinalApprove
                                ? 'Tap untuk Final Approval & Unlock (Active)'
                                : item.canVerifyShe
                                    ? 'Tap untuk Verifikasi SHE'
                                    : 'Tap untuk Input Tindakan Perbaikan',
                        style: const TextStyle(
                          color: HseTheme.darkOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: HseTheme.darkOrange),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

