import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

/// BottomNavigationBarを含むアプリ全体のScaffold
class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    int selectedIndex = 0;
    if (currentLocation == '/') {
      selectedIndex = 0;
    } else if (currentLocation.startsWith('/workout')) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith('/inventory')) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith('/settings')) {
      selectedIndex = 3;
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: '計測',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: '在庫',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/workout');
        break;
      case 2:
        context.go('/inventory');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
