import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/journal/journal_cubit.dart';
import 'package:lawnly/presentation/journal/journal_editor_sheet.dart';
import 'package:lawnly/presentation/journal/widgets/journal_widgets.dart';

class JournalEntryPage extends StatelessWidget {
  const JournalEntryPage({required this.id, super.key});

  final String id;

  Future<void> _delete(BuildContext context, JournalEntry entry) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;

    final deleted = await context.read<JournalCubit>().delete(entry);
    messenger.showSnackBar(
      SnackBar(content: Text(deleted ? strings.journalDeleted : strings.onboardingSaveError)),
    );
    if (deleted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        final entry = state.byId(id);
        final profile = state.profile;
        if (entry == null || profile == null) return const Scaffold();

        final cubit = context.read<JournalCubit>();
        final strings = context.strings;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              capitalized(context.longDate(entry.date)),
              style: context.textTheme.bodyMedium,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
            children: [
              _Title(entry: entry),
              Gap.large,
              ..._details(context, entry, profile),
              if (entry.careKind == CareKind.fertilizing) ...[
                _RainAfter(entry: entry, cubit: cubit),
                Gap.large,
              ],
              if (entry.photos.isNotEmpty) ...[
                Wrap(
                  spacing: Insets.small,
                  runSpacing: Insets.small,
                  children: [
                    for (final photo in entry.photos)
                      PhotoThumb(file: cubit.photoFile(photo), height: 160, width: 160),
                  ],
                ),
                Gap.large,
              ],
              if (entry.note?.trim() case final note? when note.isNotEmpty) ...[
                Text(strings.journalNote, style: context.textTheme.titleSmall),
                Gap.small,
                _Card(child: Text(note, style: context.textTheme.bodyLarge)),
                Gap.large,
              ],
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showJournalEditor(context, cubit: cubit, entry: entry),
                      child: Text(strings.journalEdit),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _delete(context, entry),
                      style: OutlinedButton.styleFrom(foregroundColor: context.palette.errorColor),
                      child: Text(strings.journalDelete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _details(BuildContext context, JournalEntry entry, LawnProfile profile) {
    final strings = context.strings;
    final palette = context.palette;
    final rows = <(String, String)>[
      if (entry.careKind == CareKind.fertilizing) ...[
        if (entry.product case final product?) (strings.journalProduct, product),
        if (entry.npk case final npk?) (strings.journalNpk, npk),
        if (entry.dose case final dose?) ...[
          (strings.journalDoseLabel, strings.journalDose(formatDecimal(dose), entry.doseUnit.name)),
          (
            strings.journalWholeLawn,
            strings.journalTotal(
              formatDecimal(dose * profile.areaSqm / 1000),
              entry.doseUnit.name,
              profile.areaSqm,
            ),
          ),
        ],
      ],
      if (entry.mowingHeightCm case final height?)
        (strings.journalHeightLabel, '${formatDecimal(height)} cm'),
      if (entry.wateringMinutes case final minutes?)
        (strings.journalMinutesLabel, '$minutes ${strings.commonMinutes}'),
      if (entry.wateringLitres case final litres?)
        (strings.journalLitresLabel, strings.journalLitres(formatDecimal(litres))),
      if (entry.ph case final ph?) (strings.journalPhValue, formatDecimal(ph)),
    ];

    return [
      if (entry.tags.isNotEmpty) ...[
        Wrap(
          spacing: Insets.small,
          runSpacing: Insets.small,
          children: [
            for (final tag in entry.tags)
              Chip(
                label: Text(strings.observationTag(tag.name)),
                backgroundColor: palette.tintColor,
                side: BorderSide.none,
              ),
          ],
        ),
        Gap.large,
      ],
      if (rows.isNotEmpty) ...[
        _Card(
          child: Column(
            spacing: Insets.medium,
            children: [
              for (final (label, value) in rows)
                Row(
                  children: [
                    Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
                    Text(value, style: context.textTheme.titleSmall),
                  ],
                ),
            ],
          ),
        ),
        Gap.large,
      ] else if (entry.careKind == CareKind.fertilizing) ...[
        OutlinedButton.icon(
          onPressed: () =>
              showJournalEditor(context, cubit: context.read<JournalCubit>(), entry: entry),
          icon: const Icon(Icons.add),
          label: Text(strings.journalDetailsMissing),
        ),
        Gap.large,
      ],
    ];
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final color = entry.colorIn(palette);
    final time = DateFormat('HH:mm').format(entry.date);
    final subtitle = [
      if (entry.cycleDay case final day?)
        capitalized(strings.homeCycleDay(day, entry.interval ?? day)),
      if (entry.kind == JournalKind.care) strings.journalDoneAt(time) else time,
    ].join(' · ');

    return Row(
      spacing: Insets.medium,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(entry.icon, color: color),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(entry.title(context), style: context.textTheme.headlineMedium),
              Text(subtitle, style: context.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _RainAfter extends StatefulWidget {
  const _RainAfter({required this.entry, required this.cubit});

  final JournalEntry entry;
  final JournalCubit cubit;

  @override
  State<_RainAfter> createState() => _RainAfterState();
}

class _RainAfterState extends State<_RainAfter> {
  late final Future<Map<DateTime, double>?> _rain = widget.cubit.rainAfter(widget.entry.date);

  static const _maxBarHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final confirmed = widget.entry.rainConfirmed;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Insets.medium,
        children: [
          Row(
            children: [
              Expanded(child: Text(strings.journalRainAfter, style: context.textTheme.titleMedium)),
              Text(strings.journalRainDays, style: context.textTheme.bodySmall),
            ],
          ),
          FutureBuilder(
            future: _rain,
            builder: (context, snapshot) {
              final rain = snapshot.data;
              if (rain == null || rain.isEmpty) {
                return SizedBox(
                  height: 40,
                  child: snapshot.connectionState == ConnectionState.done
                      ? Text(strings.homeLoadError, style: context.textTheme.bodySmall)
                      : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final most = rain.values.fold<double>(1, (a, b) => a > b ? a : b);
              return SizedBox(
                height: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: Insets.large,
                  children: [
                    for (final MapEntry(key: day, value: mm) in rain.entries)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 6,
                          children: [
                            Text(
                              strings.homeRainMm(formatDecimal(mm)),
                              style: AppTheme.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ).copyWith(color: palette.rainColor),
                            ),
                            Container(
                              height: mm > 0
                                  ? (mm / most * _maxBarHeight).clamp(4, _maxBarHeight)
                                  : 2,
                              decoration: BoxDecoration(
                                color: mm > 0 ? palette.rainColor : palette.outlineColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Text(
                              context.weekdayShort(day.weekday),
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Text(strings.journalRainSource, style: context.textTheme.bodySmall),
          if (confirmed == null)
            Row(
              spacing: Insets.small,
              children: [
                Expanded(
                  child: Text(strings.journalRainQuestion, style: context.textTheme.titleSmall),
                ),
                OutlinedButton(
                  onPressed: () => widget.cubit.confirmRain(widget.entry, rained: true),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(64, 44)),
                  child: Text(strings.journalYes),
                ),
                OutlinedButton(
                  onPressed: () => widget.cubit.confirmRain(widget.entry, rained: false),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(64, 44)),
                  child: Text(strings.journalNo),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Insets.medium, vertical: 10),
              decoration: BoxDecoration(
                color: palette.rainTintColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                confirmed ? strings.journalRainYes : strings.journalRainNo,
                style: context.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
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
