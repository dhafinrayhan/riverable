import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/add_characteristic.dart';
import '../screens/characteristics.dart';
import '../screens/device.dart';
import '../screens/devices.dart';
import '../screens/settings.dart';
import '../widgets/models/nav_bar_item.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final navBarItems = [
    NavBarItem(
      path: '/devices',
      widget: const DevicesScreen(),
      icon: Icons.bluetooth,
      label: 'Devices',
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return DeviceScreen(id);
          },
        ),
      ],
    ),
    NavBarItem(
      path: '/characteristics',
      widget: const CharacteristicsScreen(),
      icon: Icons.pin,
      label: 'Characteristics',
      routes: [
        GoRoute(
          path: 'add',
          builder: (_, __) {
            return const AddCharacteristicScreen();
          },
        ),
      ],
    ),
    NavBarItem(
      path: '/settings',
      widget: const SettingsScreen(),
      icon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final router = GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: navBarItems.first.path,
    routes: [
      // Configuration for the bottom navigation bar routes. The routes
      // themselves should be defined in [navBarItems].
      ShellRoute(
        builder: (_, state, child) => ScaffoldWithNavBar(
          currentPath: state.uri.path,
          navBarItems: navBarItems,
          child: child,
        ),
        routes: [
          for (final item in navBarItems)
            GoRoute(
              path: item.path,
              pageBuilder: (_, __) => CustomTransitionPage(
                child: item.widget,
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation.drive(CurveTween(curve: Curves.ease)),
                    child: child,
                  );
                },
              ),
              routes: item.routes,
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);

  return router;
}
