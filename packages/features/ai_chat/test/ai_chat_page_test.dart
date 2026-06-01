// Widget tests for the AI chat page: list rendering, submit wiring, and the
// investment safety disclaimer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart';

import '_fixtures.dart';

Widget _wrap(StubAiChatService service) => ProviderScope(
      overrides: <Override>[
        aiChatServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(home: AiChatPage()),
    );

void main() {
  testWidgets('renders the empty state then the message list after a reply',
      (tester) async {
    final service = StubAiChatService(reply: 'Привет!');
    await tester.pumpWidget(_wrap(service));
    await tester.pumpAndSettle();

    // Empty conversation initially: no message list, quick prompts visible.
    expect(find.byKey(const Key('ai_chat_message_list')), findsNothing);
    expect(find.text('Где я переплачиваю?'), findsOneWidget);

    // Type and send a message.
    await tester.enterText(
      find.byKey(const Key('ai_chat_composer_field')),
      'Сколько я трачу?',
    );
    await tester.tap(find.byKey(const Key('ai_chat_send_button')));
    await tester.pumpAndSettle();

    // List now renders both the user message and the AI reply.
    expect(find.byKey(const Key('ai_chat_message_list')), findsOneWidget);
    expect(find.text('Сколько я трачу?'), findsOneWidget);
    expect(find.text('Привет!'), findsOneWidget);
  });

  testWidgets('sending a message triggers controller.submit', (tester) async {
    final service = StubAiChatService(reply: 'ok');
    await tester.pumpWidget(_wrap(service));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ai_chat_composer_field')),
      'Оптимизируй подписки',
    );
    await tester.tap(find.byKey(const Key('ai_chat_send_button')));
    await tester.pumpAndSettle();

    // The controller forwarded the prompt to the service exactly once.
    expect(service.prompts, <String>['Оптимизируй подписки']);
  });

  testWidgets('disclaimer appears for an investment-themed AI reply',
      (tester) async {
    final service = StubAiChatService(
      reply: 'Если говорить про инвестиции и акции, вот общая картина.',
    );
    await tester.pumpWidget(_wrap(service));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('ai_chat_safety_disclaimer')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('ai_chat_composer_field')),
      'Куда инвестировать?',
    );
    await tester.tap(find.byKey(const Key('ai_chat_send_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('ai_chat_safety_disclaimer')),
      findsOneWidget,
    );
  });

  testWidgets('non-investment reply does not surface the disclaimer',
      (tester) async {
    final service = StubAiChatService(reply: 'Ваши расходы под контролем.');
    await tester.pumpWidget(_wrap(service));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('ai_chat_composer_field')),
      'Как мои траты?',
    );
    await tester.tap(find.byKey(const Key('ai_chat_send_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('ai_chat_safety_disclaimer')),
      findsNothing,
    );
  });
}
