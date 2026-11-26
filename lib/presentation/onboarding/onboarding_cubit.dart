import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/location/location_repository.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required Future<bool> Function(LawnProfile profile) saveProfile,
    required LocationRepository locationRepository,
  }) : _saveProfile = saveProfile,
       _locationRepository = locationRepository,
       super(const OnboardingState());

  static const stepCount = 5;

  final Future<bool> Function(LawnProfile profile) _saveProfile;
  final LocationRepository _locationRepository;

  bool get isBusy => state.status != OnboardingStatus.editing;

  void update(OnboardingDraft Function(OnboardingDraft draft) change) {
    emit(state.copyWith(draft: change(state.draft), error: null));
  }

  void updateCityQuery(String query) {
    update((draft) => draft.copyWith(cityQuery: query, location: null));
  }

  Future<void> useCurrentLocation() async {
    if (isBusy) return;
    emit(state.copyWith(status: OnboardingStatus.locating, error: null));

    final result = await _locationRepository.current().run();
    emit(
      result.match(
        (failure) => state.copyWith(status: OnboardingStatus.editing, error: _errorOf(failure)),
        (location) => state.copyWith(
          status: OnboardingStatus.editing,
          draft: state.draft.copyWith(location: location, cityQuery: ''),
        ),
      ),
    );
  }

  Future<void> next() async {
    if (isBusy || !state.draft.isStepComplete(state.step)) return;

    if (state.step == 0 && state.draft.location == null) {
      final found = await _searchCity();
      if (!found) return;
    }

    if (state.step < stepCount - 1) {
      emit(state.copyWith(step: state.step + 1, error: null));
    } else {
      await _finish();
    }
  }

  Future<void> finishWithDefaults() async {
    if (isBusy || state.step < 1 || !state.draft.isStepComplete(state.step)) return;
    await _finish();
  }

  bool back() {
    if (isBusy || state.step == 0) return false;
    emit(state.copyWith(step: state.step - 1, error: null));
    return true;
  }

  Future<bool> _searchCity() async {
    emit(state.copyWith(status: OnboardingStatus.locating, error: null));

    final result = await _locationRepository.search(state.draft.cityQuery).run();
    return result.match(
      (failure) {
        emit(state.copyWith(status: OnboardingStatus.editing, error: _errorOf(failure)));
        return false;
      },
      (location) {
        emit(
          state.copyWith(
            status: OnboardingStatus.editing,
            draft: state.draft.copyWith(location: location),
          ),
        );
        return true;
      },
    );
  }

  Future<void> _finish() async {
    emit(state.copyWith(status: OnboardingStatus.saving, error: null));

    final saved = await _saveProfile(state.draft.toProfile());
    emit(
      saved
          ? state.copyWith(status: OnboardingStatus.done)
          : state.copyWith(status: OnboardingStatus.editing, error: OnboardingError.save),
    );
  }

  OnboardingError _errorOf(LocationFailure failure) => switch (failure) {
    LocationFailure.serviceDisabled => OnboardingError.locationServiceDisabled,
    LocationFailure.permissionDenied => OnboardingError.locationPermissionDenied,
    LocationFailure.notFound => OnboardingError.cityNotFound,
    LocationFailure.network => OnboardingError.network,
  };
}
