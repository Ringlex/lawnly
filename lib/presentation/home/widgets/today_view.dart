import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/month_grid.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/watering_hint.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';
import 'package:lawnly/presentation/home/home_notice.dart';
import 'package:lawnly/presentation/home/home_state.dart';
import 'package:lawnly/presentation/home/widgets/focus_card.dart';
import 'package:lawnly/presentation/home/widgets/notice_card.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';
import 'package:lawnly/presentation/lawn/lawn_name_button.dart';

class TodayView extends StatelessWidget {
  const TodayView({required this.onOpenCalendar, super.key});

  final ValueChanged<DateTime?> onOpenCalendar;

  Future<void> _markDone(BuildContext context, CareEntry entry) async {
    final cubit = context.read<HomeCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;

    final saved = await cubit.markDone(entry);
    final interval = cubit.state.profile?.fertilizingIntervalDays ?? 0;
    final window = _nextWindow(cubit.state);
    final message = !saved
        ? strings.onboardingSaveError
        : entry.kind == CareKind.fertilizing
        ? (window == null ? strings.homeDoneSnack(interval) : strings.homeDoneNextWindow(window))
        : strings.homeDoneGeneric;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String? _nextWindow(HomeState state) {
    final span = state.calendar?.entries
        .where((e) => e.kind == CareKind.fertilizing && e.certainty != EntryCertainty.done)
        .map((e) => e.cycle?.window)
        .nonNulls
        .firstOrNull;
    if (span == null) return null;
    final month = DateFormat('MMMM');
    final sameMonth = span.start.month == span.end.month;
    return sameMonth
        ? '${span.start.day}–${span.end.day} ${month.format(span.end)}'
        : '${span.start.day} ${month.format(span.start)} – ${span.end.day} ${month.format(span.end)}';
  }

  void _postpone(BuildContext context) {
    final cubit = context.read<HomeCubit>()..postpone();
    final strings = context.strings;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(strings.homePostponedSnack),
          action: SnackBarAction(label: strings.sheetUndo, onPressed: cubit.undoPostpone),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => state.type.map(
        loading: () => const Center(child: GrassLoader()),
        error: () => _LoadError(onRetry: context.read<HomeCubit>().load),
        loaded: () => GrassRefresh(
          onRefresh: context.read<HomeCubit>().load,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, Insets.large, 20, Insets.large),
              children: [
                _Header(
                  name: state.profile!.name,
                  today: state.today,
                  forecast: state.forecast,
                  current: state.current,
                ),
                for (final notice in homeNotices(state, DateTime.now())) ...[
                  Gap.large,
                  NoticeCard(notice: notice, onUndo: context.read<HomeCubit>().undoPostpone),
                ],
                Gap.large,
                if (state.focusDate case final date?)
                  FocusCard(
                    date: date,
                    today: state.today,
                    entries: state.focusEntries,
                    profile: state.profile!,
                    forecast: state.forecast.firstWhereOrNull(
                      (day) => CarePlanner.dateOnly(day.date) == date,
                    ),
                    onDone: (entry) => _markDone(context, entry),
                    onPostpone: () => _postpone(context),
                    onOpen: (entry) => onOpenCalendar(entry.date),
                  )
                else if (state.seasonStartsOn case final start?)
                  _OffSeasonCard(
                    text: context.strings.homeSeasonOver(DateFormat('d MMMM').format(start)),
                  ),
                Gap.large,
                _SectionTitle(
                  title: context.strings.homeNextDays,
                  action: context.strings.homeCalendar,
                  onAction: () => onOpenCalendar(null),
                ),
                Gap.medium,
                _DayStrip(forecast: state.forecast, today: state.today, calendar: state.calendar!),
                if (state.inSeason) ...[
                  Gap.large,
                  _WateringCard(advice: state.watering!, profile: state.profile!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.today,
    required this.forecast,
    required this.current,
  });

  final String name;
  final DateTime today;
  final List<DayForecast> forecast;
  final CurrentWeather? current;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final today = forecast.firstOrNull;
    final (icon, iconColor, temperature, kind) = switch (current) {
      final now? => (now.icon, now.colorIn(palette), now.temperatureC, now.kind),
      null => (today?.kind.icon, today?.kind.colorIn(palette), today?.maxTempC, today?.kind),
    };
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                capitalized(DateFormat('EEEE, d MMMM').format(this.today)),
                style: AppTheme.body(fontSize: 14).copyWith(color: palette.mutedTextColor),
              ),
              LawnNameButton(
                name: name,
                style: context.textTheme.headlineMedium,
                color: palette.mutedTextColor,
              ),
            ],
          ),
        ),
        if (icon != null && iconColor != null && temperature != null && kind != null)
          Tooltip(
            message: context.strings.weatherOpen,
            child: Material(
              color: palette.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: palette.outlineColor),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: () => context.push(Routes.weather),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.medium,
                    vertical: Insets.small,
                  ),
                  child: Row(
                    spacing: Insets.small,
                    children: [
                      LiveWeatherIcon(icon: icon, color: iconColor, kind: kind),
                      CountUp(
                        value: temperature.round(),
                        builder: (context, value) => Text(
                          context.strings.homeTemperatureShort(value),
                          style: AppTheme.body(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: palette.headingColor),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: palette.mutedTextColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, required this.onAction});

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: context.textTheme.titleLarge)),
      TextButton(onPressed: onAction, child: Text(action)),
    ],
  );
}

