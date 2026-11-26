import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/assistant/widgets/assistant_widgets.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/motion_widgets.dart';

class ChatTurn {
  const ChatTurn.user(this.text, {this.photo}) : fromUser = true, answer = null, offline = false;

  const ChatTurn.assistant(this.text, {this.answer, this.offline = false})
    : fromUser = false,
      photo = null;

  final bool fromUser;
  final String text;
  final XFile? photo;

  final AssistantAnswer? answer;
  final bool offline;
}

class ChatPage extends StatefulWidget {
  const ChatPage({this.question, this.photo, this.initialTurns = const [], super.key});

  final String? question;
  final XFile? photo;
  final List<ChatTurn> initialTurns;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final List<ChatTurn> _turns = [...widget.initialTurns];
  final _scroll = ScrollController();
  var _sending = false;
  AssistantFailure? _error;

  @override
  void initState() {
    super.initState();
    if (widget.question case final question?) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(question, widget.photo));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String question, XFile? photo) async {
    final quota = context.read<AssistantCubit>();
    if (_sending || !await ensureAssistantConsent(context) || !mounted) return;

    final history = [
      for (final turn in _turns)
        if (!turn.offline) (fromUser: turn.fromUser, text: turn.text),
    ];
    setState(() {
      _turns.add(ChatTurn.user(question, photo: photo));
      _sending = true;
      _error = null;
    });
    _scrollToEnd();

    final result = await getIt<AssistantService>()
        .ask(question: question, history: history, photos: [?photo])
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
          _turns.add(ChatTurn.assistant(response.value.answer, answer: response.value));
        },
      );
    });
    _scrollToEnd();
  }

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final quota = context.watch<AssistantCubit>().state;
    final available = context.read<AssistantCubit>().isAvailable;

    return Scaffold(
      appBar: AppBar(title: Text(strings.assistantTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.large),
              children: [
                for (final (index, turn) in _turns.indexed) ...[
                  SlideIn(
                    key: ValueKey(index),
                    child: turn.fromUser
                        ? _UserBubble(turn: turn)
                        : _AssistantBubble(turn: turn, onFollowUp: (q) => _send(q, null)),
                  ),
                  Gap.medium,
                ],
                if (_sending)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(Insets.medium),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Insets.small,
                        children: [
                          const GrassLoader(size: 28),
                          Text(strings.diagnoseWorking, style: context.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                if (_error case final error?)
                  Text(
                    assistantErrorText(context, error),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.palette.errorColor,
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Insets.small,
                children: [
                  if (!available)
                    Text(strings.assistantUnavailable, style: context.textTheme.bodySmall)
                  else ...[
                    if (quota != null)
                      QuotaLabel(text: strings.assistantQuota(quota.remaining, quota.limit)),
                    AskBar(
                      hint: strings.assistantFollowHint,
                      enabled: !_sending && (quota?.remaining ?? 1) > 0,
                      onSend: _send,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: Insets.xSmall,
          children: [
            if (turn.photo case final photo?)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(photo.path), width: 160, height: 120, fit: BoxFit.cover),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: palette.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                turn.text,
                style: AppTheme.body(
                  fontSize: 15,
                ).copyWith(color: palette.onPrimaryColor, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.turn, required this.onFollowUp});

  final ChatTurn turn;
  final ValueChanged<String> onFollowUp;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final answer = turn.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Insets.small,
      children: [
        Container(
          padding: const EdgeInsets.all(Insets.large),
          decoration: BoxDecoration(
            color: palette.cardColor,
            border: Border.all(color: palette.outlineColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.medium,
            children: [
              Text(turn.text, style: context.textTheme.bodyLarge),
              for (final action in answer?.actions ?? const <SuggestedAction>[])
                SuggestedActionTile(action: action, tinted: true),
              if (turn.offline)
                Text(strings.assistantOfflineAnswer, style: context.textTheme.bodySmall)
              else if (answer != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ReportButton(content: answer.reportText, kind: 'ask'),
                ),
            ],
          ),
        ),
        if (answer != null && answer.followUpQuestions.isNotEmpty)
          Wrap(
            spacing: Insets.small,
            runSpacing: Insets.small,
            children: [
              for (final question in answer.followUpQuestions)
                ActionChip(label: Text(question), onPressed: () => onFollowUp(question)),
            ],
          ),
        if (!turn.offline) const AiNote(),
      ],
    );
  }
}
