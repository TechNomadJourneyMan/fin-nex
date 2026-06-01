// Limits list page — sibling of budgets but with escalation semantics.
//
// PRD distinguishes "budgets" (planned envelopes that progress fills) from
// "limits" (defensive guards that escalate). This page lists the latter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import '../controllers/budgets_controller.dart';

/// Lists the user's defensive [Limit] guards.
class LimitsListPage extends ConsumerWidget {
  /// Creates the page.
  const LimitsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final state = ref.watch(limitsControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Limits')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('$e', style: TextStyle(color: colors.error))),
        data: (limits) {
          if (limits.isEmpty) {
            return PfEmptyState(
              icon: Icons.shield_outlined,
              title: l10n.budgetsEmpty,
              body: l10n.budgetsCreate,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(spacing.s5),
            itemCount: limits.length,
            separatorBuilder: (_, __) => SizedBox(height: spacing.s3),
            itemBuilder: (context, i) {
              final l = limits[i];
              final typo = context.fnxTypography;
              return Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(context.fnxRadii.r4),
                child: Padding(
                  padding: EdgeInsets.all(spacing.s5),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.shield_outlined,
                          color: colors.warning),
                      SizedBox(width: spacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(l.name,
                                style: typo.bodyLg.copyWith(
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: spacing.s1),
                            Text(
                              '${l.scope} · ${l.period.code} · '
                              '${l.severity.code}',
                              style: typo.bodySm
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
