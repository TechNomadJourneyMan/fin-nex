// Settings → Profile. Shows the name, the (read-only) email, and a
// "change password" CTA. The CTA is a placeholder until the auth feature
// publishes a dedicated flow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:go_router/go_router.dart';

/// Profile page (read-only summary + change-password CTA).
class ProfilePage extends ConsumerStatefulWidget {
  /// Default constructor.
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Pocket Flow User');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.setProfile)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: colors.brandSubtle,
                child: Icon(Icons.person, size: 36, color: colors.brand),
              ),
            ),
            const SizedBox(height: 24),
            Text('Name', style: typo.bodySm.copyWith(color: colors.textMuted)),
            const SizedBox(height: 4),
            TextField(controller: _name),
            const SizedBox(height: 16),
            Text('Email', style: typo.bodySm.copyWith(color: colors.textMuted)),
            const SizedBox(height: 4),
            TextField(
              enabled: false,
              controller: TextEditingController(text: 'you@example.com'),
            ),
            const SizedBox(height: 24),
            PfButton(
              label: l10n.setSignOut,
              onPressed: () {
                // TODO(F-AUTH-WIRE): route into the auth sign-out flow.
                GoRouter.maybeOf(context)?.go('/auth');
              },
              variant: PfButtonVariant.secondary,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            PfButton(
              label: l10n.setDeleteAccount,
              onPressed: () =>
                  GoRouter.maybeOf(context)?.push('/auth/delete-account'),
              variant: PfButtonVariant.destructive,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
