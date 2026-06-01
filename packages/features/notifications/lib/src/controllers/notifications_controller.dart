import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import '../models/notification_preferences.dart';
import '../models/notification_type.dart';
import '../services/notifications_service.dart';

/// In-memory repository used by the feature when no real backend store is
/// available yet. Mirrors the [NotificationsRepository] contract.
class InMemoryNotificationsRepository implements NotificationsRepository {
  /// Seeds with [seed] (defaults to empty).
  InMemoryNotificationsRepository([List<AppNotification>? seed])
      : _items = <AppNotification>[...?seed];

  final List<AppNotification> _items;
  final List<void Function()> _listeners = <void Function()>[];

  void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Inserts a notification (used by the controller and tests).
  void insert(AppNotification n) {
    _items.insert(0, n);
    _notify();
  }

  @override
  Stream<List<AppNotification>> watchAll(Ulid userId) {
    final controller = StreamController<List<AppNotification>>(sync: true);
    void emit() => controller.add(_snapshot(userId));
    _listeners.add(emit);
    emit();
    controller.onCancel = () {
      _listeners.remove(emit);
    };
    return controller.stream;
  }

  List<AppNotification> _snapshot(Ulid userId) =>
      _items.where((n) => n.userId == userId).toList(growable: false);

  @override
  Future<List<AppNotification>> list(Ulid userId) async => _snapshot(userId);

  @override
  Future<void> markRead(Ulid id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) {
      return;
    }
    _items[idx] = _items[idx].copyWith(readAt: DateTime.now().toUtc());
    _notify();
  }

  @override
  Future<void> dismiss(Ulid id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) {
      return;
    }
    _items[idx] = _items[idx].copyWith(dismissedAt: DateTime.now().toUtc());
    _notify();
  }
}

/// Immutable view-state for the notifications center page.
@immutable
class NotificationsState {
  /// Default constructor.
  const NotificationsState({
    required this.items,
    this.isLoading = false,
  });

  /// Empty initial state.
  const NotificationsState.initial()
      : items = const <AppNotification>[],
        isLoading = true;

  /// Currently visible notifications (newest first).
  final List<AppNotification> items;

  /// Whether a load is in flight.
  final bool isLoading;

  /// Convenience copy.
  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
      );

  /// Total unread items.
  int get unreadCount => items.where((n) => n.isUnread).length;
}

/// Controller for the notifications center.
class NotificationsController extends StateNotifier<NotificationsState> {
  /// Default constructor.
  NotificationsController({
    required NotificationsRepository repository,
    required Ulid userId,
  })  : _repository = repository,
        _userId = userId,
        super(const NotificationsState.initial()) {
    _subscription = _repository.watchAll(_userId).listen((items) {
      state = state.copyWith(items: items, isLoading: false);
    });
  }

  final NotificationsRepository _repository;
  final Ulid _userId;
  StreamSubscription<List<AppNotification>>? _subscription;

  /// Marks [id] as read.
  Future<void> markRead(Ulid id) => _repository.markRead(id);

  /// Dismisses [id].
  Future<void> dismiss(Ulid id) => _repository.dismiss(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// State for the per-type preference toggles.
class PreferencesController extends StateNotifier<NotificationPreferences> {
  /// Default constructor.
  PreferencesController({
    NotificationPreferences? initial,
    NotificationsService? service,
  })  : _service = service,
        super(initial ?? NotificationPreferences.defaults());

  final NotificationsService? _service;

  /// Toggles [type] to [value]. When disabling, cancels any scheduled
  /// notifications associated with the type (best-effort).
  Future<void> setEnabled(
    NotificationPreferenceType type,
    bool value,
  ) async {
    state = state.setEnabled(type, value);
    if (!value) {
      await _service?.cancel(_scheduledIdFor(type));
    }
  }

  /// Stable per-type id used for scheduling.
  int _scheduledIdFor(NotificationPreferenceType type) =>
      type.index + 1000; // namespace away from arbitrary ids
}
