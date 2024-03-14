import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/discovered_devices.dart';
import '../screens/settings.dart';
import '../widgets/models/nav_bar_item.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final navBarItems = [
    NavBarItem(
      path: '/discovered-devices',
      widget: const DiscoveredDevicesScreen(),
      icon: Icons.bluetooth,
      label: 'Devices',
    ),
    NavBarItem(
      path: '/settings',
      widget: const SettingsScreen(),
      icon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final router = GoRouter(
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
