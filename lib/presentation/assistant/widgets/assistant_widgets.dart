import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<XFile?> pickAssistantPhoto(BuildContext context) async {
  final strings = context.strings;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(strings.journalCamera),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(strings.journalGallery),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 80);
}

Future<bool> ensureAssistantConsent(BuildContext context) async {
  const key = 'assistant.privacyAccepted.v2';
  final preferences = await SharedPreferences.getInstance();
  if (preferences.getBool(key) ?? false) return true;
  if (!context.mounted) return false;

  final strings = context.strings;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.assistantPrivacyTitle),
      content: Text(strings.assistantPrivacy),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.sheetClose),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(strings.assistantPrivacyAccept),
        ),
      ],
    ),
  );
  if (accepted ?? false) await preferences.setBool(key, true);
  return accepted ?? false;
}

String assistantErrorText(BuildContext context, AssistantFailure failure) =>
    context.strings.assistantError(failure.name);

class QuotaLabel extends StatelessWidget {
  const QuotaLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(Icons.auto_awesome, size: 14, color: palette.primaryColor),
        Flexible(child: Text(text, style: context.textTheme.bodySmall)),
      ],
    );
  }
}

class AskBar extends StatefulWidget {
  const AskBar({required this.hint, required this.onSend, this.enabled = true, super.key});

  final String hint;
  final bool enabled;
  final void Function(String text, XFile? photo) onSend;

  @override
  State<AskBar> createState() => _AskBarState();
}

class _AskBarState extends State<AskBar> {
  final _controller = TextEditingController();
  XFile? _photo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text, _photo);
    _controller.clear();
    setState(() => _photo = null);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final square = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Insets.small,
      children: [
        if (_photo case final photo?)
          InputChip(
            avatar: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(photo.path), width: 24, height: 24, fit: BoxFit.cover),
            ),
            label: Text(strings.diagnosePhotos),
            onDeleted: () => setState(() => _photo = null),
          ),
        Row(
          spacing: Insets.small,
          children: [
            IconButton(
              onPressed: widget.enabled
                  ? () async {
                      final photo = await pickAssistantPhoto(context);
                      if (photo != null) setState(() => _photo = photo);
                    }
                  : null,
              tooltip: strings.assistantAddPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              style: IconButton.styleFrom(
                fixedSize: const Size.square(48),
                backgroundColor: palette.cardColor,
                foregroundColor: palette.primaryColor,
                side: BorderSide(color: palette.outlineColor),
                shape: square,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton.filled(
              onPressed: widget.enabled ? _send : null,
              tooltip: strings.assistantSend,
              icon: const Icon(Icons.arrow_forward),
              style: IconButton.styleFrom(
                fixedSize: const Size.square(48),
                backgroundColor: palette.primaryColor,
                foregroundColor: palette.onPrimaryColor,
                shape: square,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SuggestedActionTile extends StatelessWidget {
  const SuggestedActionTile({required this.action, this.tinted = false, super.key});

  final SuggestedAction action;

  final bool tinted;

  Future<void> _add(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;
    final today = CarePlanner.dateOnly(DateTime.now());
    final proposed = action.earliestDate;

    final date = proposed != null && !proposed.isBefore(today)
        ? proposed
        : await showDatePicker(
            context: context,
            initialDate: today.add(const Duration(days: 7)),
            firstDate: today,
            lastDate: DateTime(today.year + 1, today.month, today.day),
          );
    if (date == null) return;

    final saved = await getIt<AssistantService>().addToCalendar(action, date);
    messenger.showSnackBar(
      SnackBar(
        content: Text(saved ? strings.assistantAddedToCalendar : strings.onboardingSaveError),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: tinted ? palette.tintColor : palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        border: tinted ? null : Border.all(color: palette.outlineColor),
      ),
      child: Row(
        spacing: Insets.medium,
        children: [
          Icon(action.kind.icon, size: 20, color: action.kind.colorIn(palette)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(action.title, style: context.textTheme.titleMedium),
                if (action.when.isNotEmpty) Text(action.when, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _add(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: Insets.medium),
              textStyle: AppTheme.body(fontSize: 13, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.strings.assistantToCalendar),
          ),
        ],
      ),
    );
  }
}

class ReportButton extends StatelessWidget {
  const ReportButton({required this.content, required this.kind, super.key});

  final String content;

  final String kind;

  Future<void> _report(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;
    final result = await showDialog<(ReportReason, String)>(
      context: context,
      builder: (_) => const _ReportDialog(),
    );
    if (result == null) return;

    final sent = await getIt<AssistantService>()
        .report(reason: result.$1, note: result.$2, content: content, kind: kind)
        .run();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          sent.match((failure) => strings.assistantError(failure.name), (_) => strings.reportSent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => _report(context),
    icon: const Icon(Icons.flag_outlined, size: 18),
    label: Text(context.strings.assistantReport),
  );
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  var _reason = ReportReason.wrong;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return AlertDialog(
      title: Text(strings.reportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (reason) => setState(() => _reason = reason ?? _reason),
              child: Column(
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(strings.reportReason(reason.name)),
                    ),
                ],
              ),
            ),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(hintText: strings.reportNote),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.sheetClose)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((_reason, _note.text)),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(strings.reportSend),
        ),
      ],
    );
  }
}

class AiNote extends StatelessWidget {
  const AiNote({super.key});

  @override
  Widget build(BuildContext context) =>
      Text(context.strings.assistantAiNote, style: context.textTheme.bodySmall);
}
