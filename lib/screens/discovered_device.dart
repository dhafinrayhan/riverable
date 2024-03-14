import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble.dart';

class DiscoveredDeviceScreen extends ConsumerWidget {
  const DiscoveredDeviceScreen(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(
      discoveredDevicesProvider.select((value) => value.value![id]!),
    );

    final records = <({String label, String text})>[
      (label: 'ID', text: device.id),
      (label: 'Name', text: device.name),
      (label: 'RSSI (dBm)', text: device.rssi.toString()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovered Device'),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (_, index) {
          final record = records[index];
          return ListTile(
            title: Text(record.label),
            subtitle: Text(record.text),
          );
        },
      ),
    );
  }
}
