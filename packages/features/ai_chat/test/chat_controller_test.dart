// Unit tests for ChatController.submit streaming + state transitions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_ai_chat/pf_feat_ai_chat.dart';

import '_fixtures.dart';

void main() {
  test('submit appends user + AI messages and clears responding flag',
      () async {
    final service = StubAiChatService(reply: 'Разобрался.');
    final container = ProviderContainer(
      overrides: <Override>[
        aiChatServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    // Resolve the initial (fresh-session) state.
    await container.read(chatControllerProvider.future);

    final notifier = container.read(chatControllerProvider.notifier);
    await notifier.submit('Привет');

    final state = container.read(chatControllerProvider).requireValue;
    expect(state.messages, hasLength(2));
    expect(state.messages.first.sender, ChatSender.user);
    expect(state.messages.first.content, 'Привет');
    expect(state.messages.last.sender, ChatSender.ai);
    expect(state.messages.last.content, 'Разобрался.');
    expect(state.isResponding, isFalse);
    expect(service.prompts, <String>['Привет']);
  });

  test('blank input is ignored', () async {
    final service = StubAiChatService();
    final container = ProviderContainer(
      overrides: <Override>[
        aiChatServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container.read(chatControllerProvider.future);

    await container.read(chatControllerProvider.notifier).submit('   ');

    expect(
      container.read(chatControllerProvider).requireValue.messages,
      isEmpty,
    );
    expect(service.prompts, isEmpty);
  });

  test('AI message carries through inline widgets from the stream', () async {
    final service = StubAiChatService(
      reply: 'Вот разбивка.',
      widgets: const <WidgetSpec>[
        BarChartSpec(
          bars: <BarChartBar>[BarChartBar(label: 'Еда', value: 100)],
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: <Override>[
        aiChatServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    await container.read(chatControllerProvider.future);

    await container.read(chatControllerProvider.notifier).submit('Где трачу?');

    final ai =
        container.read(chatControllerProvider).requireValue.messages.last;
    expect(ai.widgets, hasLength(1));
    expect(ai.widgets.single, isA<BarChartSpec>());
  });
}
