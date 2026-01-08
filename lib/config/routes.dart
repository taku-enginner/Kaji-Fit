import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/workout/presentation/screens/workout_screen.dart';
import '../features/inventory/presentation/screens/inventory_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../shared/widgets/app_scaffold.dart';

/// ルート定義
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/workout',
          name: 'workout',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WorkoutScreen(),
          ),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: InventoryScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
