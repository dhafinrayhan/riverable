import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/device.dart';
import '../screens/devices.dart';
import '../screens/settings.dart';
import '../widgets/scaffold_with_navigation.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final navigationItems = [
    NavigationItem(
      path: '/devices',
      body: (_) => const DevicesScreen(),
      icon: Icons.bluetooth_searching_outlined,
      selectedIcon: Icons.bluetooth_searching,
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
    NavigationItem(
      path: '/settings',
      body: (_) => const SettingsScreen(),
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  final router = GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: navigationItems.first.path,
    routes: [
      // Configuration for the bottom navigation bar routes. The routes
      // themselves should be defined in [navigationItems].
      ShellRoute(
        builder: (_, state, child) => ScaffoldWithNavigation(
          currentPath: state.uri.path,
          navigationItems: navigationItems,
          child: child,
        ),
        routes: [
          for (final item in navigationItems)
            GoRoute(
              path: item.path,
              pageBuilder: (context, __) => CustomTransitionPage(
                child: item.body(context),
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
