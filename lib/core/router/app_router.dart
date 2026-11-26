import 'package:go_router/go_router.dart';
import 'package:lawnly/presentation/common/app_page_transitions.dart';
import 'package:lawnly/presentation/common/route_error_page.dart';
import 'package:lawnly/presentation/day/day_page.dart';
import 'package:lawnly/presentation/home/home_page.dart';
import 'package:lawnly/presentation/onboarding/onboarding_page.dart';
import 'package:lawnly/presentation/splash/splash_page.dart';
import 'package:lawnly/presentation/weather/weather_page.dart';

abstract class Routes {
  const Routes._();

  static const splash = '/';
  static const onboarding = '/start';
  static const home = '/home';
  static const addLawn = '/lawns/new';
  static const weather = '/weather';
  static const _day = '/day/:date';

  static String day(DateTime date) =>
      '/day/${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  errorBuilder: (_, _) => const RouteErrorPage(),
  routes: [
    GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (_, state) => fadeSlidePage(key: state.pageKey, child: const OnboardingPage()),
    ),
    GoRoute(
      path: Routes.addLawn,
      pageBuilder: (_, state) =>
          fadeSlidePage(key: state.pageKey, child: const OnboardingPage(addingLawn: true)),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (_, state) => fadeSlidePage(key: state.pageKey, child: const HomePage()),
    ),
    GoRoute(
      path: Routes.weather,
      pageBuilder: (_, state) => fadeSlidePage(key: state.pageKey, child: const WeatherPage()),
    ),
    GoRoute(
      path: Routes._day,
      pageBuilder: (_, state) => fadeSlidePage(
        key: state.pageKey,
        child: DayPage(date: DateTime.parse(state.pathParameters['date']!)),
      ),
    ),
  ],
);
