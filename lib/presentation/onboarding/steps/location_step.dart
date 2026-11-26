import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

class LocationStep extends StatefulWidget {
  const LocationStep({super.key});

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  late final TextEditingController _name;
  late final TextEditingController _city;

  @override
  void initState() {
    super.initState();
    final draft = context.read<OnboardingCubit>().state.draft;
    _name = TextEditingController(text: draft.name);
    _city = TextEditingController(text: draft.cityQuery);
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.draft.cityQuery != current.draft.cityQuery && current.draft.cityQuery.isEmpty,
      listener: (_, _) => _city.clear(),
      builder: (context, state) {
        final location = state.draft.location;
        final gpsLocation = location != null && location.label == null;

        return OnboardingStepLayout(
          title: strings.locationTitle,
          subtitle: strings.locationBody,
          children: [
            LabeledField(
              label: FieldLabel(strings.locationNameLabel),
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: strings.locationNameHint),
                onChanged: (value) => cubit.update((draft) => draft.copyWith(name: value)),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.locationLabel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.small,
                children: [
                  FilledButton.icon(
                    onPressed: state.status == OnboardingStatus.editing
                        ? cubit.useCurrentLocation
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppTheme.fieldHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                      ),
                      textStyle: AppTheme.body(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(Icons.my_location, size: 20),
                    label: Text(strings.locationUseMine),
                  ),
                  if (gpsLocation) _CurrentLocationChip(label: strings.locationCurrent),
                  FieldHelper(strings.locationOr, textAlign: TextAlign.center),
                  TextField(
                    controller: _city,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(hintText: strings.locationCityHint),
                    onChanged: cubit.updateCityQuery,
                    onSubmitted: (_) => cubit.next(),
                  ),
                  if (state.error case final error?) OnboardingErrorText(error: error),
                ],
              ),
            ),
            Gap.large,
            TipCard(icon: Icons.cloud_outlined, text: strings.locationTip),
          ],
        );
      },
    );
  }
}

class _CurrentLocationChip extends StatelessWidget {
  const _CurrentLocationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        Icon(Icons.check_circle, size: 18, color: palette.accentColor),
        Text(
          label,
          style: AppTheme.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ).copyWith(color: palette.headingColor),
        ),
      ],
    );
  }
}
