import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/day_panel.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({required this.entry, super.key});

  final CareEntry entry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: EntrySheet(entry: entry),
  );
}

class EntrySheet extends StatelessWidget {
  const EntrySheet({required this.entry, super.key});

  final CareEntry entry;

  static const _forecastLeadDays = 5;

  Future<void> _run(BuildContext context, Future<bool> Function() action) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = context.strings.onboardingSaveError;

    final saved = await action();
    if (saved) {
      navigator.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _remove(BuildContext context, CalendarCubit cubit) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;

    final undo = await cubit.remove(entry);
    if (undo == null) {
      messenger.showSnackBar(SnackBar(content: Text(strings.onboardingSaveError)));
      return;
    }
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(strings.sheetRemoved),
        action: SnackBarAction(label: strings.sheetUndo, onPressed: undo),
      ),
    );
  }

  Future<void> _changeFertilizingDate(BuildContext context, CalendarCubit cubit) async {
    final today = cubit.state.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: entry.date.isBefore(today) ? today : entry.date,
      firstDate: today,
      lastDate: DateTime(today.year, today.month + 3, today.day),
    );
    if (picked != null && context.mounted) {
      await _run(context, () => cubit.pinFertilizing(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarCubit>();
    final state = cubit.state;
    final profile = state.profile!;
    final palette = context.palette;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 18,
          children: [
            _Header(entry: entry, profile: profile),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  context.longDate(entry.date),
                  style: AppTheme.display(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: palette.headingColor),
                ),
                _CertaintyTag(entry: entry),
              ],
            ),
            if (entry.cycle case final cycle? when entry.certainty != EntryCertainty.done)
              _WindowStrip(cycle: cycle, planned: entry.date, profile: profile),
            _InfoCard(lines: _infoLines(context, profile, state.today)),
            ..._actions(context, cubit, state.today),
          ],
        ),
      ),
    );
  }

  List<(IconData, String)> _infoLines(BuildContext context, LawnProfile profile, DateTime today) {
    final strings = context.strings;
    final forecast = context.read<CalendarCubit>().forecastFor(entry.date);

    if (entry.task case final task?) {
      return [
        if (entry.movedFrom case final from?)
          (Icons.update, strings.entryMoved(context.shortDate(from))),
        if (forecast != null) (Icons.cloud_outlined, context.weatherSummary(forecast)),
        if (entry.certainty != EntryCertainty.done)
          (Icons.event_outlined, task.flexible ? strings.sheetFlexible : strings.sheetFixed),
        if (task.note?.trim() case final note? when note.isNotEmpty) (Icons.notes, note),
      ];
    }

    switch (entry.kind) {
      case CareKind.fertilizing:
        final cycle = entry.cycle;
        final window = FertilizingWindow(profile.fertilizingIntervalDays);
        final forecastFrom = cycle == null
            ? null
            : DateTime(
                cycle.window.start.year,
                cycle.window.start.month,
                cycle.window.start.day - _forecastLeadDays,
              );
        return [
          if (cycle != null)
            (
              Icons.calendar_month_outlined,
              strings.sheetWindow(
                context.shortDate(cycle.window.start),
                context.shortDate(cycle.window.end),
                window.start,
                window.end,
              ),
            ),
          if (forecast != null) (Icons.cloud_outlined, context.weatherSummary(forecast)),
          if (cycle != null && entry.certainty == EntryCertainty.tentative)
            if (!cycle.isCurrent)
              (Icons.cloud_outlined, strings.sheetNextCycle)
            else if (forecastFrom!.isAfter(today))
              (Icons.cloud_outlined, strings.sheetForecastLater(context.shortDate(forecastFrom))),
        ];
      case CareKind.mowing:
        return [
          (Icons.repeat, strings.sheetMowing(strings.daysCount(profile.mowingIntervalDays))),
          if (forecast != null) (Icons.cloud_outlined, context.weatherSummary(forecast)),
        ];
      default:
        return [(entry.kind.icon, entrySubtitle(context, entry, profile, forecast))];
    }
  }

  List<Widget> _actions(BuildContext context, CalendarCubit cubit, DateTime today) {
    final strings = context.strings;
    if (entry.certainty == EntryCertainty.done) {
      return [
        if (entry.task != null)
          OutlinedButton(
            onPressed: () => _remove(context, cubit),
            child: Text(strings.sheetDelete),
          ),
      ];
    }

    final isDue = !entry.date.isAfter(today);
    final done = FilledButton(
      onPressed: () => _run(context, () => cubit.markDone(entry)),
      child: Text(strings.homeDone),
    );

    if (entry.task case final task?) {
      return [
        if (isDue) done,
        _ButtonRow(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(task),
              child: Text(strings.sheetChangeDate),
            ),
            OutlinedButton(
              onPressed: () => _remove(context, cubit),
              child: Text(strings.sheetDelete),
            ),
          ],
        ),
      ];
    }

    switch (entry.kind) {
      case CareKind.fertilizing:
        final cycle = entry.cycle;
        if (cycle == null) return [];
        final skip = OutlinedButton(
          onPressed: () => _remove(context, cubit),
          child: Text(strings.sheetSkipCycle),
        );
        if (!cycle.isCurrent) return [skip];

        final pinned = entry.certainty == EntryCertainty.fixed;
        return [
          if (isDue)
            done
          else if (!pinned) ...[
            FilledButton(
              onPressed: () => _run(context, () => cubit.pinFertilizing(entry.date)),
              child: Text(strings.sheetPin(context.shortDate(entry.date))),
            ),
            Text(
              strings.sheetPinHelper,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ],
          _ButtonRow(
            children: [
              OutlinedButton(
                onPressed: () => _changeFertilizingDate(context, cubit),
                child: Text(strings.sheetChangeDate),
              ),
              if (pinned)
                OutlinedButton(
                  onPressed: () => _run(context, () => cubit.pinFertilizing(null)),
                  child: Text(strings.sheetUnpin),
                )
              else
                skip,
            ],
          ),
        ];
      default:
        return [
          if (isDue && entry.kind == CareKind.mowing) done,
          OutlinedButton(
            onPressed: () => _remove(context, cubit),
            child: Text(strings.sheetRemove),
          ),
        ];
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entry, required this.profile});

  final CareEntry entry;
  final LawnProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final color = entry.kind.colorIn(palette);
    final subtitle = switch (entry) {
      CareEntry(task: _?) => strings.entryOwn,
      CareEntry(kind: CareKind.fertilizing) => strings.sheetFromPlan(
        strings.daysCount(profile.fertilizingIntervalDays),
      ),
      CareEntry(kind: CareKind.mowing) => strings.sheetFromPlan(
        strings.daysCount(profile.mowingIntervalDays),
      ),
      _ => null,
    };

    return Row(
      spacing: Insets.medium,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(entry.kind.icon, size: 22, color: color),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(entry.kind.label(context), style: context.textTheme.headlineSmall),
              if (subtitle != null) Text(subtitle, style: context.textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: strings.sheetClose,
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(44),
            backgroundColor: palette.cardColor,
            side: BorderSide(color: palette.outlineColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            ),
          ),
        ),
      ],
    );
  }
}

