import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';

class GuideMixesPage extends StatelessWidget {
  const GuideMixesPage({super.key});

  static const _mixes = [
    GrassMix.universal,
    GrassMix.ornamental,
    GrassMix.shade,
    GrassMix.drought,
    GrassMix.sport,
  ];

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final yours = context.watch<HomeCubit>().state.profile?.grassMix;

    final choices = [
      (strings.guideMixWhenUniversal, GrassMix.universal),
      (strings.guideMixWhenOrnamental, GrassMix.ornamental),
      (strings.guideMixWhenShade, GrassMix.shade),
      (strings.guideMixWhenDrought, GrassMix.drought),
    ];

    return GuideScaffold(
      title: strings.guideMixes,
      subtitle: strings.guideMixesPageSub,
      children: [
        GuideLabel(strings.guideMixHowTitle, top: Insets.medium),
        GuideTileGrid(
          children: [
            for (final (condition, mix) in choices)
              GuideCard(
                padding: const EdgeInsets.all(Insets.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: Insets.xSmall,
                  children: [
                    Text(
                      condition,
                      maxLines: 2,
                      style: AppTheme.body(
                        fontSize: 13,
                      ).copyWith(color: palette.mutedTextColor, height: 1.3),
                    ),
                    Text(
                      strings.guideMixShort(mix.name),
                      style: AppTheme.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: palette.headingColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
        GuideLabel(strings.guideMixListTitle),
        for (final mix in _mixes) ...[_MixCard(mix: mix, yours: mix == yours), Gap.small],
        Gap.small,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: Insets.medium),
          decoration: BoxDecoration(
            color: palette.tintColor,
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.xSmall,
            children: [
              Text(
                strings.guideSeedsTitle,
                style: AppTheme.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ).copyWith(color: palette.headingColor),
              ),
              Text(
                strings.guideSeedsText,
                style: AppTheme.body(
                  fontSize: 13,
                ).copyWith(color: palette.secondaryTextColor, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({required this.mix, required this.yours});

  final GrassMix mix;
  final bool yours;

  String _name(BuildContext context) {
    final strings = context.strings;
    return switch (mix) {
      GrassMix.universal => strings.soilMixUniversal,
      GrassMix.ornamental => strings.soilMixOrnamental,
      GrassMix.shade => strings.soilMixShade,
      GrassMix.drought => strings.soilMixDrought,
      GrassMix.sport => strings.soilMixSport,
      GrassMix.unknown => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final range = mowingRange(mix);

    return GuideCard(
      highlighted: yours,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.small,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Wrap(
                      spacing: Insets.small,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _name(context),
                          style: AppTheme.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ).copyWith(color: palette.headingColor),
                        ),
                        if (yours) GuideBadge(strings.guideYoursMix),
                      ],
                    ),
                    Text(
                      strings.guideMixText(mix.name),
                      style: AppTheme.body(fontSize: 13).copyWith(color: palette.mutedTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Insets.small, vertical: 6),
                decoration: BoxDecoration(
                  color: yours ? palette.windowColor : palette.tintColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${formatCm(range.min)}–${formatCm(range.max)}',
                      style: AppTheme.display(fontSize: 16).copyWith(color: palette.headingColor),
                    ),
                    Text(
                      strings.guideCm,
                      style: AppTheme.body(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: palette.secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            strings.guideMixSpecies(mix.name),
            style: AppTheme.body(
              fontSize: 13,
            ).copyWith(color: palette.secondaryTextColor, height: 1.45),
          ),
        ],
      ),
    );
  }
}
