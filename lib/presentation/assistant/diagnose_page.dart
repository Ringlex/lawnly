import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/assistant/chat_page.dart';
import 'package:lawnly/presentation/assistant/widgets/assistant_widgets.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';
import 'package:lawnly/presentation/common/form_controls.dart';
import 'package:lawnly/presentation/lawn/lawn_labels.dart';

enum _Since { days, weeks, month, unknown }

class DiagnosePage extends StatefulWidget {
  const DiagnosePage({required this.problem, required this.profile, super.key});

  final LawnProblem problem;
  final LawnProfile profile;

  @override
  State<DiagnosePage> createState() => _DiagnosePageState();
}

class _DiagnosePageState extends State<DiagnosePage> {
  static const _revealStepMs = 60;

  static const _maxPhotos = 2;

  final _photos = <XFile>[];
  final _description = TextEditingController();
  _Since? _since;
  var _sending = false;
  AssistantFailure? _error;
  Diagnosis? _result;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  String get _problemLabel => context.strings.lawnProblem(widget.problem.name);

  Future<void> _diagnose() async {
    final quota = context.read<AssistantCubit>();
    final strings = context.strings;
    if (_sending || !await ensureAssistantConsent(context) || !mounted) return;
    setState(() {
      _sending = true;
      _error = null;
    });

    final result = await getIt<AssistantService>()
        .diagnose(
          problem: widget.problem,
          problemLabel: _problemLabel,
          description: _description.text,
          since: _since == null ? null : strings.diagnoseSinceOption(_since!.name),
          photos: _photos,
        )
        .run();
    if (!mounted) return;

    setState(() {
      _sending = false;
      result.match(
        (failure) {
          _error = failure;
          if (failure == AssistantFailure.quotaExceeded) quota.exhausted();
        },
        (response) {
          quota.update(response.quota);
          _result = response.value;
        },
      );
    });
  }

