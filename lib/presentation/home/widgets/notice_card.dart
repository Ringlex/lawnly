import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/home/home_notice.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({required this.notice, this.onUndo, super.key});

  final HomeNotice notice;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = context.strings;
    final content = _content(context);
    final (background, border, foreground) = switch (notice) {
      WeatherWarning() => (
        palette.warningTintColor,
        palette.warningOutlineColor,
        palette.onWarningColor,
      ),
      PlanMoved() => (palette.rainTintColor, palette.rainColor, palette.headingColor),
      StaleForecast() => (palette.tintColor, palette.outlineColor, palette.textColor),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(Insets.medium),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.medium,
          children: [
            Icon(content.icon, size: 22, color: foreground),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    content.title,
                    style: AppTheme.display(fontSize: 17).copyWith(color: foreground),
                  ),
                  Text(
                    content.body,
                    style: AppTheme.body(fontSize: 14).copyWith(color: foreground, height: 1.4),
                  ),
                ],
              ),
            ),
            if (notice is PlanMoved && onUndo != null)
              TextButton(
                onPressed: onUndo,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: Text(strings.sheetUndo),
              ),
          ],
        ),
      ),
    );
  }

  ({IconData icon, String title, String body}) _content(BuildContext context) {
    final strings = context.strings;

    return switch (notice) {
      WeatherWarning(:final risk, :final date, :final isToday, :final value) => switch (risk) {
        WeatherRisk.frost => (
          icon: Icons.ac_unit,
          title: strings.noticeFrostTitle,
          body: strings.noticeFrostBody(_day(context, date, isToday), value.round()),
        ),
        WeatherRisk.heat => (
          icon: Icons.wb_sunny_outlined,
          title: strings.noticeHeatTitle,
          body: strings.noticeHeatBody(_day(context, date, isToday), value.round()),
        ),
        WeatherRisk.downpour => (
          icon: Icons.umbrella_outlined,
          title: strings.noticeDownpourTitle,
          body: strings.noticeDownpourBody(_day(context, date, isToday), formatMm(value)),
        ),
      },
      PlanMoved(:final date) => (
        icon: Icons.event_repeat,
        title: strings.noticeMovedTitle(DateFormat('d MMMM').format(date)),
        body: strings.noticeMovedBody,
      ),
      StaleForecast(:final age) => (
        icon: Icons.cloud_off_outlined,
        title: strings.noticeStaleTitle(age.inHours),
        body: strings.noticeStaleBody,
      ),
    };
  }

  String _day(BuildContext context, DateTime date, bool isToday) =>
      isToday ? context.strings.noticeToday : context.strings.noticeTomorrow;
}
