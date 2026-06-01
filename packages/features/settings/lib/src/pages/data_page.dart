// Settings → Data. Export (CSV/JSON) + delete-account.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

/// Data management page.
class DataPage extends ConsumerWidget {
  /// Default constructor.
  const DataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final router = GoRouter.maybeOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setData)),
      body: SafeArea(
        child: ListView(
          children: [
            PfListItem(
              leading: Icon(Icons.file_download_outlined,
                  color: colors.textSecondary),
              title: '${l10n.setExport} (CSV)',
              onTap: () => _toast(context, '${l10n.setExport} (CSV)'),
            ),
            PfListItem(
              leading: Icon(Icons.file_download_outlined,
                  color: colors.textSecondary),
              title: '${l10n.setExport} (JSON)',
              onTap: () => _toast(context, '${l10n.setExport} (JSON)'),
            ),
            const Divider(height: 1),
            PfListItem(
              leading: Icon(Icons.delete_outline, color: colors.error),
              title: l10n.setDeleteAccount,
              onTap: router == null
                  ? null
                  : () => router.push('/auth/delete-account'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    // TODO(F-EXPORT): wire to `ExportRepository` from `pf_domain`.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message — coming soon')),
    );
  }
}
