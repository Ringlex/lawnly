import 'package:lawnly/core/l10n/current_l10n.dart';

class LocalizedText {
  const LocalizedText({required this.pl, required this.en});

  const LocalizedText.same(String value) : pl = value, en = value;

  final String pl;
  final String en;

  String get text => of(english: isEnglish);

  String of({required bool english}) => english ? en : pl;
}
