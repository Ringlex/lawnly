import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/watering_hint.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/lawn/calibration_page.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';

class LawnCarePage extends StatefulWidget {
  const LawnCarePage({super.key});

  @override
  State<LawnCarePage> createState() => _LawnCarePageState();
}

class _LawnCarePageState extends State<LawnCarePage> {
  static const _defaultHeightCm = 4;

  late final LawnCubit _cubit = context.read<LawnCubit>();
  late LawnProfile _draft = _cubit.state.profile!;
  var _saving = false;
  String? _programName;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgram());
  }

  Future<void> _loadProgram() async {
    final plan = await getIt<CareService>().plan().run();
    final id = plan.activeProgramId;
    final custom = plan.customPrograms.where((p) => '${CustomProgram.idPrefix}${p.id}' == id);
    final name = custom.firstOrNull?.name ?? programById(id)?.name.text;
    if (mounted) setState(() => _programName = name);
  }

  void _update(LawnProfile Function(LawnProfile profile) change) =>
      setState(() => _draft = change(_draft));

  bool get _seasonValid {
    final season = _draft.season;
    return season.startOf(2000).isBefore(season.endOf(2000));
  }

  Future<void> _pickSeasonDay({required bool start}) async {
    final year = DateTime.now().year;
    final season = _draft.season;
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? season.startOf(year) : season.endOf(year),
      firstDate: DateTime(year),
      lastDate: DateTime(year, 12, 31),
    );
    if (picked == null) return;
    _update(
      (profile) => start
          ? profile.copyWith(seasonStartMonth: picked.month, seasonStartDay: picked.day)
          : profile.copyWith(seasonEndMonth: picked.month, seasonEndDay: picked.day),
    );
  }

  Future<void> _save() async {
    if (_saving || !_seasonValid || _draft.gardenWeekdays.isEmpty) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;

    final saved = await _cubit.save(_draft);
    messenger.showSnackBar(
      SnackBar(content: Text(saved ? strings.lawnSaved : strings.onboardingSaveError)),
    );
    if (saved) {
      navigator.pop();
    } else if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final window = FertilizingWindow(_draft.fertilizingIntervalDays);
    final height = _draft.mowingHeightCm?.round() ?? _defaultHeightCm;
    final minutes = _draft.sprinklerMinutes ?? 20;
    final rate = _draft.sprinklerMmPerMinute;
    final dayFormat = DateFormat('d MMMM');
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: Text(strings.lawnCare)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.medium,
            children: [
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.careMowingLabel),
                  child: DayStepper(
                    value: _draft.mowingIntervalDays,
                    label: strings.daysCount(_draft.mowingIntervalDays),
                    min: 2,
                    max: 21,
                    decreaseLabel: strings.commonLess,
                    increaseLabel: strings.commonMore,
                    onChanged: (days) => _update((p) => p.copyWith(mowingIntervalDays: days)),
                  ),
                ),
              ),
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.lawnHeight),
                  child: DayStepper(
                    value: height,
                    label: strings.lawnHeightValue(height),
                    min: 2,
                    max: 10,
                    decreaseLabel: strings.commonLess,
                    increaseLabel: strings.commonMore,
                    onChanged: (cm) => _update((p) => p.copyWith(mowingHeightCm: cm.toDouble())),
                  ),
                ),
              ),
            ],
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.feedIntervalLabel),
            child: _programName != null
                ? Text(
                    strings.programsControlsDates(_programName!),
                    style: context.textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Insets.small,
                    children: [
                      DayStepper(
                        value: _draft.fertilizingIntervalDays,
                        label: strings.daysCount(_draft.fertilizingIntervalDays),
                        min: 7,
                        max: 90,
                        decreaseLabel: strings.commonLess,
                        increaseLabel: strings.commonMore,
                        onChanged: (days) =>
                            _update((p) => p.copyWith(fertilizingIntervalDays: days)),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.feedWindowLabel,
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            strings.feedWindowRange(window.start, window.end),
                            style: context.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.lawnGardenDays),
            child: Row(
              spacing: 6,
              children: [
                for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
                  Expanded(
                    child: ChoiceTile(
                      selected: _draft.gardenWeekdays.contains(weekday),
                      height: 44,
                      padding: EdgeInsets.zero,
                      onTap: () => _update((p) {
                        final days = <int>{...p.gardenWeekdays};
                        if (!days.remove(weekday)) days.add(weekday);
                        return p.copyWith(gardenWeekdays: days);
                      }),
                      child: Text(
                        context.weekdayShort(weekday),
                        style: AppTheme.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: palette.headingColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.lawnWatering),
            helper: switch (_draft.watering) {
              WateringMode.automatic when rate != null => strings.lawnSectionMm(
                formatDecimal(minutes * rate),
              ),
              WateringMode.manual when _draft.manualWateringMethod != null => wateringHint(
                context,
                _draft,
              ),
              _ => null,
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Insets.small,
              children: [
                SegmentedChoice<WateringMode>(
                  values: WateringMode.values,
                  selected: _draft.watering,
                  labelOf: (mode) => switch (mode) {
                    WateringMode.automatic => strings.careWateringAuto,
                    WateringMode.manual => strings.careWateringManual,
                  },
                  onSelected: (mode) => _update(
                    (p) => p.copyWith(
                      watering: mode,
                      sprinklerMinutes: mode == WateringMode.automatic ? minutes : null,
                    ),
                  ),
                ),
                if (_draft.watering == WateringMode.manual)
                  ManualMethodChoice(
                    selected: _draft.manualWateringMethod,
                    onSelected: (method) =>
                        _update((p) => p.copyWith(manualWateringMethod: method)),
                  )
                else
                  DayStepper(
                    value: minutes,
                    label: '$minutes ${strings.commonMinutes}',
                    min: 5,
                    max: 90,
                    decreaseLabel: strings.commonLess,
                    increaseLabel: strings.commonMore,
                    onChanged: (value) => _update((p) => p.copyWith(sprinklerMinutes: value)),
                  ),
              ],
            ),
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.lawnSeason),
            helper: _seasonValid ? strings.lawnSeasonHelper : strings.lawnSeasonInvalid,
            child: Row(
              spacing: Insets.medium,
              children: [
                Expanded(
                  child: _SeasonField(
                    label: strings.lawnSeasonStart,
                    value: dayFormat.format(_draft.season.startOf(year)),
                    onTap: () => _pickSeasonDay(start: true),
                  ),
                ),
                Expanded(
                  child: _SeasonField(
                    label: strings.lawnSeasonEnd,
                    value: dayFormat.format(_draft.season.endOf(year)),
                    onTap: () => _pickSeasonDay(start: false),
                  ),
                ),
              ],
            ),
          ),
          Gap.xLarge,
          FilledButton(
            onPressed: !_saving && _seasonValid && _draft.gardenWeekdays.isNotEmpty ? _save : null,
            child: Text(strings.lawnSave),
          ),
        ],
      ),
    );
  }
}

class _SeasonField extends StatelessWidget {
  const _SeasonField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: Insets.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.textTheme.labelSmall),
              Text(value, style: context.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
