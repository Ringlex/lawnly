import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/common/text_utils.dart';
import 'package:lawnly/presentation/journal/journal_cubit.dart';
import 'package:lawnly/presentation/journal/widgets/journal_widgets.dart';

Future<void> showJournalEditor(
  BuildContext context, {
  required JournalCubit cubit,
  JournalEntry? entry,
}) => showModalBottomSheet<void>(
  context: context,
  sheetAnimationStyle: AppMotion.sheet,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: _initialHeight,
    minChildSize: _minHeight,
    snap: true,
    snapSizes: const [_initialHeight],
    builder: (_, scrollController) =>
        _JournalEditor(cubit: cubit, entry: entry, scrollController: scrollController),
  ),
);

const _initialHeight = 0.8;

const _minHeight = 0.4;

class _JournalEditor extends StatefulWidget {
  const _JournalEditor({required this.cubit, required this.scrollController, this.entry});

  final JournalCubit cubit;
  final JournalEntry? entry;

  final ScrollController scrollController;

  @override
  State<_JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<_JournalEditor> {
  static const _minPh = 3.0;
  static const _maxPh = 9.0;

  late final JournalEntry? _initial = widget.entry;
  late JournalKind _kind = _initial?.kind ?? JournalKind.observation;
  late CareKind _careKind = _initial?.careKind ?? CareKind.mowing;
  late DateTime _date = _initial?.date ?? DateTime.now();
  late final Set<ObservationTag> _tags = {...?_initial?.tags};
  late final List<String> _photos = [...?_initial?.photos];
  late DoseUnit _doseUnit = _initial?.doseUnit ?? DoseUnit.gramsPerSqm;

  late final _note = TextEditingController(text: _initial?.note ?? '');
  late final _ph = TextEditingController(text: _decimal(_initial?.ph));
  late final _product = TextEditingController(text: _initial?.product ?? '');
  late final _npk = TextEditingController(text: _initial?.npk ?? '');
  late final _dose = TextEditingController(text: _decimal(_initial?.dose));
  late final _height = TextEditingController(text: _decimal(_initial?.mowingHeightCm));
  late final _minutes = TextEditingController(text: _initial?.wateringMinutes?.toString() ?? '');
  late final _litres = TextEditingController(text: _decimal(_initial?.wateringLitres));

  var _saving = false;

  bool get _isNew => _initial == null;

  ManualWateringMethod? get _wateringMethod {
    final profile = widget.cubit.state.profile;
    return profile?.watering == WateringMode.manual ? profile?.manualWateringMethod : null;
  }

  static String _decimal(double? value) => value == null ? '' : formatDecimal(value);

  static double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  double? get _phValue {
    final value = _parse(_ph);
    return value != null && value >= _minPh && value <= _maxPh ? value : null;
  }

  bool get _canSave => switch (_kind) {
    JournalKind.observation => _tags.isNotEmpty || _note.text.trim().isNotEmpty,
    JournalKind.photo => _photos.isNotEmpty,
    JournalKind.measurement => _phValue != null,
    JournalKind.care => true,
  };

  @override
  void dispose() {
    for (final controller in [_note, _ph, _product, _npk, _dose, _height, _minutes, _litres]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    final photo = await ImagePicker().pickImage(source: source, maxWidth: 2048, imageQuality: 85);
    if (photo == null) return;
    final name = await widget.cubit.savePhoto(photo);
    if (mounted) setState(() => _photos.add(name));
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (picked != null) {
      setState(
        () => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute),
      );
    }
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = context.strings.onboardingSaveError;
    String? text(TextEditingController controller) =>
        controller.text.trim().isEmpty ? null : controller.text.trim();
    final isCare = _kind == JournalKind.care;
    final careKind = isCare ? _careKind : null;

    final entry = (_initial ?? JournalEntry(id: '', kind: _kind, date: _date)).copyWith(
      id: _initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      kind: _kind,
      date: _date,
      careKind: careKind,
      note: text(_note),
      photos: _photos,
      tags: _kind == JournalKind.observation ? _tags : {},
      ph: _kind == JournalKind.measurement ? _phValue : null,
      product: careKind == CareKind.fertilizing ? text(_product) : null,
      npk: careKind == CareKind.fertilizing ? text(_npk) : null,
      dose: careKind == CareKind.fertilizing ? _parse(_dose) : null,
      doseUnit: _doseUnit,
      mowingHeightCm: careKind == CareKind.mowing ? _parse(_height) : null,
      wateringMinutes: careKind == CareKind.watering ? int.tryParse(_minutes.text.trim()) : null,
      wateringLitres: careKind == CareKind.watering ? _parse(_litres) : null,
    );

    final saved = await widget.cubit.save(entry);
    if (saved) {
      navigator.pop();
    } else {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.large,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isNew ? strings.journalNewTitle : strings.journalEditTitle,
                      style: context.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: strings.sheetClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (_isNew)
                _KindPicker(selected: _kind, onSelected: (k) => setState(() => _kind = k)),
              ..._fields(context),
              LabeledField(
                label: FieldLabel(strings.journalPhotos),
                child: _PhotoRow(
                  photos: _photos,
                  cubit: widget.cubit,
                  onAdd: _addPhoto,
                  onRemove: (name) => setState(() => _photos.remove(name)),
                ),
              ),
              LabeledField(
                label: FieldLabel(strings.journalDate),
                child: PickerField(
                  text: capitalized(context.longDate(_date)),
                  hint: strings.feedLastHint,
                  onTap: _pickDate,
                ),
              ),
              FilledButton(
                onPressed: _canSave && !_saving ? _save : null,
                child: Text(strings.journalSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    final strings = context.strings;
    final note = LabeledField(
      label: FieldLabel(
        _kind == JournalKind.care ? strings.journalNote : strings.journalDescription,
      ),
      child: TextField(
        controller: _note,
        minLines: 2,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: strings.journalDescriptionHint),
        onChanged: (_) => setState(() {}),
      ),
    );

    switch (_kind) {
      case JournalKind.observation:
        return [
          LabeledField(
            label: FieldLabel(strings.journalWhatSeen),
            child: Wrap(
              spacing: Insets.small,
              runSpacing: Insets.small,
              children: [
                for (final tag in ObservationTag.values)
                  _Chip(
                    label: strings.observationTag(tag.name),
                    selected: _tags.contains(tag),
                    onTap: () =>
                        setState(() => _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag)),
                  ),
              ],
            ),
          ),
          note,
        ];
      case JournalKind.photo:
        return [note];
      case JournalKind.measurement:
        return [
          LabeledField(
            label: FieldLabel(strings.journalPhValue),
            child: TextField(
              controller: _ph,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: strings.journalPhHint,
                errorText: _ph.text.isNotEmpty && _phValue == null ? strings.soilPhError : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          note,
        ];
      case JournalKind.care:
        return [
          if (_isNew)
            Wrap(
              spacing: Insets.small,
              runSpacing: Insets.small,
              children: [
                for (final kind in CareKind.values)
                  _Chip(
                    label: kind.label(context),
                    selected: kind == _careKind,
                    onTap: () => setState(() => _careKind = kind),
                  ),
              ],
            ),
          ..._careDetails(context),
          note,
        ];
    }
  }

  List<Widget> _careDetails(BuildContext context) {
    final strings = context.strings;
    TextField number(TextEditingController controller, String hint, {String? suffix}) => TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(hintText: hint, suffixText: suffix),
    );

    return switch (_careKind) {
      CareKind.fertilizing => [
        LabeledField(
          label: FieldLabel(strings.journalProduct, suffix: strings.commonOptional),
          child: TextField(
            controller: _product,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: strings.journalProductHint),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.medium,
          children: [
            Expanded(
              child: LabeledField(
                label: FieldLabel(strings.journalNpk),
                child: TextField(
                  controller: _npk,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(hintText: strings.journalNpkHint),
                ),
              ),
            ),
            Expanded(
              child: LabeledField(
                label: FieldLabel(strings.journalDoseLabel),
                child: number(_dose, strings.journalDoseHint),
              ),
            ),
          ],
        ),
        SegmentedChoice<DoseUnit>(
          values: DoseUnit.values,
          selected: _doseUnit,
          fontSize: 14,
          labelOf: (unit) => switch (unit) {
            DoseUnit.gramsPerSqm => 'g/m²',
            DoseUnit.mlPerSqm => 'ml/m²',
          },
          onSelected: (unit) => setState(() => _doseUnit = unit),
        ),
      ],
      CareKind.mowing => [
        LabeledField(
          label: FieldLabel(strings.journalHeightLabel, suffix: strings.commonOptional),
          child: number(_height, '4', suffix: 'cm'),
        ),
      ],
      CareKind.watering => [
        if (_wateringMethod == ManualWateringMethod.wateringCan)
          LabeledField(
            label: FieldLabel(strings.journalLitresLabel, suffix: strings.commonOptional),
            child: number(_litres, '30', suffix: 'l'),
          )
        else
          LabeledField(
            label: FieldLabel(
              _wateringMethod == ManualWateringMethod.hoseSprinkler
                  ? strings.journalMinutesSpot
                  : strings.journalMinutesLabel,
              suffix: strings.commonOptional,
            ),
            child: number(_minutes, '20', suffix: strings.commonMinutes),
          ),
      ],
      _ => [],
    };
  }
}

class _KindPicker extends StatelessWidget {
  const _KindPicker({required this.selected, required this.onSelected});

  final JournalKind selected;
  final ValueChanged<JournalKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const kinds = [
      (JournalKind.observation, Icons.description_outlined),
      (JournalKind.photo, Icons.photo_camera_outlined),
      (JournalKind.measurement, Icons.science_outlined),
      (JournalKind.care, Icons.event_available_outlined),
    ];

    return Row(
      spacing: Insets.small,
      children: [
        for (final (kind, icon) in kinds)
          Expanded(
            child: ChoiceTile(
              selected: kind == selected,
              height: 76,
              padding: EdgeInsets.zero,
              onTap: () => onSelected(kind),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Icon(icon, size: 22, color: palette.primaryColor),
                  Text(
                    context.strings.journalKind(kind.name),
                    textAlign: TextAlign.center,
                    style: AppTheme.body(
                      fontSize: 12,
                      fontWeight: kind == selected ? FontWeight.w600 : FontWeight.w500,
                    ).copyWith(color: palette.headingColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ChoiceTile(
      selected: selected,
      alignment: null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: onTap,
      child: Text(
        label,
        style: AppTheme.body(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ).copyWith(color: selected ? palette.headingColor : palette.secondaryTextColor),
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.photos,
    required this.cubit,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final JournalCubit cubit;
  final ValueChanged<ImageSource> onAdd;
  final ValueChanged<String> onRemove;

  static const _size = 88.0;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    Widget addButton(IconData icon, String label, ImageSource source) => SizedBox.square(
      dimension: _size,
      child: OutlinedButton(
        onPressed: () => onAdd(source),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          side: BorderSide(color: palette.outlineColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Insets.xSmall,
          children: [
            Icon(icon, color: palette.primaryColor),
            Text(label, style: AppTheme.body(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

    return Wrap(
      spacing: Insets.small,
      runSpacing: Insets.small,
      children: [
        for (final name in photos)
          Stack(
            children: [
              PhotoThumb(file: cubit.photoFile(name), height: _size, width: _size),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton.filled(
                  onPressed: () => onRemove(name),
                  tooltip: strings.journalRemovePhoto,
                  iconSize: 16,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(28),
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        addButton(Icons.photo_camera_outlined, strings.journalCamera, ImageSource.camera),
        addButton(Icons.photo_library_outlined, strings.journalGallery, ImageSource.gallery),
      ],
    );
  }
}
