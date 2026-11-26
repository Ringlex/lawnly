import 'package:flutter/material.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';

class CustomProgramPage extends StatefulWidget {
  const CustomProgramPage({this.program, super.key});

  final CustomProgram? program;

  @override
  State<CustomProgramPage> createState() => _CustomProgramPageState();
}

class _CustomProgramPageState extends State<CustomProgramPage> {
  static const _maxDose = 200;
  static const _maxInterval = 365;

  late final _name = TextEditingController(text: widget.program?.name);
  late final _product = TextEditingController(text: widget.program?.product);
  late final _dose = TextEditingController(text: widget.program?.doseGramsPerSqm.toString());
  late final _interval = TextEditingController(text: widget.program?.intervalDays.toString());
  late DateTime _start = widget.program?.startDate ?? CarePlanner.dateOnly(DateTime.now());
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _product.dispose();
    _dose.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final today = CarePlanner.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _start.isBefore(today) ? today : _start,
      firstDate: today,
      lastDate: DateTime(today.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _save() async {
    final dose = int.tryParse(_dose.text.trim());
    final interval = int.tryParse(_interval.text.trim());
    final product = _product.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final strings = context.strings;

    final valid =
        product.isNotEmpty &&
        dose != null &&
        dose > 0 &&
        dose <= _maxDose &&
        interval != null &&
        interval > 0 &&
        interval <= _maxInterval;
    if (!valid) {
      messenger.showSnackBar(SnackBar(content: Text(strings.customInvalid)));
      return;
    }

    setState(() => _saving = true);
    final name = _name.text.trim();
    final saved = await getIt<CareService>().saveCustomProgram(
      CustomProgram(
        id: widget.program?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.isEmpty ? product : name,
        product: product,
        doseGramsPerSqm: dose,
        intervalDays: interval,
        startDate: _start,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      navigator.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(strings.onboardingSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.customFormTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: strings.customName),
          ),
          Gap.medium,
          TextField(
            controller: _product,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: strings.customProduct),
          ),
          Gap.medium,
          TextField(
            controller: _dose,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: strings.customDose),
          ),
          Gap.medium,
          TextField(
            controller: _interval,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: strings.customInterval),
          ),
          Gap.medium,
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(strings.customStart),
            subtitle: Text(context.longDate(_start)),
            trailing: const Icon(Icons.event_outlined),
            onTap: _pickStart,
          ),
          Gap.large,
          FilledButton(onPressed: _saving ? null : _save, child: Text(strings.customSave)),
        ],
      ),
    );
  }
}
