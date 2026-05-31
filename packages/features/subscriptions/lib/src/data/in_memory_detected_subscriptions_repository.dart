// Volatile, in-memory implementation of [DetectedSubscriptionsRepository].
//
// Web-safe; used as the default until the data layer wires real persistence,
// and as the stub backing widget tests.

import 'dart:async';

import 'package:fnx_domain/domain.dart';

import '../domain/detected_subscription.dart';
import '../domain/detected_subscriptions_repository.dart';

/// Simple in-process [DetectedSubscriptionsRepository].
class InMemoryDetectedSubscriptionsRepository
    implements DetectedSubscriptionsRepository {
  /// Creates a repository optionally seeded with [seed].
  InMemoryDetectedSubscriptionsRepository([
    List<DetectedSubscription> seed = const <DetectedSubscription>[],
  ]) : _subs = List<DetectedSubscription>.of(seed);

  final List<DetectedSubscription> _subs;
  final StreamController<List<DetectedSubscription>> _ctrl =
      StreamController<List<DetectedSubscription>>.broadcast();

  List<DetectedSubscription> get _active =>
      _subs.where((s) => s.deletedAt == null).toList();

  void _emit() => _ctrl.add(List<DetectedSubscription>.unmodifiable(_active));

  @override
  Stream<List<DetectedSubscription>> watchAll(Ulid userId) async* {
    yield List<DetectedSubscription>.unmodifiable(
      _active.where((s) => s.userId == userId).toList(),
    );
    yield* _ctrl.stream.map(
      (list) => list.where((s) => s.userId == userId).toList(),
    );
  }

  @override
  Future<DetectedSubscription?> getById(Ulid id) async {
    for (final s in _subs) {
      if (s.id == id && s.deletedAt == null) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(DetectedSubscription sub) async {
    final i = _subs.indexWhere((s) => s.id == sub.id);
    if (i >= 0) {
      _subs[i] = sub;
    } else {
      _subs.add(sub);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    final i = _subs.indexWhere((s) => s.id == id);
    if (i < 0) {
      return;
    }
    _subs[i] = _subs[i].copyWith(deletedAt: DateTime.now().toUtc());
    _emit();
  }

  /// Releases the broadcast controller.
  Future<void> dispose() async {
    await _ctrl.close();
  }
}
