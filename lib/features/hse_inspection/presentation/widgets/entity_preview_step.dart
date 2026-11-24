import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';

class EntityPreviewStep extends StatelessWidget {
  final HseWizardNotifier notifier;

  const EntityPreviewStep({Key? key, required this.notifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final target = notifier.previewEntity;
    if (target == null) {
      return Center(
        child: ElevatedButton(
          style: HseTheme.btnStyle(HseTheme.primaryOrange),
          onPressed: () => notifier.goToStep(0),
          child: HseTheme.btnLabel('Pilih Target Terlebih Dahulu'),
        ),
      );
    }

    final photoUrl = target.fullPhotoUrl;

    return Container(
      decoration: HseTheme.softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: HseTheme.lightOrange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    color: HseTheme.primaryOrange, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Step 2: Verifikasi Data Target',
                    style: TextStyle(
                      color: HseTheme.darkOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                HseStatusBadge(
                  text: HseEntityType.label(target.entityType),
                  bgColor: Colors.white,
                  textColor: HseTheme.darkOrange,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HseTheme.borderOrangeSoft),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: photoUrl.isNotEmpty
                            ? () => HseTheme.showImagePreviewDialog(
                                  context,
                                  imageUrl: photoUrl,
                                  title: target.title,
                                )
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 68,
                            height: 68,
                            color: HseTheme.lightOrange,
                            child: photoUrl.isEmpty
                                ? Icon(
                                    HseTheme.entityIcon(target.entityType),
                                    size: 34,
                                    color: HseTheme.primaryOrange,
                                  )
                                : Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      HseTheme.entityIcon(target.entityType),
                                      size: 34,
                                      color: HseTheme.primaryOrange,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.title,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${target.id}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: HseTheme.darkOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (target.subtitle.isNotEmpty)
                              Text(
                                target.subtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            if (target.detail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                target.detail,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _infoTile(
                  icon: Icons.info_outline,
                  label: 'Status Master Server',
                  value: target.statusMaster.isEmpty ? '-' : target.statusMaster,
                ),
                const SizedBox(height: 8),
                _infoTile(
                  icon: Icons.location_on_outlined,
                  label: target.entityType == HseEntityType.karyawan
                      ? 'Cabang / Divisi'
                      : 'Pool / Pangkalan',
                  value: target.branchOrPool.isEmpty ? '-' : target.branchOrPool,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: target.isLocked
                        ? HseTheme.lockRedBg
                        : HseTheme.unlockGreenBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: target.isLocked
                          ? HseTheme.lockRed.withAlpha(80)
                          : HseTheme.unlockGreen.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        target.isLocked
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        color: target.isLocked
                            ? HseTheme.lockRed
                            : HseTheme.unlockGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          target.isLocked
                              ? 'Saat ini SEDANG TERKUNCI (${target.activeLockTicket ?? target.statusMaster}). Anda tetap dapat menambahkan temuan baru jika ditemukan pelanggaran tambahan.'
                              : 'Status Saat Ini: NORMAL (Tidak Terkunci).',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: target.isLocked
                                ? HseTheme.lockRed
                                : HseTheme.unlockGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HseTheme.waitAmberBg,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: HseTheme.waitAmber.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: HseTheme.waitAmber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          HseEntityType.lockEffectHint(target.entityType),
                          style: const TextStyle(
                            fontSize: 12,
                            color: HseTheme.waitAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(Colors.grey.shade600),
                        onPressed: () => notifier.goToStep(0),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Ganti Target'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.primaryOrange),
                        onPressed: () => notifier.goToStep(2),
                        icon: const Icon(Icons.assignment_late_outlined,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Lanjut Isi Temuan'),
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

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: HseTheme.primaryOrange),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

