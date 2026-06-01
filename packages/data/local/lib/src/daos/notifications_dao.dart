import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/_helpers.dart';
import '../models/notification_row.dart';

/// Data access object for the `notifications` table.
class NotificationsDao {
  /// Wraps [db] for typed access to the `notifications` table.
  NotificationsDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'notifications';
  Database get _raw => db.raw;

  /// Inserts (or replaces) a notification row.
  Future<void> upsert(NotificationRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Lists unread, undismissed notifications for [userId] (newest first).
  Future<List<NotificationRow>> unread(String userId, {int? limit}) async {
    final rows = await _raw.query(
      _table,
      where: 'user_id = ? AND read_at IS NULL AND dismissed_at IS NULL',
      whereArgs: <Object?>[userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(NotificationRow.fromMap).toList(growable: false);
  }

  /// Watches the unread feed for [userId].
  Stream<List<NotificationRow>> watchUnread(String userId,
      {int? limit}) async* {
    yield await unread(userId, limit: limit);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await unread(userId, limit: limit);
    }
  }

  /// Marks [id] as read.
  Future<void> markRead(String id) async {
    await _raw.update(
      _table,
      <String, Object?>{'read_at': nowIso()},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }

  /// Marks [id] as dismissed.
  Future<void> dismiss(String id) async {
    await _raw.update(
      _table,
      <String, Object?>{'dismissed_at': nowIso()},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }
}
