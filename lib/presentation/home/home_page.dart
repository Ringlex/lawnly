import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/domain/lawn/lawn_service.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/assistant/assistant_page.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/calendar/calendar_page.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';
import 'package:lawnly/presentation/journal/journal_cubit.dart';
import 'package:lawnly/presentation/journal/journal_page.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';
import 'package:lawnly/presentation/lawn/lawn_page.dart';
import 'package:lawnly/presentation/home/widgets/home_nav_bar.dart';
import 'package:lawnly/presentation/home/widgets/today_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: getIt<LawnService>().activeId,
    builder: (_, lawnId, _) => MultiBlocProvider(
      key: ValueKey(lawnId),
      providers: [
        BlocProvider(
          create: (_) => HomeCubit(
            careService: getIt(),
            calendar: getIt(),
            planner: getIt(),
            notifications: getIt(),
          )..load(),
        ),
        BlocProvider(
          create: (_) => CalendarCubit(careService: getIt(), calendar: getIt())..load(),
        ),
        BlocProvider(create: (_) => JournalCubit(careService: getIt())..load()),
        BlocProvider(create: (_) => LawnCubit(careService: getIt())..load()),
        BlocProvider(create: (_) => AssistantCubit(service: getIt())..loadQuota()),
      ],
      child: const _HomeShell(),
    ),
  );
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> with SingleTickerProviderStateMixin {
  static const _fadeDuration = Duration(milliseconds: 250);
  static const _enterScale = 0.96;

  var _tab = HomeTab.today;

  late final _fade = AnimationController(vsync: this, duration: _fadeDuration, value: 1);

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _select(HomeTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    if (!AppMotion.reduced(context)) _fade.forward(from: 0);
  }

  void _openCalendar(DateTime? date) {
    if (date != null) context.read<CalendarCubit>().select(date);
    _select(HomeTab.calendar);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(palette, navigationBarColor: palette.cardColor),
      child: Scaffold(
        body: FadeTransition(
          opacity: CurvedAnimation(
            parent: _fade,
            curve: const Interval(0.35, 1, curve: Curves.easeOut),
          ),
          child: ScaleTransition(
            scale: Tween(
              begin: _enterScale,
              end: 1.0,
            ).animate(CurvedAnimation(parent: _fade, curve: AppMotion.emphasized)),
            child: IndexedStack(
              index: _tab.index,
              children: [
                for (final tab in HomeTab.values)
                  switch (tab) {
                    HomeTab.today => TodayView(onOpenCalendar: _openCalendar),
                    HomeTab.calendar => const CalendarPage(),
                    HomeTab.journal => const JournalPage(),
                    HomeTab.assistant => const AssistantPage(),
                    HomeTab.lawn => LawnPage(onOpenJournal: () => _select(HomeTab.journal)),
                  },
              ],
            ),
          ),
        ),
        bottomNavigationBar: HomeNavBar(selected: _tab, onSelected: _select),
      ),
    );
  }
}
