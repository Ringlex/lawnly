import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

class CareStep extends StatefulWidget {
  const CareStep({super.key});

  @override
  State<CareStep> createState() => _CareStepState();
}

class _CareStepState extends State<CareStep> {
  late final TextEditingController _minutes;

  @override
  void initState() {
    super.initState();
    final minutes = context.read<OnboardingCubit>().state.draft.sprinklerMinutes;
    _minutes = TextEditingController(text: '$minutes');
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _pickLastMowed(OnboardingCubit cubit) async {
    final today = CarePlanner.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.draft.lastMowedOn ?? today,
      firstDate: today.subtract(const Duration(days: 60)),
      lastDate: today,
    );
    if (picked != null) {
      cubit.update((draft) => draft.copyWith(lastMowedOn: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) => previous.draft != current.draft,
      builder: (context, state) {
        final draft = state.draft;

        return OnboardingStepLayout(
          title: strings.careTitle,
          children: [
            LabeledField(
              label: FieldLabel(strings.careWateringLabel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.small,
                children: [
                  SegmentedChoice<WateringMode>(
                    values: WateringMode.values,
                    selected: draft.watering,
                    labelOf: (mode) => switch (mode) {
                      WateringMode.automatic => strings.careWateringAuto,
                      WateringMode.manual => strings.careWateringManual,
                    },
                    onSelected: (mode) => cubit.update((draft) => draft.copyWith(watering: mode)),
                  ),
                  if (draft.watering == WateringMode.automatic)
                    _SprinklerCard(
                      controller: _minutes,
                      onChanged: (value) => cubit.update(
                        (draft) => draft.copyWith(sprinklerMinutes: int.tryParse(value) ?? 0),
                      ),
                    )
                  else
                    FieldHelper(strings.careManualHelper),
                ],
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.careMowingLabel),
              child: DayStepper(
                value: draft.mowingIntervalDays,
                label: strings.daysCount(draft.mowingIntervalDays),
                min: 2,
                max: 21,
                decreaseLabel: strings.commonLess,
                increaseLabel: strings.commonMore,
                onChanged: (days) =>
                    cubit.update((draft) => draft.copyWith(mowingIntervalDays: days)),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.careLastMowedLabel, suffix: strings.commonOptional),
              child: PickerField(
                text: draft.lastMowedOn == null
                    ? null
                    : DateFormat('d MMMM').format(draft.lastMowedOn!),
                hint: strings.feedLastHint,
                onTap: () => _pickLastMowed(cubit),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.careGardenDaysLabel),
              helper: strings.careGardenDaysHelper,
              child: Row(
                spacing: 6,
                children: [
                  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
                    Expanded(
                      child: _WeekdayToggle(
                        label: context.weekdayShort(weekday),
                        selected: draft.gardenWeekdays.contains(weekday),
                        palette: palette,
                        onTap: () => cubit.update((draft) {
                          final days = <int>{...draft.gardenWeekdays};
                          if (!days.remove(weekday)) days.add(weekday);
                          return draft.copyWith(gardenWeekdays: days);
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SprinklerCard extends StatelessWidget {
  const _SprinklerCard({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Insets.medium,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.careSectionTime,
                  style: AppTheme.body(fontSize: 14).copyWith(color: palette.secondaryTextColor),
                ),
              ),
              SizedBox(
                width: 64,
                height: 40,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: AppTheme.body(fontSize: 15).copyWith(color: palette.textColor),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: onChanged,
                ),
              ),
              HorizontalGap.small,
              Text(
                strings.commonMinutes,
                style: AppTheme.body(fontSize: 14).copyWith(color: palette.mutedTextColor),
              ),
            ],
          ),
          FieldHelper(strings.careSectionHelper),
        ],
      ),
    );
  }
}

class _WeekdayToggle extends StatelessWidget {
  const _WeekdayToggle({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Palette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? palette.primaryColor : palette.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected ? BorderSide.none : BorderSide(color: palette.outlineColor),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                style: AppTheme.body(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ).copyWith(color: selected ? palette.onPrimaryColor : palette.secondaryTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
