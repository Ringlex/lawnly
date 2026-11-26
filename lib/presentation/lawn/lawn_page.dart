import 'package:adaptive_theme/adaptive_theme.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/branding/lawnly_mark.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/l10n/language_controller.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/programs/program_catalog.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/state_type.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/weekday_label.dart';
import 'package:lawnly/presentation/lawn/calibration_page.dart';
import 'package:lawnly/presentation/lawn/fertilizer_programs_page.dart';
import 'package:lawnly/presentation/lawn/lawn_care_page.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';
import 'package:lawnly/presentation/lawn/lawn_data_page.dart';
import 'package:lawnly/presentation/lawn/lawn_labels.dart';
import 'package:lawnly/presentation/lawn/lawn_name_button.dart';
import 'package:lawnly/presentation/lawn/notification_settings_page.dart';

class LawnPage extends StatelessWidget {
  const LawnPage({required this.onOpenJournal, super.key});

  final VoidCallback onOpenJournal;

  void _push(BuildContext context, Widget page) {
    final cubit = context.read<LawnCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return BlocBuilder<LawnCubit, LawnState>(
      builder: (context, state) => state.type.map(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: () => Center(
          child: OutlinedButton(
            onPressed: context.read<LawnCubit>().load,
            child: Text(strings.commonRetry),
          ),
        ),
        loaded: () {
          final profile = state.profile!;
          final weekdays = [
            for (var day = DateTime.monday; day <= DateTime.sunday; day++)
              if (profile.gardenWeekdays.contains(day)) context.weekdayShort(day),
          ].join(', ');

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, Insets.large, 20, Insets.large),
              children: [
                Text(strings.lawnTitle, style: context.textTheme.headlineMedium),
                Gap.large,
                _LawnCard(state: state, onOpenJournal: onOpenJournal),
                Gap.xLarge,
                _SectionTitle(strings.lawnSettings),
                _Group(
                  children: [
                    _SettingRow(
                      label: strings.lawnData,
                      value: [
                        grassMixShortLabel(context, profile.grassMix),
                        strings.lawnSoilSummary(soilLabel(context, profile.soil).toLowerCase()),
                      ].join(', '),
                      onTap: () => _push(context, const LawnDataPage()),
                    ),
                    _SettingRow(
                      label: strings.lawnCare,
                      value: strings.lawnMowingEvery(strings.daysCount(profile.mowingIntervalDays)),
                      subtitle: strings.lawnCareSub(
                        strings.daysCount(profile.fertilizingIntervalDays),
                        weekdays,
                      ),
                      onTap: () => _push(context, const LawnCarePage()),
                    ),
                    _SettingRow(
                      label: profile.watering == WateringMode.automatic
                          ? strings.lawnCalibration
                          : strings.lawnMeasurement,
                      value: _measurementValue(context, profile),
                      onTap: () => _push(context, const CalibrationPage()),
                    ),
                    const _ProgramsRow(),
                    const NotificationSettingsTile(),
                  ],
                ),
                Gap.xLarge,
                _SectionTitle(strings.lawnAppearance),
                const _ThemePicker(),
                Gap.xLarge,
                _SectionTitle(strings.languageTitle),
                const _LanguagePicker(),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _measurementValue(BuildContext context, LawnProfile profile) {
  final strings = context.strings;
  final rate = profile.sprinklerMmPerMinute;
  final flow = profile.hoseLitresPerMinute;
  String rateOr(double? value, String Function(String) format) =>
      value == null ? strings.lawnNotCalibrated : format(formatDecimal(value));

  if (profile.watering == WateringMode.automatic) return rateOr(rate, strings.lawnRate);
  return switch (profile.manualWateringMethod) {
    null => strings.lawnMethodNone,
    ManualWateringMethod.hoseSprinkler => rateOr(rate, strings.lawnRate),
    ManualWateringMethod.hose => rateOr(flow, strings.lawnFlow),
    ManualWateringMethod.wateringCan => strings.lawnCanValue(wateringCanLitres),
  };
}

class _LawnCard extends StatelessWidget {
  const _LawnCard({required this.state, required this.onOpenJournal});

  final LawnState state;
  final VoidCallback onOpenJournal;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final profile = state.profile!;
    final now = DateTime.now();
    final months =
        (now.year - profile.establishedOn.year) * 12 + now.month - profile.establishedOn.month;
    String date(DateTime? value) => value == null ? '–' : context.shortDate(value);
    final observations = state.observations;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 14,
            children: [
              const LawnlyMark(size: 52, background: LawnlyMark.splashGreen, outlined: true),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    LawnNameButton(
                      name: profile.name,
                      style: AppTheme.display(fontSize: 22).copyWith(color: Colors.white),
                      color: palette.heroMutedColor,
                    ),
                    CountUp(
                      value: profile.areaSqm,
                      builder: (context, area) => Text(
                        strings.lawnSubtitle(
                          profile.location.label ?? strings.locationCurrent,
                          area,
                          strings.lawnAge(months ~/ 12),
                        ),
                        style: AppTheme.body(fontSize: 13).copyWith(color: palette.heroMutedColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: Insets.small,
            children: [
              _Stat(
                label: strings.lawnPh,
                value: profile.soilPh == null ? '–' : formatDecimal(profile.soilPh!),
              ),
              _Stat(label: strings.lawnLastFertilized, value: date(profile.lastFertilizedOn)),
              _Stat(label: strings.lawnLastMowed, value: date(profile.lastMowedOn)),
            ],
          ),
          if (observations.isNotEmpty)
            Material(
              color: palette.springColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onOpenJournal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.medium, vertical: 10),
                  child: Row(
                    spacing: Insets.small,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF10301B)),
                      Expanded(
                        child: Text(
                          strings.lawnObservations(
                            observations.length,
                            {
                              for (final entry in observations)
                                for (final tag in entry.tags) strings.observationTag(tag.name),
                            }.join(', ').toLowerCase(),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ).copyWith(color: const Color(0xFF10301B)),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF10301B)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(label, style: AppTheme.body(fontSize: 11).copyWith(color: palette.heroMutedColor)),
            Text(
              value,
              style: AppTheme.body(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ).copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Insets.small),
    child: Text(
      text.toUpperCase(),
      style: AppTheme.body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ).copyWith(color: context.palette.mutedTextColor, letterSpacing: 0.5),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: Insets.large, endIndent: Insets.large),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ProgramsRow extends StatefulWidget {
  const _ProgramsRow();

  @override
  State<_ProgramsRow> createState() => _ProgramsRowState();
}

class _ProgramsRowState extends State<_ProgramsRow> {
  final _service = getIt<CareService>();

  late final StreamSubscription<void> _changes;
  String? _activeName;

  @override
  void initState() {
    super.initState();
    _changes = _service.changes.listen((_) => unawaited(_refresh()));
    unawaited(_refresh());
  }

  @override
  void dispose() {
    unawaited(_changes.cancel());
    super.dispose();
  }

  Future<void> _refresh() async {
    final plan = await _service.plan().run();
    final id = plan.activeProgramId;
    final custom = plan.customPrograms.where((p) => '${CustomProgram.idPrefix}${p.id}' == id);
    final name = custom.firstOrNull?.name ?? programById(id)?.name.text;
    if (mounted) setState(() => _activeName = name);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return _SettingRow(
      label: strings.programsTitle,
      value: _activeName ?? strings.programsOff,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const FertilizerProgramsPage())),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value, required this.onTap, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.large,
            Insets.small,
            Insets.medium,
            Insets.small,
          ),
          child: Row(
            spacing: Insets.medium,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(label, style: context.textTheme.bodyLarge),
                    if (subtitle != null) Text(subtitle!, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: context.textTheme.titleSmall?.copyWith(color: palette.secondaryTextColor),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: palette.mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final adaptive = AdaptiveTheme.of(context);

    return SegmentedChoice<AdaptiveThemeMode>(
      values: const [AdaptiveThemeMode.light, AdaptiveThemeMode.dark, AdaptiveThemeMode.system],
      selected: adaptive.mode,
      fontSize: 14,
      labelOf: (mode) => switch (mode) {
        AdaptiveThemeMode.light => strings.lawnThemeLight,
        AdaptiveThemeMode.dark => strings.lawnThemeDark,
        AdaptiveThemeMode.system => strings.lawnThemeSystem,
      },
      onSelected: (mode) => switch (mode) {
        AdaptiveThemeMode.light => adaptive.setLight(),
        AdaptiveThemeMode.dark => adaptive.setDark(),
        AdaptiveThemeMode.system => adaptive.setSystem(),
      },
    );
  }
}

class _LanguagePicker extends StatefulWidget {
  const _LanguagePicker();

  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  final _language = getIt<LanguageController>();

  Future<void> _select(AppLanguage language) async {
    await _language.select(language);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SegmentedChoice<AppLanguage>(
      values: AppLanguage.values,
      selected: _language.preference,
      fontSize: 14,
      labelOf: (language) => switch (language) {
        AppLanguage.system => strings.languageSystem,
        AppLanguage.pl => 'Polski',
        AppLanguage.en => 'English',
      },
      onSelected: _select,
    );
  }
}
