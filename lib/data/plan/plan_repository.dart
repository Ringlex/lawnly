import 'package:fpdart/fpdart.dart';
import 'package:lawnly/data/local/single_value_store.dart';
import 'package:lawnly/data/plan/care_plan.dart';

class PlanRepository {
  static const storageKey = 'care_plan';

  const PlanRepository({required SingleValueStore<CarePlan> store}) : _store = store;

  final SingleValueStore<CarePlan> _store;

  Task<CarePlan> plan() => _store.read().match((_) => const CarePlan(), (plan) => plan);

  TaskEither<SingleValueStoreFailure, Unit> save(CarePlan plan) => _store.write(value: plan);
}
