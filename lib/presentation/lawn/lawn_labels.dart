import 'package:flutter/widgets.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';

String grassMixLabel(BuildContext context, GrassMix mix) {
  final strings = context.strings;
  return switch (mix) {
    GrassMix.universal => strings.soilMixUniversal,
    GrassMix.ornamental => strings.soilMixOrnamental,
    GrassMix.shade => strings.soilMixShade,
    GrassMix.drought => strings.soilMixDrought,
    GrassMix.sport => strings.soilMixSport,
    GrassMix.unknown => strings.commonDontKnow,
  };
}

String grassMixShortLabel(BuildContext context, GrassMix mix) =>
    grassMixLabel(context, mix).split(' / ').first;

String soilLabel(BuildContext context, SoilType soil) {
  final strings = context.strings;
  return switch (soil) {
    SoilType.sandy => strings.soilTypeSandy,
    SoilType.medium => strings.soilTypeMedium,
    SoilType.clay => strings.soilTypeClay,
    SoilType.unknown => strings.commonDontKnow,
  };
}
