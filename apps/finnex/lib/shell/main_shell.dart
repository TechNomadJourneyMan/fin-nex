// Main app shell with bottom NavigationBar (Home / Transactions /
// Analytics / Settings). Hosts the inner [child] from go_router's
// [StatefulShellRoute].

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Top-level shell with persistent bottom navigation.
///
/// The four tabs are wired to the matching go_router branches via
/// [navigationShell]. A floating action button is shown only on the
/// Transactions tab to open the quick-add expense sheet.
class MainShell extends StatelessWidget {
  /// Create the shell with a [StatefulNavigationShell] from go_router.
  const MainShell({super.key, required this.navigationShell});

  /// The navigation shell that owns the per-tab navigation stacks.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: _onTap,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: current == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/transactions/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
    );
  }
}
