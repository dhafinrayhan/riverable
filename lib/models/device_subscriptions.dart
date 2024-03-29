import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// A container for BLE-related subscriptions that belong to a device.
class DeviceSubscriptionContainer {
  StreamSubscription<ConnectionStateUpdate>? connection;
  StreamSubscription<List<int>>? characteristic;
}
