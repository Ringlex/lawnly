import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    logInfo('${_baseType(bloc)}: Created ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    logInfo('${_baseType(bloc)}: Closed ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logSevere('${_baseType(bloc)}: Error in ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    logInfo('${_baseType(bloc)}: Transition in ${bloc.runtimeType}: $transition');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    logInfo('${_baseType(bloc)}: Event in ${bloc.runtimeType}: $event');
  }

  String _baseType(BlocBase<dynamic> blocBase) => blocBase is Bloc ? 'bloc' : 'cubit';
}
