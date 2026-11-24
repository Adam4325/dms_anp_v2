import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/features/hse_inspection/data/datasources/hse_remote_datasource.dart';
import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HseFindingDetailPage extends StatefulWidget {
  final HseFindingItem initialItem;
  final String username;
  final HseRepository? repository;

  const HseFindingDetailPage({
    Key? key,
    required this.initialItem,
    required this.username,
    this.repository,
  }) : super(key: key);

  @override
  State<HseFindingDetailPage> createState() => _HseFindingDetailPageState();
}

class _HseFindingDetailPageState extends State<HseFindingDetailPage> {
  late final HseRepository _repo;
  late HseFindingItem _item;
  bool _loading = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? HseRemoteDataSource();
    _item = widget.initialItem;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final fresh = await _repo.detailFinding(
        username: widget.username,
        findingNo: _item.findingNo,
      );
      if (mounted) setState(() => _item = fresh);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? HseTheme.lockRed : HseTheme.unlockGreen,
      ),
    );
  }

  Future<void> _openRepairSheet() async {
    final msg = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RepairSheetDialog(
        onSubmit: (note, b64) => _repo.submitRepair(
          username: widget.username,
          findingNo: _item.findingNo,
          repairActionNote: note,
          evidenceAfterBase64: b64,
        ),
      ),
    );
    if (!mounted || msg == null) return;
    _changed = true;
    _showMsg(msg);
    await _refresh();
  }

  Future<void> _openApprovalDialog({
    required String stage, // 'BP' | 'SHE' | 'FINAL'
    required bool isApprove,
  }) async {
    String title;
    String promptText;
    if (stage == 'BP') {
      title = isApprove ? 'Konfirmasi Approve' : 'Tolak Temuan ONGOING';
      promptText = isApprove
          ? 'Menyetujui temuan ONGOING akan mengupdate status master ${_item.entityType} (${_item.entityId}) menjadi BP dan mengunci entitas (IS_LOCKED = 1).'
          : 'Berikan catatan penolakan untuk tiket ${_item.findingNo}:';
    } else if (stage == 'FINAL') {
      title = isApprove ? 'Konfirmasi Final Approve & Unlock' : 'Tolak Final Approval';
      promptText = isApprove
          ? 'Menyetujui Final Approval akan membuka kunci (IS_LOCKED = 0) dan memulihkan status ${_item.entityType} (${_item.entityId}) menjadi Active.'
          : 'Berikan catatan keputusan untuk tiket ${_item.findingNo}:';
    } else {
      title = isApprove ? 'Setujui Verifikasi SHE' : 'Tolak Verifikasi SHE';
      promptText = 'Berikan catatan keputusan untuk tiket ${_item.findingNo}:';
    }

    final notes = await showDialog<String>(
      context: context,
      builder: (_) => _ApprovalDecisionDialog(
        title: title,
        promptText: promptText,
        isApprove: isApprove,
      ),
    );
    if (!mounted || notes == null) return;

    setState(() => _loading = true);
    try {
      final status = isApprove ? 'APPROVED' : 'REJECTED';
      final msg = stage == 'BP'
          ? await _repo.approveBp(
              username: widget.username,
              findingNo: _item.findingNo,
              status: status,
              notes: notes,
            )
          : (stage == 'FINAL'
              ? await _repo.finalApprove(
                  username: widget.username,
                  findingNo: _item.findingNo,
                  status: status,
                  notes: notes,
                )
              : await _repo.verifyShe(
                  username: widget.username,
                  findingNo: _item.findingNo,
                  status: status,
                  notes: notes,
                ));
      _changed = true;
      _showMsg(msg);
      await _refresh();
    } catch (e) {
      _showMsg(e.toString(), isError: true);
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final beforeUrl = _item.fullBeforeUrl;
    final afterUrl = _item.fullAfterUrl;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: HseTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: HseTheme.primaryOrange,
          foregroundColor: Colors.white,
          title: Text(
            _item.findingNo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _refresh,
            ),
          ],
        ),
        body: _loading && _item.findingNo.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: HseTheme.primaryOrange,
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 12),
                    _buildWorkflowStepper(),
                    const SizedBox(height: 12),
                    _buildDetailCard('Detail Pelanggaran', [
                      _row('Tanggal Kejadian', _item.incidentDate),
                      _row('Kategori', _item.violationCategory),
                      _row('Tingkat Sanksi', _item.sanctionLevel),
                      _row('Due Date', _item.dueDate.isEmpty ? '-' : _item.dueDate),
                      _row('Dibuat Oleh', '${_item.createdBy} (${_item.createdAt})'),
                      const SizedBox(height: 8),
                      HseTheme.fieldLabel('Deskripsi:'),
                      const SizedBox(height: 4),
                      Text(
                        _item.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildPhotoCard(
                      'Bukti Foto Temuan (Before)',
                      beforeUrl,
                    ),
                    if (_item.repairActionNote.isNotEmpty ||
                        afterUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailCard('Tindakan Perbaikan (After)', [
                        _row('PIC Perbaikan', _item.repairedBy),
                        _row('Tanggal Perbaikan', _item.repairedDate),
                        const SizedBox(height: 6),
                        Text(
                          _item.repairActionNote,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade800),
                        ),
                      ]),
                      if (afterUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildPhotoCard('Bukti Foto Perbaikan (After)', afterUrl),
                      ],
                    ],
                    if (_item.sheVerifiedBy.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailCard('Verifikasi Tahap 1 (SHE)', [
                        _row('Oleh', _item.sheVerifiedBy),
                        _row('Tanggal', _item.sheVerifiedDate),
                        _row(
                          'Status',
                          _item.sheVerified ? 'DISETUJUI' : 'DITOLAK',
                        ),
                        if (_item.sheNotes.isNotEmpty)
                          _row('Catatan', _item.sheNotes),
                      ]),
                    ],
                    if (_item.finalApprovedBy.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        'Final Approval (${_item.finalApproverRole})',
                        [
                          _row('Oleh', _item.finalApprovedBy),
                          _row('Tanggal', _item.finalApprovedDate),
                          _row(
                            'Keputusan',
                            _item.finalApproved
                                ? 'APPROVED (UNLOCKED)'
                                : 'REJECTED',
                          ),
                          if (_item.finalNotes.isNotEmpty)
                            _row('Catatan', _item.finalNotes),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildActionSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: HseTheme.softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _item.isLocked
                    ? HseTheme.lockRedBg
                    : HseTheme.unlockGreenBg,
                child: Icon(
                  HseTheme.entityIcon(_item.entityType),
                  color: _item.isLocked
                      ? HseTheme.lockRed
                      : HseTheme.unlockGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _item.entityName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_item.entityType} | ID: ${_item.entityId}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              HseStatusBadge.fromStatusFlow(_item.statusFlow, _item.isLocked),
              HseStatusBadge(
                text: 'Status Master: ${_item.entityMasterStatus.isEmpty ? '-' : _item.entityMasterStatus}',
                bgColor: (_item.entityMasterStatus == 'BP' ||
                        _item.entityMasterStatus == 'BLOCKED')
                    ? HseTheme.lockRedBg
                    : Colors.white,
                textColor: (_item.entityMasterStatus == 'BP' ||
                        _item.entityMasterStatus == 'BLOCKED')
                    ? HseTheme.lockRed
                    : Colors.grey.shade800,
              ),
              HseStatusBadge(
                text: 'Approver: ${_item.finalApproverRole}',
                bgColor: HseTheme.lightOrange,
                textColor: HseTheme.darkOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStepper() {
    final sf = _item.statusFlow;
    final step1Done = true;
    final step2Done = sf == 'BP' ||
        sf == 'IN_PROGRESS' ||
        sf == 'WAITING_SHE' ||
        sf == 'WAITING_FINAL' ||
        sf == 'COMPLETE' ||
        (sf == 'REJECTED' && _item.isLocked);
    final step3Done =
        sf == 'WAITING_SHE' || sf == 'WAITING_FINAL' || sf == 'COMPLETE';
    final step4Done = sf == 'WAITING_FINAL' || sf == 'COMPLETE';
    final step5Done = sf == 'COMPLETE';

    Widget node(String label, bool done) {
      return Expanded(
        child: Column(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor:
                  done ? HseTheme.unlockGreen : Colors.grey.shade300,
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                color: done ? HseTheme.unlockGreen : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.borderOrangeSoft),
      ),
      child: Row(
        children: [
          node('1. Ongoing', step1Done),
          node('2. BP', step2Done),
          node('3. After', step3Done),
          node('4. SHE', step4Done),
          node('5. Unlock', step5Done),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.borderOrangeSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HseTheme.darkOrange,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              k,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String title, String url) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.borderOrangeSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HseTheme.darkOrange,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (url.isEmpty)
            const Text('Tidak ada foto')
          else
            GestureDetector(
              onTap: () => HseTheme.showImagePreviewDialog(
                context,
                imageUrl: url,
                title: title,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: HseTheme.lightOrange,
                    alignment: Alignment.center,
                    child: const Text('Foto gagal dimuat'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    final sections = <Widget>[];

    if (_item.canApproveBp) {
      sections.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: HseTheme.softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Approval Temuan (${_item.finalApproverRole})',
                style: const TextStyle(
                  color: HseTheme.darkOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Approve akan menyetujui temuan pelanggaran ${_item.entityType} (${_item.entityId}).',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.lockRed),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'BP',
                                isApprove: false,
                              ),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.unlockGreen),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'BP',
                                isApprove: true,
                              ),
                      icon: const Icon(Icons.verified_user_outlined,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('APPROVED'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_item.canFinalApprove) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 12));
      sections.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: HseTheme.softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Final Approval (${_item.finalApproverRole}) - Buka Kunci',
                style: const TextStyle(
                  color: HseTheme.darkOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.lockRed),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'FINAL',
                                isApprove: false,
                              ),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.unlockGreen),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'FINAL',
                                isApprove: true,
                              ),
                      icon: const Icon(Icons.lock_open_rounded,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('APPROVED & UNLOCK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_item.canVerifyShe) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 12));
      sections.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: HseTheme.softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verifikasi Tahap 1 (Tim SHE / HD)',
                style: TextStyle(
                  color: HseTheme.darkOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.lockRed),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'SHE',
                                isApprove: false,
                              ),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.unlockGreen),
                      onPressed: _loading
                          ? null
                          : () => _openApprovalDialog(
                                stage: 'SHE',
                                isApprove: true,
                              ),
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Setujui SHE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_item.canRepair) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 12));
      sections.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: HseTheme.btnStyle(HseTheme.primaryOrange),
            onPressed: _loading ? null : _openRepairSheet,
            icon: const Icon(Icons.build_circle_outlined,
                color: Colors.white, size: 20),
            label: HseTheme.btnLabel('Input Tindakan Perbaikan (After)'),
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

class _RepairSheetDialog extends StatefulWidget {
  final Future<String> Function(String note, String imageB64) onSubmit;

  const _RepairSheetDialog({required this.onSubmit});

  @override
  State<_RepairSheetDialog> createState() => _RepairSheetDialogState();
}

class _RepairSheetDialogState extends State<_RepairSheetDialog> {
  final TextEditingController _noteCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _afterFile;
  String _afterB64 = '';
  bool _submitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImg(ImageSource src) async {
    final picked = await _picker.pickImage(
      source: src,
      imageQuality: 75,
      maxWidth: 1280,
    );
    if (picked == null || !mounted) return;
    final f = File(picked.path);
    final b = await f.readAsBytes();
    if (!mounted) return;
    setState(() {
      _afterFile = f;
      _afterB64 = base64Encode(b);
      _errorMsg = null;
    });
  }

  Future<void> _submit() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty || _afterB64.isEmpty) {
      setState(() {
        _errorMsg = 'Catatan perbaikan dan foto after wajib dilengkapi.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _errorMsg = null;
    });
    try {
      final msg = await widget.onSubmit(note, _afterB64);
      if (!mounted) return;
      Navigator.pop(context, msg);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: HseTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.build_circle_outlined,
                      color: HseTheme.primaryOrange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Input Tindakan Perbaikan (Action After)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: HseTheme.darkOrange,
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: HseTheme.lockRedBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: HseTheme.lockRed, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              HseTheme.fieldLabel('Catatan Perbaikan'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: HseTheme.softDecoration(
                  hint: 'Jelaskan perbaikan yang telah diselesaikan...',
                ),
              ),
              const SizedBox(height: 12),
              HseTheme.fieldLabel('Foto Bukti Perbaikan (After) *'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.primaryOrange),
                      onPressed:
                          _submitting ? null : () => _pickImg(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Kamera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: HseTheme.btnStyle(HseTheme.accentOrange),
                      onPressed: _submitting
                          ? null
                          : () => _pickImg(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 18),
                      label: HseTheme.btnLabel('Galeri'),
                    ),
                  ),
                ],
              ),
              if (_afterFile != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _afterFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: HseTheme.btnStyle(HseTheme.darkOrange),
                  onPressed: _submitting ? null : _submit,
                  child: HseTheme.btnLabel(
                    _submitting ? 'Mengirim...' : 'Kirim Perbaikan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalDecisionDialog extends StatefulWidget {
  final String title;
  final String promptText;
  final bool isApprove;

  const _ApprovalDecisionDialog({
    required this.title,
    required this.promptText,
    required this.isApprove,
  });

  @override
  State<_ApprovalDecisionDialog> createState() =>
      _ApprovalDecisionDialogState();
}

class _ApprovalDecisionDialogState extends State<_ApprovalDecisionDialog> {
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HseTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: TextStyle(
          color: widget.isApprove ? HseTheme.unlockGreen : HseTheme.lockRed,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.promptText,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: HseTheme.softDecoration(
              hint: widget.isApprove
                  ? 'Catatan (opsional)'
                  : 'Alasan penolakan...',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: HseTheme.btnStyle(Colors.grey.shade600),
          onPressed: () => Navigator.pop(context),
          child: HseTheme.btnLabel('Batal'),
        ),
        ElevatedButton(
          style: HseTheme.btnStyle(
            widget.isApprove ? HseTheme.unlockGreen : HseTheme.lockRed,
          ),
          onPressed: () => Navigator.pop(context, _notesCtrl.text.trim()),
          child: HseTheme.btnLabel(widget.isApprove ? 'APPROVED' : 'REJECTED'),
        ),
      ],
    );
  }
}

