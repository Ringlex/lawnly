import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/day/day_page.dart';
import 'package:lawnly/presentation/guide/guide_topic_style.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';

class GuideMowingPage extends StatelessWidget {
  const GuideMowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final today = DateTime.now();
    final profile = context.watch<HomeCubit>().state.profile;
    final height = profile == null ? 5.0 : mowingHeight(profile);

    final seasons = [
      (strings.guideMowSeason1, strings.guideMowSeason1Every, strings.guideMowSeason1Height),
      (strings.guideMowSeason2, strings.guideMowSeason2Every, strings.guideMowSeason2Height),
      (strings.guideMowSeason3, strings.guideMowSeason3Every, strings.guideMowSeason3Height),
      (strings.guideMowSeason4, strings.guideMowSeason4Every, strings.guideMowSeason4Height),
    ];

    return GuideScaffold(
      title: strings.guideMowing,
      subtitle: strings.guideMowingPageSub,
      children: [
        Gap.small,
        _RuleCard(height: height),
        GuideLabel(strings.guideMowRhythmTitle),
        GuideTable(
          header: [strings.guideColSeason, strings.guideColEvery, strings.guideColHeight],
          columnFlex: const [5, 5, 5],
          rows: [
            for (final (i, (name, every, cut)) in seasons.indexed)
              GuideTableRow(
                [name, every, cut],
                highlighted: inRange(mowingSeasons[i], today.month),
                badge: inRange(mowingSeasons[i], today.month) ? strings.guideNowLegend : null,
              ),
          ],
        ),
        GuideLabel(strings.guideMowHabitsTitle),
        GuideChecklist(lines(strings.guideMowHabits)),
        Gap.large,
        GuideCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: Insets.xSmall),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.accentColor, width: 2),
              ),
              child: Icon(Icons.schedule, size: 20, color: palette.primaryColor),
            ),
            title: Text(strings.guideMowToday, style: context.textTheme.titleMedium),
            subtitle: Text(strings.guideMowTodaySub, style: context.textTheme.bodySmall),
            trailing: Icon(Icons.chevron_right, color: palette.mutedTextColor),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => DayPage(date: today))),
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 18,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  strings.guideMowRuleLabel.toUpperCase(),
                  style: AppTheme.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: palette.springColor, letterSpacing: 0.5),
                ),
                Text(
                  strings.guideMowRuleTitle,
                  style: AppTheme.display(fontSize: 20).copyWith(color: Colors.white, height: 1.2),
                ),
                Text(
                  strings.guideMowRuleText(formatCm(height), formatCm(mowWhenTaller(height))),
                  style: AppTheme.body(
                    fontSize: 14,
                  ).copyWith(color: palette.onHeroColor, height: 1.45),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    border: Border(
                      top: BorderSide(color: palette.springColor, width: 2),
                      left: BorderSide(color: palette.springColor, width: 2),
                      right: BorderSide(color: palette.springColor, width: 2),
                    ),
                  ),
                  child: Text(
                    '1/3',
                    style: AppTheme.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: palette.springColor),
                  ),
                ),
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.springColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Text(
                    '${formatCm(height)} ${strings.guideCm}',
                    style: AppTheme.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: palette.headingColor),
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
