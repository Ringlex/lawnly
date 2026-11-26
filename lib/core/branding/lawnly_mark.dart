import 'package:flutter/material.dart';
import 'package:lawnly/core/theme/app_theme.dart';

class LawnlyMark extends StatelessWidget {
  const LawnlyMark({
    this.size = 40,
    this.background,
    this.outlined = false,
    this.growth = 1,
    super.key,
  });

  final double size;

  final Color? background;

  final bool outlined;

  final double growth;

  static const murawa = Color(0xFF1E5631);
  static const splashGreen = Color(0xFF174A28);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MarkPainter(background: background ?? murawa, outlined: outlined, growth: growth),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.background, required this.outlined, required this.growth});

  final Color background;
  final bool outlined;
  final double growth;

  static const _grid = 128.0;
  static const _outline = Color(0xFF2E6B40);
  static const _bladeLeft = Color(0xFF6FB34F);
  static const _bladeMiddle = Color(0xFF9FD27A);
  static const _bladeRight = Color(0xFFC6E8A6);
  static const _baseline = 104.0;
  static const _stagger = 0.24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, _grid, _grid), const Radius.circular(30)),
      Paint()..color = background,
    );

    if (outlined) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(1, 1, 126, 126), const Radius.circular(29)),
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final middle = Path()
      ..moveTo(64, 104)
      ..cubicTo(62, 80, 58, 58, 46, 36)
      ..cubicTo(60, 52, 68, 72, 70, 104)
      ..close();
    final left = Path()
      ..moveTo(58, 104)
      ..cubicTo(54, 86, 44, 72, 30, 64)
      ..cubicTo(46, 68, 58, 80, 64, 104)
      ..close();
    final right = Path()
      ..moveTo(70, 104)
      ..cubicTo(74, 80, 84, 60, 100, 46)
      ..cubicTo(90, 64, 82, 84, 78, 104)
      ..close();

    _drawBlade(canvas, left, _bladeLeft, 0);
    _drawBlade(canvas, middle, _bladeMiddle, 1);
    _drawBlade(canvas, right, _bladeRight, 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 102, 80, 6), const Radius.circular(3)),
      Paint()..color = _bladeRight,
    );
  }

  void _drawBlade(Canvas canvas, Path blade, Color color, int index) {
    final progress = ((growth - index * _stagger * 0.5) / (1 - _stagger)).clamp(0.0, 1.0);
    if (progress == 0) return;
    canvas
      ..save()
      ..translate(0, _baseline)
      ..scale(1, progress)
      ..translate(0, -_baseline)
      ..drawPath(blade, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.outlined != outlined ||
      oldDelegate.growth != growth;
}

const lawnlyMarkHeroTag = 'lawnly-mark';

class LawnlyWordmark extends StatelessWidget {
  const LawnlyWordmark({this.fontSize = 56, this.color, super.key});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'lawnly',
      style: AppTheme.display(fontSize: fontSize).copyWith(
        color: color ?? context.palette.primaryColor,
        letterSpacing: -0.03 * fontSize,
        height: 1,
      ),
    );
  }
}
