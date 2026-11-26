import 'package:lawnly/data/plan/care_plan.dart';

enum AssistantFailure {
  quotaExceeded,
  offline,
  busy,
  badImage,
  unknown;

  static AssistantFailure fromCode(String? code) => switch (code) {
    'quota_exceeded' => AssistantFailure.quotaExceeded,
    'image_too_large' ||
    'unsupported_media_type' ||
    'missing_image' ||
    'too_many_images' => AssistantFailure.badImage,
    'upstream_busy' => AssistantFailure.busy,
    _ => AssistantFailure.unknown,
  };
}

enum Likelihood { high, medium, low }

enum DiagnosisUrgency { actNow, soon, routine }

enum ReportReason { wrong, offensive, dangerous, other }

class SuggestedAction {
  const SuggestedAction({
    required this.kind,
    required this.title,
    required this.when,
    this.earliestDate,
  });

  factory SuggestedAction.fromJson(Map<String, dynamic> json) => SuggestedAction(
    kind: CareKind.values.asNameMap()[json['kind']] ?? CareKind.other,
    title: json['title'] as String? ?? '',
    when: json['when'] as String? ?? '',
    earliestDate: DateTime.tryParse(json['earliestDate'] as String? ?? ''),
  );

  final CareKind kind;
  final String title;
  final String when;
  final DateTime? earliestDate;
}

class DiagnosisCause {
  const DiagnosisCause({
    required this.name,
    required this.likelihood,
    required this.explanation,
    required this.checkFirst,
  });

  factory DiagnosisCause.fromJson(Map<String, dynamic> json) => DiagnosisCause(
    name: json['name'] as String? ?? '',
    likelihood: Likelihood.values.asNameMap()[json['likelihood']] ?? Likelihood.low,
    explanation: json['explanation'] as String? ?? '',
    checkFirst: json['checkFirst'] as String? ?? '',
  );

  final String name;
  final Likelihood likelihood;
  final String explanation;
  final String checkFirst;
}

class Diagnosis {
  const Diagnosis({
    required this.summary,
    required this.urgency,
    required this.causes,
    required this.actions,
    required this.followUpQuestions,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) => Diagnosis(
    summary: json['summary'] as String? ?? '',
    urgency: switch (json['urgency']) {
      'act_now' => DiagnosisUrgency.actNow,
      'soon' => DiagnosisUrgency.soon,
      _ => DiagnosisUrgency.routine,
    },
    causes: [
      for (final cause in json['causes'] as List<dynamic>? ?? [])
        DiagnosisCause.fromJson(cause as Map<String, dynamic>),
    ],
    actions: _actions(json),
    followUpQuestions: _strings(json['followUpQuestions']),
  );

  final String summary;
  final DiagnosisUrgency urgency;
  final List<DiagnosisCause> causes;
  final List<SuggestedAction> actions;
  final List<String> followUpQuestions;

  String get reportText => [
    summary,
    for (final cause in causes) '${cause.name}: ${cause.explanation} ${cause.checkFirst}',
    for (final action in actions) '${action.title}: ${action.when}',
  ].join('\n');
}

class AssistantAnswer {
  const AssistantAnswer({
    required this.answer,
    required this.actions,
    required this.followUpQuestions,
  });

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) => AssistantAnswer(
    answer: json['answer'] as String? ?? '',
    actions: _actions(json),
    followUpQuestions: _strings(json['followUpQuestions']),
  );

  final String answer;
  final List<SuggestedAction> actions;
  final List<String> followUpQuestions;

  String get reportText =>
      [answer, for (final action in actions) '${action.title}: ${action.when}'].join('\n');
}

class AssistantQuota {
  const AssistantQuota({required this.remaining, required this.limit});

  final int remaining;
  final int limit;
}

List<SuggestedAction> _actions(Map<String, dynamic> json) => [
  for (final action in json['actions'] as List<dynamic>? ?? [])
    SuggestedAction.fromJson(action as Map<String, dynamic>),
];

List<String> _strings(Object? value) => (value as List<dynamic>? ?? []).cast<String>();
