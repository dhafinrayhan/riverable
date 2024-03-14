import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble.dart';
import '../utils/extensions.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceProvider(id));
    final connectionState =
        ref.watch(currentDeviceConnectionStateProvider(id)).value;

    final records = <({String label, String text})>[
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
            ListTile(
              title: Text(record.label),
              subtitle: Text(record.text),
            ),
          const Divider(),
          if (connectionState != null) _ConnectionListTile(id),
        ],
      ),
    );
  }
}

class _ConnectionListTile extends ConsumerWidget {
  const _ConnectionListTile(this.id);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState =
        ref.watch(currentDeviceConnectionStateProvider(id)).requireValue;

    void connect() {
      ref.read(currentDeviceConnectionStateProvider(id).notifier).connect();
    }

    void disconnect() {
      ref.read(currentDeviceConnectionStateProvider(id).notifier).disconnect();
    }

    GestureTapCallback? onTap;
    Icon icon;
    String subtitle;

    switch (connectionState) {
      case DeviceConnectionState.connected:
        onTap = disconnect;
        icon = Icon(
          Icons.sensors,
          color: Theme.of(context).colorScheme.primary,
        );
        subtitle = 'Tap to disconnect';
      case DeviceConnectionState.disconnected:
        onTap = connect;
        icon = const Icon(Icons.sensors_off);
        subtitle = 'Tap to connect';
      default:
        onTap = null;
        icon = const Icon(Icons.sensors);
        subtitle = '';
    }

    return ListTile(
      onTap: onTap,
      leading: icon,
      title: Text(connectionState.label),
      subtitle: Text(subtitle),
    );
  }
}
