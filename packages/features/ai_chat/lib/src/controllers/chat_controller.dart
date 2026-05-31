import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../entities/widget_spec.dart';
import '../services/ai_chat_service.dart';

/// Immutable view-state for the AI chat page.
@immutable
class ChatState {
  /// Default constructor.
  const ChatState({
    required this.session,
    required this.messages,
    this.isResponding = false,
  });

  /// The active conversation.
  final ChatSession session;

  /// Messages in chronological order.
  final List<ChatMessage> messages;

  /// Whether the AI is currently streaming a reply.
  final bool isResponding;

  /// Convenience copy.
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isResponding,
  }) =>
      ChatState(
        session: session,
        messages: messages ?? this.messages,
        isResponding: isResponding ?? this.isResponding,
      );
}

/// Holds the active [ChatSession] and its message list and drives [submit].
///
/// Implemented as an [AsyncNotifier]: [build] creates a fresh session, and
/// [submit] appends the user message, then streams the assistant reply,
/// rebuilding the list as chunks arrive.
class ChatController extends AsyncNotifier<ChatState> {
  /// Injected so tests can supply a deterministic service. The default reads
  /// [aiChatServiceProvider].
  ChatController({AiChatService? service, Ulid Function()? idFactory})
      : _injectedService = service,
        _idFactory = idFactory ?? Ulid.now;

  final AiChatService? _injectedService;
  final Ulid Function() _idFactory;

  AiChatService get _service =>
      _injectedService ?? ref.read(aiChatServiceProvider);

  @override
  Future<ChatState> build() async {
    final session = ChatSession(
      id: _idFactory(),
      createdAt: DateTime.now().toUtc(),
    );
    return ChatState(session: session, messages: const <ChatMessage>[]);
  }

  /// Sends [text] as a user message and streams the AI reply.
  ///
  /// No-ops on blank input or while a reply is already in flight.
  Future<void> submit(String text) async {
    final trimmed = text.trim();
    final current = state.valueOrNull;
    if (trimmed.isEmpty || current == null || current.isResponding) {
      return;
    }

    final session = current.session;
    final userMessage = ChatMessage(
      id: _idFactory(),
      sessionId: session.id,
      sender: ChatSender.user,
      content: trimmed,
      createdAt: DateTime.now().toUtc(),
    );

    final aiMessage = ChatMessage(
      id: _idFactory(),
      sessionId: session.id,
      sender: ChatSender.ai,
      content: '',
      createdAt: DateTime.now().toUtc(),
    );

    // Append user + empty AI placeholder, mark responding.
    state = AsyncData(
      current.copyWith(
        messages: <ChatMessage>[...current.messages, userMessage, aiMessage],
        isResponding: true,
      ),
    );

    final buffer = StringBuffer();
    final widgets = <WidgetSpec>[];
    try {
      await for (final chunk in _service.sendMessage(
        sessionId: session.id.value,
        prompt: trimmed,
      )) {
        buffer.write(chunk.textDelta);
        widgets.addAll(chunk.widgets);
        _updateAiMessage(
          aiMessage.id,
          content: buffer.toString(),
          widgets: List<WidgetSpec>.unmodifiable(widgets),
          isResponding: true,
        );
      }
      _updateAiMessage(
        aiMessage.id,
        content: buffer.toString().trimRight(),
        widgets: List<WidgetSpec>.unmodifiable(widgets),
        isResponding: false,
      );
    } catch (_) {
      _updateAiMessage(
        aiMessage.id,
        content: buffer.isEmpty
            ? 'Не удалось получить ответ. Попробуйте ещё раз.'
            : buffer.toString().trimRight(),
        widgets: List<WidgetSpec>.unmodifiable(widgets),
        isResponding: false,
      );
    }
  }

  void _updateAiMessage(
    Ulid id, {
    required String content,
    required List<WidgetSpec> widgets,
    required bool isResponding,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = <ChatMessage>[
      for (final m in current.messages)
        if (m.id == id) m.copyWith(content: content, widgets: widgets) else m,
    ];
    state = AsyncData(
      current.copyWith(messages: updated, isResponding: isResponding),
    );
  }
}

/// Backend service powering the chat. Overridden in the app shell with an
/// [HttpAiChatService]; defaults to the in-memory fake for previews/tests.
final aiChatServiceProvider = Provider<AiChatService>(
  (ref) => const FakeAiChatService(),
);

/// The active chat session + messages.
final chatControllerProvider =
    AsyncNotifierProvider<ChatController, ChatState>(ChatController.new);
