import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble.dart';

class DiscoveredDevicesScreen extends ConsumerWidget {
  const DiscoveredDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices =
        ref.watch(discoveredDevicesProvider).value?.values.toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovered Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (_, index) {
          return _DeviceListTile(devices[index]);
        },
      ),
    );
  }
}

class _DeviceListTile extends StatelessWidget {
  const _DeviceListTile(this.device);

  final DiscoveredDevice device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.go('/discovered-devices/${device.id}'),
      title: Text(device.id),
      subtitle: Text(device.name),
      trailing: Text(device.rssi.toString()),
    );
  }
}
