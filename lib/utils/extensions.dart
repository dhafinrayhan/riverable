import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

extension DeviceConnectionStateExtension on DeviceConnectionState {
  String get label => switch (this) {
        DeviceConnectionState.connecting => 'Connecting',
        DeviceConnectionState.connected => 'Connected',
        DeviceConnectionState.disconnecting => 'Disconnecting',
        DeviceConnectionState.disconnected => 'Disconnected',
      };
}

extension BuildContextExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shows a floating snack bar with text as its content.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTextSnackBar(
    String text,
  ) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));

  void showAppLicensePage() => showLicensePage(
        context: this,
        useRootNavigator: true,
        applicationName: 'Riverable',
      );
}
