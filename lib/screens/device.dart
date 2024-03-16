import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/device_state.dart';
import '../services/ble/device.dart';
import '../utils/extensions.dart';
import '../widgets/copyable_list_tile.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceProvider(id));

    final records = [
      (label: 'ID', text: device.id),
      (label: 'Name', text: device.name),
      (label: 'RSSI (dBm)', text: device.rssi.toString()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device'),
      ),
      body: ListView(
        children: [
          for (final record in records)
            CopyableListTile(
              data: () => record.text,
              title: Text(record.label),
              subtitle: Text(record.text),
            ),
          const Divider(),
          _ConnectionListTile(device),
        ],
      ),
    );
  }
}

class _ConnectionListTile extends ConsumerWidget {
  const _ConnectionListTile(this.device);

  final DeviceState device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void connect() {
      ref.read(deviceProvider(device.id).notifier).connect();
    }

    void disconnect() {
      ref.read(deviceProvider(device.id).notifier).disconnect();
    }

    GestureTapCallback? onTap;
    String subtitle;

    switch (device.connectionState) {
      case DeviceConnectionState.connected:
        onTap = disconnect;
        subtitle = 'Tap to disconnect';
      case DeviceConnectionState.disconnected:
        onTap = connect;
        subtitle = 'Tap to connect';
      default:
        onTap = null;
        subtitle = '';
    }

    return ListTile(
      onTap: onTap,
      leading: device.connectionState.iconOf(context),
      title: Text(device.connectionState.label),
      subtitle: Text(subtitle),
    );
  }
}
