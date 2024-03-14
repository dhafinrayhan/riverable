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
          if (connectionState != null)
            ListTile(
              onTap: () {
                switch (connectionState) {
                  case DeviceConnectionState.connected:
                    ref
                        .read(CurrentDeviceConnectionStateProvider(id).notifier)
                        .disconnect();
                  case DeviceConnectionState.disconnected:
                    ref
                        .read(CurrentDeviceConnectionStateProvider(id).notifier)
                        .connect();
                  default:
                }
              },
              leading: const Icon(Icons.sensors),
              title: Text(connectionState.label),
              subtitle: Text(switch (connectionState) {
                DeviceConnectionState.connecting => '',
                DeviceConnectionState.connected => 'Tap to disconnect',
                DeviceConnectionState.disconnecting => '',
                DeviceConnectionState.disconnected => 'Tap to connect',
              }),
            ),
        ],
      ),
    );
  }
}
