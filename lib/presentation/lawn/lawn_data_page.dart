import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/location/location_repository.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/options_sheet.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';
import 'package:lawnly/presentation/lawn/lawn_labels.dart';
import 'package:lawnly/presentation/onboarding/steps/month_year_picker.dart';

class LawnDataPage extends StatefulWidget {
  const LawnDataPage({super.key});

  @override
  State<LawnDataPage> createState() => _LawnDataPageState();
}

class _LawnDataPageState extends State<LawnDataPage> {
  late final LawnCubit _cubit = context.read<LawnCubit>();
  late LawnProfile _draft = _cubit.state.profile!;

  late final _name = TextEditingController(text: _draft.name);
  late final _city = TextEditingController(text: _draft.location.label ?? '');
  late final _area = TextEditingController(text: '${_draft.areaSqm}');
  late final _ph = TextEditingController(
    text: _draft.soilPh == null ? '' : formatDecimal(_draft.soilPh!),
  );

  var _busy = false;

  @override
  void dispose() {
    for (final controller in [_name, _city, _area, _ph]) {
      controller.dispose();
    }
    super.dispose();
  }

  double? get _phValue {
    final text = _ph.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    return value != null && value >= 3 && value <= 9 ? value : double.nan;
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      (int.tryParse(_area.text) ?? 0) > 0 &&
      !(_phValue?.isNaN ?? false);

  String _locationError(LocationFailure failure) {
    final strings = context.strings;
    return switch (failure) {
      LocationFailure.serviceDisabled => strings.locationServiceDisabled,
      LocationFailure.permissionDenied => strings.locationPermissionDenied,
      LocationFailure.notFound => strings.locationNotFound,
      LocationFailure.network => strings.locationNetwork,
    };
  }

  Future<void> _useGps() async {
    setState(() => _busy = true);
    final result = await getIt<LocationRepository>().current().run();
    if (!mounted) return;
    setState(() => _busy = false);
    result.match((failure) => _snack(_locationError(failure)), (location) {
      _city.clear();
      setState(() => _draft = _draft.copyWith(location: location));
    });
  }

  Future<void> _save() async {
    if (!_valid || _busy) return;
    setState(() => _busy = true);

    var location = _draft.location;
    final city = _city.text.trim();
    if (city.isNotEmpty && city != location.label) {
      final found = await getIt<LocationRepository>().search(city).run();
      if (!mounted) return;
      final failure = found.getLeft().toNullable();
      if (failure != null) {
        setState(() => _busy = false);
        _snack(_locationError(failure));
        return;
      }
      location = found.toNullable()!;
    }

    final saved = await _cubit.save(
      _draft.copyWith(
        name: _name.text.trim(),
        location: location,
        areaSqm: int.parse(_area.text),
        soilPh: _phValue,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(saved ? context.strings.lawnSaved : context.strings.onboardingSaveError);
    if (saved) Navigator.of(context).pop();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final measurement = context.select((LawnCubit c) => c.state.lastPhMeasurement);

    return Scaffold(
      appBar: AppBar(title: Text(strings.lawnData)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          LabeledField(
            label: FieldLabel(strings.locationNameLabel),
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.locationLabel),
            child: Row(
              spacing: Insets.small,
              children: [
                Expanded(
                  child: TextField(
                    controller: _city,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: _draft.location.label == null
                          ? strings.locationCurrent
                          : strings.locationCityHint,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _busy ? null : _useGps,
                  tooltip: strings.locationUseMine,
                  icon: const Icon(Icons.my_location),
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(AppTheme.fieldHeight),
                    backgroundColor: palette.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap.large,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.medium,
            children: [
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.basicsAreaLabel),
                  child: TextField(
                    controller: _area,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(suffixText: strings.commonSquareMeters),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.lawnEstablished),
                  child: PickerField(
                    text: DateFormat('LLLL yyyy').format(_draft.establishedOn),
                    hint: strings.basicsEstablishedHint,
                    onTap: () async {
                      final picked = await showMonthYearPicker(
                        context,
                        initial: _draft.establishedOn,
                      );
                      if (picked != null) {
                        setState(() => _draft = _draft.copyWith(establishedOn: picked));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.basicsMethodLabel),
            child: SegmentedChoice<EstablishmentMethod>(
              values: EstablishmentMethod.values,
              selected: _draft.establishment,
              labelOf: (method) => switch (method) {
                EstablishmentMethod.seeded => strings.basicsMethodSeeded,
                EstablishmentMethod.sod => strings.basicsMethodSod,
              },
              onSelected: (method) =>
                  setState(() => _draft = _draft.copyWith(establishment: method)),
            ),
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.basicsSunLabel),
            child: SegmentedChoice<SunExposure>(
              values: SunExposure.values,
              selected: _draft.sun,
              labelOf: (sun) => switch (sun) {
                SunExposure.sun => strings.basicsSunFull,
                SunExposure.partialShade => strings.basicsSunPartial,
                SunExposure.shade => strings.basicsSunShade,
              },
              onSelected: (sun) => setState(() => _draft = _draft.copyWith(sun: sun)),
            ),
          ),
          Gap.large,
          Row(
            spacing: Insets.medium,
            children: [
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.lawnMix),
                  child: _OptionField(
                    text: grassMixShortLabel(context, _draft.grassMix),
                    onTap: () async {
                      final mix = await showOptionsSheet(
                        context,
                        title: strings.soilMixLabel,
                        values: GrassMix.values,
                        labelOf: (mix) => grassMixLabel(context, mix),
                        selected: _draft.grassMix,
                      );
                      if (mix != null) setState(() => _draft = _draft.copyWith(grassMix: mix));
                    },
                  ),
                ),
              ),
              Expanded(
                child: LabeledField(
                  label: FieldLabel(strings.lawnSoil),
                  child: _OptionField(
                    text: soilLabel(context, _draft.soil),
                    onTap: () async {
                      final soil = await showOptionsSheet(
                        context,
                        title: strings.soilTypeLabel,
                        values: SoilType.values,
                        labelOf: (soil) => soilLabel(context, soil),
                        selected: _draft.soil,
                      );
                      if (soil != null) setState(() => _draft = _draft.copyWith(soil: soil));
                    },
                  ),
                ),
              ),
            ],
          ),
          Gap.large,
          LabeledField(
            label: FieldLabel(strings.soilPhLabel, suffix: strings.commonOptional),
            helper: measurement == null
                ? null
                : strings.lawnPhFromJournal(DateFormat('d MMMM').format(measurement.date)),
            child: TextField(
              controller: _ph,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: strings.soilPhHint,
                errorText: (_phValue?.isNaN ?? false) ? strings.soilPhError : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Gap.xLarge,
          FilledButton(onPressed: _valid && !_busy ? _save : null, child: Text(strings.lawnSave)),
        ],
      ),
    );
  }
}

class _OptionField extends StatelessWidget {
  const _OptionField({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: AppTheme.fieldHeight,
          padding: const EdgeInsets.only(left: Insets.large, right: Insets.small),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(fontSize: 16).copyWith(color: palette.textColor),
                ),
              ),
              Icon(Icons.expand_more, color: palette.mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }
}
