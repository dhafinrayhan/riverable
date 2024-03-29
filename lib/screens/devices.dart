import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble/device.dart';
import '../services/ble/devices.dart';
import '../utils/characteristics_sheet.dart';
import '../utils/extensions.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DiscoveredDevice> devices =
        ref.watch(nearbyDevicesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (_, index) {
          final id = devices[index].id;
          return _DeviceListTile(id);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showCharacteristicsSheet(context, useRootNavigator: true),
        child: const Icon(Icons.pin),
      ),
    );
  }
}

class _DeviceListTile extends ConsumerWidget {
  const _DeviceListTile(this.id);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(DeviceProvider(id));

    return ListTile(
      onTap: () => context.go('/devices/${device.id}'),
      leading: device.connectionState.iconOf(context),
      title: Text(device.id),
      subtitle: device.name.isNotEmpty ? Text(device.name) : null,
      trailing: Text(device.rssi.toString()),
    );
  }
}
