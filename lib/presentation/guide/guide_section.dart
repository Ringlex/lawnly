import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/guide/guide_care_page.dart';
import 'package:lawnly/presentation/guide/guide_fertilizing_page.dart';
import 'package:lawnly/presentation/guide/guide_mixes_page.dart';
import 'package:lawnly/presentation/guide/guide_mowing_page.dart';
import 'package:lawnly/presentation/guide/guide_topic_style.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';

class GuideSection extends StatelessWidget {
  const GuideSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final month = DateTime.now().month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Insets.small,
      children: [
        _MonthCard(month: month, onTap: () => pushGuidePage(context, const GuideCarePage())),
        GuideTileGrid(
          children: [
            _Tile(
              icon: Icons.handyman_outlined,
              title: strings.guideCare,
              subtitle: strings.guideCareSub,
              onTap: () => pushGuidePage(context, const GuideCarePage()),
            ),
            _Tile(
              icon: Icons.grain,
              title: strings.guideFertilizing,
              subtitle: strings.guideFertilizingSub,
              onTap: () => pushGuidePage(context, const GuideFertilizingPage()),
            ),
            _Tile(
              icon: Icons.content_cut,
              title: strings.guideMowing,
              subtitle: strings.guideMowingSub,
              onTap: () => pushGuidePage(context, const GuideMowingPage()),
            ),
            _Tile(
              icon: Icons.grass,
              title: strings.guideMixes,
              subtitle: strings.guideMixesSub,
              onTap: () => pushGuidePage(context, const GuideMixesPage()),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.onTap});

  final int month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    final key = monthKey(month);

    return Material(
      color: palette.heroColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Insets.large),
          child: Row(
            spacing: 14,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.xSmall,
                  children: [
                    Text(
                      strings.guideNowInSeason(monthName(month)).toUpperCase(),
                      style: AppTheme.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: palette.springColor, letterSpacing: 0.5),
                    ),
                    Text(
                      strings.guideMonthTitle(key),
                      style: AppTheme.display(
                        fontSize: 19,
                      ).copyWith(color: Colors.white, height: 1.2),
                    ),
                    Text(
                      strings.guideMonthText(key),
                      style: AppTheme.body(fontSize: 13).copyWith(color: palette.onHeroColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.springColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(AppTheme.buttonRadius);

    return Material(
      color: palette.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: palette.outlineColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.tintColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: palette.primaryColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: AppTheme.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: palette.headingColor),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(
                      fontSize: 12,
                    ).copyWith(color: palette.mutedTextColor, height: 1.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