class _CertaintyTag extends StatelessWidget {
  const _CertaintyTag({required this.entry});

  final CareEntry entry;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final isPinned = entry.task == null && entry.certainty == EntryCertainty.fixed;
    final text = switch (entry.certainty) {
      EntryCertainty.done => strings.entryDone,
      EntryCertainty.matched => strings.sheetTagMatched,
      EntryCertainty.fixed => isPinned ? strings.sheetTagPinned : strings.sheetTagFixed,
      EntryCertainty.tentative => strings.sheetTagTentative,
    };
    final dashed = entry.certainty == EntryCertainty.tentative;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: dashed ? null : palette.windowColor,
        borderRadius: BorderRadius.circular(999),
        border: dashed ? Border.all(color: palette.primaryColor, width: 1.5) : null,
      ),
      child: Text(
        text,
        style: AppTheme.body(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ).copyWith(color: palette.primaryColor),
      ),
    );
  }
}

class _WindowStrip extends StatelessWidget {
  const _WindowStrip({required this.cycle, required this.planned, required this.profile});

  final FertilizingCycle cycle;
  final DateTime planned;
  final LawnProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final days = [
      for (
        var day = cycle.window.start;
        !day.isAfter(cycle.window.end);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        day,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: Insets.xSmall,
        children: [
          for (final day in days)
            Builder(
              builder: (context) {
                final isPlanned = day == planned;
                final busy = !profile.gardenWeekdays.contains(day.weekday);
                final color = busy ? palette.mutedTextColor : palette.headingColor;

                return Container(
                  width: 46,
                  padding: const EdgeInsets.symmetric(vertical: Insets.small),
                  decoration: BoxDecoration(
                    color: busy ? palette.cardColor : palette.windowColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPlanned
                          ? palette.primaryColor
                          : busy
                          ? palette.outlineColor
                          : palette.windowColor,
                      width: isPlanned ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    spacing: 2,
                    children: [
                      Text(
                        context.weekdayShort(day.weekday),
                        style: AppTheme.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: color),
                      ),
                      Text(
                        '${day.day}',
                        style: AppTheme.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ).copyWith(color: color),
                      ),
                      Text(
                        isPlanned
                            ? strings.sheetStripPlan
                            : busy
                            ? strings.sheetStripBusy
                            : '',
                        maxLines: 1,
                        style: AppTheme.body(fontSize: 9).copyWith(color: palette.mutedTextColor),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.lines});

  final List<(IconData, String)> lines;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          for (final (icon, text) in lines)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.medium,
              children: [
                Icon(icon, size: 20, color: palette.primaryColor),
                Expanded(
                  child: Text(
                    text,
                    style: AppTheme.body(
                      fontSize: 14,
                    ).copyWith(color: palette.secondaryTextColor, height: 1.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Row(spacing: 10, children: [for (final child in children) Expanded(child: child)]);
}
