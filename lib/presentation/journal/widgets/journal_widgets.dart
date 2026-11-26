import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/presentation/calendar/care_kind_style.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/common/text_utils.dart';

const journalNoteColor = Color(0xFF7A5AA8);

extension JournalEntryStyle on JournalEntry {
  Color colorIn(Palette palette) =>
      careKind?.colorIn(palette) ??
      (kind == JournalKind.measurement ? palette.rainColor : journalNoteColor);

  IconData get icon =>
      careKind?.icon ??
      switch (kind) {
        JournalKind.photo => Icons.photo_camera_outlined,
        JournalKind.measurement => Icons.science_outlined,
        _ => Icons.description_outlined,
      };

  String title(BuildContext context) =>
      careKind?.label(context) ?? context.strings.journalKind(kind.name);

  String subtitle(BuildContext context, LawnProfile profile) {
    final strings = context.strings;
    final note = this.note?.trim();
    final parts = <String>[];

    switch (kind) {
      case JournalKind.care:
        switch (careKind) {
          case CareKind.fertilizing:
            if (product case final product? when product.isNotEmpty) parts.add(product);
            if (dose case final dose?) {
              parts
                ..add(strings.journalDose(formatDecimal(dose), doseUnit.name))
                ..add(
                  strings.journalTotal(
                    formatDecimal(dose * profile.areaSqm / 1000),
                    doseUnit.name,
                    profile.areaSqm,
                  ),
                );
            } else {
              if (cycleDay case final day?) {
                parts.add(capitalized(strings.homeCycleDay(day, interval ?? day)));
              }
              parts.add(strings.journalDetailsMissing);
            }
          case CareKind.mowing:
            if (mowingHeightCm case final height?) {
              parts.add(strings.journalHeight(formatDecimal(height)));
            }
          case CareKind.watering:
            if (wateringMinutes case final minutes?) parts.add(strings.durationMinutes(minutes));
            if (wateringLitres case final litres?) {
              parts.add(strings.journalLitres(formatDecimal(litres)));
            }
          default:
            break;
        }
      case JournalKind.observation:
        parts.addAll(tags.map((tag) => strings.observationTag(tag.name)));
      case JournalKind.measurement:
        if (ph case final ph?) parts.add(strings.journalPh(formatDecimal(ph)));
      case JournalKind.photo:
        break;
    }
    if (note != null && note.isNotEmpty) parts.add(note);
    return parts.join(' · ');
  }
}

class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({
    required this.entry,
    required this.profile,
    required this.photoFile,
    required this.onTap,
    super.key,
  });

  final JournalEntry entry;
  final LawnProfile profile;
  final File Function(String name) photoFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = entry.colorIn(palette);
    final subtitle = entry.subtitle(context, profile);
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: Insets.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.medium,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, size: 20, color: color),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.xSmall,
                  children: [
                    Text(
                      entry.title(context),
                      style: AppTheme.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: palette.headingColor),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(
                          fontSize: 13,
                        ).copyWith(color: palette.mutedTextColor, height: 1.4),
                      ),
                    if (entry.rainConfirmed ?? false)
                      RainBadge(text: context.strings.journalRainConfirmed),
                    if (entry.photos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: Insets.xSmall),
                        child: PhotoThumb(file: photoFile(entry.photos.first), height: 84),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(Icons.chevron_right, size: 20, color: palette.mutedTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RainBadge extends StatelessWidget {
  const RainBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: palette.rainTintColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(Icons.umbrella_outlined, size: 14, color: palette.rainColor),
          Text(
            text,
            style: AppTheme.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ).copyWith(color: palette.rainColor),
          ),
        ],
      ),
    );
  }
}

class PhotoThumb extends StatelessWidget {
  const PhotoThumb({required this.file, this.height = 96, this.width, super.key});

  final File file;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(Insets.large),
            clipBehavior: Clip.antiAlias,
            child: InteractiveViewer(child: Image.file(file)),
          ),
        ),
        child: Image.file(
          file,
          height: height,
          width: width ?? double.infinity,
          fit: BoxFit.cover,
          cacheHeight: (height * 3).round(),
          errorBuilder: (_, _, _) => Container(
            height: height,
            width: width,
            color: palette.trackColor,
            child: Icon(Icons.broken_image_outlined, color: palette.mutedTextColor),
          ),
        ),
      ),
    );
  }
}
