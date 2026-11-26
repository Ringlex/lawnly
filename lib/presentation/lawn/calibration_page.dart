import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/plan/sprinkler_calibration.dart';
import 'package:lawnly/domain/plan/watering_guide.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/common/watering_hint.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  static const _cupCount = 4;

  late final LawnProfile _profile = context.read<LawnCubit>().state.profile!;
  late final bool _manual = _profile.watering == WateringMode.manual;
  late ManualWateringMethod _method =
      _profile.manualWateringMethod ?? ManualWateringMethod.hoseSprinkler;

  final _cups = List.generate(_cupCount, (_) => TextEditingController());
  late final _coverage = TextEditingController(
    text: _profile.sprinklerCoverageSqm == null
        ? ''
        : formatDecimal(_profile.sprinklerCoverageSqm!),
  );
  final _seconds = TextEditingController();
  final _testArea = TextEditingController(text: '9');
  var _minutes = 15;
  var _bucketLitres = 10;

  var _hoseByCups = false;
  var _hoseMinutes = 5;
  var _saving = false;

  bool get _usesCups => !_manual || _method == ManualWateringMethod.hoseSprinkler;

  @override
  void dispose() {
    for (final controller in [..._cups, _coverage, _seconds, _testArea]) {
      controller.dispose();
    }
    super.dispose();
  }

  static double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  SprinklerCalibration? get _cupResult =>
      SprinklerCalibration.measure([for (final cup in _cups) _number(cup)], minutes: _minutes);

  SprinklerCalibration? get _hoseCupResult =>
      SprinklerCalibration.measure([for (final cup in _cups) _number(cup)], minutes: _hoseMinutes);

  double? get _flow {
    if (_hoseByCups) {
      final area = _number(_testArea);
      final result = _hoseCupResult;
      return area == null || area <= 0 || result == null ? null : result.mmPerMinute * area;
    }
    final seconds = _number(_seconds);
    return seconds == null || seconds <= 0 ? null : _bucketLitres * 60 / seconds;
  }

  LawnProfile? get _measured {
    final method = _manual ? _method : null;
    final base = _profile.copyWith(manualWateringMethod: method ?? _profile.manualWateringMethod);
    if (_usesCups) {
      final result = _cupResult;
      if (result == null) return null;
      final coverage = _number(_coverage);
      return base.copyWith(
        sprinklerMmPerMinute: result.mmPerMinute,
        sprinklerCoverageSqm: _manual && coverage != null && coverage > 0
            ? coverage
            : base.sprinklerCoverageSqm,
      );
    }
    if (_method == ManualWateringMethod.hose) {
      final flow = _flow;
      return flow == null ? null : base.copyWith(hoseLitresPerMinute: flow);
    }
    return base;
  }

  Future<void> _save(LawnProfile profile) async {
    if (_saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;

    final saved = await context.read<LawnCubit>().save(profile);
    messenger.showSnackBar(
      SnackBar(content: Text(saved ? strings.lawnSaved : strings.onboardingSaveError)),
    );
    if (saved) {
      navigator.pop();
    } else if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final measured = _measured;
    final isHose = _manual && _method == ManualWateringMethod.hose;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_manual ? strings.lawnMeasurement : strings.lawnCalibration),
            Text(
              isHose ? strings.calHoseSubtitle : strings.calSubtitle,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          if (_manual) ...[
            LabeledField(
              label: FieldLabel(strings.manualMethodLabel),
              child: ManualMethodChoice(
                selected: _method,
                onSelected: (method) => setState(() => _method = method),
              ),
            ),
            Gap.large,
          ],
          ...switch ((_usesCups, _method)) {
            (true, _) => _cupsTest(context),
            (false, ManualWateringMethod.hose) => _bucketTest(context),
            _ => [_canInfo(context)],
          },
          Gap.xLarge,
          FilledButton(
            onPressed: measured == null || _saving ? null : () => _save(measured),
            child: Text(strings.calSave),
          ),
        ],
      ),
    );
  }

  List<Widget> _cupsTest(BuildContext context) {
    final strings = context.strings;
    final result = _cupResult;
    final coverage = _number(_coverage);

    return [
      _StepsCard(
        steps: [
          (strings.calStep1Title, strings.calStep1),
          (strings.calStep2Title(_minutes), strings.calStep2),
          (strings.calStep3Title, strings.calStep3),
        ],
      ),
      Gap.large,
      LabeledField(
        label: FieldLabel(strings.calTestTime),
        child: DayStepper(
          value: _minutes,
          label: '$_minutes ${strings.commonMinutes}',
          min: 5,
          max: 60,
          decreaseLabel: strings.commonLess,
          increaseLabel: strings.commonMore,
          onChanged: (minutes) => setState(() => _minutes = minutes),
        ),
      ),
      Gap.large,
      _CupRow(cups: _cups, onChanged: _refresh),
      if (_manual) ...[
        Gap.large,
        LabeledField(
          label: FieldLabel(strings.calCoverage, suffix: strings.commonOptional),
          helper: strings.calCoverageHelper,
          child: _NumberField(
            controller: _coverage,
            suffix: strings.commonSquareMeters,
            onChanged: _refresh,
          ),
        ),
      ],
      Gap.large,
      if (result == null)
        Text(strings.calMissing, style: context.textTheme.bodySmall)
      else
        _ResultCard(
          value: strings.calRate(formatDecimal(result.mmPerMinute)),
          lines: [
            strings.calAverage(
              formatDecimal(result.averageMm),
              result.minutes,
              wateringTargetMm,
              result.minutesFor(wateringTargetMm),
            ),
            if (_manual && coverage != null && coverage > 0)
              strings.calMoves(_profile.areaSqm, (_profile.areaSqm / coverage).ceil()),
          ],
          note: result.isEven
              ? strings.calEven(formatDecimal(result.spreadMm))
              : strings.calUneven(formatDecimal(result.spreadMm)),
        ),
    ];
  }

  List<Widget> _bucketTest(BuildContext context) {
    final strings = context.strings;
    final flow = _flow;
    final area = _profile.areaSqm;
    final cupResult = _hoseCupResult;

    return [
      SegmentedChoice<bool>(
        values: const [false, true],
        selected: _hoseByCups,
        labelOf: (byCups) => byCups ? strings.calHoseByCups : strings.calHoseByBucket,
        onSelected: (byCups) => setState(() => _hoseByCups = byCups),
      ),
      Gap.large,
      if (_hoseByCups) ...[
        _StepsCard(
          steps: [
            (strings.calHoseCupsStep1Title, strings.calHoseCupsStep1),
            (strings.calHoseCupsStep2Title(_hoseMinutes), strings.calHoseCupsStep2),
            (strings.calStep3Title, strings.calStep3),
          ],
        ),
        Gap.large,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.medium,
          children: [
            Expanded(
              child: LabeledField(
                label: FieldLabel(strings.calTestArea),
                child: _NumberField(
                  controller: _testArea,
                  suffix: strings.commonSquareMeters,
                  onChanged: _refresh,
                ),
              ),
            ),
            Expanded(
              child: LabeledField(
                label: FieldLabel(strings.calTestTime),
                child: DayStepper(
                  value: _hoseMinutes,
                  label: '$_hoseMinutes ${strings.commonMinutes}',
                  min: 1,
                  max: 30,
                  decreaseLabel: strings.commonLess,
                  increaseLabel: strings.commonMore,
                  onChanged: (minutes) => setState(() => _hoseMinutes = minutes),
                ),
              ),
            ),
          ],
        ),
        Gap.large,
        _CupRow(cups: _cups, onChanged: _refresh),
        Gap.large,
        if (flow == null || cupResult == null)
          Text(strings.calAreaMissing, style: context.textTheme.bodySmall)
        else
          _ResultCard(
            value: strings.calFlow(formatDecimal(flow)),
            lines: [
              strings.calHoseCupsFlow(
                formatDecimal(cupResult.averageMm),
                cupResult.minutes,
                formatDecimal(flow),
              ),
              strings.calHoseResult(
                wateringTargetMm,
                formatDecimal(wateringTargetMm / flow),
                area,
                durationText(context, (wateringTargetMm * area / flow).round()),
              ),
            ],
            note: cupResult.isEven
                ? strings.calEven(formatDecimal(cupResult.spreadMm))
                : strings.calUneven(formatDecimal(cupResult.spreadMm)),
          ),
      ] else
        ..._bucketSteps(context, flow, area),
    ];
  }

  List<Widget> _bucketSteps(BuildContext context, double? flow, int area) {
    final strings = context.strings;

    return [
      _StepsCard(
        steps: [
          (strings.calBucketStep1Title, strings.calBucketStep1),
          (strings.calBucketStep2Title, strings.calBucketStep2),
        ],
      ),
      Gap.large,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.medium,
        children: [
          Expanded(
            child: LabeledField(
              label: FieldLabel(strings.calBucket),
              child: DayStepper(
                value: _bucketLitres,
                label: strings.calBucketLitres(_bucketLitres),
                min: 5,
                max: 20,
                decreaseLabel: strings.commonLess,
                increaseLabel: strings.commonMore,
                onChanged: (litres) => setState(() => _bucketLitres = litres),
              ),
            ),
          ),
          Expanded(
            child: LabeledField(
              label: FieldLabel(strings.calSeconds),
              child: _NumberField(
                controller: _seconds,
                suffix: 's',
                hint: strings.calSecondsHint,
                onChanged: _refresh,
              ),
            ),
          ),
        ],
      ),
      Gap.large,
      if (flow == null)
        Text(strings.calSecondsMissing, style: context.textTheme.bodySmall)
      else
        _ResultCard(
          value: strings.calFlow(formatDecimal(flow)),
          lines: [
            strings.calHoseResult(
              wateringTargetMm,
              formatDecimal(wateringTargetMm / flow),
              area,
              durationText(context, (wateringTargetMm * area / flow).round()),
            ),
          ],
        ),
    ];
  }

  Widget _canInfo(BuildContext context) {
    final strings = context.strings;
    final area = _profile.areaSqm;

    return _ResultCard(
      value: strings.calCanTitle,
      lines: [
        strings.calCanText(
          wateringTargetMm,
          formatDecimal(wateringTargetMm),
          formatDecimal(wateringTargetMm / wateringCanLitres),
          wateringCanLitres,
          area,
          wateringTargetMm * area,
        ),
      ],
    );
  }

  void _refresh(String _) => setState(() {});
}

