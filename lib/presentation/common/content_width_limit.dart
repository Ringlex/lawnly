import 'package:flutter/material.dart';
import 'package:lawnly/core/theme/app_theme.dart';

class ContentWidthLimit extends StatelessWidget {
  const ContentWidthLimit({required this.child, super.key});

  static const maxWidth = 640.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
