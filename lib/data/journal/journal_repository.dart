import 'package:fpdart/fpdart.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/local/single_value_store.dart';

class JournalRepository {
  static const storageKey = 'journal';

  const JournalRepository({required SingleValueStore<Journal> store}) : _store = store;

  final SingleValueStore<Journal> _store;

  Task<Journal> journal() => _store.read().match((_) => const Journal(), (journal) => journal);

  TaskEither<SingleValueStoreFailure, Unit> save(Journal journal) => _store.write(value: journal);
}
