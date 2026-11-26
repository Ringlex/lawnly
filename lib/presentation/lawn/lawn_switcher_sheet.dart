import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/router/app_router.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/domain/lawn/lawn_service.dart';
import 'package:lawnly/presentation/common/dimen.dart';
import 'package:lawnly/presentation/lawn/lawn_care_page.dart';
import 'package:lawnly/presentation/lawn/lawn_cubit.dart';
import 'package:lawnly/presentation/lawn/lawn_data_page.dart';

sealed class _LawnAction {
  const _LawnAction();
}

final class _SelectLawn extends _LawnAction {
  const _SelectLawn(this.id);

  final String id;
}

final class _EditData extends _LawnAction {
  const _EditData();
}

final class _EditCare extends _LawnAction {
  const _EditCare();
}

final class _AddLawn extends _LawnAction {
  const _AddLawn();
}

Future<void> showLawnSwitcher(BuildContext context) async {
  final service = getIt<LawnService>();
  final cubit = context.read<LawnCubit>();
  final lawns = await service.lawns();
  if (!context.mounted) return;

  final action = await showModalBottomSheet<_LawnAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: AppMotion.sheet,
    builder: (_) => _LawnSheet(lawns: lawns, activeId: service.activeId.value),
  );
  if (action == null || !context.mounted) return;

  void push(Widget page) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => BlocProvider.value(value: cubit, child: page)),
  );

  switch (action) {
    case _SelectLawn(:final id):
      await service.select(id);
    case _EditData():
      if (cubit.state.profile != null) push(const LawnDataPage());
    case _EditCare():
      if (cubit.state.profile != null) push(const LawnCarePage());
    case _AddLawn():
      await context.push(Routes.addLawn);
  }
}

class _LawnSheet extends StatelessWidget {
  const _LawnSheet({required this.lawns, required this.activeId});

  final List<LawnListing> lawns;
  final String activeId;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    void choose(_LawnAction action) => Navigator.of(context).pop(action);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Insets.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(strings.lawnsTitle),
            for (final lawn in lawns)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                selected: lawn.id == activeId,
                leading: Icon(Icons.grass, color: palette.primaryColor),
                title: Text(lawn.profile.name, style: context.textTheme.bodyLarge),
                subtitle: Text(
                  '${lawn.profile.location.label ?? strings.locationCurrent} · '
                  '${lawn.profile.areaSqm} ${strings.commonSquareMeters}',
                  style: context.textTheme.bodySmall,
                ),
                trailing: lawn.id == activeId
                    ? Icon(Icons.check, color: palette.primaryColor)
                    : null,
                onTap: () => choose(_SelectLawn(lawn.id)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, 0),
              child: FilledButton.icon(
                onPressed: () => choose(const _AddLawn()),
                icon: const Icon(Icons.add),
                label: Text(strings.lawnsAdd),
              ),
            ),
            if (lawns.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, 0),
                child: Text(strings.lawnsNotificationsNote, style: context.textTheme.bodySmall),
              ),
            Gap.large,
            _SheetTitle(strings.lawnsEditSection),
            _EditTile(
              icon: Icons.edit_outlined,
              label: strings.lawnsEditData,
              onTap: () => choose(const _EditData()),
            ),
            _EditTile(
              icon: Icons.tune,
              label: strings.lawnCare,
              onTap: () => choose(const _EditCare()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, Insets.small),
    child: Text(text, style: context.textTheme.titleLarge),
  );
}

class _EditTile extends StatelessWidget {
  const _EditTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    leading: Icon(icon, color: context.palette.secondaryTextColor),
    title: Text(label, style: context.textTheme.bodyLarge),
    trailing: Icon(Icons.chevron_right, color: context.palette.mutedTextColor),
    onTap: onTap,
  );
}
