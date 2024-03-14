// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bleHash() => r'a52e9b7b662f4a0a3824b2822b5fceadea809b81';

/// See also [ble].
@ProviderFor(ble)
final bleProvider = Provider<FlutterReactiveBle>.internal(
  ble,
  name: r'bleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BleRef = ProviderRef<FlutterReactiveBle>;
String _$discoveredDevicesHash() => r'ee6804602fcf1388228d5ae9f3420d17b2a06262';

/// See also [discoveredDevices].
@ProviderFor(discoveredDevices)
final discoveredDevicesProvider =
    StreamProvider<List<DiscoveredDevice>>.internal(
  discoveredDevices,
  name: r'discoveredDevicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$discoveredDevicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DiscoveredDevicesRef = StreamProviderRef<List<DiscoveredDevice>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
