// Top-bar workspace-switcher pill (F-06 client).
//
// Shows the active workspace's name + color dot. Tapping opens a bottom sheet
// that lists every workspace with a checkmark on the active one, lets the user
// tap-to-switch, and offers a "Create workspace" CTA.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../theme/workspace_theme_overlay.dart';
import '../workspaces_routes.dart';

/// A compact pill, meant to sit in a top bar, showing the active workspace's
/// color dot + name. Tapping opens the workspace picker bottom sheet.
class WorkspaceSwitcher extends ConsumerWidget {
  /// Creates the switcher pill.
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;
    final radii = context.fnxRadii;
    final workspace = ref.watch(activeWorkspaceEntityProvider);

    final String name = workspace?.name ?? '—';
    final Color dot =
        workspace == null ? colors.textMuted : workspaceAccentColor(workspace);

    return Semantics(
      button: true,
      label: 'Workspace: $name. Tap to switch.',
      child: Material(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(radii.full),
        child: InkWell(
          borderRadius: BorderRadius.circular(radii.full),
          onTap: () => showWorkspaceSwitcherSheet(context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s4,
              vertical: spacing.s3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ColorDot(color: dot),
                SizedBox(width: spacing.s3),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    name,
                    style: typo.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing.s2),
                Icon(
                  Icons.expand_more,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the workspace picker bottom sheet.
Future<void> showWorkspaceSwitcherSheet(BuildContext context) {
  return showFnxBottomSheet<void>(
    context: context,
    semanticLabel: 'Workspaces',
    builder: (ctx) => const WorkspaceSwitcherSheet(),
  );
}

/// Body of the workspace picker bottom sheet: a list of workspaces with a
/// checkmark on the active one, plus a "Create workspace" CTA.
class WorkspaceSwitcherSheet extends ConsumerWidget {
  /// Creates the sheet body.
  const WorkspaceSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;
    final activeId = ref.watch(activeWorkspaceProvider);
    final async = ref.watch(workspacesStreamProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s5,
        spacing.s3,
        spacing.s5,
        spacing.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.s2),
            child: Text('Workspaces', style: typo.heading2),
          ),
          SizedBox(height: spacing.s3),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.s4),
              child: Text('$e', style: TextStyle(color: colors.error)),
            ),
            data: (List<Workspace> list) {
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.s5),
                  child: Text(
                    'No workspaces yet.',
                    style: typo.bodyMd.copyWith(color: colors.textSecondary),
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final Workspace w in list)
                    _WorkspaceRow(
                      workspace: w,
                      selected: w.id == activeId,
                      onTap: () {
                        ref.read(activeWorkspaceProvider.notifier).select(w.id);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              );
            },
          ),
          SizedBox(height: spacing.s4),
          FnxButton(
            label: 'Create workspace',
            leadingIcon: Icons.add,
            fullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(kCreateWorkspacePath);
            },
          ),
        ],
      ),
    );
  }
}

class _WorkspaceRow extends StatelessWidget {
  const _WorkspaceRow({
    required this.workspace,
    required this.selected,
    required this.onTap,
  });

  final Workspace workspace;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return FnxListItem(
      leading: _ColorDot(color: workspaceAccentColor(workspace), size: 14),
      title: workspace.name,
      subtitle: workspace.type == WorkspaceType.business
          ? 'Business · ${workspace.baseCurrency.code}'
          : 'Personal · ${workspace.baseCurrency.code}',
      trailing: selected ? Icon(Icons.check, color: colors.brand) : null,
      semanticLabel: '${workspace.name}${selected ? ', selected' : ''}',
      onTap: onTap,
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
