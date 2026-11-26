import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/branding/lawnly_mark.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_repository.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/presentation/common/dimen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  static const _minimumDuration = Duration(milliseconds: 1200);

  static const _taglineColor = Color(0xFFDCEFD0);
  static const _statusColor = Color(0xFFB9D9AE);
  static const _dotColors = [Color(0xFFC6E8A6), Color(0xFF6FB34F), Color(0xFF2E6B40)];

  late final _intro = AnimationController(vsync: this, duration: AppMotion.long);
  late final _growth = CurvedAnimation(parent: _intro, curve: AppMotion.emphasized);
  late final _wordmark = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.4, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _route();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _intro.value = 1;
    } else if (!_intro.isAnimating && !_intro.isCompleted) {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _route() async {
    final (profile, _) = await (
      getIt<LawnRepository>().profile().run(),
      Future<void>.delayed(_minimumDuration),
    ).wait;
    final launchPayload = profile.isSome()
        ? await getIt<NotificationScheduler>().launchPayload()
        : null;
    if (!mounted) return;

    context.go(profile.isSome() ? Routes.home : Routes.onboarding);
    final date = DateTime.tryParse(launchPayload ?? '');
    if (date != null) unawaited(context.push(Routes.day(date)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = LightPalette();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(
        DarkPalette(),
      ).copyWith(systemNavigationBarColor: LawnlyMark.murawa),
      child: Scaffold(
        backgroundColor: LawnlyMark.murawa,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.xxLarge),
            child: Stack(
              children: [
                Center(child: _brand(context, palette)),
                Align(alignment: Alignment.bottomCenter, child: _status(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand(BuildContext context, LightPalette palette) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: lawnlyMarkHeroTag,
          child: AnimatedBuilder(
            animation: _growth,
            builder: (_, _) => LawnlyMark(
              size: 132,
              background: LawnlyMark.splashGreen,
              outlined: true,
              growth: _growth.value,
            ),
          ),
        ),
        Gap.xLarge,
        FadeTransition(
          opacity: _wordmark,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(_wordmark),
            child: LawnlyWordmark(color: palette.springColor),
          ),
        ),
        Gap.xLarge,
        Text(
          context.strings.appTagline,
          textAlign: TextAlign.center,
          style: AppTheme.body(fontSize: 17).copyWith(color: _taglineColor, height: 1.5),
        ),
      ],
    );
  }

  Widget _status(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xxxLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Insets.small,
            children: [
              for (final color in _dotColors)
                DecoratedBox(
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const SizedBox.square(dimension: 8),
                ),
            ],
          ),
          Gap.large,
          Text(
            context.strings.splashChecking,
            textAlign: TextAlign.center,
            style: AppTheme.body(fontSize: 14).copyWith(color: _statusColor),
          ),
        ],
      ),
    );
  }
}
