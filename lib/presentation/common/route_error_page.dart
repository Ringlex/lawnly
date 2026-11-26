import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/presentation/common/dimen.dart';

class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Insets.xLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Insets.large,
            children: [
              Text(
                context.strings.routeNotFoundTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              FilledButton(
                onPressed: () => context.go(Routes.splash),
                child: Text(context.strings.routeNotFoundAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
