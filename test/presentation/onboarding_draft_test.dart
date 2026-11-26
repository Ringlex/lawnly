import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/presentation/onboarding/onboarding_state.dart';

void main() {
  final minimal = OnboardingDraft(
    name: 'Ogród',
    location: const LawnLocation(latitude: 52, longitude: 21),
    areaSqm: 250,
    establishedOn: DateTime(2024, 4, 1),
  );

  test('po podstawach plan da się utworzyć bez gleby, mieszanki i nawożenia', () {
    expect(minimal.isStepComplete(0), isTrue);
    expect(minimal.isStepComplete(1), isTrue);
    expect(minimal.isStepComplete(2), isTrue);
    expect(minimal.isStepComplete(3), isTrue);
    expect(minimal.isStepComplete(4), isTrue);
  });

  test('brakująca mieszanka i gleba trafiają do profilu jako nieznane', () {
    final profile = minimal.toProfile();

    expect(profile.grassMix, GrassMix.unknown);
    expect(profile.soil, SoilType.unknown);
    expect(profile.lastFertilizedOn, isNull);
  });

  test('krok z błędnym pH nie jest kompletny', () {
    expect(minimal.copyWith(soilPhInvalid: true).isStepComplete(2), isFalse);
  });

  test('krok podstaw wymaga powierzchni i daty założenia', () {
    expect(const OnboardingDraft().isStepComplete(1), isFalse);
  });
}
