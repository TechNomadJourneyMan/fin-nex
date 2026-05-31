// Main app shell — OmniFi OS reskin.
//
// • Translucent AppBar with brand wordmark.
// • Body fills the canvas (extendBodyBehindAppBar).
// • Floating DynamicIslandActions hovers above the bottom NavigationBar.

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:go_router/go_router.dart';

/// Top-level shell with persistent bottom navigation.
class MainShell extends StatelessWidget {
  /// Create the shell with a [StatefulNavigationShell] from go_router.
  const MainShell({super.key, required this.navigationShell});

  /// The navigation shell that owns the per-tab navigation stacks.
  final StatefulNavigationShell navigationShell;

  static const List<String> _tabTitles = <String>[
    'Главная',
    'Операции',
    'Аналитика',
    'Настройки',
  ];

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
      extendBody: true,
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: <Widget>[
            Text(
              _tabTitles[current],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF2F2F3),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0x1FFFFFFF),
                  width: 0.5,
                ),
              ),
              child: const Text(
                'OMNIFI OS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.4,
                  color: Color(0xFF8A8A93),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'Ещё',
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFFF2F2F3),
            ),
            onSelected: (String route) => context.push(route),
            color: const Color(0xFF14141A),
            itemBuilder: (BuildContext _) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: '/goals',
                child: ListTile(
                  leading: Icon(Icons.flag_outlined, color: Color(0xFFE5E5EA)),
                  title: Text(
                    'Цели',
                    style: TextStyle(color: Color(0xFFF2F2F3)),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: '/achievements',
                child: ListTile(
                  leading: Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFFFFB840),
                  ),
                  title: Text(
                    'Достижения',
                    style: TextStyle(color: Color(0xFFF2F2F3)),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: '/workspaces/new',
                child: ListTile(
                  leading: Icon(
                    Icons.workspaces_outline,
                    color: Color(0xFFE5E5EA),
                  ),
                  title: Text(
                    'Пространства',
                    style: TextStyle(color: Color(0xFFF2F2F3)),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: '/sms-sandbox',
                child: ListTile(
                  leading: Icon(
                    Icons.sms_outlined,
                    color: Color(0xFFE5E5EA),
                  ),
                  title: Text(
                    'SMS sandbox',
                    style: TextStyle(color: Color(0xFFF2F2F3)),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: '/notifications',
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFFE5E5EA),
                  ),
                  title: Text(
                    'Уведомления',
                    style: TextStyle(color: Color(0xFFF2F2F3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          navigationShell,
          // Floating glass action island hovering above the bottom nav.
          Positioned(
            left: 0,
            right: 0,
            bottom: 72, // above NavigationBar height
            child: DynamicIslandActions(
              actions: <IslandAction>[
                IslandAction(
                  icon: Icons.add,
                  label: 'Новая операция',
                  onTap: () => context.push('/transactions/add'),
                ),
                IslandAction(
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI-ассистент',
                  onTap: () => context.push('/ai-chat'),
                ),
                IslandAction(
                  icon: Icons.subscriptions_outlined,
                  label: 'Подписки',
                  onTap: () => context.push('/subscriptions'),
                ),
              ],
              pulsingIndex: 1, // AI assistant breathes
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xCC0A0A0C),
        indicatorColor: const Color(0x1FFFFFFF),
        surfaceTintColor: Colors.transparent,
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
    );
  }
}
