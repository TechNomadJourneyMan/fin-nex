// Main app shell — OmniFi OS reskin.
//
// Adaptive navigation:
// • width <  600  → bottom NavigationBar (phone)
// • 600 ≤ w < 1200 → left NavigationRail (selected labels)
// • width ≥ 1200  → extended NavigationRail with overflow items merged in
//
// The DynamicIslandActions float above the bottom nav on phone, and collapse
// into an extended FAB on tablet+. AppBar uses translucent dark surface and
// keeps the brand wordmark.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_feedback/pf_core_feedback.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// Width below which the shell collapses to a bottom navigation bar.
@visibleForTesting
const double kShellRailBreakpoint = 600;

/// Width at and above which the shell expands the navigation rail and
/// merges the overflow menu items into the rail.
@visibleForTesting
const double kShellExtendedBreakpoint = 1200;

/// Top-level shell with persistent adaptive navigation.
class MainShell extends ConsumerWidget {
  /// Create the shell with a [StatefulNavigationShell] from go_router.
  const MainShell({super.key, required this.navigationShell});

  /// The navigation shell that owns the per-tab navigation stacks.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index, WidgetRef ref) {
    // Light selection haptic on every tab change. Sound is intentionally OFF
    // for navigation per the feedback spec — would be too chatty.
    if (index != navigationShell.currentIndex) {
      ref.read(feedbackServiceProvider).navigate();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final _ShellLayout layout;
        if (width >= kShellExtendedBreakpoint) {
          layout = _ShellLayout.extendedRail;
        } else if (width >= kShellRailBreakpoint) {
          layout = _ShellLayout.rail;
        } else {
          layout = _ShellLayout.bottomBar;
        }
        return _AdaptiveShell(
          layout: layout,
          navigationShell: navigationShell,
          onTap: (int idx) => _onTap(idx, ref),
        );
      },
    );
  }
}

enum _ShellLayout { bottomBar, rail, extendedRail }

class _AdaptiveShell extends StatelessWidget {
  const _AdaptiveShell({
    required this.layout,
    required this.navigationShell,
    required this.onTap,
  });

  final _ShellLayout layout;
  final StatefulNavigationShell navigationShell;
  final ValueChanged<int> onTap;

  static const Color _bg = Color(0xFF0A0A0C);
  static const Color _fg = Color(0xFFF2F2F3);

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final int current = navigationShell.currentIndex;
    final bool isPhone = layout == _ShellLayout.bottomBar;

