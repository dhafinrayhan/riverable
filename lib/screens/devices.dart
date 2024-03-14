import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices =
        ref.watch(nearbyDevicesProvider).value?.values.toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
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
      onTap: () => context.go('/devices/${device.id}'),
      title: Text(device.id),
      subtitle: device.name.isNotEmpty ? Text(device.name) : null,
      trailing: Text(device.rssi.toString()),
    );
  }
}
