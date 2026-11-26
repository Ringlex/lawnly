import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';

Future<DateTime?> showMonthYearPicker(BuildContext context, {DateTime? initial}) {
  final now = DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    builder: (_) => _MonthYearPicker(initial: initial ?? now, now: now),
  );
}

class _MonthYearPicker extends StatefulWidget {
  const _MonthYearPicker({required this.initial, required this.now});

  final DateTime initial;
  final DateTime now;

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  static const _firstYear = 1990;

  late int _year = widget.initial.year;

  bool _isFuture(int month) =>
      _year > widget.now.year || (_year == widget.now.year && month > widget.now.month);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final monthFormat = DateFormat('LLLL');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, Insets.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _year > _firstYear ? () => setState(() => _year--) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '$_year',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _year < widget.now.year ? () => setState(() => _year++) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Gap.medium,
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Insets.small,
              crossAxisSpacing: Insets.small,
              childAspectRatio: 2.4,
              children: [
                for (var month = 1; month <= 12; month++)
                  _MonthButton(
                    label: monthFormat.format(DateTime(_year, month)),
                    selected: widget.initial.year == _year && widget.initial.month == month,
                    onPressed: _isFuture(month)
                        ? null
                        : () => Navigator.of(context).pop(DateTime(_year, month)),
                    palette: palette,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final textStyle = AppTheme.body(fontSize: 14, fontWeight: FontWeight.w600);

    if (selected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: Size.zero, shape: shape, textStyle: textStyle),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        shape: shape,
        backgroundColor: palette.cardColor,
        textStyle: textStyle,
      ),
      child: Text(label),
    );
  }
}
