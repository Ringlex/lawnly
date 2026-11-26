import 'package:fpdart/fpdart.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/local/single_value_store.dart';

class LawnRepository {
  const LawnRepository({required SingleValueStore<LawnProfile> store}) : _store = store;

  final SingleValueStore<LawnProfile> _store;

  Task<Option<LawnProfile>> profile() =>
      _store.read().match((_) => const None(), (profile) => Some(profile));

  TaskEither<SingleValueStoreFailure, Unit> save(LawnProfile profile) =>
      _store.write(value: profile);
}
