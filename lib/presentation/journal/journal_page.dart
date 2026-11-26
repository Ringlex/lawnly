import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/journal/season_summary.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/journal/journal_cubit.dart';
import 'package:lawnly/presentation/journal/journal_editor_sheet.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/journal/journal_entry_page.dart';
import 'package:lawnly/presentation/journal/season_page.dart';
import 'package:lawnly/presentation/journal/widgets/journal_widgets.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  void _push(BuildContext context, Widget page) {
    final cubit = context.read<JournalCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) => state.type.map(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: () => Center(
          child: OutlinedButton(
            onPressed: context.read<JournalCubit>().load,
            child: Text(strings.commonRetry),
          ),
        ),
        loaded: () {
          final cubit = context.read<JournalCubit>();
          final today = CarePlanner.dateOnly(DateTime.now());
          final days = groupBy(state.visible, (e) => CarePlanner.dateOnly(e.date));

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, Insets.large, 20, Insets.large),
              children: [
                _Header(onAdd: () => showJournalEditor(context, cubit: cubit)),
                Gap.medium,
                if (state.summary case final summary?)
                  _SeasonCard(summary: summary, onTap: () => _push(context, const SeasonPage())),
                Gap.medium,
                _Filters(selected: state.filter, onSelected: cubit.setFilter),
                Gap.medium,
                if (state.entries.isEmpty)
                  TextBlock(strings.journalEmpty)
                else if (days.isEmpty)
                  TextBlock(strings.journalFilterEmpty)
                else
                  for (final MapEntry(key: day, value: entries) in days.entries) ...[
                    _DayHeader(day: day, isToday: day == today),
                    for (final entry in entries) ...[
                      OpenCard<void>(
                        radius: BorderRadius.circular(AppTheme.buttonRadius),
                        color: context.palette.cardColor,
                        openBuilder: (_) => BlocProvider.value(
                          value: cubit,
                          child: JournalEntryPage(id: entry.id),
                        ),
                        closedBuilder: (_, open) => JournalEntryTile(
                          entry: entry,
                          profile: state.profile!,
                          photoFile: cubit.photoFile,
                          onTap: open,
                        ),
                      ),
                      Gap.small,
                    ],
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class TextBlock extends StatelessWidget {
  const TextBlock(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Insets.large),
    child: Text(text, style: context.textTheme.bodyMedium),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: Text(context.strings.journalTitle, style: context.textTheme.headlineMedium),
        ),
        IconButton(
          onPressed: onAdd,
          tooltip: context.strings.journalAdd,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(44),
            backgroundColor: palette.primaryColor,
            foregroundColor: palette.onPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.summary, required this.onTap});

  final SeasonSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.heroRadius);

    Widget stat(int count, String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          '$count',
          style: AppTheme.display(fontSize: 28).copyWith(color: Colors.white, height: 1),
        ),
        Text(label, style: AppTheme.body(fontSize: 12).copyWith(color: palette.heroMutedColor)),
      ],
    );

    return Material(
      color: palette.heroColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: Insets.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.medium,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.journalSeason(summary.start.year).toUpperCase(),
                      style: AppTheme.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: palette.springColor, letterSpacing: 0.7),
                    ),
                  ),
                  Text(
                    strings.journalSummary,
                    style: AppTheme.body(fontSize: 13).copyWith(color: palette.heroMutedColor),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: palette.heroMutedColor),
                ],
              ),
              Row(
                children: [
                  Expanded(child: stat(summary.mowings, strings.journalMowings(summary.mowings))),
                  Expanded(
                    child: stat(
                      summary.fertilizings,
                      strings.journalFertilizings(summary.fertilizings),
                    ),
                  ),
                  Expanded(
                    child: stat(summary.waterings, strings.journalWaterings(summary.waterings)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});

  final JournalFilter selected;
  final ValueChanged<JournalFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    String label(JournalFilter filter) => switch (filter) {
      JournalFilter.all => strings.journalFilterAll,
      JournalFilter.fertilizing => CareKind.fertilizing.label(context),
      JournalFilter.mowing => CareKind.mowing.label(context),
      JournalFilter.notes => strings.journalFilterNotes,
      JournalFilter.photos => strings.journalFilterPhotos,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: Insets.small,
        children: [
          for (final filter in JournalFilter.values)
            ChoiceChip(
              label: Text(label(filter)),
              selected: filter == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(filter),
              shape: const StadiumBorder(),
              side: filter == selected ? BorderSide.none : BorderSide(color: palette.outlineColor),
              backgroundColor: palette.cardColor,
              selectedColor: palette.primaryColor,
              labelStyle:
                  AppTheme.body(
                    fontSize: 13,
                    fontWeight: filter == selected ? FontWeight.w600 : FontWeight.w500,
                  ).copyWith(
                    color: filter == selected ? palette.onPrimaryColor : palette.secondaryTextColor,
                  ),
            ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.isToday});

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final date = context.longDate(day);
    final text = isToday ? context.strings.calendarToday(date.replaceFirst(',', '')) : date;

    return Padding(
      padding: const EdgeInsets.only(top: Insets.xSmall, bottom: Insets.small),
      child: Text(
        capitalized(text).toUpperCase(),
        style: AppTheme.body(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ).copyWith(color: context.palette.mutedTextColor, letterSpacing: 0.3),
      ),
    );
  }
}
