import 'package:flutter/widgets.dart';
import 'package:lawnly/core/l10n/generated/app_localizations.dart';

export 'package:lawnly/core/l10n/generated/app_localizations.dart';

extension AppStrings on BuildContext {
  L10n get strings => L10n.of(this);
}
