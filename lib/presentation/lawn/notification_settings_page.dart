import 'package:flutter/material.dart';
import 'package:lawnly/core/di/injection.dart';
import 'package:lawnly/core/l10n/app_strings.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/presentation/common/dimen.dart';

class NotificationSettingsTile extends StatefulWidget {
  const NotificationSettingsTile({super.key});

  @override
  State<NotificationSettingsTile> createState() => _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends State<NotificationSettingsTile> {
  final _scheduler = getIt<NotificationScheduler>();

  NotificationPrefs _prefs = const NotificationPrefs();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final prefs = await _scheduler.prefs();
    if (mounted) setState(() => _prefs = prefs);
  }

  Future<void> _toggle(bool enabled) async {
    final messenger = ScaffoldMessenger.of(context);
    final denied = context.strings.notifSettingsDenied;
    setState(() => _prefs = _prefs.copyWith(enabled: enabled));
    final granted = await _scheduler.update(_prefs);
    await _refresh();
    if (!granted) messenger.showSnackBar(SnackBar(content: Text(denied)));
  }

  Future<void> _openDetails() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationSettingsPage()));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _openDetails,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.large,
                  Insets.small,
                  Insets.small,
                  Insets.small,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(strings.notifSettingsTitle, style: context.textTheme.bodyLarge),
                    Text(
                      _prefs.enabled
                          ? strings.notifSettingsOn(_prefs.morningHour)
                          : strings.notifSettingsOff,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: palette.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Semantics(
          label: strings.notifSettingsEnable,
          child: Switch(value: _prefs.enabled, onChanged: _toggle),
        ),
        const SizedBox(width: Insets.small),
      ],
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _scheduler = getIt<NotificationScheduler>();

  NotificationPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    _scheduler.prefs().then((prefs) {
      if (mounted) setState(() => _prefs = prefs);
    });
  }

  Future<void> _change(NotificationPrefs next) async {
    setState(() => _prefs = next);
    final messenger = ScaffoldMessenger.of(context);
    final denied = context.strings.notifSettingsDenied;
    final granted = await _scheduler.update(next);
    if (granted) return;
    final saved = await _scheduler.prefs();
    if (!mounted) return;
    setState(() => _prefs = saved);
    messenger.showSnackBar(SnackBar(content: Text(denied)));
  }

  Future<void> _pickHour(NotificationPrefs prefs) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: prefs.morningHour, minute: 0),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (picked == null) return;
    final hour = picked.hour.clamp(
      NotificationPrefs.quietUntilHour,
      NotificationPrefs.quietFromHour - 1,
    );
    await _change(prefs.copyWith(morningHour: hour));
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final palette = context.palette;
    final prefs = _prefs;

    return Scaffold(
      appBar: AppBar(title: Text(strings.notifSettingsTitle)),
      body: prefs == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, Insets.small, 20, Insets.xxLarge),
              children: [
                Text(
                  strings.notifSettingsIntro,
                  style: AppTheme.body(
                    fontSize: 15,
                  ).copyWith(color: palette.secondaryTextColor, height: 1.5),
                ),
                Gap.large,
                _Group(
                  children: [
                    SwitchListTile(
                      title: Text(strings.notifSettingsEnable),
                      value: prefs.enabled,
                      onChanged: (value) => _change(prefs.copyWith(enabled: value)),
                    ),
                  ],
                ),
                if (prefs.enabled) ...[
                  Gap.large,
                  _Group(
                    children: [
                      ListTile(
                        title: Text(strings.notifSettingsHour),
                        trailing: Text(strings.notifSettingsHourValue(prefs.morningHour)),
                        onTap: () => _pickHour(prefs),
                      ),
                      SwitchListTile(
                        title: Text(strings.notifSettingsFertilizing),
                        value: prefs.fertilizing,
                        onChanged: (value) => _change(prefs.copyWith(fertilizing: value)),
                      ),
                      SwitchListTile(
                        title: Text(strings.notifSettingsWatering),
                        value: prefs.watering,
                        onChanged: (value) => _change(prefs.copyWith(watering: value)),
                      ),
                      SwitchListTile(
                        title: Text(strings.notifSettingsCare),
                        value: prefs.care,
                        onChanged: (value) => _change(prefs.copyWith(care: value)),
                      ),
                      SwitchListTile(
                        title: Text(strings.notifSettingsWarnings),
                        value: prefs.warnings,
                        onChanged: (value) => _change(prefs.copyWith(warnings: value)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: palette.outlineColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: Insets.large, endIndent: Insets.large, height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}
