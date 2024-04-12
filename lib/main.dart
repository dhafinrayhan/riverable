import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/ble/characteristics.dart';
import 'services/ble/devices.dart';
import 'services/router.dart';
import 'services/settings.dart';
import 'utils/extensions.dart';
import 'utils/methods.dart';
import 'utils/provider_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await [
    // Request permissions.
    [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request(),

    // Initialize Hive.
    Future(() async {
      await Hive.initFlutter();

      // Register adapters.
      Hive.registerAdapter(AppQualifiedCharacteristicAdapter());

      // Open boxes.
      await [
        Hive.openBox<AppQualifiedCharacteristic>('characteristics'),
        Hive.openBox('settings'),
      ].wait;
    }),
  ].wait;

  runApp(ProviderScope(
    observers: [AppProviderObserver()],
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

    final (lightTheme, darkTheme) = createDualThemeData(
      seedColor: Colors.blue,
      useMaterial3: true,
      transformer: (themeData) => themeData.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Riverable',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
