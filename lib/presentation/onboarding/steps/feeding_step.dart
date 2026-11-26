import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

class FeedingStep extends StatelessWidget {
  const FeedingStep({super.key});

  Future<void> _pickLastFertilized(BuildContext context, OnboardingCubit cubit) async {
    final today = CarePlanner.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.draft.lastFertilizedOn ?? today,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today,
    );
    if (picked != null) {
      cubit.update(
        (draft) => draft.copyWith(lastFertilizedOn: picked, lastFertilizedUnknown: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft || previous.error != current.error,
      builder: (context, state) {
        final draft = state.draft;
        final window = FertilizingWindow(draft.fertilizingIntervalDays);
        final last = draft.lastFertilizedOn;

        return OnboardingStepLayout(
          title: strings.feedTitle,
          subtitle: strings.feedBody,
          children: [
            LabeledField(
              label: FieldLabel(strings.feedIntervalLabel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.small,
                children: [
                  DayStepper(
                    value: draft.fertilizingIntervalDays,
                    label: strings.daysCount(draft.fertilizingIntervalDays),
                    min: 7,
                    max: 90,
                    decreaseLabel: strings.commonLess,
                    increaseLabel: strings.commonMore,
                    onChanged: (days) =>
                        cubit.update((draft) => draft.copyWith(fertilizingIntervalDays: days)),
                  ),
                  _WindowCard(window: window),
                ],
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.feedLastLabel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PickerField(
                    text: draft.lastFertilizedUnknown
                        ? strings.feedLastUnknown
                        : last == null
                        ? null
                        : DateFormat('d MMMM').format(last),
                    hint: strings.feedLastHint,
                    onTap: () => _pickLastFertilized(context, cubit),
                  ),
                  if (!draft.lastFertilizedUnknown)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => cubit.update(
                          (draft) =>
                              draft.copyWith(lastFertilizedUnknown: true, lastFertilizedOn: null),
                        ),
                        child: Text(strings.feedLastUnknown),
                      ),
                    ),
                ],
              ),
            ),
            if (state.error case final error?) ...[Gap.small, OnboardingErrorText(error: error)],
          ],
        );
      },
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({required this.window});

  final FertilizingWindow window;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    final scaleStart = window.interval - window.slack * 2.5;
    final scaleLength = window.slack * 5;
    double position(num day) => (day - scaleStart) / scaleLength;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.feedWindowLabel,
                  style: AppTheme.body(fontSize: 14).copyWith(color: palette.secondaryTextColor),
                ),
              ),
              Text(
                strings.feedWindowRange(window.start, window.end),
                style: AppTheme.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.headingColor),
              ),
            ],
          ),
          SizedBox(
            height: 18,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final windowLeft = position(window.start) * width;
                final windowRight = position(window.end) * width;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 4,
                      height: 10,
                      child: _Bar(color: palette.trackColor),
                    ),
                    Positioned(
                      left: windowLeft,
                      width: windowRight - windowLeft,
                      top: 4,
                      height: 10,
                      child: _Bar(color: palette.accentColor),
                    ),
                    Positioned(
                      left: position(window.interval) * width - 2,
                      top: 0,
                      width: 4,
                      height: 18,
                      child: _Bar(color: palette.headingColor),
                    ),
                  ],
                );
              },
            ),
          ),
          FieldHelper(strings.feedWindowHelper(window.interval)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
  );
}
