import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/weather/day_forecast.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:lawnly/presentation/common/state_type.dart';

part 'weather_cubit.freezed.dart';

@freezed
abstract class WeatherState with _$WeatherState {
  const factory WeatherState({
    @Default(StateType.loading) StateType type,
    LawnProfile? profile,
    WeatherReport? report,
  }) = _WeatherState;
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({required CareService careService})
    : _careService = careService,
      super(const WeatherState());

  final CareService _careService;

  Future<void> load() async {
    final result = await _careService.weather().run();
    if (isClosed) return;
    emit(
      result.match(
        (_) => state.copyWith(type: StateType.error),
        (data) => WeatherState(type: StateType.loaded, profile: data.$1, report: data.$2),
      ),
    );
  }
}
