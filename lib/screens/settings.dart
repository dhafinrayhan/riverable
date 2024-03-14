import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/settings.dart';

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
        value: threshold,
        min: minThreshold,
        max: maxThreshold,
        divisions: (maxThreshold - minThreshold).toInt(),
        // label: threshold.toStringAsFixed(0),
        onChanged: (value) {
          ref.read(rssiThresholdProvider.notifier).set(value);
        },
      ),
      trailing: Text(threshold.toStringAsFixed(0)),
    );
  }
}
