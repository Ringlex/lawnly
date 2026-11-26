import 'package:flutter/material.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {this.suffix, super.key});

  final String text;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = AppTheme.body(fontSize: 14, fontWeight: FontWeight.w600);

    return Text.rich(
      TextSpan(
        text: text,
        style: style.copyWith(color: palette.headingColor),
        children: [
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: style.copyWith(fontWeight: FontWeight.w400, color: palette.mutedTextColor),
            ),
        ],
      ),
    );
  }
}

class FieldHelper extends StatelessWidget {
  const FieldHelper(this.text, {this.textAlign, super.key});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: textAlign,
    style: context.textTheme.bodySmall?.copyWith(color: context.palette.mutedTextColor),
  );
}

class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child, this.helper, super.key});

  final Widget label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Insets.small,
    children: [label, child, if (helper != null) FieldHelper(helper!)],
  );
}

class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
    this.fontSize = 15,
    super.key,
  });

  final List<T> values;
  final String Function(T value) labelOf;
  final T? selected;
  final ValueChanged<T> onSelected;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(Insets.xSmall),
      decoration: BoxDecoration(
        color: palette.trackColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      ),
      child: Row(
        spacing: Insets.xSmall,
        children: [
          for (final value in values)
            Expanded(
              child: _Segment(
                label: labelOf(value),
                selected: value == selected,
                fontSize: fontSize,
                onTap: () => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(12);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? palette.primaryColor : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(
                  fontSize: fontSize,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ).copyWith(color: selected ? palette.onPrimaryColor : palette.secondaryTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.selected,
    required this.onTap,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 10),
    this.alignment = Alignment.center,
    this.selectedFill = true,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  final AlignmentGeometry? alignment;

  final bool selectedFill;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected && selectedFill ? palette.selectedTintColor : palette.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected
              ? BorderSide(color: palette.primaryColor, width: 2)
              : BorderSide(color: palette.outlineColor),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(height: height, padding: padding, alignment: alignment, child: child),
        ),
      ),
    );
  }
}

class DayStepper extends StatelessWidget {
  const DayStepper({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.min = 1,
    this.max = 60,
    super.key,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;
  final String decreaseLabel;
  final String increaseLabel;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(Insets.small),
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove,
            tooltip: decreaseLabel,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.display(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ).copyWith(color: palette.headingColor),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: increaseLabel,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(44),
        backgroundColor: palette.trackColor,
        foregroundColor: palette.headingColor,
        disabledBackgroundColor: palette.trackColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  const TipCard({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(Insets.large),
      decoration: BoxDecoration(
        color: palette.tintColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.medium,
        children: [
          Icon(icon, size: 22, color: palette.primaryColor),
          Expanded(
            child: Text(
              text,
              style: AppTheme.body(
                fontSize: 14,
              ).copyWith(color: palette.secondaryTextColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class PickerField extends StatelessWidget {
  const PickerField({required this.text, required this.hint, required this.onTap, super.key});

  final String? text;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.fieldRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: AppTheme.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: Insets.large),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text ?? hint,
                  style: AppTheme.body(
                    fontSize: 16,
                  ).copyWith(color: text == null ? palette.mutedTextColor : palette.textColor),
                ),
              ),
              Icon(Icons.calendar_today_outlined, size: 18, color: palette.mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }
}
