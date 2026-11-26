import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/localized_text.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/fertilizer_program.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';
import 'package:lawnly/presentation/lawn/custom_program_page.dart';

class FertilizerProgramsPage extends StatefulWidget {
  const FertilizerProgramsPage({super.key});

  @override
  State<FertilizerProgramsPage> createState() => _FertilizerProgramsPageState();
}

class _FertilizerProgramsPageState extends State<FertilizerProgramsPage> {
  final _service = getIt<CareService>();

  String? _activeId;
  List<CustomProgram> _custom = const [];
  var _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final plan = await _service.plan().run();
    if (!mounted) return;
    setState(() {
      _activeId = plan.activeProgramId;
      _custom = plan.customPrograms;
    });
  }

  Future<void> _toggle(FertilizerProgram program) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;
    final enabling = _activeId != program.id;

    final saved = enabling
        ? await _service.activateProgram(program.id)
        : await _service.deactivateProgram();
    await _refresh();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          !saved
              ? strings.onboardingSaveError
              : enabling
              ? strings.programsEnabled
              : strings.programsDisabled,
        ),
      ),
    );
  }

  Future<void> _openForm([CustomProgram? program]) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => CustomProgramPage(program: program)));
    await _refresh();
  }

  Future<void> _delete(CustomProgram program) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;
    final deleted = await _service.deleteCustomProgram(program.id);
    await _refresh();
    messenger.showSnackBar(
      SnackBar(content: Text(deleted ? strings.programsDeleted : strings.onboardingSaveError)),
    );
  }

  FertilizerProgram _asProgram(CustomProgram custom) {
    final strings = context.strings;
    return FertilizerProgram(
      id: '${CustomProgram.idPrefix}${custom.id}',
      brand: '',
      name: LocalizedText.same(custom.name),
      summary: LocalizedText.same(
        strings.customSummary(
          custom.product,
          custom.doseGramsPerSqm,
          strings.daysCount(custom.intervalDays),
        ),
      ),
      steps: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.programsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          Text(strings.programsIntro, style: context.textTheme.bodyMedium),
          Gap.small,
          Text(strings.programsFixedNote, style: context.textTheme.bodyMedium),
          Gap.large,
          Text(strings.programsCustomTitle, style: context.textTheme.titleLarge),
          Gap.small,
          for (final custom in _custom) ...[
            _ProgramCard(
              program: _asProgram(custom),
              active: _activeId == '${CustomProgram.idPrefix}${custom.id}',
              busy: _busy,
              onToggle: () => _toggle(_asProgram(custom)),
              onEdit: () => _openForm(custom),
              onDelete: () => _delete(custom),
            ),
            Gap.medium,
          ],
          OutlinedButton.icon(
            onPressed: _openForm,
            icon: const Icon(Icons.add),
            label: Text(strings.programsCreate),
          ),
          for (final source in programSources) ...[
            Gap.large,
            Text(source.brand, style: context.textTheme.titleLarge),
            Gap.small,
            for (final program in source.programs) ...[
              _ProgramCard(
                program: program,
                active: _activeId == program.id,
                busy: _busy,
                onToggle: () => _toggle(program),
              ),
              Gap.medium,
            ],
            Text(
              strings.programsSource(source.brand, source.site),
              style: context.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.active,
    required this.busy,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  final FertilizerProgram program;
  final bool active;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return GuideCard(
      highlighted: active,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.small,
        children: [
          Row(
            spacing: Insets.small,
            children: [
              Expanded(child: Text(program.name.text, style: context.textTheme.titleMedium)),
              if (active) GuideBadge(strings.programsActive),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: strings.programsEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: strings.programsDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
            ],
          ),
          Text(program.summary.text, style: context.textTheme.bodyMedium),
          for (final step in program.steps)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.small,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    _window(context, step),
                    style: AppTheme.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: palette.primaryColor),
                  ),
                ),
                Expanded(child: Text(_label(context, step), style: context.textTheme.bodySmall)),
              ],
            ),
          Gap.xSmall,
          SizedBox(
            width: double.infinity,
            child: active
                ? OutlinedButton(
                    onPressed: busy ? null : onToggle,
                    child: Text(strings.programsDisable),
                  )
                : FilledButton(
                    onPressed: busy ? null : onToggle,
                    child: Text(strings.programsEnable),
                  ),
          ),
        ],
      ),
    );
  }

  String _window(BuildContext context, ProgramStep step) {
    if (step.fromMonth == step.toMonth) return capitalized(monthName(step.fromMonth));
    return context.strings.programsWindow(
      capitalized(monthName(step.fromMonth)),
      monthName(step.toMonth),
    );
  }

  String _label(BuildContext context, ProgramStep step) {
    if (!step.hasDose) return step.product.text;
    final dose = step.doseTo == null || step.doseTo == step.doseFrom
        ? '${step.doseFrom}'
        : '${step.doseFrom}–${step.doseTo}';
    return '${step.product.text}, ${context.strings.programsDose(dose)}';
  }
}
