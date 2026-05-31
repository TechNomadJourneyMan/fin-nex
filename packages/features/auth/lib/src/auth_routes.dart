// go_router routes for the auth feature.

import 'package:go_router/go_router.dart';

import 'pages/biometric_unlock_page.dart';
import 'pages/delete_account_page.dart';
import 'pages/phone_otp_page.dart';
import 'pages/session_devices_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';

/// All auth-feature routes. Mount under the root [GoRouter].
List<RouteBase> authRoutes() => <RouteBase>[
      GoRoute(
        path: '/auth/sign-in',
        name: 'auth.signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        name: 'auth.signUp',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'auth.otp',
        builder: (context, state) => const PhoneOtpPage(),
      ),
      GoRoute(
        path: '/auth/biometric',
        name: 'auth.biometric',
        builder: (context, state) => const BiometricUnlockPage(),
      ),
      GoRoute(
        path: '/auth/devices',
        name: 'auth.devices',
        builder: (context, state) => const SessionDevicesPage(),
      ),
      GoRoute(
        path: '/auth/delete',
        name: 'auth.delete',
        builder: (context, state) => const DeleteAccountPage(),
      ),
    ];
