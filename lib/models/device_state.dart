import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_state.freezed.dart';

/// The state of a specific device.
///
/// This class is needed because the [DiscoveredDevice] object does not include
/// some properties that should be bound to the device, such as
/// [DeviceConnectionState].
@freezed
class DeviceState with _$DeviceState {
  factory DeviceState({
    required String id,
    required String name,
    required Map<Uuid, Uint8List> serviceData,
    required Uint8List manufacturerData,
    required int rssi,
    required List<Uuid> serviceUuids,
    required Connectable connectable,
    required DeviceConnectionState connectionState,
  }) = _DeviceState;
}
