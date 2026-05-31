// Create-workspace form (F-06 client).
//
// Collects: name, type (personal / business), base currency, accent color,
// and an icon key. On save, builds a [Workspace], upserts it through the
// repository, and selects it as the active workspace.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../theme/workspace_theme_overlay.dart';

/// Selectable accent color swatches offered on the create form.
const List<String> kWorkspaceColorSwatches = <String>[
  '#3D5AFE', // Tech Dark Blue (personal default)
  '#00A87D', // Tech Emerald Green (business default)
  '#7C4DFF', // Violet
  '#FF6D00', // Orange
  '#D9342B', // Red
  '#0066CC', // Blue
  '#00B8D4', // Cyan
  '#E89500', // Amber
];

/// Selectable icon keys offered on the create form. Each maps to a Material
/// icon via [workspaceIconData].
const List<String> kWorkspaceIconKeys = <String>[
  'wallet',
  'business',
  'home',
  'savings',
  'travel',
  'family',
];

/// Maps a workspace [iconKey] to a Material [IconData]. Falls back to a
/// generic wallet icon for unknown keys.
IconData workspaceIconData(String? iconKey) {
  switch (iconKey) {
    case 'business':
      return Icons.business_center_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'savings':
      return Icons.savings_outlined;
    case 'travel':
      return Icons.flight_takeoff_outlined;
    case 'family':
      return Icons.family_restroom_outlined;
    case 'wallet':
    default:
      return Icons.account_balance_wallet_outlined;
  }
}

/// Form page that creates a new workspace.
class CreateWorkspacePage extends ConsumerStatefulWidget {
  /// Creates the page.
  const CreateWorkspacePage({super.key});

  @override
  ConsumerState<CreateWorkspacePage> createState() =>
      _CreateWorkspacePageState();
}

class _CreateWorkspacePageState extends ConsumerState<CreateWorkspacePage> {
  final TextEditingController _name = TextEditingController();
  WorkspaceType _type = WorkspaceType.personal;
  Currency _currency = Currency.kzt;
  String _colorHex = kWorkspaceColorSwatches.first;
  String _iconKey = kWorkspaceIconKeys.first;
  bool _saving = false;
  bool _showNameError = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// When the user switches type, nudge the default accent to the PRD color
  /// unless they've already picked a non-default swatch.
  void _onTypeChanged(WorkspaceType type) {
    setState(() {
      _type = type;
      if (_colorHex == '#3D5AFE' || _colorHex == '#00A87D') {
        _colorHex = type == WorkspaceType.business ? '#00A87D' : '#3D5AFE';
      }
      if (_iconKey == 'wallet' || _iconKey == 'business') {
        _iconKey = type == WorkspaceType.business ? 'business' : 'wallet';
      }
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    setState(() => _saving = true);

    final now = DateTime.now().toUtc();
    final userId = ref.read(workspacesCurrentUserIdProvider);
    final workspace = Workspace(
      id: Ulid.now(),
      userId: userId,
      name: name,
      type: _type,
      baseCurrency: _currency,
      colorHex: _colorHex,
      iconKey: _iconKey,
      createdAt: now,
      updatedAt: now,
      isDefault: false,
    );

    await ref.read(workspacesRepositoryProvider).upsert(workspace);
    ref.read(activeWorkspaceProvider.notifier).select(workspace.id);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Create workspace')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(spacing.s5),
          children: <Widget>[
            FnxTextField(
              label: 'Name',
              hint: 'e.g. Personal, Acme LLC',
              controller: _name,
              autofocus: true,
              errorText: _showNameError ? 'Enter a name' : null,
              onChanged: (_) {
                if (_showNameError) {
                  setState(() => _showNameError = false);
                }
              },
            ),
            SizedBox(height: spacing.s5),
            Text(
              'Type',
              style: typo.bodySm.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s3),
            FnxSegmentedControl<WorkspaceType>(
              value: _type,
              segments: const <WorkspaceType, String>{
                WorkspaceType.personal: 'Personal',
                WorkspaceType.business: 'Business',
              },
              onChanged: _onTypeChanged,
            ),
            SizedBox(height: spacing.s5),
            FnxSelect<Currency>(
              label: 'Base currency',
              value: _currency,
              options: <FnxSelectOption<Currency>>[
                for (final Currency c in Currency.values)
                  FnxSelectOption<Currency>(
                    value: c,
                    label: '${c.code} ${c.symbol}',
                  ),
              ],
              onChanged: (Currency? c) {
                if (c != null) {
                  setState(() => _currency = c);
                }
              },
            ),
            SizedBox(height: spacing.s5),
            Text(
              'Color',
              style: typo.bodySm.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s3),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final String hex in kWorkspaceColorSwatches)
                  _ColorSwatch(
                    hex: hex,
                    selected: hex == _colorHex,
                    onTap: () => setState(() => _colorHex = hex),
                  ),
              ],
            ),
            SizedBox(height: spacing.s5),
            Text(
              'Icon',
              style: typo.bodySm.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s3),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final String key in kWorkspaceIconKeys)
                  _IconChoice(
                    iconKey: key,
                    accent: workspaceColorFromHex(
                      _colorHex,
                      fallback: colors.brand,
                    ),
                    selected: key == _iconKey,
                    onTap: () => setState(() => _iconKey = key),
                  ),
              ],
            ),
            SizedBox(height: spacing.s7),
            FnxButton(
              label: 'Create',
              fullWidth: true,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            SizedBox(height: spacing.s3),
            FnxButton(
              label: 'Cancel',
              variant: FnxButtonVariant.secondary,
              fullWidth: true,
              onPressed: _saving ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final color = workspaceColorFromHex(hex, fallback: colors.brand);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Color $hex',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.iconKey,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String iconKey;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Icon $iconKey',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? accent : colors.surfaceSunken,
            borderRadius: BorderRadius.circular(context.fnxRadii.r3),
            border: Border.all(
              color: selected ? accent : colors.borderDefault,
            ),
          ),
          child: Icon(
            workspaceIconData(iconKey),
            size: 22,
            color: selected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
