import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings.dart';

part 'devices.g.dart';

/// Exposes a singleton of the BLE service.
@Riverpod(keepAlive: true)
FlutterReactiveBle ble(BleRef ref) => FlutterReactiveBle();

/// Exposes a map of all discovered devices with device ID as the key.
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

/// Exposes discovered devices within the RSSI threshold.
@riverpod
Stream<List<DiscoveredDevice>> nearbyDevices(NearbyDevicesRef ref) async* {
  final sortBasedOnRssi = ref.watch(sortBasedOnRssiProvider);
  // final connectedDevicesOnTop = ref.watch(connectedDevicesOnTopProvider);
  final threshold = ref.watch(rssiThresholdProvider);
  final devices = (await ref.watch(discoveredDevicesProvider.future)).values;

  final nearbyDevices =
      devices.where((device) => device.rssi >= threshold).toList();
  if (sortBasedOnRssi) {
    nearbyDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  yield nearbyDevices;
}

@riverpod
Stream<ConnectionStateUpdate> latestConnectionStateUpdate(
  LatestConnectionStateUpdateRef ref,
) =>
    ref.watch(bleProvider).connectedDeviceStream.distinct();
