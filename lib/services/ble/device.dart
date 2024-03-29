import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/device_state.dart';
import '../../models/device_subscriptions.dart';
import 'characteristics.dart';
import 'devices.dart';

part 'device.g.dart';

/// A holder for [DeviceSubscriptionContainer] of each device with device ID as
/// the key.
final Map<String, DeviceSubscriptionContainer> _subscriptionContainers = {};

/// A notifier that exposes a specific device state and manage BLE operations
/// related to the device.
@riverpod
class Device extends _$Device {
  @override
  DeviceState build(String id) {
    final DiscoveredDevice device = ref.watch(
      discoveredDevicesProvider.select((devices) => devices.requireValue[id]!),
    );
    final DeviceConnectionState connectionState =
        ref.watch(deviceConnectionStateProvider(id)).value ??
            DeviceConnectionState.disconnected;

    _subscriptionContainers.putIfAbsent(
        id, () => DeviceSubscriptionContainer());

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
    _subscriptionContainers[id]!.connection =
        ref.read(bleProvider).connectToDevice(id: id).listen((_) {});
  }

  Future<void> disconnect() async {
    await _subscriptionContainers[id]!.connection?.cancel();
    _subscriptionContainers[id]!.connection = null;
  }

  Future<List<int>> read(AppQualifiedCharacteristic characteristic) async {
    final response = await ref
        .read(bleProvider)
        .readCharacteristic(characteristic.toQualifiedCharacteristic());
    return response;
  }

  Future<void> write(
    AppQualifiedCharacteristic characteristic, {
    required List<int> value,
    bool withResponse = true,
  }) async {
    if (withResponse) {
      await ref.read(bleProvider).writeCharacteristicWithResponse(
            characteristic.toQualifiedCharacteristic(),
            value: value,
          );
    } else {
      await ref.read(bleProvider).writeCharacteristicWithoutResponse(
            characteristic.toQualifiedCharacteristic(),
            value: value,
          );
    }
  }

  void subscribe(AppQualifiedCharacteristic characteristic) {
    _subscriptionContainers[id]!.characteristic = ref
        .read(bleProvider)
        .subscribeToCharacteristic(characteristic.toQualifiedCharacteristic())
        .listen((_) {});
  }

  Future<void> unsubscribe() async {
    await _subscriptionContainers[id]!.characteristic?.cancel();
    _subscriptionContainers[id]!.characteristic = null;
  }

  Future<int> requestMtu(int mtu) async {
    final negotiatedMtu =
        await ref.read(bleProvider).requestMtu(deviceId: id, mtu: mtu);
    return negotiatedMtu;
  }

  Future<void> requestConnectionPriority(ConnectionPriority priority) async {
    await ref
        .read(bleProvider)
        .requestConnectionPriority(deviceId: id, priority: priority);
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
