import 'package:flutter/material.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/l10n/current_l10n.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicy(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final failureText = context.strings.privacyPolicyFailed;
  final url = AppConfig.privacyPolicy(english: isEnglish);

  try {
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
  } catch (error, stackTrace) {
    logWarning('openPrivacyPolicy', error, stackTrace);
  }
  messenger.showSnackBar(SnackBar(content: Text(failureText)));
}
