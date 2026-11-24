import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FindingFormStep extends StatefulWidget {
  final HseWizardNotifier notifier;

  const FindingFormStep({Key? key, required this.notifier}) : super(key: key);

  @override
  State<FindingFormStep> createState() => _FindingFormStepState();
}

class _FindingFormStepState extends State<FindingFormStep> {
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descCtrl.text = widget.notifier.description;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HseTheme.primaryOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final err = await widget.notifier.pickEvidenceBefore(source);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: HseTheme.lockRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier;
    final target = notifier.previewEntity;
    final df = DateFormat('dd MMM yyyy');
    final categories = notifier.violationTypes.map((e) => e.categoryName).toList();
    final sanctions = notifier.sanctionOptions;

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
                const Icon(Icons.edit_note_rounded,
                    color: HseTheme.primaryOrange, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Step 3: Form Pelanggaran & Bukti Foto',
                    style: TextStyle(
                      color: HseTheme.darkOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (target != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HseTheme.borderOrangeSoft),
                    ),
                    child: Row(
                      children: [
                        Icon(HseTheme.entityIcon(target.entityType),
                            color: HseTheme.darkOrange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${target.title} (${target.id})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                HseTheme.fieldLabel('Tanggal Kejadian'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickDate(
                    initial: notifier.incidentDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    onSelected: notifier.setIncidentDate,
                  ),
                  child: InputDecorator(
                    decoration: HseTheme.softDecoration(
                      prefixIcon: const Icon(Icons.calendar_today_outlined,
                          color: HseTheme.primaryOrange, size: 19),
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: HseTheme.darkOrange),
                    ),
                    child: Text(
                      df.format(notifier.incidentDate),
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                HseTheme.fieldLabel('Kategori Pelanggaran K3 / SHE'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('cat_${notifier.selectedEntityType}_${categories.length}'),
                  initialValue: categories.contains(notifier.selectedCategory)
                      ? notifier.selectedCategory
                      : (categories.isNotEmpty ? categories.first : null),
                  isExpanded: true,
                  decoration: HseTheme.softDecoration(
                    prefixIcon: const Icon(Icons.category_outlined,
                        color: HseTheme.primaryOrange, size: 19),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: notifier.setCategory,
                ),
                const SizedBox(height: 12),
                HseTheme.fieldLabel('Tingkat Sanksi / Tindakan'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey('sanc_${notifier.selectedEntityType}'),
                  initialValue: sanctions.contains(notifier.selectedSanction)
                      ? notifier.selectedSanction
                      : (sanctions.isNotEmpty ? sanctions.first : null),
                  isExpanded: true,
                  decoration: HseTheme.softDecoration(
                    prefixIcon: const Icon(Icons.gavel_rounded,
                        color: HseTheme.primaryOrange, size: 19),
                  ),
                  items: sanctions
                      .map((s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: notifier.setSanction,
                ),
                const SizedBox(height: 12),
                HseTheme.fieldLabel('Batas Waktu Tindak Lanjut (Due Date)'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickDate(
                    initial: notifier.dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onSelected: notifier.setDueDate,
                  ),
                  child: InputDecorator(
                    decoration: HseTheme.softDecoration(
                      prefixIcon: const Icon(Icons.event_available_outlined,
                          color: HseTheme.primaryOrange, size: 19),
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: HseTheme.darkOrange),
                    ),
                    child: Text(
                      '${df.format(notifier.dueDate)} (17:00)',
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                HseTheme.fieldLabel('Deskripsi Rinci Pelanggaran'),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  onChanged: notifier.setDescription,
                  decoration: HseTheme.softDecoration(
                    hint:
                        'Tuliskan kronologi, lokasi temuan, atau kondisi ketidaksesuaian...',
                  ),
                ),
                const SizedBox(height: 14),
                HseTheme.fieldLabel('Bukti Foto Temuan (Evidence Before) *'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.primaryOrange),
                        onPressed: notifier.isSubmitting
                            ? null
                            : () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Kamera'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.accentOrange),
                        onPressed: notifier.isSubmitting
                            ? null
                            : () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Galeri'),
                      ),
                    ),
                  ],
                ),
                if (notifier.evidenceBeforeFile != null) ...[
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          notifier.evidenceBeforeFile!,
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: notifier.clearEvidencePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (notifier.submitError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HseTheme.lockRedBg,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: HseTheme.lockRed.withAlpha(80)),
                    ),
                    child: Text(
                      notifier.submitError!,
                      style: const TextStyle(
                        color: HseTheme.lockRed,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(Colors.grey.shade600),
                        onPressed: notifier.isSubmitting
                            ? null
                            : () => notifier.goToStep(1),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 18),
                        label: HseTheme.btnLabel('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: HseTheme.btnStyle(HseTheme.darkOrange),
                        onPressed: notifier.isSubmitting
                            ? null
                            : () {
                                notifier.setDescription(_descCtrl.text);
                                notifier.submitFinding();
                              },
                        icon: notifier.isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined,
                                color: Colors.white, size: 18),
                        label: HseTheme.btnLabel(
                          notifier.isSubmitting
                              ? 'Menyimpan...'
                              : 'Simpan Temuan (ONGOING)',
                        ),
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
}

