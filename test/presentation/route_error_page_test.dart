import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/presentation/common/route_error_page.dart';

void main() {
  testWidgets('nieznana ścieżka pokazuje stronę błędu z powrotem na start', (tester) async {
    final router = GoRouter(
      initialLocation: '/nie-ma',
      errorBuilder: (_, _) => const RouteErrorPage(),
      routes: [GoRoute(path: '/', builder: (_, _) => const Text('start'))],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nie ma takiej strony'), findsOneWidget);

    await tester.tap(find.text('Wróć na start'));
    await tester.pumpAndSettle();

    expect(find.text('start'), findsOneWidget);
  });
}
