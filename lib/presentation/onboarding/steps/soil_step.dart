import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

class SoilStep extends StatefulWidget {
  const SoilStep({super.key});

  @override
  State<SoilStep> createState() => _SoilStepState();
}

class _SoilStepState extends State<SoilStep> {
  static const _minPh = 3.0;
  static const _maxPh = 9.0;

  late final TextEditingController _ph;

  @override
  void initState() {
    super.initState();
    final ph = context.read<OnboardingCubit>().state.draft.soilPh;
    _ph = TextEditingController(text: ph?.toString().replaceAll('.', ',') ?? '');
  }

  @override
  void dispose() {
    _ph.dispose();
    super.dispose();
  }

  void _onPhChanged(OnboardingCubit cubit, String value) {
    final text = value.trim().replaceAll(',', '.');
    final ph = double.tryParse(text);
    final invalid = text.isNotEmpty && (ph == null || ph < _minPh || ph > _maxPh);
    cubit.update((draft) => draft.copyWith(soilPh: invalid ? null : ph, soilPhInvalid: invalid));
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) => previous.draft != current.draft,
      builder: (context, state) {
        final draft = state.draft;
        void selectMix(GrassMix mix) => cubit.update((draft) => draft.copyWith(grassMix: mix));

        return OnboardingStepLayout(
          title: strings.soilTitle,
          subtitle: strings.soilBody,
          children: [
            LabeledField(
              label: FieldLabel(strings.soilMixLabel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.small,
                children: [
                  _MixCard(
                    title: strings.soilMixUniversal,
                    description: strings.soilMixUniversalHint,
                    selected: draft.grassMix == GrassMix.universal,
                    onTap: () => selectMix(GrassMix.universal),
                  ),
                  _MixCard(
                    title: strings.soilMixOrnamental,
                    description: strings.soilMixOrnamentalHint,
                    selected: draft.grassMix == GrassMix.ornamental,
                    onTap: () => selectMix(GrassMix.ornamental),
                  ),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: Insets.small,
                      crossAxisSpacing: Insets.small,
                      mainAxisExtent: 48,
                    ),
                    children: [
                      for (final (mix, label) in [
                        (GrassMix.shade, strings.soilMixShade),
                        (GrassMix.drought, strings.soilMixDrought),
                        (GrassMix.sport, strings.soilMixSport),
                        (GrassMix.unknown, strings.commonDontKnow),
                      ])
                        ChoiceTile(
                          selected: draft.grassMix == mix,
                          padding: EdgeInsets.zero,
                          onTap: () => selectMix(mix),
                          child: _TileLabel(label, selected: draft.grassMix == mix),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.soilTypeLabel),
              child: SegmentedChoice<SoilType>(
                values: SoilType.values,
                selected: draft.soil,
                fontSize: 13,
                labelOf: (soil) => switch (soil) {
                  SoilType.sandy => strings.soilTypeSandy,
                  SoilType.medium => strings.soilTypeMedium,
                  SoilType.clay => strings.soilTypeClay,
                  SoilType.unknown => strings.commonDontKnow,
                },
                onSelected: (soil) => cubit.update((draft) => draft.copyWith(soil: soil)),
              ),
            ),
            Gap.large,
            LabeledField(
              label: FieldLabel(strings.soilPhLabel, suffix: strings.commonOptional),
              child: TextField(
                controller: _ph,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  hintText: strings.soilPhHint,
                  errorText: draft.soilPhInvalid ? strings.soilPhError : null,
                ),
                onChanged: (value) => _onPhChanged(cubit, value),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ChoiceTile(
      selected: selected,
      alignment: Alignment.centerLeft,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(
            title,
            style: AppTheme.body(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ).copyWith(color: palette.headingColor),
          ),
          Text(
            description,
            style: AppTheme.body(
              fontSize: 13,
            ).copyWith(color: selected ? palette.secondaryTextColor : palette.mutedTextColor),
          ),
        ],
      ),
    );
  }
}

class _TileLabel extends StatelessWidget {
  const _TileLabel(this.text, {required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTheme.body(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ).copyWith(color: selected ? palette.headingColor : palette.secondaryTextColor),
    );
  }
}
