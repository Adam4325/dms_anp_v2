import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:dms_anp/src/Helper/scanner_helper.dart';
import 'package:flutter/material.dart';

class EntitySearchStep extends StatefulWidget {
  final HseWizardNotifier notifier;

  const EntitySearchStep({Key? key, required this.notifier}) : super(key: key);

  @override
  State<EntitySearchStep> createState() => _EntitySearchStepState();
}

class _EntitySearchStepState extends State<EntitySearchStep> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.notifier.searchQuery;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final scanned = await openQrScanner(context);
    if (!mounted || scanned == null || scanned.trim().isEmpty) return;
    final clean = scanned.trim();
    _searchCtrl.text = clean;
    widget.notifier.setSearchQuery(clean);
    await widget.notifier.lookupAndAdvance(clean);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: HseTheme.softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: HseTheme.lightOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: HseTheme.primaryOrange, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Step 1: Pilih Entitas & Cari Target',
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
                    HseTheme.fieldLabel('Tipe Entitas Inspeksi'),
                    const SizedBox(height: 8),
                    Row(
                      children: HseEntityType.all.map((type) {
                        final selected = notifier.selectedEntityType == type;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: type == HseEntityType.mobil ? 0 : 8,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _searchCtrl.clear();
                                notifier.setSearchQuery('');
                                notifier.setEntityType(type);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? HseTheme.primaryOrange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? HseTheme.primaryOrange
                                        : HseTheme.borderOrangeMid,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      HseTheme.entityIcon(type),
                                      size: 20,
                                      color: selected
                                          ? Colors.white
                                          : HseTheme.darkOrange,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      type == HseEntityType.mobil
                                          ? 'Mobil'
                                          : HseEntityType.label(type),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    HseTheme.fieldLabel(
                      HseEntityType.searchLabel(notifier.selectedEntityType),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchCtrl,
                            builder: (context, value, _) {
                              return TextField(
                                controller: _searchCtrl,
                                focusNode: _searchFocusNode,
                                textInputAction: TextInputAction.search,
                                onChanged: (val) => notifier.setSearchQuery(val),
                                onSubmitted: (val) {
                                  _searchFocusNode.unfocus();
                                  notifier.searchEntities(val);
                                },
                                decoration: HseTheme.softDecoration(
                                  hint:
                                      'Ketik ${HseEntityType.searchLabel(notifier.selectedEntityType)}...',
                                  prefixIcon: const Icon(Icons.badge_outlined,
                                      color: HseTheme.primaryOrange, size: 20),
                                  suffixIcon: value.text.isEmpty
                                      ? null
                                      : IconButton(
                                          icon:
                                              const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            notifier.searchEntities('');
                                          },
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Scan Barcode / QR',
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              style: HseTheme.btnStyle(HseTheme.accentOrange),
                              onPressed: notifier.isLookingUp ? null : _scanBarcode,
                              child: const Icon(Icons.qr_code_scanner_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: HseTheme.btnStyle(HseTheme.accentOrange),
                            onPressed: notifier.isSearching
                                ? null
                                : () {
                                    _searchFocusNode.unfocus();
                                    notifier.searchEntities(_searchCtrl.text);
                                  },
                            icon: const Icon(Icons.search,
                                color: Colors.white, size: 18),
                            label: HseTheme.btnLabel('Cari Daftar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: HseTheme.btnStyle(HseTheme.primaryOrange),
                            onPressed: notifier.isLookingUp
                                ? null
                                : () => notifier
                                    .lookupAndAdvance(_searchCtrl.text),
                            icon: notifier.isLookingUp
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                            label: HseTheme.btnLabel('Pilih ID Ini'),
                          ),
                        ),
                      ],
                    ),
                    if (notifier.lookupError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: HseTheme.lockRedBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: HseTheme.lockRed.withAlpha(80)),
                        ),
                        child: Text(
                          notifier.lookupError!,
                          style: const TextStyle(
                            color: HseTheme.lockRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            HseTheme.fieldLabel(
                'Daftar ${HseEntityType.label(notifier.selectedEntityType)} (${notifier.suggestions.length})'),
            const Spacer(),
            if (notifier.isSearching)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HseTheme.primaryOrange,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!notifier.isSearching && notifier.suggestions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'Tidak ada data yang cocok. Coba kata kunci lain atau tekan Scan QR.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifier.suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final item = notifier.suggestions[idx];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: notifier.isLookingUp
                    ? null
                    : () => notifier.lookupAndAdvance(item.id),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isLocked
                          ? HseTheme.lockRed.withAlpha(90)
                          : HseTheme.borderOrangeSoft,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: HseTheme.shadowColor,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: item.isLocked
                            ? HseTheme.lockRedBg
                            : HseTheme.lightOrange,
                        child: Icon(
                          HseTheme.entityIcon(item.entityType),
                          color: item.isLocked
                              ? HseTheme.lockRed
                              : HseTheme.darkOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (item.entityType == HseEntityType.driver &&
                                      !item.subtitle
                                          .toUpperCase()
                                          .contains('DRVID'))
                                  ? 'DRVID: ${item.id} | ${item.subtitle}'
                                  : item.subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              item.detail,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.isLocked)
                            const HseStatusBadge(
                              text: 'LOCKED',
                              bgColor: HseTheme.lockRedBg,
                              textColor: HseTheme.lockRed,
                              icon: Icons.lock_rounded,
                            )
                          else
                            const HseStatusBadge(
                              text: 'NORMAL',
                              bgColor: HseTheme.unlockGreenBg,
                              textColor: HseTheme.unlockGreen,
                              icon: Icons.check_circle_outline,
                            ),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right,
                              color: HseTheme.primaryOrange, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

