import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/app_bloc_observer.dart';
import 'package:lawnly/presentation/common/content_width_limit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = AppLogger.instance()
    ..configure(level: kDebugMode ? AppLogger.levelAll : AppLogger.levelSevere);
  if (kDebugMode) {
    logger.enableConsoleOutput();
  }
  Bloc.observer = AppBlocObserver();

  Intl.defaultLocale = 'pl';
  await initializeDateFormatting('pl');
  await configureDependencies();
  final themeMode = await AdaptiveTheme.getThemeMode();

  getIt<NotificationScheduler>().selections.listen(
    (payload) => appRouter.push(Routes.day(DateTime.parse(payload))),
  );

  runApp(LawnlyApp(themeMode: themeMode ?? AdaptiveThemeMode.system));
}

class LawnlyApp extends StatelessWidget {
  const LawnlyApp({required this.themeMode, super.key});

  final AdaptiveThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme();

    return AdaptiveTheme(
      light: appTheme.theme(LightPalette()),
      dark: appTheme.theme(DarkPalette()),
      initial: themeMode,
      builder: (light, dark) => MaterialApp.router(
        title: 'Lawnly',
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.overlayStyle(context.palette),
          child: ContentWidthLimit(child: child!),
        ),
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        routerConfig: appRouter,
        locale: const Locale('pl'),
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
