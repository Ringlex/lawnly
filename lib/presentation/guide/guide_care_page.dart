import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/guide/guide.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/guide/guide_topic_page.dart';
import 'package:lawnly/presentation/guide/guide_topic_style.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';

class GuideCarePage extends StatelessWidget {
  const GuideCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final today = CarePlanner.dateOnly(DateTime.now());
    final profile = context.watch<HomeCubit>().state.profile;
    final now = [
      for (final topic in guideOrder)
        if (topic.goodNow(profile, today)) topic,
    ];
    final later = [
      for (final topic in guideOrder)
        if (!topic.goodNow(profile, today)) topic,
    ];
    final laterTitle =
        later.every((topic) => topic.planDate(today, profile: profile).year > today.year)
        ? strings.guideNextSeason
        : strings.guideLater;

    Widget page(GuideTopic topic) => guideScope(context, GuideTopicPage(topic: topic));

    return GuideScaffold(
      title: strings.guideCare,
      subtitle: strings.guideCarePageSub,
      children: [
        if (now.isNotEmpty) ...[
          GuideLabel(strings.guideNowGood, top: Insets.medium),
          _TopicList(topics: now, today: today, profile: profile, pageFor: page),
        ],
        if (later.isNotEmpty) ...[
          GuideLabel(laterTitle, top: now.isEmpty ? Insets.medium : Insets.xLarge),
          _TopicList(topics: later, today: today, profile: profile, pageFor: page),
        ],
        Gap.large,
        GuideWarning(text: strings.guideOrderTip),
      ],
    );
  }
}

class _TopicList extends StatelessWidget {
  const _TopicList({
    required this.topics,
    required this.today,
    required this.profile,
    required this.pageFor,
  });

  final List<GuideTopic> topics;
  final DateTime today;
  final LawnProfile? profile;
  final Widget Function(GuideTopic topic) pageFor;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return GuideCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, topic) in topics.indexed) ...[
            if (i > 0) const Divider(indent: 14, endIndent: 14),
            OpenCard<void>(
              color: palette.cardColor,
              openBuilder: (_) => pageFor(topic),
              closedBuilder: (_, open) => InkWell(
                onTap: open,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    Insets.medium,
                    Insets.medium,
                    Insets.medium,
                  ),
                  child: Row(
                    spacing: Insets.medium,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: palette.tintColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(topic.icon, size: 20, color: palette.primaryColor),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              topic.title(context),
                              style: AppTheme.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ).copyWith(color: palette.headingColor),
                            ),
                            Text(
                              topic.when(context),
                              style: AppTheme.body(
                                fontSize: 13,
                              ).copyWith(color: palette.mutedTextColor),
                            ),
                          ],
                        ),
                      ),
                      if (topic.goodNow(profile, today))
                        GuideBadge(strings.guideNowBadge, solid: false)
                      else
                        Text(
                          capitalized(planMonth(topic.planDate(today, profile: profile), today)),
                          style: AppTheme.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: palette.mutedTextColor),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
