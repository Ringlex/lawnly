import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:lawnly/core/l10n/generated/app_localizations.dart';

bool get isEnglish => Intl.defaultLocale == 'en';

String get currentLanguageCode => isEnglish ? 'en' : 'pl';

L10n currentL10n() => lookupL10n(Locale(currentLanguageCode));
