import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';

Future<void> showAddTaskSheet(
  BuildContext context, {
  required CalendarCubit cubit,
  required DateTime initialDate,
  PlannedTask? task,
  CareKind? kind,
  String? note,
}) => showModalBottomSheet<void>(
  context: context,
  sheetAnimationStyle: AppMotion.sheet,
  isScrollControlled: true,
  builder: (_) =>
      _AddTaskSheet(cubit: cubit, initialDate: initialDate, task: task, kind: kind, note: note),
);

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({
    required this.cubit,
    required this.initialDate,
    this.task,
    this.kind,
    this.note,
  });

  final CalendarCubit cubit;
  final DateTime initialDate;
  final PlannedTask? task;
  final CareKind? kind;
  final String? note;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late CareKind? _kind = widget.task?.kind ?? widget.kind;
  late DateTime _date = widget.initialDate;
  late bool _flexible = widget.task?.flexible ?? true;
  late final _note = TextEditingController(text: widget.task?.note ?? widget.note ?? '');
  var _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = widget.cubit.state.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _date.isBefore(today) ? _date : today,
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final kind = _kind;
    if (kind == null || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = context.strings.onboardingSaveError;
    final note = _note.text.trim();

    final saved = await widget.cubit.saveTask(
      PlannedTask(
        id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        kind: kind,
        date: _date,
        flexible: _flexible,
        note: note.isEmpty ? null : note,
      ),
    );
    if (saved) {
      navigator.pop();
    } else {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final kind = _kind;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.large,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task == null ? strings.addTitle : strings.addEditTitle,
                      style: context.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: strings.sheetClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              LabeledField(
                label: FieldLabel(strings.addKind),
                child: Wrap(
                  spacing: Insets.small,
                  runSpacing: Insets.small,
                  children: [
                    for (final option in CareKind.values)
                      _KindChip(
                        label: option.label(context),
                        selected: option == kind,
                        onTap: () => setState(() => _kind = option),
                      ),
                  ],
                ),
              ),
              LabeledField(
                label: FieldLabel(strings.addDate),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Insets.small,
                  children: [
                    PickerField(
                      text: context.longDate(_date),
                      hint: strings.feedLastHint,
                      onTap: _pickDate,
                    ),
                    if (kind != null)
                      if (ageLimitedTopic(kind) case final topic?
                          when topic.tooYoung(widget.cubit.state.profile, _date))
                        _AgeNote(
                          kind: kind,
                          readyOn: topic.readyOn(widget.cubit.state.profile!)!,
                          moveTo: topic.planDate(_date, profile: widget.cubit.state.profile),
                          onMove: (date) => setState(() => _date = date),
                        ),
                    if (kind != null)
                      _WeatherNote(
                        check: widget.cubit.checkWeather(kind, _date),
                        kind: kind,
                        onMove: (date) => setState(() => _date = date),
                      ),
                  ],
                ),
              ),
              LabeledField(
                label: FieldLabel(strings.addFlexLabel),
                helper: _flexible ? strings.addFlexHelper : null,
                child: SegmentedChoice<bool>(
                  values: const [false, true],
                  selected: _flexible,
                  fontSize: 14,
                  labelOf: (flexible) => flexible ? strings.addFitWeather : strings.addKeepDay,
                  onSelected: (flexible) => setState(() => _flexible = flexible),
                ),
              ),
              LabeledField(
                label: FieldLabel(strings.addNote, suffix: strings.commonOptional),
                child: TextField(
                  controller: _note,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: strings.addNoteHint),
                ),
              ),
              FilledButton(
                onPressed: kind == null || _saving ? null : _save,
                child: Text(strings.addSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ChoiceTile(
      selected: selected,
      alignment: null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: Text(
        label,
        style: AppTheme.body(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ).copyWith(color: selected ? palette.headingColor : palette.secondaryTextColor),
      ),
    );
  }
}

class _AgeNote extends StatelessWidget {
  const _AgeNote({
    required this.kind,
    required this.readyOn,
    required this.moveTo,
    required this.onMove,
  });

  final CareKind kind;

  final DateTime readyOn;

  final DateTime moveTo;
  final ValueChanged<DateTime> onMove;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
      decoration: BoxDecoration(
        color: palette.warningTintColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.medium,
        children: [
          Icon(Icons.spa_outlined, size: 22, color: palette.onWarningColor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.small,
              children: [
                Text(
                  strings.addTooYoung(
                    kind.label(context).toLowerCase(),
                    DateFormat('LLLL yyyy').format(readyOn),
                  ),
                  style: AppTheme.body(
                    fontSize: 14,
                  ).copyWith(color: palette.onWarningColor, height: 1.45),
                ),
                OutlinedButton(
                  onPressed: () => onMove(moveTo),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    backgroundColor: palette.cardColor,
                    foregroundColor: palette.onWarningColor,
                    side: BorderSide(color: palette.warningOutlineColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: AppTheme.body(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: Text(strings.addMoveToReady(context.longDate(moveTo))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherNote extends StatelessWidget {
  const _WeatherNote({required this.check, required this.kind, required this.onMove});

  final WeatherCheck check;
  final CareKind kind;
  final ValueChanged<DateTime> onMove;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    switch (check) {
      case NoForecast():
        return TipCard(icon: Icons.cloud_outlined, text: strings.addNoForecast);
      case GoodWeather(:final day):
        return TipCard(
          icon: Icons.check_circle_outline,
          text: strings.addGoodWeather(context.weekdayDate(day.date), context.weatherSummary(day)),
        );
      case BadWeather(:final day, :final suggestion):
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
          decoration: BoxDecoration(
            color: palette.warningTintColor,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.medium,
            children: [
              Icon(Icons.umbrella_outlined, size: 22, color: palette.onWarningColor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.small,
                  children: [
                    Text(
                      strings.addBadWeather(
                        context.weekdayDate(day.date),
                        context.weatherSummary(day),
                        strings.careWeatherHint(kind.name),
                      ),
                      style: AppTheme.body(
                        fontSize: 14,
                      ).copyWith(color: palette.onWarningColor, height: 1.45),
                    ),
                    if (suggestion != null)
                      OutlinedButton(
                        onPressed: () => onMove(suggestion.date),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          backgroundColor: palette.cardColor,
                          foregroundColor: palette.onWarningColor,
                          side: BorderSide(color: palette.warningOutlineColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: AppTheme.body(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        child: Text(
                          strings.addMoveTo(
                            context.weekdayDate(suggestion.date),
                            context.weatherSummary(suggestion),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
