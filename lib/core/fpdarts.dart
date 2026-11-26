import 'package:fpdart/fpdart.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';

extension $TaskEither<L, R> on TaskEither<L, R> {
  TaskEither<C, R> mapLeft<C>(C Function(L a) f) {
    return TaskEither<C, R>(() async => (await run()).match((l) => left(f(l)), right));
  }
}

TaskEither<L, R> tryCatchE<L, R>(
  Future<Either<L, R>> Function() run,
  L Function(Object error, StackTrace stackTrace) onError, {
  Future<void> Function()? onErrorRun,
}) {
  return TaskEither<L, R>(() async {
    try {
      return await run();
    } catch (error, stackTrace) {
      logSevere('tryCatchE', error, stackTrace);
      await onErrorRun?.call();
      return Left<L, R>(onError(error, stackTrace));
    }
  });
}
