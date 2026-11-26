import 'package:flutter/material.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';

enum HomeTab { today, calendar, journal, assistant, lawn }

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({required this.selected, required this.onSelected, super.key});

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.cardColor,
        border: Border(top: BorderSide(color: palette.outlineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.xSmall, vertical: Insets.small),
          child: Row(
            children: [
              for (final (tab, icon, activeIcon, label) in [
                (HomeTab.today, Icons.home_outlined, Icons.home, strings.navToday),
                (
                  HomeTab.calendar,
                  Icons.calendar_month_outlined,
                  Icons.calendar_month,
                  strings.navCalendar,
                ),
                (
                  HomeTab.journal,
                  Icons.description_outlined,
                  Icons.description,
                  strings.navJournal,
                ),
                (
                  HomeTab.assistant,
                  Icons.chat_bubble_outline,
                  Icons.chat_bubble,
                  strings.navAssistant,
                ),
                (HomeTab.lawn, Icons.grass, Icons.grass, strings.navLawn),
              ])
                Expanded(
                  child: _NavItem(
                    icon: icon,
                    activeIcon: activeIcon,
                    label: label,
                    selected: tab == selected,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.primaryColor : palette.mutedTextColor;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.xSmall),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Insets.xSmall,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.short,
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey(selected),
                  size: 24,
                  color: color,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ).copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
