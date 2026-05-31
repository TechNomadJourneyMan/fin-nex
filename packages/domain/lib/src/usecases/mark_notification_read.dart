import '../repositories/notifications_repository.dart';
import '../values/ulid.dart';

/// Marks a notification as read.
class MarkNotificationRead {
  /// Default constructor.
  const MarkNotificationRead(this._repo);

  final NotificationsRepository _repo;

  /// Invokes the use case.
  Future<void> call(Ulid id) => _repo.markRead(id);
}
