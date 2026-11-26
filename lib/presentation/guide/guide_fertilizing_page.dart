import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/guide/guide_topic_style.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';

class GuideFertilizingPage extends StatelessWidget {
  const GuideFertilizingPage({super.key});

  static const _seasonNpk = ['20-5-8', '15-5-15', '12-4-18', '5-5-25'];

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final month = DateTime.now().month;

    final seasonNames = [
      (strings.guideFertSeason1, strings.guideFertSeason1Why),
      (strings.guideFertSeason2, strings.guideFertSeason2Why),
      (strings.guideFertSeason3, strings.guideFertSeason3Why),
      (strings.guideFertSeason4, strings.guideFertSeason4Why),
    ];
    final types = [
      (
        FertilizerType.slowGranular,
        strings.guideFertSlow,
        strings.guideFertSlowWorks,
        strings.guideFertSlowEvery,
      ),
      (
        FertilizerType.fastGranular,
        strings.guideFertFast,
        strings.guideFertFastWorks,
        strings.guideFertFastEvery,
      ),
      (
        FertilizerType.liquid,
        strings.guideFertLiquid,
        strings.guideFertLiquidWorks,
        strings.guideFertLiquidEvery,
      ),
      (
        null,
        strings.guideFertOrganic,
        strings.guideFertOrganicWorks,
        strings.guideFertOrganicEvery,
      ),
    ];

    return GuideScaffold(
      title: strings.guideFertilizing,
      subtitle: strings.guideFertilizingPageSub,
      children: [
        GuideLabel(strings.guideNpkTitle, top: Insets.medium),
        GuideCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.medium,
            children: [
              Text(
                strings.guideNpkIntro,
                style: AppTheme.body(
                  fontSize: 14,
                ).copyWith(color: palette.secondaryTextColor, height: 1.45),
              ),
              _Nutrient(
                symbol: 'N',
                color: palette.primaryColor,
                name: strings.guideNitrogen,
                text: strings.guideNitrogenText,
              ),
              _Nutrient(
                symbol: 'P',
                color: palette.sunColor,
                name: strings.guidePhosphorus,
                text: strings.guidePhosphorusText,
              ),
              _Nutrient(
                symbol: 'K',
                color: palette.rainColor,
                name: strings.guidePotassium,
                text: strings.guidePotassiumText,
              ),
              const Divider(height: 1),
              Text(
                strings.guideMicro,
                style: AppTheme.body(
                  fontSize: 13,
                ).copyWith(color: palette.mutedTextColor, height: 1.45),
              ),
            ],
          ),
        ),
        GuideLabel(strings.guideFertSeasonsTitle),
        GuideTable(
          header: [strings.guideColSeason, strings.guideColNpk, strings.guideColWhy],
          columnFlex: const [5, 3, 6],
          rows: [
            for (final (i, (name, why)) in seasonNames.indexed)
              GuideTableRow(
                [name, _seasonNpk[i], why],
                highlighted: inRange(fertilizingSeasons[i], month),
                badge: inRange(fertilizingSeasons[i], month) ? strings.guideNowLegend : null,
              ),
          ],
        ),
        GuideLabel(strings.guideFertTypesTitle),
        GuideTable(
          header: [strings.guideColType, strings.guideColWorks, strings.guideColEvery],
          columnFlex: const [6, 3, 4],
          rows: [
            for (final (_, name, works, every) in types) GuideTableRow([name, works, every]),
          ],
        ),
        GuideLabel(strings.guideFertHowTitle),
        GuideChecklist(lines(strings.guideFertHow)),
        Gap.large,
        GuideWarning(text: strings.guideFertNote),
      ],
    );
  }
}

class _Nutrient extends StatelessWidget {
  const _Nutrient({
    required this.symbol,
    required this.color,
    required this.name,
    required this.text,
  });

  final String symbol;
  final Color color;
  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      spacing: Insets.medium,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(symbol, style: AppTheme.display(fontSize: 16).copyWith(color: Colors.white)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTheme.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.headingColor),
              ),
              Text(
                text,
                style: AppTheme.body(fontSize: 13).copyWith(color: palette.mutedTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
