import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/journal/season_summary.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/journal/journal_cubit.dart';
import 'package:lawnly/presentation/journal/widgets/journal_widgets.dart';

class SeasonPage extends StatefulWidget {
  const SeasonPage({super.key});

  @override
  State<SeasonPage> createState() => _SeasonPageState();
}

class _SeasonPageState extends State<SeasonPage> {
  late final Future<double?> _rain = context.read<JournalCubit>().seasonRain();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        final summary = state.summary;
        final profile = state.profile;
        if (summary == null || profile == null) return const Scaffold();

        final format = DateFormat('d MMMM');
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.journalSeason(summary.start.year)),
                Text(
                  strings.journalSeasonRange(
                    format.format(summary.start),
                    format.format(summary.end),
                    profile.name,
                  ),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
            children: [
              _MonthsCard(summary: summary),
              Gap.medium,
              _NitrogenCard(summary: summary),
              Gap.medium,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: _FertilizerTile(summary: summary)),
                  Expanded(
                    child: _RainTile(
                      rain: _rain,
                      waterings: summary.waterings,
                      wateringMm: summary.wateringMm,
                    ),
                  ),
                ],
              ),
              if (summary.observations.isNotEmpty) ...[
                Gap.large,
                Text(strings.journalObservations, style: context.textTheme.titleLarge),
                Gap.small,
                for (final entry in summary.observations) ...[
                  JournalEntryTile(
                    entry: entry,
                    profile: profile,
                    photoFile: context.read<JournalCubit>().photoFile,
                    onTap: () {},
                  ),
                  Gap.small,
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(Insets.large),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: child,
    );
  }
}

class _MonthsCard extends StatelessWidget {
  const _MonthsCard({required this.summary});

  final SeasonSummary summary;

  static const _barHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final most = summary.months.fold<int>(1, (a, m) => m.mowings > a ? m.mowings : a);
    final mowColor = CareKind.mowing.colorIn(palette);
    final fertColor = CareKind.fertilizing.colorIn(palette);

    Widget legend(Widget marker, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        marker,
        Text(label, style: context.textTheme.bodySmall),
      ],
    );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Insets.medium,
        children: [
          Text(strings.journalMonths, style: context.textTheme.titleMedium),
          Wrap(
            spacing: Insets.medium,
            children: [
              legend(
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: mowColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                strings.journalLegendMowing,
              ),
              legend(
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: fertColor, shape: BoxShape.circle),
                ),
                strings.journalLegendFertilizing,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Insets.small,
            children: [
              for (final month in summary.months)
                Expanded(
                  child: Column(
                    spacing: 6,
                    children: [
                      Text('${month.mowings}', style: context.textTheme.labelSmall),
                      Container(
                        height: month.mowings == 0
                            ? 2
                            : (month.mowings / most * _barHeight).clamp(6, _barHeight),
                        decoration: BoxDecoration(
                          color: month.mowings == 0 ? palette.outlineColor : mowColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 3,
                          children: [
                            for (var i = 0; i < month.fertilizings.clamp(0, 3); i++)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: fertColor, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('LLL').format(month.month),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NitrogenCard extends StatelessWidget {
  const _NitrogenCard({required this.summary});

  final SeasonSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final nitrogen = summary.nitrogenPer100Sqm;
    final (min, max) = summary.nitrogenRange;
    final scale = max * 1.5;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Insets.medium,
        children: [
          Row(
            children: [
              Expanded(child: Text(strings.journalNitrogen, style: context.textTheme.titleMedium)),
              if (nitrogen != null)
                Text(
                  strings.journalNitrogenValue(formatDecimal(nitrogen)),
                  style: context.textTheme.titleMedium,
                ),
            ],
          ),
          if (nitrogen == null)
            Text(strings.journalNitrogenMissing, style: context.textTheme.bodySmall)
          else ...[
            SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  double x(double value) => (value / scale).clamp(0, 1) * width;
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 4,
                        height: 10,
                        child: _Bar(color: palette.trackColor),
                      ),
                      Positioned(
                        left: x(min),
                        width: x(max) - x(min),
                        top: 4,
                        height: 10,
                        child: _Bar(color: palette.springColor),
                      ),
                      Positioned(
                        left: (x(nitrogen) - 2).clamp(0, width - 4),
                        width: 4,
                        top: 0,
                        height: 18,
                        child: _Bar(color: palette.headingColor),
                      ),
                    ],
                  );
                },
              ),
            ),
            Text(
              strings.journalNitrogenRange(formatDecimal(min), formatDecimal(max)),
              style: context.textTheme.bodySmall,
            ),
          ],
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

class _FertilizerTile extends StatelessWidget {
  const _FertilizerTile({required this.summary});

  final SeasonSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.xSmall,
        children: [
          Text(strings.journalFertilizerUsed, style: context.textTheme.bodySmall),
          Text('${formatDecimal(summary.granularKg)} kg', style: context.textTheme.headlineSmall),
          if (summary.liquidLitres > 0)
            Text(
              strings.journalLiquid(formatDecimal(summary.liquidLitres)),
              style: context.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _RainTile extends StatelessWidget {
  const _RainTile({required this.rain, required this.waterings, this.wateringMm});

  final Future<double?> rain;
  final int waterings;
  final double? wateringMm;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.xSmall,
        children: [
          Text(strings.journalRain, style: context.textTheme.bodySmall),
          FutureBuilder(
            future: rain,
            builder: (context, snapshot) => Text(
              snapshot.data == null ? '–' : strings.journalRainMm(formatDecimal(snapshot.data!)),
              style: context.textTheme.headlineSmall?.copyWith(color: palette.rainColor),
            ),
          ),
          Text(
            wateringMm == null
                ? '$waterings ${strings.journalWaterings(waterings)}'
                : strings.journalWateringMm(formatDecimal(wateringMm!)),
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