    final List<_NavSpec> mainDestinations = <_NavSpec>[
      _NavSpec(
        label: l10n.navHome,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      _NavSpec(
        label: l10n.navTransactions,
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz,
      ),
      _NavSpec(
        label: l10n.navAnalytics,
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
      ),
      _NavSpec(
        label: l10n.navSettings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
      ),
    ];

    final List<_OverflowEntry> overflow = <_OverflowEntry>[
      _OverflowEntry(
        route: '/goals',
        label: l10n.menuGoals,
        icon: Icons.flag_outlined,
      ),
      _OverflowEntry(
        route: '/achievements',
        label: l10n.menuAchievements,
        icon: Icons.emoji_events_outlined,
      ),
      _OverflowEntry(
        route: '/workspaces/new',
        label: l10n.menuWorkspaces,
        icon: Icons.workspaces_outline,
      ),
      _OverflowEntry(
        route: '/sms-sandbox',
        label: l10n.menuSmsSandbox,
        icon: Icons.sms_outlined,
      ),
      _OverflowEntry(
        route: '/notifications',
        label: l10n.menuNotifications,
        icon: Icons.notifications_outlined,
      ),
    ];

    final String titleText = mainDestinations[current].label;

    // Only show the overflow menu in the AppBar when items aren't merged
    // into the extended rail.
    final bool showOverflowMenu = layout != _ShellLayout.extendedRail;

    final PreferredSizeWidget appBar = AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: <Widget>[
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _fg,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        if (showOverflowMenu)
          PopupMenuButton<String>(
            tooltip: l10n.menuMore,
            icon: const Icon(Icons.more_vert, color: _fg),
            onSelected: (String route) => context.push(route),
            color: const Color(0xFF14141A),
            itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
              for (final _OverflowEntry entry in overflow)
                PopupMenuItem<String>(
                  value: entry.route,
                  child: ListTile(
                    leading: Icon(
                      entry.icon,
                      color: const Color(0xFFE5E5EA),
                    ),
                    title: Text(
                      entry.label,
                      style: const TextStyle(color: _fg),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );

    final Widget islandActions = DynamicIslandActions(
      expanded: !isPhone,
      pulsingIndex: 1,
      actions: <IslandAction>[
        IslandAction(
          icon: Icons.add,
          label: l10n.dashFab,
          onTap: () => context.push('/transactions/add'),
        ),
        IslandAction(
          icon: Icons.auto_awesome_outlined,
          label: 'AI',
          onTap: () => context.push('/ai-chat'),
        ),
        IslandAction(
          icon: Icons.subscriptions_outlined,
          label: l10n.subsTitle,
          onTap: () => context.push('/subscriptions'),
        ),
      ],
    );

    // Wrap the navigationShell in a PageTransitionSwitcher so tab swaps fade
    // across the horizontal shared axis. The child is keyed by the current
    // tab index so PageTransitionSwitcher detects the change.
    final Duration tabDuration = PfMotion.effective(context, PfMotion.base);
    final Widget animatedShell = PageTransitionSwitcher(
      duration: tabDuration,
      reverse: false,
      transitionBuilder: (
        Widget child,
        Animation<double> primary,
        Animation<double> secondary,
      ) {
        return SharedAxisTransition(
          animation: primary,
          secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: _bg,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(current),
        child: navigationShell,
      ),
    );

    // Body content: animatedShell with the floating island on phone, or a
    // non-floating action bar on tablet/desktop.
    final Widget body = isPhone
        ? Stack(
            children: <Widget>[
              animatedShell,
              Positioned(
                left: 0,
                right: 0,
                bottom: 72, // above NavigationBar height
                child: islandActions,
              ),
            ],
          )
        : Stack(
            children: <Widget>[
              animatedShell,
              Positioned(
                right: 16,
                bottom: 16,
                child: islandActions,
              ),
            ],
          );

    // Bottom navigation region wrapped in AnimatedSwitcher so breakpoint
    // crossings cross-fade with PfMotion.base.
    final Widget? bottomNav = isPhone
        ? AnimatedSwitcher(
            duration: PfMotion.base,
            switchInCurve: PfMotion.standard,
            switchOutCurve: PfMotion.accelerated,
            child: NavigationBar(
              key: const ValueKey<String>('shell.bottom-bar'),
              backgroundColor: const Color(0xCC0A0A0C),
              indicatorColor: const Color(0x1FFFFFFF),
              surfaceTintColor: Colors.transparent,
              selectedIndex: current,
              onDestinationSelected: onTap,
              destinations: <NavigationDestination>[
                for (final _NavSpec spec in mainDestinations)
                  NavigationDestination(
                    icon: Icon(spec.icon),
                    selectedIcon: Icon(spec.selectedIcon),
                    label: spec.label,
                  ),
              ],
            ),
          )
        : null;

    if (isPhone) {
      return Scaffold(
        extendBody: true,
        backgroundColor: _bg,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNav,
      );
    }

    // Tablet / desktop: rail on the left, body on the right.
    final bool extended = layout == _ShellLayout.extendedRail;
    final Widget rail = _AdaptiveRail(
      key: ValueKey<String>(
        'shell.rail.${extended ? 'extended' : 'collapsed'}',
      ),
      extended: extended,
      currentIndex: current,
      destinations: mainDestinations,
      overflow: extended ? overflow : const <_OverflowEntry>[],
      onTap: onTap,
      onOverflowTap: (String route) => context.push(route),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: appBar,
      body: Row(
        children: <Widget>[
          AnimatedSwitcher(
            duration: PfMotion.base,
            switchInCurve: PfMotion.standard,
            switchOutCurve: PfMotion.accelerated,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: rail,
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0x14FFFFFF),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _AdaptiveRail extends StatelessWidget {
  const _AdaptiveRail({
    super.key,
    required this.extended,
    required this.currentIndex,
    required this.destinations,
    required this.overflow,
    required this.onTap,
    required this.onOverflowTap,
  });

  final bool extended;
  final int currentIndex;
  final List<_NavSpec> destinations;
  final List<_OverflowEntry> overflow;
  final ValueChanged<int> onTap;
  final ValueChanged<String> onOverflowTap;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: const Color(0xFF0A0A0C),
      extended: extended,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: extended ? null : NavigationRailLabelType.selected,
      indicatorColor: const Color(0x1FFFFFFF),
      destinations: <NavigationRailDestination>[
        for (final _NavSpec spec in destinations)
          NavigationRailDestination(
            icon: Icon(spec.icon),
            selectedIcon: Icon(spec.selectedIcon),
            label: Text(spec.label),
          ),
      ],
      trailing: overflow.isEmpty
          ? null
          : SizedBox(
              // Match the default extended/collapsed rail width so the inner
              // Row children get a finite width constraint.
              width: extended ? 256 : 72,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0x14FFFFFF),
                      indent: 12,
                      endIndent: 12,
                    ),
                    const SizedBox(height: 8),
                    for (final _OverflowEntry entry in overflow)
                      _RailOverflowTile(
                        entry: entry,
                        extended: extended,
                        onTap: () => onOverflowTap(entry.route),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RailOverflowTile extends StatelessWidget {
  const _RailOverflowTile({
    required this.entry,
    required this.extended,
    required this.onTap,
  });

  final _OverflowEntry entry;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color fg = Color(0xFFE5E5EA);
    final Widget content = extended
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(entry.icon, color: fg, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.label,
                    style: const TextStyle(
                      color: Color(0xFFF2F2F3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Icon(entry.icon, color: fg, size: 22),
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _OverflowEntry {
  const _OverflowEntry({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}
