import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class RssiThreshold extends _$RssiThreshold {
  final _box = Hive.box('settings');

  @override
  int build() {
    final rssi = _box.get('rssiThreshold') as int?;
    return rssi ?? -80;
  }

  void set(int value) {
    state = value;
    _box.put('rssiThreshold', value);
  }
}

/// The current theme mode of the app.
///
/// When this provider is first read, it will read the saved value from storage,
/// and defaults to [ThemeMode.system] if the theme mode was not set before.
@Riverpod(keepAlive: true)
class CurrentThemeMode extends _$CurrentThemeMode {
  final _box = Hive.box('settings');

  @override
  ThemeMode build() {
    // Load the saved theme mode setting from Hive box.
    final themeModeName = _box.get('themeMode') as String?;

    // Return [ThemeMode] based on the saved setting, or [ThemeMode.system]
    // if there's no saved setting yet.
    return ThemeMode.values.singleWhere(
      (themeMode) => themeMode.name == themeModeName,
      orElse: () => ThemeMode.system,
    );
  }

  void set(ThemeMode themeMode) {
    state = themeMode;

    // Save the new theme mode to Hive box.
    _box.put('themeMode', themeMode.name);
  }
}

@Riverpod(keepAlive: true)
class SortBasedOnRssi extends _$SortBasedOnRssi {
  final _box = Hive.box('settings');

  @override
  bool build() {
    final value = _box.get('sortBasedOnRssi') as bool?;
    return value ?? false;
  }

  void set(bool value) {
    state = value;
    _box.put('sortBasedOnRssi', value);
  }
}

@Riverpod(keepAlive: true)
class ConnectedDevicesOnTop extends _$ConnectedDevicesOnTop {
  final _box = Hive.box('settings');

  @override
  bool build() {
    final value = _box.get('connectedDevicesOnTop') as bool?;
    return value ?? false;
  }

  void set(bool value) {
    state = value;
    _box.put('connectedDevicesOnTop', value);
  }
}
