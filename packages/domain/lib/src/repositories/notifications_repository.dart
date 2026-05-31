import '../entities/notification.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [AppNotification].
abstract interface class NotificationsRepository {
  /// Live list of notifications for [userId].
  Stream<List<AppNotification>> watchAll(Ulid userId);

  /// Snapshot list.
  Future<List<AppNotification>> list(Ulid userId);

  /// Marks [id] as read.
  Future<void> markRead(Ulid id);

  /// Marks [id] as dismissed.
  Future<void> dismiss(Ulid id);
}