class ManualMethodChoice extends StatelessWidget {
  const ManualMethodChoice({required this.selected, required this.onSelected, super.key});

  final ManualWateringMethod? selected;
  final ValueChanged<ManualWateringMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return SegmentedChoice<ManualWateringMethod>(
      values: ManualWateringMethod.values,
      selected: selected,
      labelOf: (method) => switch (method) {
        ManualWateringMethod.hoseSprinkler => strings.manualSprinkler,
        ManualWateringMethod.hose => strings.manualHose,
        ManualWateringMethod.wateringCan => strings.manualCan,
      },
      onSelected: onSelected,
    );
  }
}

class _CupRow extends StatelessWidget {
  const _CupRow({required this.cups, required this.onChanged});

  final List<TextEditingController> cups;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Insets.small,
    children: [
      for (final (i, cup) in cups.indexed)
        Expanded(
          child: Column(
            spacing: 6,
            children: [
              Text(context.strings.calCup(i + 1), style: context.textTheme.bodySmall),
              _NumberField(controller: cup, suffix: 'mm', onChanged: onChanged),
            ],
          ),
        ),
    ],
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.suffix,
    required this.onChanged,
    this.hint,
  });

  final TextEditingController controller;
  final String suffix;
  final String? hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    textAlign: TextAlign.center,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      LengthLimitingTextInputFormatter(5),
    ],
    decoration: InputDecoration(
      hintText: hint,
      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    ),
    onChanged: onChanged,
  );
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps});

  final List<(String, String)> steps;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(Insets.large),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        spacing: 14,
        children: [
          for (final (i, (title, text)) in steps.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.medium,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: palette.trackColor, shape: BoxShape.circle),
                  child: Text('${i + 1}', style: context.textTheme.titleSmall),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: context.textTheme.titleMedium),
                      Text(text, style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.value, required this.lines, this.note});

  final String value;
  final List<String> lines;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.heroColor,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.small,
        children: [
          Text(
            strings.calResult.toUpperCase(),
            style: AppTheme.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ).copyWith(color: palette.springColor, letterSpacing: 0.7),
          ),
          Text(value, style: AppTheme.display(fontSize: 28).copyWith(color: Colors.white)),
          for (final line in lines)
            Text(
              line,
              style: AppTheme.body(fontSize: 14).copyWith(color: palette.onHeroColor, height: 1.45),
            ),
          if (note != null)
            Text(
              note!,
              style: AppTheme.body(
                fontSize: 13,
              ).copyWith(color: palette.heroMutedColor, height: 1.45),
            ),
        ],
      ),
    );
  }
}
