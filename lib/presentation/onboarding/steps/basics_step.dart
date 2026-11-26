import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';
import 'package:lawnly/presentation/onboarding/steps/month_year_picker.dart';

class BasicsStep extends StatefulWidget {
  const BasicsStep({super.key});

  @override
  State<BasicsStep> createState() => _BasicsStepState();
}

class _BasicsStepState extends State<BasicsStep> {
  late final TextEditingController _area;

  @override
  void initState() {
    super.initState();
    final area = context.read<OnboardingCubit>().state.draft.areaSqm;
    _area = TextEditingController(text: area?.toString() ?? '');
  }

  @override
  void dispose() {
    _area.dispose();
    super.dispose();
  }

  Future<void> _pickEstablished(OnboardingCubit cubit) async {
    final picked = await showMonthYearPicker(context, initial: cubit.state.draft.establishedOn);
    if (picked != null) {
      cubit.update((draft) => draft.copyWith(establishedOn: picked));
    }
  }

  static int _seasonsSince(DateTime established) {
    final now = DateTime.now();
    final months = (now.year - established.year) * 12 + now.month - established.month;
    return months ~/ 12;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) => previous.draft != current.draft,
      builder: (context, state) {
        final draft = state.draft;
        final established = draft.establishedOn;

        return OnboardingStepLayout(
          title: strings.basicsTitle,
          subtitle: strings.basicsBody,
          children: [
            LabeledField(
              label: FieldLabel(strings.basicsAreaLabel),
              helper: strings.basicsAreaHelper,
              child: TextField(
                controller: _area,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: '250',
                  suffixText: strings.commonSquareMeters,
                ),
                onChanged: (value) =>
                    cubit.update((draft) => draft.copyWith(areaSqm: int.tryParse(value))),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.basicsEstablishedLabel),
              helper: established == null
                  ? strings.basicsEstablishedHelper
                  : strings.basicsLawnAge(_seasonsSince(established)),
              child: PickerField(
                text: established == null ? null : DateFormat('LLLL yyyy').format(established),
                hint: strings.basicsEstablishedHint,
                onTap: () => _pickEstablished(cubit),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.basicsMethodLabel),
              child: SegmentedChoice<EstablishmentMethod>(
                values: EstablishmentMethod.values,
                selected: draft.establishment,
                labelOf: (method) => switch (method) {
                  EstablishmentMethod.seeded => strings.basicsMethodSeeded,
                  EstablishmentMethod.sod => strings.basicsMethodSod,
                },
                onSelected: (method) =>
                    cubit.update((draft) => draft.copyWith(establishment: method)),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.basicsSunLabel),
              child: Row(
                spacing: Insets.small,
                children: [
                  for (final sun in SunExposure.values)
                    Expanded(
                      child: _SunTile(
                        sun: sun,
                        selected: draft.sun == sun,
                        onTap: () => cubit.update((draft) => draft.copyWith(sun: sun)),
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

class _SunTile extends StatelessWidget {
  const _SunTile({required this.sun, required this.selected, required this.onTap});

  final SunExposure sun;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final (icon, label) = switch (sun) {
      SunExposure.sun => (Icons.wb_sunny_outlined, strings.basicsSunFull),
      SunExposure.partialShade => (Icons.wb_cloudy_outlined, strings.basicsSunPartial),
      SunExposure.shade => (Icons.park_outlined, strings.basicsSunShade),
    };

    return ChoiceTile(
      selected: selected,
      selectedFill: false,
      height: 76,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(icon, size: 22, color: selected ? palette.primaryColor : palette.secondaryTextColor),
          Text(
            label,
            style: AppTheme.body(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ).copyWith(color: selected ? palette.headingColor : palette.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
