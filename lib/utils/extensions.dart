import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

extension DeviceConnectionStateExtension on DeviceConnectionState {
  String get label => switch (this) {
        DeviceConnectionState.connecting => 'Connecting',
        DeviceConnectionState.connected => 'Connected',
        DeviceConnectionState.disconnecting => 'Disconnecting',
        DeviceConnectionState.disconnected => 'Disconnected',
      };
}
