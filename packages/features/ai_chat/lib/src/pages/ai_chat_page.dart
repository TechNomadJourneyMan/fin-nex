import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

import '../controllers/chat_controller.dart';
import '../entities/chat_message.dart';
import '../widgets/inline_widget_renderer.dart';
import '../widgets/safety_disclaimer.dart';

/// Quick prompt suggestions surfaced as chips above the composer.
const List<String> kQuickPrompts = <String>[
  'Где я переплачиваю?',
  'Оптимизируй подписки',
  'Кассовый разрыв?',
];

/// Conversational CFO page: a chat thread with the FinNex AI assistant.
///
/// User bubbles are right-aligned in the brand accent; AI bubbles are
/// left-aligned with markdown rendering and inline data widgets. Quick prompt
/// chips sit at the top and a composer sits at the bottom.
class AiChatPage extends ConsumerStatefulWidget {
  /// Default constructor.
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _composer.clear();
    await ref.read(chatControllerProvider.notifier).submit(trimmed);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(chatControllerProvider);
    final colors = context.fnxColors;

    return Scaffold(
      appBar: AppBar(title: const Text('AI ассистент')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text('Ошибка: $e'),
        ),
        data: (ChatState state) {
          final messages = state.messages;
          return Column(
            children: <Widget>[
              _QuickPromptBar(onSelect: _send),
              Expanded(
                child: messages.isEmpty
                    ? const _EmptyConversation()
                    : ListView.builder(
                        key: const Key('ai_chat_message_list'),
                        controller: _scroll,
                        padding: const EdgeInsets.all(FnxSpacing.x4),
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int i) =>
                            _MessageBubble(message: messages[i]),
                      ),
              ),
              _Composer(
                controller: _composer,
                enabled: !state.isResponding,
                onSend: _send,
                accent: colors.brand,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickPromptBar extends StatelessWidget {
  const _QuickPromptBar({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FnxSpacing.x4),
        itemCount: kQuickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: FnxSpacing.x2),
        itemBuilder: (BuildContext context, int i) {
          final prompt = kQuickPrompts[i];
          return Center(
            child: FnxChip(
              label: prompt,
              icon: Icons.auto_awesome,
              onTap: () => onSelect(prompt),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FnxEmptyState(
        icon: Icons.forum_outlined,
        title: 'Спросите вашего AI-CFO',
        body: 'Задайте вопрос о расходах, подписках или прогнозе бюджета.',
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    final colors = context.fnxColors;
    final typo = context.fnxTypography;

    final Color bubbleColor = isUser ? colors.brand : colors.surfaceRaised;
    final Color textColor = isUser ? colors.onBrand : colors.textPrimary;

    final Widget body = isUser
        ? Text(message.content, style: typo.bodyMd.copyWith(color: textColor))
        : MarkdownBody(
            data: message.content.isEmpty ? '…' : message.content,
            styleSheet: MarkdownStyleSheet(
              p: typo.bodyMd.copyWith(color: textColor),
              strong: typo.bodyMd
                  .copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
          );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FnxSpacing.x4,
        vertical: FnxSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(FnxTokens.radiusLg),
          topRight: const Radius.circular(FnxTokens.radiusLg),
          bottomLeft: Radius.circular(isUser ? FnxTokens.radiusLg : 4),
          bottomRight: Radius.circular(isUser ? 4 : FnxTokens.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          body,
          for (final spec in message.widgets) InlineWidgetRenderer(spec: spec),
          if (!isUser && mentionsInvestment(message.content))
            const SafetyDisclaimer(),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: FnxSpacing.x3),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[Flexible(child: bubble)],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
    required this.accent,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSend;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(FnxSpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: FnxTextField(
                key: const Key('ai_chat_composer_field'),
                controller: controller,
                hint: 'Спросите что-нибудь…',
                enabled: enabled,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? onSend : null,
              ),
            ),
            const SizedBox(width: FnxSpacing.x2),
            IconButton.filled(
              key: const Key('ai_chat_send_button'),
              style: IconButton.styleFrom(backgroundColor: accent),
              onPressed: enabled ? () => onSend(controller.text) : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
