import 'package:flutter/foundation.dart';
import 'package:fnx_domain/domain.dart';

import 'widget_spec.dart';

/// Who authored a [ChatMessage].
enum ChatSender {
  /// The user typed it.
  user,

  /// The AI assistant produced it.
  ai,
}

/// A single conversation turn within a [ChatSession].
@immutable
class ChatMessage {
  /// Default constructor.
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.content,
    required this.createdAt,
    this.widgets = const <WidgetSpec>[],
  });

  /// Stable identifier.
  final Ulid id;

  /// Owning session.
  final Ulid sessionId;

  /// Author.
  final ChatSender sender;

  /// Markdown body text.
  final String content;

  /// Inline data widgets attached to this (AI) message.
  final List<WidgetSpec> widgets;

  /// Creation moment (UTC).
  final DateTime createdAt;

  /// Returns a copy with [content] replaced (used while streaming chunks).
  ChatMessage copyWith({
    String? content,
    List<WidgetSpec>? widgets,
  }) =>
      ChatMessage(
        id: id,
        sessionId: sessionId,
        sender: sender,
        content: content ?? this.content,
        widgets: widgets ?? this.widgets,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      other is ChatMessage &&
      other.id == id &&
      other.sessionId == sessionId &&
      other.sender == sender &&
      other.content == content &&
      listEquals(other.widgets, widgets) &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        sessionId,
        sender,
        content,
        Object.hashAll(widgets),
        createdAt,
      );
}
