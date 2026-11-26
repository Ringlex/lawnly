import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/assistant/assistant_cubit.dart';
import 'package:lawnly/presentation/calendar/calendar_cubit.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/home/home_cubit.dart';

Widget guideScope(BuildContext context, Widget page) => MultiBlocProvider(
  providers: [
    BlocProvider.value(value: context.read<HomeCubit>()),
    BlocProvider.value(value: context.read<CalendarCubit>()),
    BlocProvider.value(value: context.read<AssistantCubit>()),
  ],
  child: page,
);

void pushGuidePage(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => guideScope(context, page)));

String monthName(int month) => DateFormat('LLLL').format(DateTime(2000, month));

String planMonth(DateTime date, DateTime today) =>
    date.year == today.year ? monthName(date.month) : DateFormat('LLLL yyyy').format(date);

String formatCm(double cm) => NumberFormat('#0.#').format(cm);

class GuideTileGrid extends StatelessWidget {
  const GuideTileGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Insets.small,
    children: [
      for (var i = 0; i < children.length; i += 2)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Insets.small,
            children: [
              Expanded(child: children[i]),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
    ],
  );
}

class GuideScaffold extends StatelessWidget {
  const GuideScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(subtitle, style: context.textTheme.bodySmall),
        ],
      ),
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
        children: children,
      ),
    ),
  );
}

class GuideLabel extends StatelessWidget {
  const GuideLabel(this.text, {this.top = Insets.xLarge, super.key});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: Insets.medium),
    child: Text(
      text.toUpperCase(),
      style: AppTheme.body(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ).copyWith(color: context.palette.mutedTextColor, letterSpacing: 0.5),
    ),
  );
}

class GuideCard extends StatelessWidget {
  const GuideCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: Insets.large, vertical: 14),
    this.highlighted = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: highlighted
            ? Border.all(color: palette.primaryColor, width: 2)
            : Border.all(color: palette.outlineColor),
      ),
      child: child,
    );
  }
}

class GuideChecklist extends StatelessWidget {
  const GuideChecklist(this.lines, {super.key});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GuideCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.medium,
        children: [
          for (final line in lines)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.medium,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check, size: 18, color: palette.primaryColor),
                ),
                Expanded(
                  child: Text(
                    line,
                    style: AppTheme.body(
                      fontSize: 14,
                    ).copyWith(color: palette.textColor, height: 1.45),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class GuideWarning extends StatelessWidget {
  const GuideWarning({required this.text, this.title, super.key});

  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = AppTheme.body(fontSize: 13).copyWith(color: palette.onWarningColor, height: 1.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: Insets.medium),
      decoration: BoxDecoration(
        color: palette.warningTintColor,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        border: Border.all(color: palette.warningOutlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.xSmall,
        children: [
          if (title != null) Text(title!, style: style.copyWith(fontWeight: FontWeight.w700)),
          Text(text, style: style),
        ],
      ),
    );
  }
}

class GuideBadge extends StatelessWidget {
  const GuideBadge(this.text, {this.solid = true, super.key});

  final String text;

  final bool solid;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.small, vertical: 2),
      decoration: BoxDecoration(
        color: solid ? palette.primaryColor : palette.windowColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTheme.body(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ).copyWith(color: solid ? palette.onPrimaryColor : palette.primaryColor),
      ),
    );
  }
}

class GuideTableRow {
  const GuideTableRow(this.cells, {this.highlighted = false, this.badge});

  final List<String> cells;
  final bool highlighted;

  final String? badge;
}

class GuideTable extends StatelessWidget {
  const GuideTable({required this.header, required this.rows, this.columnFlex, super.key});

  final List<String> header;
  final List<GuideTableRow> rows;

  final List<int>? columnFlex;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final flex = columnFlex ?? List.filled(header.length, 1);

    Widget row({required List<Widget> cells, Color? color, bool divider = true}) => Container(
      decoration: BoxDecoration(
        color: color,
        border: divider ? Border(top: BorderSide(color: palette.trackColor)) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Insets.medium, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.small,
        children: [for (var i = 0; i < cells.length; i++) Expanded(flex: flex[i], child: cells[i])],
      ),
    );

    final headerStyle = AppTheme.body(
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ).copyWith(color: palette.secondaryTextColor);
    final firstStyle = AppTheme.body(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ).copyWith(color: palette.headingColor);
    final cellStyle = AppTheme.body(fontSize: 13).copyWith(color: palette.secondaryTextColor);

    return GuideCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            color: palette.tintColor,
            divider: false,
            cells: [for (final title in header) Text(title, style: headerStyle)],
          ),
          for (final data in rows)
            row(
              color: data.highlighted ? palette.selectedTintColor : null,
              cells: [
                for (var i = 0; i < data.cells.length; i++)
                  if (i == 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Insets.xSmall,
                      children: [
                        Text(data.cells[i], style: firstStyle),
                        if (data.badge case final badge?) GuideBadge(badge),
                      ],
                    )
                  else
                    Text(data.cells[i], style: cellStyle),
              ],
            ),
        ],
      ),
    );
  }
}
