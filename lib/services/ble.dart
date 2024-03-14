import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble.g.dart';

@Riverpod(keepAlive: true)
FlutterReactiveBle ble(BleRef ref) => FlutterReactiveBle();

@Riverpod(keepAlive: true)
Stream<Map<String, DiscoveredDevice>> discoveredDevices(
    DiscoveredDevicesRef ref) async* {
  final devices = <String, DiscoveredDevice>{};
  yield devices;

  final deviceStream = ref
      .watch(bleProvider)
      .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency);

  await for (final device in deviceStream) {
    devices[device.id] = device;
    yield devices;
  }
}
