import 'package:flutter/widgets.dart';

abstract class AppMotion {
  const AppMotion._();

  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const long = Duration(milliseconds: 500);

  static const duration = Duration(milliseconds: 350);
  static const curve = Cubic(0.25, 0.1, 0.25, 1);
  static const emphasized = Cubic(0.2, 0.8, 0.2, 1);

  static const sheet = AnimationStyle(
    duration: medium,
    reverseDuration: Duration(milliseconds: 250),
    curve: emphasized,
  );

  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);
}

abstract class AppConfig {
  const AppConfig._();

  static const assistantUrl = String.fromEnvironment(
    'ASSISTANT_URL',
    defaultValue: 'https://lawnly-assistant.pitstop-garage.workers.dev',
  );

  static const _privacyPolicyUrl = 'https://lawnly-assistant.pitstop-garage.workers.dev/privacy';

  static Uri privacyPolicy({required bool english}) =>
      Uri.parse(english ? '$_privacyPolicyUrl/en' : _privacyPolicyUrl);
}
