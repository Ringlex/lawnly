import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';

class PopIn extends StatefulWidget {
  const PopIn({this.delay = Duration.zero, required this.child, super.key});

  final Duration delay;
  final Widget child;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppMotion.short);
  late final _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale, child: widget.child);
}

class CountUp extends StatelessWidget {
  const CountUp({required this.value, required this.builder, super.key});

  final int value;
  final Widget Function(BuildContext context, int value) builder;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return builder(context, value);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
      builder: (context, current, _) => builder(context, current.round()),
    );
  }
}

class DrawnCheck extends StatelessWidget {
  const DrawnCheck({required this.progress, required this.color, this.size = 22, super.key});

  final Animation<double> progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: AnimatedBuilder(
      animation: progress,
      builder: (_, _) => CustomPaint(painter: _CheckPainter(progress.value, color)),
    ),
  );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final path = Path()
      ..moveTo(5 * unit, 12.5 * unit)
      ..lineTo(9.5 * unit, 17 * unit)
      ..lineTo(19 * unit, 7.5 * unit);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class GrassLoader extends StatefulWidget {
  const GrassLoader({this.size = 48, super.key});

  final double size;

  @override
  State<GrassLoader> createState() => _GrassLoaderState();
}

class _GrassLoaderState extends State<GrassLoader> with SingleTickerProviderStateMixin {
  static const _blades = [Color(0xFF6FB34F), Color(0xFF1E5631), Color(0xFF9FD27A)];
  static const _maxTurns = 0.025;

  late final _controller = AnimationController(vsync: this, duration: AppMotion.long * 2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: SizedBox(
        width: widget.size,
        height: widget.size * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: widget.size * 0.06,
          children: [
            for (final (index, color) in _blades.indexed)
              RotationTransition(
                alignment: Alignment.bottomCenter,
                turns: Tween(begin: -_maxTurns, end: _maxTurns).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(index * 0.15, 0.7 + index * 0.15, curve: Curves.easeInOut),
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(widget.size)),
                  ),
                  child: SizedBox(
                    width: widget.size * 0.16,
                    height: widget.size * (index == 1 ? 0.9 : 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OpenCard<T> extends StatelessWidget {
  const OpenCard({
    required this.closedBuilder,
    required this.openBuilder,
    this.radius = BorderRadius.zero,
    this.color = Colors.transparent,
    this.onClosed,
    super.key,
  });

  final Widget Function(BuildContext context, VoidCallback open) closedBuilder;
  final WidgetBuilder openBuilder;
  final BorderRadius radius;
  final Color color;
  final ValueChanged<T?>? onClosed;

  static const _duration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final openColor = Theme.of(context).scaffoldBackgroundColor;
    final duration = AppMotion.reduced(context) ? Duration.zero : _duration;

    return OpenContainer<T>(
      transitionDuration: duration,
      closedElevation: 0,
      openElevation: 0,
      closedColor: color,
      middleColor: openColor,
      openColor: openColor,
      closedShape: RoundedRectangleBorder(borderRadius: radius),
      useRootNavigator: false,
      onClosed: onClosed,
      openBuilder: (context, _) => openBuilder(context),
      closedBuilder: closedBuilder,
    );
  }
}

class GrassRefresh extends StatefulWidget {
  const GrassRefresh({required this.onRefresh, required this.child, super.key});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<GrassRefresh> createState() => _GrassRefreshState();
}

class _GrassRefreshState extends State<GrassRefresh> {
  static const _visibleStatuses = {
    RefreshIndicatorStatus.drag,
    RefreshIndicatorStatus.armed,
    RefreshIndicatorStatus.snap,
    RefreshIndicatorStatus.refresh,
  };

  RefreshIndicatorStatus? _status;

  @override
  Widget build(BuildContext context) {
    final visible = _visibleStatuses.contains(_status);
    final palette = Theme.of(context).colorScheme;

    return Stack(
      children: [
        RefreshIndicator.noSpinner(
          onRefresh: widget.onRefresh,
          onStatusChange: (status) => setState(() => _status = status),
          child: widget.child,
        ),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: AnimatedScale(
                scale: visible ? 1 : 0.5,
                duration: AppMotion.short,
                curve: AppMotion.emphasized,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: AppMotion.short,
                  child: Material(
                    color: palette.surface,
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: const Padding(padding: EdgeInsets.all(12), child: GrassLoader(size: 32)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LeafHop extends StatefulWidget {
  const LeafHop({required this.from, required this.to, required this.onEnd, super.key});

  final Offset from;
  final Offset to;
  final VoidCallback onEnd;

  @override
  State<LeafHop> createState() => _LeafHopState();
}

class _LeafHopState extends State<LeafHop> with SingleTickerProviderStateMixin {
  static const _size = 24.0;
  static const _arcHeight = 22.0;
  static const _ringSize = 40.0;
  static const _duration = Duration(milliseconds: 450);

  late final _controller = AnimationController(vsync: this, duration: _duration)
    ..forward().whenComplete(widget.onEnd);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = AppMotion.emphasized.transform(_controller.value);
          final position = Offset.lerp(widget.from, widget.to, t)!;
          final lift = _arcHeight * (1 - (2 * t - 1) * (2 * t - 1));
          final ring = Curves.easeOut.transform(((_controller.value - 0.6) / 0.4).clamp(0.0, 1.0));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (ring > 0)
                Positioned(
                  left: widget.to.dx + _size / 2 - _ringSize * (0.5 + ring * 0.5) / 2,
                  top: widget.to.dy + _size / 2 - _ringSize * (0.5 + ring * 0.5) / 2,
                  child: SizedBox.square(
                    dimension: _ringSize * (0.5 + ring * 0.5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.5 * (1 - ring)),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: position.dx,
                top: position.dy - lift,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                  child: SizedBox.square(
                    dimension: _size,
                    child: Icon(Icons.grass, size: 14, color: scheme.onPrimary),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SlideIn extends StatefulWidget {
  const SlideIn({this.delay = Duration.zero, required this.child, super.key});

  final Duration delay;
  final Widget child;

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  static const _offset = Offset(0, 0.15);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final _curved = CurvedAnimation(parent: _controller, curve: AppMotion.emphasized);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curved,
    child: SlideTransition(
      position: Tween(begin: _offset, end: Offset.zero).animate(_curved),
      child: widget.child,
    ),
  );
}
