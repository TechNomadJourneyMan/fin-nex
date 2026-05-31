// Onboarding go_router routes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/first_transaction_prompt_page.dart';
import 'pages/grant_permissions_page.dart';
import 'pages/setup_first_account_page.dart';
import 'pages/value_props_page.dart';
import 'pages/welcome_page.dart';

/// Top-level path for the onboarding flow.
const String kOnboardingPath = '/onboarding';

/// Build the onboarding subtree for `go_router`.
///
/// [onTryFirstTransaction] is forwarded to the final page so the host app
/// can decide how to open the quick-add sheet (e.g. via the transactions
/// feature). When null, the page falls back to `context.go('/transactions/add')`.
List<RouteBase> buildOnboardingRoutes({
  void Function(BuildContext context)? onTryFirstTransaction,
}) {
  return [
    GoRoute(
      path: kOnboardingPath,
      builder: (context, state) => const WelcomePage(),
      routes: [
        GoRoute(
          path: 'value-props',
          builder: (context, state) => const ValuePropsPage(),
        ),
        GoRoute(
          path: 'setup-account',
          builder: (context, state) => const SetupFirstAccountPage(),
        ),
        GoRoute(
          path: 'permissions',
          builder: (context, state) => const GrantPermissionsPage(),
        ),
        GoRoute(
          path: 'first-transaction',
          builder: (context, state) => FirstTransactionPromptPage(
            onTryNow: onTryFirstTransaction,
          ),
        ),
      ],
    ),
  ];
}
