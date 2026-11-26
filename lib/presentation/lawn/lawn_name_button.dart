import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/lawn/lawn_switcher_sheet.dart';

class LawnNameButton extends StatelessWidget {
  const LawnNameButton({required this.name, required this.style, required this.color, super.key});

  final String name;
  final TextStyle? style;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.strings.lawnsOpen,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showLawnSwitcher(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Insets.xSmall,
          children: [
            Flexible(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
            ),
            Icon(Icons.expand_more, color: color),
          ],
        ),
      ),
    ),
  );
}
