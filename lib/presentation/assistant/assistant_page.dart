import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';
import 'package:lawnly/domain/assistant/offline_answers.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/assistant/chat_page.dart';
import 'package:lawnly/presentation/assistant/diagnose_page.dart';
import 'package:lawnly/presentation/assistant/widgets/assistant_widgets.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/guide/guide_section.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';
import 'package:lawnly/presentation/home/home_state.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  void _push(BuildContext context, Widget page) {
    final cubit = context.read<AssistantCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final quota = context.watch<AssistantCubit>().state;
    final available = context.read<AssistantCubit>().isAvailable;
    final home = context.watch<HomeCubit>().state;
    final profile = home.profile;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.large, 20, Insets.large),
        children: [
          Text(strings.assistantTitle, style: context.textTheme.headlineMedium),
          Text(strings.assistantSubtitle, style: context.textTheme.bodyMedium),
          Gap.large,
          if (!available)
            TipCard(icon: Icons.cloud_off_outlined, text: strings.assistantUnavailable)
          else ...[
            AskBar(
              hint: strings.assistantAskHint,
              enabled: (quota?.remaining ?? 1) > 0,
              onSend: (question, photo) =>
                  _push(context, ChatPage(question: question, photo: photo)),
            ),
            if (quota != null) ...[
              Gap.small,
              QuotaLabel(text: strings.assistantQuota(quota.remaining, quota.limit)),
            ],
            Gap.xLarge,
            _SectionTitle(strings.assistantProblems),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Insets.small,
              crossAxisSpacing: Insets.small,
              childAspectRatio: 0.85,
              children: [
                for (final problem in LawnProblem.values)
                  _ProblemTile(
                    problem: problem,
                    onTap: profile == null
                        ? null
                        : () => _push(context, DiagnosePage(problem: problem, profile: profile)),
                  ),
              ],
            ),
          ],
          Gap.xLarge,
          Row(
            spacing: Insets.small,
            children: [
              _SectionTitle(strings.assistantQuick),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Insets.small, vertical: 2),
                decoration: BoxDecoration(
                  color: context.palette.trackColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(strings.assistantOffline, style: context.textTheme.labelSmall),
              ),
            ],
          ),
          _QuickAnswers(
            home: home,
            onOpen: (question, answer) => _push(context, _offlineChat(question, answer)),
          ),
          Gap.xLarge,
          Row(
            spacing: Insets.small,
            children: [
              _SectionTitle(strings.guideTitle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Insets.small, vertical: 2),
                decoration: BoxDecoration(
                  color: context.palette.trackColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(strings.assistantOffline, style: context.textTheme.labelSmall),
              ),
            ],
          ),
          const GuideSection(),
        ],
      ),
    );
  }

  static ChatPage _offlineChat(String question, String answer) =>
      ChatPage(initialTurns: [ChatTurn.user(question), ChatTurn.assistant(answer, offline: true)]);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Insets.small),
    child: Text(
      text.toUpperCase(),
      style: AppTheme.body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ).copyWith(color: context.palette.mutedTextColor, letterSpacing: 0.5),
    ),
  );
}

class _ProblemTile extends StatelessWidget {
  const _ProblemTile({required this.problem, required this.onTap});

  final LawnProblem problem;
  final VoidCallback? onTap;

  static IconData _icon(LawnProblem problem) => switch (problem) {
    LawnProblem.yellowPatches => Icons.circle_outlined,
    LawnProblem.dryGrass => Icons.wb_sunny_outlined,
    LawnProblem.moss => Icons.waves,
    LawnProblem.weeds => Icons.local_florist_outlined,
    LawnProblem.bareSpots => Icons.crop_square,
    LawnProblem.fungus => Icons.coronavirus_outlined,
    LawnProblem.molehills => Icons.landscape_outlined,
    LawnProblem.grubs => Icons.bug_report_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.buttonRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Insets.xSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Insets.small,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.tintColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon(problem), size: 20, color: palette.primaryColor),
              ),
              Text(
                context.strings.lawnProblem(problem.name),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTheme.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.headingColor, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAnswers extends StatelessWidget {
  const _QuickAnswers({required this.home, required this.onOpen});

  final HomeState home;
  final void Function(String question, String answer) onOpen;

  String _weekAnswer(BuildContext context) {
    final strings = context.strings;
    final calendar = home.calendar;
    final today = home.today;
    final end = today.add(const Duration(days: 7));
    final upcoming = [
      for (final entry in calendar?.entries ?? const <CareEntry>[])
        if (entry.certainty != EntryCertainty.done &&
            !entry.date.isBefore(today) &&
            entry.date.isBefore(end))
          entry,
    ];
    if (upcoming.isEmpty) return strings.quickWeekNone;

    final days = groupBy(upcoming, (e) => e.date).entries.sortedBy((e) => e.key);
    return [
      strings.quickWeekIntro,
      for (final MapEntry(key: day, value: entries) in days)
        '${capitalized(context.longDate(day))}: ${entries.map((e) => e.kind.label(context).toLowerCase()).toSet().join(', ')}',
    ].join('\n');
  }

  String _weekPreview(BuildContext context, String answer) {
    final lines = answer.split('\n');
    return lines.length > 1 ? lines[1] : lines.first;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final week = _weekAnswer(context);
    final scarify = scarificationAdvice(
      CarePlanner.dateOnly(DateTime.now()),
      profile: home.profile,
    );
    final nextDate = scarify.next == null ? null : DateFormat('d MMMM').format(scarify.next!);
    final scarifyAnswer = scarify.now
        ? strings.quickScarifyNow
        : '${scarify.tooYoung ? strings.quickScarifyYoung : strings.quickScarifyLater}'
              '\n\n${strings.quickScarifyNext(nextDate!)}';

    final questions = [
      (strings.quickWeek, week, _weekPreview(context, week)),
      (
        strings.quickScarify,
        scarifyAnswer,
        scarify.now ? strings.quickScarifyNowPreview : strings.quickScarifyLaterPreview(nextDate!),
      ),
      (strings.quickWinter, strings.quickWinterText, strings.quickWinterPreview),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        children: [
          for (final (i, (question, answer, preview)) in questions.indexed) ...[
            if (i > 0) const Divider(indent: Insets.large, endIndent: Insets.large),
            ListTile(
              contentPadding: const EdgeInsets.only(left: Insets.large, right: Insets.medium),
              title: Text(question, style: context.textTheme.titleMedium),
              subtitle: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
              trailing: Icon(Icons.chevron_right, color: palette.mutedTextColor),
              onTap: () => onOpen(question, answer),
            ),
          ],
        ],
      ),
    );
  }
}
