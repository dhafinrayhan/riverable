import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/device_state.dart';
import '../services/ble/characteristics.dart';
import '../services/ble/device.dart';
import '../utils/characteristics_sheet.dart';
import '../utils/extensions.dart';
import '../widgets/list_tiles.dart';

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
      (label: 'Connectable', text: device.connectable.label),
      (label: 'Manufacturer data', text: device.manufacturerData.toString()),
    ];

    void showServices() {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) {
          return PaddedColumn(
            padding: const EdgeInsets.only(bottom: 24),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              for (final uuid in device.serviceUuids)
                CopyableListTile(
                  data: () => uuid.toString(),
                  title: Text(uuid.toString(), textAlign: TextAlign.center),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          for (final record in records)
            CopyableListTile(
              data: () => record.text,
              title: Text(record.label),
              subtitle: Text(record.text),
            ),
          ListTile(
            title: const Text('Services'),
            subtitle: Text('${device.serviceUuids.length} service(s)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: showServices,
          ),
          const Divider(),
          _ConnectSection(device),
          const Divider(),
          _WriteSection(device),
        ],
      ),
    );
  }
}

class _ConnectSection extends StatelessWidget {
  const _ConnectSection(this.device);

  final DeviceState device;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleListTile('Connect to device'),
        _ConnectionListTile(device),
      ],
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

    if (device.connectable != Connectable.available) {
      onTap = null;
      subtitle = 'Device not available to connect';
    } else if (device.connectionState == DeviceConnectionState.connected) {
      onTap = disconnect;
      subtitle = 'Tap to disconnect';
    } else if (device.connectionState == DeviceConnectionState.disconnected) {
      onTap = connect;
      subtitle = 'Tap to connect';
    } else {
      onTap = null;
      subtitle = '';
    }

    return ListTile(
      onTap: onTap,
      enabled: device.connectable == Connectable.available,
      leading: device.connectionState.iconOf(context),
      title: Text(device.connectionState.label),
      subtitle: Text(subtitle),
    );
  }
}

class _WriteSection extends HookConsumerWidget {
  const _WriteSection(this.device);

  final DeviceState device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristic = useState<AppQualifiedCharacteristic?>(null);
    final isWithResponse = useState(true);
    final valueController = useTextEditingController(text: '0');

    Future<void> selectCharacteristic() async {
      final selectedCharacteristic =
          await showCharacteristicsSheet(context, selectable: true);
      if (selectedCharacteristic != null) {
        characteristic.value = selectedCharacteristic;
      }
    }

    void writeCharacteristic() {
      if (characteristic.value == null) {
        context.showTextSnackBar('Please select a characteristic first');
        return;
      }

      ref.read(deviceProvider(device.id).notifier).write(
        characteristic.value!,
        value: [for (final e in valueController.text.split(',')) int.parse(e)],
      );
    }

    return Column(
      children: [
        const TitleListTile('Write characteristic'),
        ListTile(
          onTap: selectCharacteristic,
          title: const Text('Characteristic'),
          subtitle: Text(
            characteristic.value != null
                ? '${characteristic.value!.name}\n${characteristic.value!.shortDescription}'
                : 'Select a characteristic',
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: const Text('Value'),
          subtitle: TextField(
            controller: valueController,
            decoration: const InputDecoration(
              helperText: 'Example: 12,34,56,78',
              border: UnderlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        SwitchListTile(
          value: isWithResponse.value,
          onChanged: (value) => isWithResponse.value = value,
          title: const Text('Wait for acknowledgement'),
        ),
        ListTile(
          onTap: writeCharacteristic,
          leading: const Icon(Icons.north_east),
          title: const Text('Write'),
          subtitle: const Text('Tap to write'),
        ),
      ],
    );
  }
}
