import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/app_logger/app_logger.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/l10n/current_l10n.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/data/backup/backup_codec.dart';
import 'package:lawnly/data/backup/backup_file_gateway.dart';
import 'package:lawnly/domain/backup/backup_service.dart';

Future<void> exportBackup(BuildContext context) async {
  final service = getIt<BackupService>();
  final messenger = ScaffoldMessenger.of(context);
  final strings = context.strings;

  try {
    final bytes = await _withProgress(context, service.export);
    final saved = await getIt<BackupFileGateway>().save(fileName: service.fileName(), bytes: bytes);
    if (saved) _show(messenger, strings.backupExported);
  } catch (error, stackTrace) {
    logWarning('exportBackup', error, stackTrace);
    _show(messenger, _failureText(error, fallback: strings.backupExportFailed));
  }
}

Future<void> importBackup(BuildContext context, {required bool replacesData}) async {
  final service = getIt<BackupService>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final router = GoRouter.of(context);
  final strings = context.strings;

  try {
    final bytes = await getIt<BackupFileGateway>().pick();
    if (bytes == null || !context.mounted) return;

    final data = await _withProgress(context, () => service.open(bytes));
    if (!context.mounted) return;

    final confirmed = await _confirmImport(context, service.summaryOf(data), replacesData);
    if (!confirmed || !navigator.mounted) return;

    await _withProgress(navigator.context, () => service.restore(data));
    router.go(Routes.splash);
    _show(messenger, currentL10n().backupImported);
  } catch (error, stackTrace) {
    logWarning('importBackup', error, stackTrace);
    _show(messenger, _failureText(error, fallback: strings.backupImportFailed));
  }
}

Future<T> _withProgress<T>(BuildContext context, Future<T> Function() action) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
  );
  unawaited(navigator.push(route));
  try {
    return await action();
  } finally {
    if (route.isActive) navigator.removeRoute(route);
  }
}

Future<bool> _confirmImport(BuildContext context, BackupSummary summary, bool replacesData) async {
  final strings = context.strings;
  final details = strings.backupSummary(
    DateFormat.yMMMd().format(summary.createdAt),
    summary.lawns,
    summary.photos,
  );
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(strings.backupImportTitle),
      content: Text(replacesData ? '$details\n\n${strings.backupReplaceWarning}' : details),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(strings.backupCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(strings.backupRestore),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

String _failureText(Object error, {required String fallback}) {
  final strings = currentL10n();
  if (error is! BackupException) return fallback;
  return switch (error.failure) {
    BackupFailure.invalidFile => strings.backupInvalidFile,
    BackupFailure.newerVersion => strings.backupNewerVersion,
    BackupFailure.nothingToExport => strings.backupNothingToExport,
    BackupFailure.storage => strings.backupImportFailed,
  };
}

void _show(ScaffoldMessengerState messenger, String text) =>
    messenger.showSnackBar(SnackBar(content: Text(text)));
