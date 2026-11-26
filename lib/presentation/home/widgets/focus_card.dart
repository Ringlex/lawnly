import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/day_panel.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({
    required this.date,
    required this.today,
    required this.entries,
    required this.profile,
    required this.forecast,
    required this.onDone,
    required this.onPostpone,
    required this.onOpen,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final List<CareEntry> entries;
  final LawnProfile profile;

  final DayForecast? forecast;
  final ValueChanged<CareEntry> onDone;
  final VoidCallback onPostpone;
  final ValueChanged<CareEntry> onOpen;

  static int _order(CareEntry entry) => switch (entry.kind) {
    CareKind.mowing => 0,
    CareKind.fertilizing => 1,
    _ => 2,
  };

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final isToday = date == today;
    final sorted = entries.sortedBy<num>(_order);
    final fertilizing = sorted.firstWhereOrNull((e) => e.task == null && e.advice != null);
    final advice = fertilizing?.advice;

    final badge = switch (advice) {
      _ when !isToday => strings.homeBadgeNext,
      FertilizeOn(pinned: true) => strings.homeBadgePinned,
      FertilizeOn(conditions: DayConditions.ideal) => strings.homeBadgeIdeal,
      _ => strings.homeBadgeToday,
    };
    final canPostpone = isToday && advice is FertilizeOn && !advice.pinned;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: Insets.small,
            children: [
              _Badge(badge),
              if (!isToday)
                Flexible(
                  child: Text(
                    strings.homeNothingToday,
                    style: AppTheme.body(fontSize: 13).copyWith(color: palette.heroMutedColor),
                  ),
                ),
            ],
          ),
          Text(
            isToday ? strings.homeTodayWork : capitalized(context.longDate(date)),
            style: AppTheme.display(fontSize: 26).copyWith(color: Colors.white, height: 1.15),
          ),
          if (forecast case final day?) _WeatherLine(day: day),
          for (final entry in sorted)
            _TaskRow(
              entry: entry,
              count: _cycleDay(entry),
              subtitleFor: (count) => _subtitle(context, entry, cycleDay: count),
              onDone: isToday ? () => onDone(entry) : null,
              onTap: () => onOpen(entry),
            ),
          if (fertilizing != null)
            Text(
              strings.homeSeason(_season(date.month)),
              style: AppTheme.body(fontSize: 13).copyWith(color: palette.heroMutedColor),
            ),
          if (canPostpone)
            OutlinedButton(
              onPressed: onPostpone,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.white,
                side: BorderSide(color: palette.heroOutlineColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                ),
                textStyle: AppTheme.body(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              child: Text(strings.homePostponeFertilizing),
            ),
        ],
      ),
    );
  }

  static int _cycleDay(CareEntry entry) => entry.task == null ? (entry.advice?.cycleDay ?? 0) : 0;

  String _subtitle(BuildContext context, CareEntry entry, {int? cycleDay}) {
    final strings = context.strings;
    if (entry.advice case FertilizeOn(
      :final day,
      cycleDay: final plannedCycleDay,
      :final interval,
      :final pinned,
    ) when entry.task == null) {
      final cycle = pinned
          ? strings.entryPinned
          : strings.homeCycleDay(cycleDay ?? plannedCycleDay, interval);
      final rain = day.rainMm <= 0
          ? strings.homeNoRain
          : day.rainFromHour == null
          ? strings.homeRain(formatMm(day.rainMm))
          : strings.homeRainFrom(day.rainFromHour!, formatMm(day.rainMm));
      return '${capitalized(cycle)} · $rain';
    }
    return entrySubtitle(context, entry, profile, forecast);
  }

  static String _season(int month) => switch (month) {
    >= 3 && <= 5 => 'spring',
    >= 6 && <= 8 => 'summer',
    >= 9 && <= 11 => 'autumn',
    _ => 'winter',
  };
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.springColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTheme.body(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ).copyWith(color: const Color(0xFF10301B), letterSpacing: 0.5),
      ),
    );
  }
}

class _WeatherLine extends StatelessWidget {
  const _WeatherLine({required this.day});

  final DayForecast day;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = day.rainFromHour == null
        ? context.weatherSummary(day)
        : context.strings.weatherRainFrom(day.maxTempC.round(), day.rainFromHour!);

    return Row(
      spacing: 10,
      children: [
        Icon(day.kind.icon, size: 18, color: palette.springColor),
        Expanded(
          child: Text(
            capitalized(text),
            style: AppTheme.body(fontSize: 14).copyWith(color: palette.onHeroColor),
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.entry,
    required this.count,
    required this.subtitleFor,
    required this.onDone,
    required this.onTap,
  });

  final CareEntry entry;
  final int count;
  final String Function(int count) subtitleFor;

  final VoidCallback? onDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.medium, Insets.medium, Insets.xSmall, 10),
          child: Row(
            spacing: Insets.medium,
            children: [
              Icon(entry.kind.icon, size: 22, color: palette.springColor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      entry.kind.label(context),
                      style: AppTheme.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: Colors.white),
                    ),
                    CountUp(
                      value: count,
                      builder: (context, value) => Text(
                        subtitleFor(value),
                        style: AppTheme.body(
                          fontSize: 13,
                        ).copyWith(color: palette.heroMutedColor, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDone != null)
                _DoneButton(tooltip: strings.homeMarkDone, onPressed: onDone!)
              else
                Padding(
                  padding: const EdgeInsets.only(right: Insets.small),
                  child: Icon(Icons.chevron_right, color: palette.heroMutedColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneButton extends StatefulWidget {
  const _DoneButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> with SingleTickerProviderStateMixin {
  static const _pressedScale = 0.92;

  var _pressed = false;

  late final _check = AnimationController(vsync: this, duration: AppMotion.medium, value: 1);

  @override
  void dispose() {
    _check.dispose();
    super.dispose();
  }

  void _setPressed(bool value) => setState(() => _pressed = value);

  void _tap() {
    HapticFeedback.lightImpact();
    if (!AppMotion.reduced(context)) _check.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(12);

    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _pressed ? _pressedScale : 1,
        duration: AppMotion.short,
        curve: Curves.easeOut,
        child: Material(
          color: palette.springColor,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: _tap,
            onHighlightChanged: _setPressed,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: DrawnCheck(
                  progress: CurvedAnimation(parent: _check, curve: AppMotion.emphasized),
                  color: const Color(0xFF10301B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