  Future<void> _saveToJournal(Diagnosis diagnosis) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.strings;
    final top = diagnosis.causes.firstOrNull;
    final saved = await getIt<AssistantService>().saveToJournal(
      problem: widget.problem,
      note: [if (top != null) top.name, diagnosis.summary].join(': '),
      photos: _photos,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(saved ? strings.assistantSavedJournal : strings.onboardingSaveError)),
    );
  }

  void _followUp(Diagnosis diagnosis, String question) {
    final cubit = context.read<AssistantCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ChatPage(
            question: question,
            initialTurns: [ChatTurn.user(_problemLabel), ChatTurn.assistant(diagnosis.summary)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_problemLabel),
            Text(
              result == null ? strings.diagnoseSubtitle : strings.resultTitle,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: result == null ? _form(context) : _resultView(context, result),
    );
  }

  Widget _form(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final quota = context.watch<AssistantCubit>().state;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
      children: [
        LabeledField(
          label: FieldLabel(strings.diagnosePhotos),
          helper: strings.diagnosePhotosHint,
          child: Row(
            spacing: Insets.small,
            children: [
              for (final photo in _photos)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(photo.path),
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton.filled(
                        onPressed: () => setState(() => _photos.remove(photo)),
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
              if (_photos.length < _maxPhotos)
                SizedBox.square(
                  dimension: 104,
                  child: OutlinedButton(
                    onPressed: () async {
                      final photo = await pickAssistantPhoto(context);
                      if (photo != null) setState(() => _photos.add(photo));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Insets.xSmall,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: palette.primaryColor),
                        Text(strings.assistantAddPhoto, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Gap.large,
        LabeledField(
          label: FieldLabel(strings.diagnoseDescribe),
          child: TextField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            maxLength: 3000,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: strings.diagnoseDescribeHint),
          ),
        ),
        Gap.large,
        LabeledField(
          label: FieldLabel(strings.diagnoseSince),
          child: Wrap(
            spacing: Insets.small,
            runSpacing: Insets.small,
            children: [
              for (final since in _Since.values)
                ChoiceChip(
                  label: Text(strings.diagnoseSinceOption(since.name)),
                  selected: _since == since,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _since = since),
                ),
            ],
          ),
        ),
        Gap.large,
        TipCard(
          icon: Icons.lightbulb_outline,
          text:
              '${strings.diagnoseContextTitle}: ${strings.diagnoseContext(widget.profile.areaSqm, grassMixShortLabel(context, widget.profile.grassMix).toLowerCase())}',
        ),
        Gap.xLarge,
        if (_error case final error?) ...[
          Text(
            assistantErrorText(context, error),
            style: context.textTheme.bodyMedium?.copyWith(color: palette.errorColor),
          ),
          Gap.medium,
        ],
        FilledButton.icon(
          onPressed: _sending || (quota?.remaining ?? 1) == 0 ? null : _diagnose,
          icon: _sending ? const GrassLoader(size: 22) : const Icon(Icons.auto_awesome),
          label: Text(_sending ? strings.diagnoseWorking : strings.diagnoseButton),
        ),
        if (quota != null) ...[
          Gap.small,
          Center(child: QuotaLabel(text: strings.assistantQuotaCost(quota.remaining))),
        ],
      ],
    );
  }

  Widget _resultView(BuildContext context, Diagnosis diagnosis) {
    final strings = context.strings;
    final palette = context.palette;
    final top = diagnosis.causes.firstOrNull;
    var revealed = 0;
    Widget reveal(Widget child) => SlideIn(
      delay: Duration(milliseconds: _revealStepMs * revealed++),
      child: child,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
      children: [
        reveal(
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.heroColor,
              borderRadius: BorderRadius.circular(AppTheme.heroRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.small,
              children: [
                Wrap(
                  spacing: Insets.small,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.springColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        strings.resultMost.toUpperCase(),
                        style: AppTheme.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ).copyWith(color: const Color(0xFF10301B)),
                      ),
                    ),
                    Text(
                      strings.resultUrgency(diagnosis.urgency.name),
                      style: AppTheme.body(fontSize: 13).copyWith(color: palette.heroMutedColor),
                    ),
                  ],
                ),
                if (top != null)
                  Text(
                    top.name,
                    style: AppTheme.display(fontSize: 24).copyWith(color: Colors.white),
                  ),
                Text(
                  diagnosis.summary,
                  style: AppTheme.body(
                    fontSize: 14,
                  ).copyWith(color: palette.onHeroColor, height: 1.45),
                ),
              ],
            ),
          ),
        ),
        Gap.medium,
        reveal(
          _Card(
            child: Column(
              spacing: Insets.small,
              children: [
                for (final cause in diagnosis.causes)
                  Row(
                    children: [
                      Expanded(child: Text(cause.name, style: context.textTheme.bodyLarge)),
                      _LikelihoodPill(cause.likelihood),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (top != null) ...[
          Gap.medium,
          reveal(
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Insets.xSmall,
                children: [
                  Text(strings.resultCheck, style: context.textTheme.titleMedium),
                  Text(top.checkFirst, style: context.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
        if (diagnosis.actions.isNotEmpty) ...[
          Gap.large,
          Text(strings.resultActions.toUpperCase(), style: context.textTheme.labelMedium),
          Gap.small,
          for (final action in diagnosis.actions) ...[
            reveal(SuggestedActionTile(action: action)),
            Gap.small,
          ],
        ],
        if (diagnosis.followUpQuestions.isNotEmpty) ...[
          Gap.medium,
          Wrap(
            spacing: Insets.small,
            runSpacing: Insets.small,
            children: [
              for (final question in diagnosis.followUpQuestions)
                ActionChip(label: Text(question), onPressed: () => _followUp(diagnosis, question)),
            ],
          ),
        ],
        Gap.large,
        Row(
          children: [
            ReportButton(content: diagnosis.reportText, kind: 'diagnosis'),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _saveToJournal(diagnosis),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(strings.assistantSaveJournal),
            ),
          ],
        ),
        const AiNote(),
      ],
    );
  }
}

class _LikelihoodPill extends StatelessWidget {
  const _LikelihoodPill(this.likelihood);

  final Likelihood likelihood;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (likelihood) {
      Likelihood.high => (palette.springColor, const Color(0xFF10301B)),
      Likelihood.medium => (palette.warningTintColor, palette.onWarningColor),
      Likelihood.low => (palette.trackColor, palette.secondaryTextColor),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        context.strings.resultLikelihood(likelihood.name),
        style: AppTheme.body(fontSize: 12, fontWeight: FontWeight.w700).copyWith(color: foreground),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}
