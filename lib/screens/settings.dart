import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/settings.dart';
import '../utils/extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          _RssiThresholdListTile(),
          Divider(),
          _ThemeModeListTile(),
        ],
      ),
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
      context.pop();
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
