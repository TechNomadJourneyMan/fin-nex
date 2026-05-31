import 'package:flutter/foundation.dart';
import 'package:fnx_domain/domain.dart';

/// A single AI chat conversation.
@immutable
class ChatSession {
  /// Default constructor.
  const ChatSession({required this.id, required this.createdAt});

  /// Stable identifier.
  final Ulid id;

  /// Creation moment (UTC).
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is ChatSession && other.id == id && other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, createdAt);
}
