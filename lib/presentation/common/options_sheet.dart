import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';

Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> values,
  required String Function(T value) labelOf,
  T? selected,
}) => showModalBottomSheet<T>(
  context: context,
  sheetAnimationStyle: AppMotion.sheet,
  builder: (context) {
    final palette = context.palette;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, Insets.small),
            child: Text(title, style: context.textTheme.titleLarge),
          ),
          for (final value in values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(labelOf(value), style: context.textTheme.bodyLarge),
              trailing: value == selected ? Icon(Icons.check, color: palette.primaryColor) : null,
              onTap: () => Navigator.of(context).pop(value),
            ),
          Gap.medium,
        ],
      ),
    );
  },
);
