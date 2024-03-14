import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble.g.dart';

@Riverpod(keepAlive: true)
FlutterReactiveBle ble(BleRef ref) => FlutterReactiveBle();

@Riverpod(keepAlive: true)
Stream<List<DiscoveredDevice>> discoveredDevices(
    DiscoveredDevicesRef ref) async* {
  final devices = <DiscoveredDevice>[];
  yield devices;

  final deviceStream = ref
      .watch(bleProvider)
      .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency);

  await for (final device in deviceStream) {
    if (devices.every((d) => d.id != device.id)) {
      devices.add(device);
      yield devices;
    }
  }
}
