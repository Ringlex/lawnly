import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:lawnly/core/fpdarts.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';

typedef WithQuota<T> = ({T value, AssistantQuota? quota});

class AssistantClient {
  const AssistantClient({required String baseUrl, required http.Client client})
    : _baseUrl = baseUrl,
      _client = client;

  final String _baseUrl;
  final http.Client _client;

  TaskEither<AssistantFailure, WithQuota<Diagnosis>> diagnose({
    required String installId,
    required Map<String, dynamic> context,
    required String problem,
    String? description,
    String? since,
    List<XFile> photos = const [],
  }) => _post(
    path: '/v1/diagnose',
    installId: installId,
    photos: photos,
    body: {
      ...context,
      'problem': problem,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      'since': ?since,
    },
  ).map((result) => (value: Diagnosis.fromJson(result.value), quota: result.quota));

  TaskEither<AssistantFailure, WithQuota<AssistantAnswer>> ask({
    required String installId,
    required Map<String, dynamic> context,
    required String question,
    List<({bool fromUser, String text})> history = const [],
    List<XFile> photos = const [],
  }) => _post(
    path: '/v1/ask',
    installId: installId,
    photos: photos,
    body: {
      ...context,
      'question': question,
      'history': [
        for (final turn in history)
          {'role': turn.fromUser ? 'user' : 'assistant', 'text': turn.text},
      ],
    },
  ).map((result) => (value: AssistantAnswer.fromJson(result.value), quota: result.quota));

  TaskEither<AssistantFailure, AssistantQuota> quota({required String installId}) =>
      _post(path: '/v1/quota', installId: installId, body: const {}).map(
        (result) => AssistantQuota(
          remaining: (result.value['remaining'] as num).toInt(),
          limit: (result.value['limit'] as num).toInt(),
        ),
      );

  TaskEither<AssistantFailure, Unit> report({
    required String installId,
    required ReportReason reason,
    required String content,
    required String kind,
    String? note,
  }) => _post(
    path: '/v1/report',
    installId: installId,
    body: {
      'reason': reason.name,
      'kind': kind,
      'content': content,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    },
  ).map((_) => unit);

  TaskEither<AssistantFailure, WithQuota<Map<String, dynamic>>> _post({
    required String path,
    required String installId,
    required Map<String, dynamic> body,
    List<XFile> photos = const [],
  }) => tryCatchE(
    () async {
      final payload = <String, dynamic>{...body, 'installId': installId};
      if (photos.isNotEmpty) {
        payload['images'] = [
          for (final photo in photos)
            {
              'base64': base64Encode(await photo.readAsBytes()),
              'mediaType': _mediaTypeOf(photo.path),
            },
        ];
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl$path'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(payload),
      );
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        logWarning('Assistant $path: ${response.statusCode} ${decoded['error']}');
        return left(AssistantFailure.fromCode(decoded['error'] as String?));
      }

      final remaining = int.tryParse(response.headers['x-quota-remaining'] ?? '');
      final limit = int.tryParse(response.headers['x-quota-limit'] ?? '');
      return right((
        value: decoded,
        quota: remaining != null && limit != null
            ? AssistantQuota(remaining: remaining, limit: limit)
            : null,
      ));
    },
    (error, _) =>
        error is SocketException || error is HttpException || error is http.ClientException
        ? AssistantFailure.offline
        : AssistantFailure.unknown,
  );

  static String _mediaTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
