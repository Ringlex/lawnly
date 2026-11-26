import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/data/assistant/assistant_models.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';

class AssistantCubit extends Cubit<AssistantQuota?> {
  AssistantCubit({required AssistantService service}) : _service = service, super(null);

  final AssistantService _service;

  bool get isAvailable => _service.isAvailable;

  Future<void> loadQuota() async {
    if (!_service.isAvailable) return;
    final result = await _service.quota().run();
    if (!isClosed) result.match((_) {}, emit);
  }

  void update(AssistantQuota? quota) {
    if (quota != null) emit(quota);
  }

  void exhausted() {
    final quota = state;
    if (quota != null) emit(AssistantQuota(remaining: 0, limit: quota.limit));
  }
}
