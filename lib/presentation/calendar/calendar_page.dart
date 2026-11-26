import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/calendar_state.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/calendar/widgets/add_task_sheet.dart';
import 'package:lawnly/presentation/calendar/widgets/day_panel.dart';
import 'package:lawnly/presentation/calendar/widgets/month_grid.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/text_utils.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  Future<void> _addTask(BuildContext context, DateTime date) =>
      showAddTaskSheet(context, cubit: context.read<CalendarCubit>(), initialDate: date);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) => state.type.map(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: () => Center(
          child: OutlinedButton(
            onPressed: context.read<CalendarCubit>().load,
            child: Text(context.strings.commonRetry),
          ),
        ),
        loaded: () {
          final cubit = context.read<CalendarCubit>();
          final selected = state.selected;

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, Insets.large, 20, Insets.large),
              children: [
                _Header(
                  onAdd: () =>
                      _addTask(context, selected.isBefore(state.today) ? state.today : selected),
                ),
                Gap.medium,
                _MonthSwitcher(month: state.month, onChange: cubit.showMonth),
                Gap.medium,
                _MonthPager(
                  month: state.month,
                  onChange: cubit.showMonth,
                  child: MonthGrid(
                    month: state.month,
                    today: state.today,
                    selected: selected,
                    calendar: state.calendar!,
                    onSelect: cubit.select,
                  ),
                ),
                Gap.medium,
                const CalendarLegend(),
                Gap.large,
                DayPanel(
                  date: selected,
                  isToday: selected == state.today,
                  entries: state.calendar!.on(selected),
                  forecast: cubit.forecastFor(selected),
                  profile: state.profile!,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
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
          child: Text(context.strings.calendarTitle, style: context.textTheme.headlineMedium),
        ),
        IconButton(
          onPressed: onAdd,
          tooltip: context.strings.calendarAdd,
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

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.month, required this.onChange});

  final DateTime month;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = IconButton.styleFrom(
      fixedSize: const Size.square(44),
      backgroundColor: palette.cardColor,
      foregroundColor: palette.headingColor,
      side: BorderSide(color: palette.outlineColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.fieldRadius)),
    );

    return Row(
      children: [
        IconButton(
          onPressed: () => onChange(-1),
          tooltip: context.strings.calendarPrevMonth,
          icon: const Icon(Icons.chevron_left),
          style: style,
        ),
        Expanded(
          child: Text(
            capitalized(DateFormat('LLLL yyyy').format(month)),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: () => onChange(1),
          tooltip: context.strings.calendarNextMonth,
          icon: const Icon(Icons.chevron_right),
          style: style,
        ),
      ],
    );
  }
}

class _MonthPager extends StatefulWidget {
  const _MonthPager({required this.month, required this.onChange, required this.child});

  final DateTime month;
  final ValueChanged<int> onChange;
  final Widget child;

  @override
  State<_MonthPager> createState() => _MonthPagerState();
}

class _MonthPagerState extends State<_MonthPager> {
  static const _swipeVelocity = 200.0;

  var _reverse = false;

  @override
  void didUpdateWidget(_MonthPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reverse = widget.month.isBefore(oldWidget.month);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -_swipeVelocity) widget.onChange(1);
    if (velocity >= _swipeVelocity) widget.onChange(-1);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: _onDragEnd,
      child: PageTransitionSwitcher(
        reverse: _reverse,
        duration: reduced ? Duration.zero : AppMotion.medium,
        transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
          child: child,
        ),
        child: KeyedSubtree(key: ValueKey(widget.month), child: widget.child),
      ),
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final style = AppTheme.body(fontSize: 12).copyWith(color: palette.secondaryTextColor);

    Widget item(Widget marker, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        marker,
        Text(label, style: style),
      ],
    );

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final kind in [CareKind.fertilizing, CareKind.mowing, CareKind.watering])
          item(EntryDot(color: kind.colorIn(palette)), kind.label(context)),
        item(EntryDot(color: palette.sunColor), strings.calendarLegendOwn),
        item(
          Container(
            width: 14,
            height: 10,
            decoration: BoxDecoration(
              color: palette.windowColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          strings.calendarLegendWindow,
        ),
        item(
          EntryDot(color: palette.secondaryTextColor, hollow: true),
          strings.calendarLegendTentative,
        ),
      ],
    );
  }
}
