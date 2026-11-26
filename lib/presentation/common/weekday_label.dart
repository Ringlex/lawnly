import 'package:flutter/widgets.dart';
import 'package:lawnly/core/l10n/app_strings.dart';

extension WeekdayLabel on BuildContext {
  String weekdayShort(int weekday) =>
      strings.weekdayShort(const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][weekday - 1]);
}
