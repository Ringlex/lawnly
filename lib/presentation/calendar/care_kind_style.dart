import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/l10n/current_l10n.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/home/widgets/weather_icon.dart';

extension CareKindStyle on CareKind {
  Color colorIn(Palette palette) => switch (this) {
    CareKind.fertilizing => palette.primaryColor,
    CareKind.mowing => palette.accentColor,
    CareKind.watering => palette.rainColor,
    _ => palette.sunColor,
  };

  IconData get icon => switch (this) {
    CareKind.fertilizing => Icons.grain,
    CareKind.mowing => Icons.content_cut,
    CareKind.watering => Icons.water_drop_outlined,
    CareKind.aeration => Icons.blur_on,
    CareKind.scarification => Icons.reorder,
    CareKind.overseeding => Icons.spa_outlined,
    CareKind.liming => Icons.science_outlined,
    CareKind.other => Icons.event_note_outlined,
  };

  String label(BuildContext context) => context.strings.careKind(name);
}

extension CalendarFormats on BuildContext {
  String shortDate(DateTime date) => DateFormat(isEnglish ? 'd MMM' : 'd.MM').format(date);

  String longDate(DateTime date) => DateFormat('EEEE, d MMMM').format(date);

  String weekdayDate(DateTime date) =>
      capitalized(DateFormat(isEnglish ? 'EEEE, d MMM' : 'EEEE d.MM').format(date));

  String weatherSummary(DayForecast day) {
    final temp = day.maxTempC.round();
    return day.rainMm > 0
        ? strings.weatherRain(temp, formatMm(day.rainMm))
        : strings.weatherDry(temp);
  }
}
