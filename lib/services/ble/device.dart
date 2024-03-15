import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/device_state.dart';
import 'devices.dart';

part 'device.g.dart';

/// A notifier that exposes a specific device state and manage BLE operations
/// related to the device.
@riverpod
class Device extends _$Device {
  @override
  DeviceState build(String id) {
    final DiscoveredDevice device = ref.watch(
      discoveredDevicesProvider.select((device) => device.requireValue[id]!),
    );
    final DeviceConnectionState connectionState =
        ref.watch(deviceConnectionStateProvider(id)).value ??
            DeviceConnectionState.disconnected;

    return DeviceState(
      id: id,
      name: device.name,
      serviceData: device.serviceData,
      manufacturerData: device.manufacturerData,
      rssi: device.rssi,
      serviceUuids: device.serviceUuids,
      connectable: device.connectable,
      connectionState: connectionState,
    );
  }

  void connect() {
    ref.read(deviceConnectionProvider(id).notifier).connect();
  }

  Future<void> disconnect() async {
    await ref.read(deviceConnectionProvider(id).notifier).disconnect();
  }
}

/// Exposes the latest connection state of a specific device.
@Riverpod(keepAlive: true)
Stream<DeviceConnectionState> deviceConnectionState(
  DeviceConnectionStateRef ref,
  String id,
) async* {
  final connectedDeviceStream = ref.watch(bleProvider).connectedDeviceStream;

  yield DeviceConnectionState.disconnected;
  await for (final event in connectedDeviceStream) {
    if (event.deviceId == id) {
      yield event.connectionState;
    }
  }
}

/// A notifier that acts as a singleton for the connection stream subscription
/// of a specific device.
@Riverpod(keepAlive: true)
class DeviceConnection extends _$DeviceConnection {
  @override
  StreamSubscription<ConnectionStateUpdate>? build(String id) => null;

  void connect() {
    state ??= ref.read(bleProvider).connectToDevice(id: id).listen((_) {});
  }

  Future<void> disconnect() async {
    await state?.cancel();
    ref.invalidateSelf();
  }
}
