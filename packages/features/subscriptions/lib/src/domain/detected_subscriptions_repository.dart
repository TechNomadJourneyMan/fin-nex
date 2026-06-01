// Local mirror of the agreed `DetectedSubscriptionsRepository` contract.
//
// See `detected_subscription.dart` for why these shapes live inside the
// feature package. The interface is byte-for-byte the contract the UI is
// written against; the app overrides the providers with the real
// `pf_domain` implementation at composition time.

import 'package:pf_domain/domain.dart';

import 'detected_subscription.dart';

/// Read/write access to detected (auto-discovered) subscriptions.
abstract interface class DetectedSubscriptionsRepository {
  /// Streams all non-deleted detected subscriptions for [userId], newest
  /// state first; re-emits on change.
  Stream<List<DetectedSubscription>> watchAll(Ulid userId);

  /// Fetches a single subscription by [id], or null when absent/deleted.
  Future<DetectedSubscription?> getById(Ulid id);

  /// Inserts or updates [sub].
  Future<void> upsert(DetectedSubscription sub);

  /// Soft-deletes the subscription with [id].
  Future<void> softDelete(Ulid id);
}
