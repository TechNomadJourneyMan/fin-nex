import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart';

/// A deterministic [AiChatService] for tests: emits the configured reply (and
/// optional widgets) as a single synchronous chunk, with no streaming delay.
class StubAiChatService implements AiChatService {
  /// Default constructor.
  StubAiChatService({
    this.reply = 'Готово.',
    this.widgets = const <WidgetSpec>[],
  });

  /// Canned reply text.
  String reply;

  /// Canned inline widgets.
  List<WidgetSpec> widgets;

  /// Records the prompts passed to [sendMessage].
  final List<String> prompts = <String>[];

  @override
  Stream<AiChatChunk> sendMessage({
    required String sessionId,
    required String prompt,
  }) async* {
    prompts.add(prompt);
    yield AiChatChunk(textDelta: reply, widgets: widgets);
  }
}
