import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';

class SubmissionSuccessStep extends StatelessWidget {
  final HseWizardNotifier notifier;
  final VoidCallback onViewList;

  const SubmissionSuccessStep({
    Key? key,
    required this.notifier,
    required this.onViewList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticket = notifier.submittedTicket ?? const <String, dynamic>{};
    final findingNo = (ticket['finding_no'] ?? '-').toString();
    final entityType = (ticket['entity_type'] ?? '-').toString();
    final entityTitle = (ticket['entity_title'] ?? ticket['entity_id'] ?? '-').toString();
    final approver = (ticket['final_approver_role'] ?? '-').toString();
    final masterStatus = (ticket['entity_master_status'] ?? '-').toString();

    return Container(
      decoration: HseTheme.softCardDecoration(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const BoxDecoration(
              color: HseTheme.lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: HseTheme.primaryOrange,
                  child: Icon(Icons.pending_actions_rounded, color: Colors.white, size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  'Temuan Tercatat (Status ONGOING)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HseTheme.darkOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow('Nomor Tiket', findingNo, highlight: true),
                const SizedBox(height: 8),
                _detailRow('Tipe Entitas', entityType),
                const SizedBox(height: 8),
                _detailRow('Target', entityTitle),
                const SizedBox(height: 8),
                _detailRow('Status Master DB', masterStatus),
                const SizedBox(height: 8),
                _detailRow('Status Alur', 'ONGOING (Menunggu Approve -> BP)', highlight: true),
                const SizedBox(height: 8),
                _detailRow('Otoritas Approval', approver),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.accentOrange),
                        onPressed: notifier.resetWizard,
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Buat Temuan Baru'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.primaryOrange),
                        onPressed: () {
                          notifier.resetWizard();
                          onViewList();
                        },
                        icon: const Icon(Icons.list_alt_rounded,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Lihat Daftar'),
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

  Widget _detailRow(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: highlight ? HseTheme.lockRed : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

