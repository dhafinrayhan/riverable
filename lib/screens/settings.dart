import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble/characteristics.dart';
import '../services/settings.dart';
import '../utils/characteristics_sheet.dart';
import '../utils/extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () => context.showAppLicensePage(),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        children: const [
          _SortBasedOnRssiListTile(),
          _ConnectedDevicesOnTopListTile(),
          _CharacteristicsListTile(),
          Divider(),
          _RssiThresholdListTile(),
          Divider(),
          _ThemeModeListTile(),
        ],
      ),
    );
  }
}

class _CharacteristicsListTile extends ConsumerWidget {
  const _CharacteristicsListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristics = ref.watch(characteristicsProvider);

    return ListTile(
      onTap: () => showCharacteristicsSheet(context, useRootNavigator: true),
      title: const Text('Characteristics'),
      subtitle: Text('${characteristics.length} saved characteristic(s)'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _RssiThresholdListTile extends ConsumerWidget {
  const _RssiThresholdListTile();

  static const double minThreshold = -100;
  static const double maxThreshold = -20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threshold = ref.watch(rssiThresholdProvider);

    return ListTile(
      title: const Text('RSSI threshold (dBm)'),
      subtitle: Slider(
        value: threshold.toDouble(),
        min: minThreshold,
        max: maxThreshold,
        divisions: (maxThreshold - minThreshold).toInt(),
        onChanged: (value) {
          ref.read(rssiThresholdProvider.notifier).set(value.toInt());
        },
      ),
      trailing: Text(threshold.toStringAsFixed(0)),
    );
  }
}

class _SortBasedOnRssiListTile extends ConsumerWidget {
  const _SortBasedOnRssiListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isChecked = ref.watch(sortBasedOnRssiProvider);

    return CheckboxListTile(
      value: isChecked,
      onChanged: (value) =>
          ref.read(sortBasedOnRssiProvider.notifier).set(value!),
      title: const Text('Sort devices based on RSSI strength'),
    );
  }
}

class _ConnectedDevicesOnTopListTile extends ConsumerWidget {
  const _ConnectedDevicesOnTopListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isChecked = ref.watch(connectedDevicesOnTopProvider);

    return CheckboxListTile(
      enabled: false,
      subtitle: const Text('(Feature not available yet)'),
      value: isChecked,
      onChanged: (value) =>
          ref.read(connectedDevicesOnTopProvider.notifier).set(value!),
      title: const Text('Show connected devices on top of the list'),
    );
  }
}

class _ThemeModeListTile extends ConsumerWidget {
  const _ThemeModeListTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);

    void showThemeModeDialog() {
      showDialog(
        context: context,
        builder: (_) => const _ThemeModeDialog(),
      );
    }

    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme mode'),
      trailing: Text(themeMode.label),
      onTap: showThemeModeDialog,
    );
  }
}

class _ThemeModeDialog extends ConsumerWidget {
  const _ThemeModeDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void setThemeMode(ThemeMode themeMode) {
      ref.read(currentThemeModeProvider.notifier).set(themeMode);
      Navigator.of(context).pop();
    }

    return SimpleDialog(
      clipBehavior: Clip.antiAlias,
      children: [
        for (final themeMode in ThemeMode.values)
          _ThemeModeDialogOption(
            value: themeMode,
            onTap: () => setThemeMode(themeMode),
          )
      ],
    );
  }
}

class _ThemeModeDialogOption extends StatelessWidget {
  const _ThemeModeDialogOption({required this.value, required this.onTap});

  final ThemeMode value;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(value.label),
    );
  }
}
