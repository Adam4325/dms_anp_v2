import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:dms_anp/features/hse_inspection/presentation/controllers/hse_wizard_notifier.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/entity_preview_step.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/entity_search_step.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/finding_form_step.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/hse_theme.dart';
import 'package:dms_anp/features/hse_inspection/presentation/widgets/submission_success_step.dart';
import 'package:flutter/material.dart';

class HseWizardPage extends StatefulWidget {
  final String username;
  final VoidCallback onFindingCreated;
  final VoidCallback onOpenListTab;
  final HseRepository? repository;

  const HseWizardPage({
    Key? key,
    required this.username,
    required this.onFindingCreated,
    required this.onOpenListTab,
    this.repository,
  }) : super(key: key);

  @override
  State<HseWizardPage> createState() => HseWizardPageState(); //
}

class HseWizardPageState extends State<HseWizardPage>
    with AutomaticKeepAliveClientMixin {
  late final HseWizardNotifier _notifier;
  int _lastStep = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _notifier = HseWizardNotifier(
      username: widget.username,
      repository: widget.repository,
    );
    _notifier.addListener(_handleStepChange);
    _notifier.init();
  }

  /// Steps backward within wizard steps 1..2; returns true if handled.
  bool handleBackStep() {
    if (_notifier.currentStep > 0 && _notifier.currentStep < 3) {
      _notifier.goToStep(_notifier.currentStep - 1);
      return true;
    }
    return false;
  }

  void _handleStepChange() {
    if (_notifier.currentStep == 3 && _lastStep != 3) {
      widget.onFindingCreated();
    }
    _lastStep = _notifier.currentStep;
  }

  @override
  void dispose() {
    _notifier.removeListener(_handleStepChange);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _notifier,
      builder: (context, _) {
        final step = _notifier.currentStep;
        return Container(
          color: HseTheme.backgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepperHeader(step),
                const SizedBox(height: 14),
                if (step == 0)
                  EntitySearchStep(notifier: _notifier)
                else if (step == 1)
                  EntityPreviewStep(notifier: _notifier)
                else if (step == 2)
                  FindingFormStep(notifier: _notifier)
                else
                  SubmissionSuccessStep(
                    notifier: _notifier,
                    onViewList: widget.onOpenListTab,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepperHeader(int currentStep) {
    const labels = ['1. Cari ID', '2. Preview', '3. Temuan', '4. Terkunci'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HseTheme.borderOrangeSoft),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == currentStep;
          final passed = i < currentStep;
          final color = active
              ? HseTheme.primaryOrange
              : (passed ? HseTheme.unlockGreen : Colors.grey.shade400);
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: color,
                        child: passed
                            ? const Icon(Icons.check,
                                size: 15, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? HseTheme.darkOrange
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < labels.length - 1)
                  Container(
                    width: 12,
                    height: 2,
                    color: passed ? HseTheme.unlockGreen : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