class _DayStrip extends StatefulWidget {
  const _DayStrip({required this.forecast, required this.today, required this.calendar});

  final List<DayForecast> forecast;
  final DateTime today;
  final CalendarPlan calendar;

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const _uncertainFrom = 3;

  static const _tileWidth = 64.0;
  static const _tileHeight = 128.0;
  static const _tileGap = 8.0;
  static const _markerTop = 6.0;

  final _scroll = ScrollController();

  ({Offset from, Offset to})? _hop;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = _fertilizingIndex(oldWidget);
    final after = _fertilizingIndex(widget);
    if (before == null || after == null || before == after || AppMotion.reduced(context)) return;
    _hop = (from: _markerOffset(before), to: _markerOffset(after));
  }

  int? _fertilizingIndex(_DayStrip strip) {
    for (final (index, day) in strip.forecast.indexed) {
      final isPlanned = strip.calendar
          .on(CarePlanner.dateOnly(day.date))
          .any((e) => e.kind == CareKind.fertilizing && e.certainty != EntryCertainty.done);
      if (isPlanned) return index;
    }
    return null;
  }

  Offset _markerOffset(int index) =>
      Offset(index * (_tileWidth + _tileGap) + (_tileWidth - 24) / 2, _markerTop);

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;
    final today = widget.today;

    return SizedBox(
      height: _tileHeight,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            separatorBuilder: (_, _) => HorizontalGap.small,
            itemBuilder: (context, index) {
              final day = forecast[index];
              final date = CarePlanner.dateOnly(day.date);
              final offset = CarePlanner.daysBetween(today, date);

              return SizedBox(
                width: _tileWidth,
                child: _DayTile(
                  day: day,
                  isToday: offset == 0,
                  uncertain: offset >= _uncertainFrom,
                  entries: [
                    for (final entry in widget.calendar.on(date))
                      if (entry.certainty != EntryCertainty.done) entry,
                  ],
                  onTap: () => context.push(Routes.day(date)),
                ),
              );
            },
          ),
          if (_hop case final hop?)
            AnimatedBuilder(
              animation: _scroll,
              builder: (context, child) {
                final shift = Offset(_scroll.hasClients ? -_scroll.offset : 0, 0);
                return Transform.translate(offset: shift, child: child);
              },
              child: LeafHop(
                key: ValueKey(hop),
                from: hop.from,
                to: hop.to,
                onEnd: () => setState(() => _hop = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.isToday,
    required this.uncertain,
    required this.entries,
    required this.onTap,
  });

  final DayForecast day;
  final bool isToday;
  final bool uncertain;
  final List<CareEntry> entries;
  final VoidCallback onTap;

  static const _maxDots = 3;

  static const _minRainMm = 0.5;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    final labelColor = isToday ? Colors.white : palette.headingColor;
    final mutedColor = isToday ? palette.heroMutedColor : palette.mutedTextColor;
    final iconColor = isToday ? palette.springColor : day.kind.colorIn(palette);
    final rainColor = isToday ? palette.springColor : palette.rainColor;

    Color dotColor(CareEntry entry) {
      if (!isToday) return entry.kind.colorIn(palette);
      return entry.kind == CareKind.fertilizing ? palette.springColor : Colors.white;
    }

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5,
      children: [
        Text(
          context.weekdayShort(day.date.weekday),
          style: AppTheme.body(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ).copyWith(color: labelColor),
        ),
        Text(
          context.shortDate(day.date),
          style: AppTheme.body(fontSize: 11).copyWith(color: mutedColor, height: 1),
        ),
        Icon(day.kind.icon, size: 24, color: iconColor),
        CountUp(
          value: day.maxTempC.round(),
          builder: (context, value) => Text(
            strings.homeTemperatureShort(value),
            style: AppTheme.body(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ).copyWith(color: labelColor, height: 1),
          ),
        ),
        SizedBox(
          height: 14,
          child: day.rainMm >= _minRainMm
              ? Text(
                  strings.homeRainMm(formatMm(day.rainMm)),
                  maxLines: 1,
                  style: AppTheme.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: rainColor),
                )
              : null,
        ),
        SizedBox(
          height: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              for (final entry in entries.take(_maxDots))
                EntryDot(
                  color: dotColor(entry),
                  hollow: entry.certainty == EntryCertainty.tentative,
                ),
            ],
          ),
        ),
      ],
    );

    return Material(
      color: isToday ? palette.heroColor : palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: isToday || uncertain ? BorderSide.none : BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: uncertain && !isToday
              ? _DashedBorderPainter(color: palette.outlineColor, radius: AppTheme.fieldRadius)
              : null,
          child: SizedBox.expand(child: content),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 4.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), Radius.circular(radius)),
      );

    for (final metric in outline.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += _dash + _gap) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _WateringCard extends StatelessWidget {
  const _WateringCard({required this.advice, required this.profile});

  final WateringAdvice advice;
  final LawnProfile profile;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    final title = advice.needed ? strings.homeWateringNeeded : strings.homeWateringNotNeeded;
    final body = switch (advice.reason) {
      WateringReason.rainExpected => strings.homeWateringRain,
      WateringReason.cool => strings.homeWateringCool,
      WateringReason.dry => wateringHint(context, profile),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.rainTintColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.water_drop_outlined, size: 22, color: palette.rainColor),
          ),
          Expanded(
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
                  body,
                  style: AppTheme.body(fontSize: 13).copyWith(color: palette.mutedTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xxLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Insets.large,
          children: [
            Text(
              context.strings.homeLoadError,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            OutlinedButton(onPressed: onRetry, child: Text(context.strings.commonRetry)),
          ],
        ),
      ),
    ),
  );
}

class _OffSeasonCard extends StatelessWidget {
  const _OffSeasonCard({required this.text});

  final String text;

  static const _background = Color(0xFF10301B);
  static const _title = Color(0xFFC6E8A6);
  static const _body = Color(0xFFDCEFD0);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _background,
      borderRadius: BorderRadius.circular(AppTheme.heroRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          context.strings.homeOffSeasonTitle,
          style: AppTheme.display(fontSize: 22).copyWith(color: _title),
        ),
        Text(text, style: AppTheme.body(fontSize: 14).copyWith(color: _body, height: 1.4)),
      ],
    ),
  );
}
