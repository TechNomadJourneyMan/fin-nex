// Riverpod providers for the subscriptions manager feature (F-04).
//
// The repository and user-id providers throw by default and MUST be overridden
// in app composition (apps/finnex/lib/providers.dart) with the real
// `fnx_domain` implementation and the authenticated user id. The stream
// provider derives from them so pages can `ref.watch` a live list.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import 'domain/detected_subscription.dart';
import 'domain/detected_subscriptions_repository.dart';

/// Active [DetectedSubscriptionsRepository].
///
/// Throws until overridden in app composition.
final detectedSubscriptionsRepositoryProvider =
    Provider<DetectedSubscriptionsRepository>((ref) {
  throw UnimplementedError(
    'detectedSubscriptionsRepositoryProvider must be overridden in the app '
    'composition layer (apps/finnex/lib/providers.dart).',
  );
});

/// Authenticated user id whose subscriptions are shown.
///
/// Throws until overridden by the auth feature in app composition.
final subscriptionsUserIdProvider = Provider<Ulid>((ref) {
  throw UnimplementedError(
    'subscriptionsUserIdProvider must be overridden in the app composition '
    'layer with the authenticated user id.',
  );
});

/// Streams all active detected subscriptions for the current user.
final detectedSubscriptionsStreamProvider =
    StreamProvider<List<DetectedSubscription>>((ref) {
  final repo = ref.watch(detectedSubscriptionsRepositoryProvider);
  final userId = ref.watch(subscriptionsUserIdProvider);
  return repo.watchAll(userId);
});
