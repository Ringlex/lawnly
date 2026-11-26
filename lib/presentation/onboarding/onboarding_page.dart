import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/branding/lawnly_mark.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/lawn/lawn_repository.dart';
import 'package:lawnly/domain/lawn/lawn_service.dart';
import 'package:lawnly/presentation/backup/backup_actions.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/onboarding/onboarding_cubit.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';
import 'package:lawnly/presentation/onboarding/steps/basics_step.dart';
import 'package:lawnly/presentation/onboarding/steps/care_step.dart';
import 'package:lawnly/presentation/onboarding/steps/feeding_step.dart';
import 'package:lawnly/presentation/onboarding/steps/location_step.dart';
import 'package:lawnly/presentation/onboarding/steps/soil_step.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({this.addingLawn = false, super.key});

  final bool addingLawn;

  Future<bool> _saveFirstLawn(LawnProfile profile) async =>
      (await getIt<LawnRepository>().save(profile).run()).isRight();

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => OnboardingCubit(
      saveProfile: addingLawn ? getIt<LawnService>().add : _saveFirstLawn,
      locationRepository: getIt(),
    ),
    child: _OnboardingView(onClose: addingLawn ? () => context.pop() : null),
  );
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView({required this.onClose});

  final VoidCallback? onClose;

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _canRestoreBackup(OnboardingState state) =>
      widget.onClose == null && state.step == 0 && state.status == OnboardingStatus.editing;

  bool _canSkipRest(OnboardingState state) =>
      state.status == OnboardingStatus.editing &&
      state.step >= 1 &&
      state.step < OnboardingCubit.stepCount - 1 &&
      state.draft.isStepComplete(state.step);

  void _onStateChanged(BuildContext context, OnboardingState state) {
    if (state.status == OnboardingStatus.done) {
      context.go(Routes.home);
      return;
    }
    if (_pageController.hasClients && _pageController.page?.round() != state.step) {
      FocusScope.of(context).unfocus();
      _pageController.animateToPage(
        state.step,
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.step != current.step || previous.status != current.status,
      listener: _onStateChanged,
      builder: (context, state) => PopScope(
        canPop: state.step == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) cubit.back();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, Insets.xxLarge, 20, 0),
                  child: _StepHeader(step: state.step, onBack: cubit.back, onClose: widget.onClose),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final (index, step) in const [
                        LocationStep(),
                        BasicsStep(),
                        SoilStep(),
                        CareStep(),
                        FeedingStep(),
                      ].indexed)
                        _StepTransition(controller: _pageController, index: index, child: step),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Insets.xSmall,
                    children: [
                      _NextButton(state: state, onPressed: cubit.next),
                      if (_canRestoreBackup(state))
                        TextButton(
                          onPressed: () => importBackup(context, replacesData: false),
                          child: Text(context.strings.backupRestoreFromFile),
                        ),
                      if (_canSkipRest(state))
                        TextButton(
                          onPressed: cubit.finishWithDefaults,
                          child: Text(context.strings.onboardingSkipRest),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTransition extends StatelessWidget {
  const _StepTransition({required this.controller, required this.index, required this.child});

  final PageController controller;
  final int index;
  final Widget child;

  static const _shift = 30.0;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? controller.page ?? index.toDouble()
            : index.toDouble();
        final delta = (index - page).clamp(-1.0, 1.0);

        return Opacity(
          opacity: 1 - delta.abs(),
          child: Transform.translate(offset: Offset(delta * _shift, 0), child: child),
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.onBack, required this.onClose});

  final int step;
  final VoidCallback onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final close = step == 0 ? onClose : null;

    return Row(
      spacing: Insets.medium,
      children: [
        if (step == 0 && close == null)
          const Hero(tag: lawnlyMarkHeroTag, child: LawnlyMark())
        else
          IconButton(
            onPressed: close ?? onBack,
            tooltip: context.strings.commonBack,
            icon: Icon(close == null ? Icons.chevron_left : Icons.close),
            style: IconButton.styleFrom(
              fixedSize: const Size.square(44),
              backgroundColor: palette.cardColor,
              foregroundColor: palette.headingColor,
              side: BorderSide(color: palette.outlineColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                context.strings.onboardingStep(step + 1, OnboardingCubit.stepCount),
                style: AppTheme.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.mutedTextColor),
              ),
              Row(
                spacing: Insets.xSmall,
                children: [
                  for (var i = 0; i < OnboardingCubit.stepCount; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: AppMotion.medium,
                        curve: AppMotion.emphasized,
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= step ? palette.primaryColor : palette.outlineColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.state, required this.onPressed});

  final OnboardingState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLast = state.step == OnboardingCubit.stepCount - 1;
    final busy = state.status != OnboardingStatus.editing;
    final enabled = state.draft.isStepComplete(state.step) && !busy;

    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: busy
          ? SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.palette.mutedTextColor,
              ),
            )
          : Text(isLast ? context.strings.onboardingFinish : context.strings.commonNext),
    );
  }
}

class OnboardingStepLayout extends StatelessWidget {
  const OnboardingStepLayout({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, Insets.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textTheme.displaySmall),
          if (subtitle != null) ...[
            Gap.small,
            Text(
              subtitle!,
              style: AppTheme.body(
                fontSize: 15,
              ).copyWith(color: palette.secondaryTextColor, height: 1.5),
            ),
          ],
          Gap.xLarge,
          ...children,
        ],
      ),
    );
  }
}

class OnboardingErrorText extends StatelessWidget {
  const OnboardingErrorText({required this.error, super.key});

  final OnboardingError error;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final text = switch (error) {
      OnboardingError.locationServiceDisabled => strings.locationServiceDisabled,
      OnboardingError.locationPermissionDenied => strings.locationPermissionDenied,
      OnboardingError.cityNotFound => strings.locationNotFound,
      OnboardingError.network => strings.locationNetwork,
      OnboardingError.save => strings.onboardingSaveError,
    };

    return Text(
      text,
      style: AppTheme.body(fontSize: 13).copyWith(color: context.palette.errorColor),
    );
  }
}
