// Main app shell — OmniFi OS reskin.
//
// Adaptive navigation:
// • width <  600  → bottom NavigationBar (phone)
// • 600 ≤ w < 1200 → left NavigationRail (selected labels)
// • width ≥ 1200  → extended NavigationRail with overflow items merged in
//
// Quick actions (Add / AI / Subscriptions): on phone a single FAB opens them
// as a popup bottom sheet (so nothing floats over content); on tablet+ they
// stay as a docked island in the bottom-right corner. AppBar uses a translucent
// dark surface and keeps the brand wordmark.

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

    final List<IslandAction> islandActionList = <IslandAction>[
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
    ];

    // Desktop/tablet keep the always-visible docked island in the corner — it
    // has room and never overlaps content. Phones get a single FAB that opens
    // the actions as a popup (see [floatingActionButton] below), so the bar no
    // longer floats over the screen.
    final Widget islandActions = DynamicIslandActions(
      expanded: !isPhone,
      pulsingIndex: 1,
      actions: islandActionList,
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

    // Body content. On phone the actions live behind a single FAB that opens a
    // popup (see [floatingActionButton] on the phone Scaffold below), so nothing
    // floats over the content. On tablet/desktop the docked island sits in the
    // bottom-right corner where it never overlaps the body.
    final Widget body = isPhone
        ? animatedShell
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
        floatingActionButton: _QuickActionsFab(
          actions: islandActionList,
          onPressed: () => _showQuickActionsSheet(context, islandActionList),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

/// Shows the quick actions (Add / AI / Subscriptions) as a popup bottom sheet.
///
/// Used on phone where a persistent floating bar would cover content. The
/// sheet animates its rows in with a short staggered scale/slide and routes
/// through the same [IslandAction.onTap] callbacks as the desktop docked bar.
Future<void> _showQuickActionsSheet(
  BuildContext context,
  List<IslandAction> actions,
) async {
  // Light haptic on open. The provider is read lazily so tests without an
  // override still work (FeedbackService no-ops when unconfigured).
  final container = ProviderScope.containerOf(context, listen: false);
  container.read(feedbackServiceProvider).selectTap();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return _QuickActionsSheet(
        actions: actions,
        reduceMotion: MediaQuery.disableAnimationsOf(sheetContext),
      );
    },
  );
}

/// The animated content of the quick-actions popup.
class _QuickActionsSheet extends StatefulWidget {
  const _QuickActionsSheet({required this.actions, required this.reduceMotion});

  final List<IslandAction> actions;
  final bool reduceMotion;

  @override
  State<_QuickActionsSheet> createState() => _QuickActionsSheetState();
}

class _QuickActionsSheetState extends State<_QuickActionsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.reduceMotion ? Duration.zero : PfMotion.base,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.viewPaddingOf(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.only(bottom: safe.bottom > 0 ? 0 : 4),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            // Grab handle.
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < widget.actions.length; i++)
              _buildRow(context, widget.actions[i], i),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, IslandAction action, int index) {
    final int count = widget.actions.length;
    final double start = count <= 1 ? 0 : (index / count) * 0.5;
    final Animation<double> anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start,
        (start + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(anim),
        child: Semantics(
          button: true,
          label: action.label,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).pop();
              action.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: <Widget>[
                  Icon(action.icon, color: const Color(0xFFE5E5EA), size: 24),
                  const SizedBox(width: 16),
                  Text(
                    action.label,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F7),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The single phone FAB that opens the quick-actions popup. Shows the primary
/// "+" glyph; the [actions] are surfaced in the sheet, not on the button.
class _QuickActionsFab extends StatelessWidget {
  const _QuickActionsFab({required this.actions, required this.onPressed});

  final List<IslandAction> actions;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Quick actions',
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add),
      ),
    );
  }
}
