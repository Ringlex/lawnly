import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/assistant/chat_page.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/widgets/add_task_sheet.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/guide/guide_topic_style.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';

class GuideTopicPage extends StatelessWidget {
  const GuideTopicPage({required this.topic, super.key});

  final GuideTopic topic;

  void _plan(BuildContext context, DateTime date) => showAddTaskSheet(
    context,
    cubit: context.read<CalendarCubit>(),
    initialDate: date,
    kind: topic.kind,
    note: topic.taskNote(context),
  );

  void _ask(BuildContext context) {
    final assistant = context.read<AssistantCubit>();
    final question = context.strings.guideAskQuestion(topic.title(context).toLowerCase());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: assistant,
          child: ChatPage(question: question),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final today = CarePlanner.dateOnly(DateTime.now());
    final profile = context.watch<HomeCubit>().state.profile;
    final planDate = topic.planDate(today, profile: profile);
    final readyOn = profile == null ? null : topic.readyOn(profile);
    final assistant = context.watch<AssistantCubit>();
    final canAsk = assistant.isAvailable && (assistant.state?.remaining ?? 1) > 0;

    return GuideScaffold(
      title: topic.title(context),
      subtitle: topic.summary(context),
      children: [
        Gap.small,
        if (topic.tooYoung(profile, today)) ...[
          GuideWarning(
            title: strings.guideTooYoungTitle,
            text: strings.guideTooYoung(DateFormat('LLLL yyyy').format(readyOn!)),
          ),
          Gap.medium,
        ],
        _WhenCard(topic: topic, month: today.month),
        GuideLabel(strings.guideSignsTitle),
        GuideChecklist(lines(strings.guideTopicSigns(topic.name))),
        GuideLabel(strings.guideStepsTitle),
        _Steps(lines(strings.guideTopicSteps(topic.name))),
        GuideLabel(strings.guideToolsTitle),
        Wrap(
          spacing: Insets.small,
          runSpacing: Insets.small,
          children: [
            for (final tool in lines(strings.guideTopicTools(topic.name)))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Insets.medium, vertical: 7),
                decoration: BoxDecoration(
                  color: palette.cardColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.outlineColor),
                ),
                child: Text(
                  tool,
                  style: AppTheme.body(fontSize: 13).copyWith(color: palette.secondaryTextColor),
                ),
              ),
          ],
        ),
        Gap.xLarge,
        GuideWarning(title: strings.guideAvoidTitle, text: strings.guideTopicAvoid(topic.name)),
        Gap.xLarge,
        FilledButton.icon(
          onPressed: () => _plan(context, planDate),
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            planDate == today
                ? strings.guidePlanNow
                : strings.guidePlanOn(planMonth(planDate, today)),
          ),
        ),
        if (canAsk) ...[
          Gap.small,
          OutlinedButton(onPressed: () => _ask(context), child: Text(strings.guideAsk)),
        ],
      ],
    );
  }
}

class _WhenCard extends StatelessWidget {
  const _WhenCard({required this.topic, required this.month});

  final GuideTopic topic;
  final int month;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final idle = palette.heroOutlineColor.withValues(alpha: 0.45);
    final legendStyle = AppTheme.body(fontSize: 12).copyWith(color: palette.onHeroColor);

    BoxDecoration cell({required bool best, required bool possible, required bool now}) =>
        BoxDecoration(
          color: best ? palette.springColor : (possible ? null : idle),
          borderRadius: BorderRadius.circular(5),
          border: now
              ? Border.all(color: Colors.white, width: 2)
              : possible
              ? Border.all(color: palette.springColor, width: 2)
              : null,
        );

    Widget legend(BoxDecoration decoration, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(width: 12, height: 12, decoration: decoration),
        Text(label, style: legendStyle),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.medium,
        children: [
          Text(
            strings.guideWhen.toUpperCase(),
            style: AppTheme.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ).copyWith(color: palette.springColor, letterSpacing: 0.5),
          ),
          Row(
            spacing: 3,
            children: [
              for (var m = 1; m <= 12; m++)
                Expanded(
                  child: Column(
                    spacing: Insets.xSmall,
                    children: [
                      Container(
                        height: 26,
                        decoration: cell(
                          best: topic.best.contains(m),
                          possible: topic.possible.contains(m),
                          now: m == month,
                        ),
                      ),
                      Text(
                        DateFormat('MMMMM').format(DateTime(2000, m)).toUpperCase(),
                        style:
                            AppTheme.body(
                              fontSize: 10,
                              fontWeight: topic.goodIn(m) || m == month
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ).copyWith(
                              color: topic.goodIn(m) || m == month
                                  ? Colors.white
                                  : palette.heroMutedColor,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: 14,
            runSpacing: Insets.xSmall,
            children: [
              legend(cell(best: true, possible: false, now: false), strings.guideBest),
              if (topic.possible.isNotEmpty)
                legend(cell(best: false, possible: true, now: false), strings.guidePossible),
              legend(
                BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                strings.guideNowLegend,
              ),
            ],
          ),
          Text(
            strings.guideTopicWhenText(topic.name),
            style: AppTheme.body(fontSize: 14).copyWith(color: palette.onHeroColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps(this.steps);

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GuideCard(
      padding: const EdgeInsets.all(Insets.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          for (final (i, step) in steps.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.medium,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: palette.primaryColor, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: AppTheme.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: palette.onPrimaryColor),
                  ),
                ),
                Expanded(child: _StepText(step)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  const _StepText(this.step);

  final String step;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final split = step.indexOf(': ');
    final title = split < 0 ? step : step.substring(0, split);
    final body = split < 0 ? null : step.substring(split + 2);

    return Column(
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
        if (body != null)
          Text(
            body,
            style: AppTheme.body(
              fontSize: 14,
            ).copyWith(color: palette.secondaryTextColor, height: 1.45),
          ),
      ],
    );
  }
}
