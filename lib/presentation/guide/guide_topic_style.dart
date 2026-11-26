import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';

extension GuideTopicStyle on GuideTopic {
  IconData get icon => switch (this) {
    GuideTopic.raking => Icons.cleaning_services_outlined,
    GuideTopic.sanding => Icons.texture,
    _ => kind.icon,
  };

  String title(BuildContext context) => context.strings.guideTopicTitle(name);

  String summary(BuildContext context) => context.strings.guideTopicSummary(name);

  String when(BuildContext context) => context.strings.guideTopicWhen(name);

  String? taskNote(BuildContext context) => kind == CareKind.other ? title(context) : null;
}

String monthKey(int month) => const [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
][month - 1];

List<String> lines(String text) =>
    text.split('\n').where((line) => line.trim().isNotEmpty).toList();
