import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

extension DeviceConnectionStateExtension on DeviceConnectionState {
  String get label => switch (this) {
        DeviceConnectionState.connecting => 'Connecting',
        DeviceConnectionState.connected => 'Connected',
        DeviceConnectionState.disconnecting => 'Disconnecting',
        DeviceConnectionState.disconnected => 'Disconnected',
      };

  Icon iconOf(BuildContext context) => switch (this) {
        DeviceConnectionState.connected => Icon(
            Icons.sensors,
            color: Theme.of(context).colorScheme.primary,
          ),
        DeviceConnectionState.disconnected => const Icon(Icons.sensors_off),
        _ => const Icon(Icons.sensors),
      };
}

extension ConnectableExtension on Connectable {
  String get label => switch (this) {
        Connectable.unknown => 'Unknown',
        Connectable.unavailable => 'Unavailable',
        Connectable.available => 'Available',
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

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    showTextSnackBar('Copied to clipboard');
  }

  void showAppLicensePage() => showLicensePage(
        context: this,
        useRootNavigator: true,
        applicationName: 'Riverable',
      );
}

extension ThemeModeExtension on ThemeMode {
  String get label => switch (this) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}
