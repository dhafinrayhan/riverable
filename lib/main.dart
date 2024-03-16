import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'services/ble/characteristics.dart';
import 'services/ble/devices.dart';
import 'services/router.dart';
import 'services/settings.dart';
import 'utils/extensions.dart';

Future<void> main() async {
  // Initialize Hive.
  await Future(() async {
    await Hive.initFlutter();

    Hive.registerAdapter(HiveQualifiedCharacteristicAdapter());

    // Open boxes.
    await [
      Hive.openBox<HiveQualifiedCharacteristic>('characteristics'),
      Hive.openBox('settings'),
    ].wait;
  });

  runApp(ProviderScope(
    observers: [_ProviderObserver()],
    child: const RiverableApp(),
  ));
}

class RiverableApp extends ConsumerWidget {
  const RiverableApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    // Show a snackbar when a device is connected/disconnected.
    ref.listen(latestConnectionStateUpdateProvider, (_, connectionStateUpdate) {
      if (connectionStateUpdate.hasValue) {
        final ConnectionStateUpdate(:deviceId, :connectionState) =
            connectionStateUpdate.requireValue;
        switch (connectionState) {
          case DeviceConnectionState.connected:
          case DeviceConnectionState.disconnected:
            EasyThrottle.throttle(
              '$deviceId-${connectionState.name}-snackbar',
              const Duration(seconds: 2),
              () => navigatorKey.currentContext?.showTextSnackBar(
                  'Device $deviceId ${connectionState.name}'),
            );
          default:
            break;
        }
      }
    });

    return MaterialApp.router(
      title: 'Riverable',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
    );
  }
}

class _ProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint('Provider $provider was initialized with $value');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    debugPrint('Provider $provider was disposed');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('Provider $provider updated from $previousValue to $newValue');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('Provider $provider threw $error at $stackTrace');
  }
}
