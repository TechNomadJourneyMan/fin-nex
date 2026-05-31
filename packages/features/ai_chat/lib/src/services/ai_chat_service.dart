import 'dart:async';

import 'package:dio/dio.dart';

import '../entities/widget_spec.dart';

/// One streamed fragment of an AI reply.
///
/// The backend `/ai/chat` endpoint emits a sequence of chunks: text deltas
/// arrive first, then any inline widget specs, then a terminal chunk. The
/// controller concatenates [textDelta]s and collects [widgets].
class AiChatChunk {
  /// Default constructor.
  const AiChatChunk({this.textDelta = '', this.widgets = const <WidgetSpec>[]});

  /// Incremental text appended to the running reply.
  final String textDelta;

  /// Inline widgets carried by this chunk (usually only the final chunk).
  final List<WidgetSpec> widgets;
}

/// Abstraction over the backend conversational endpoint (`POST /ai/chat`).
///
/// Implementations stream the assistant reply as a sequence of [AiChatChunk]s
/// so the UI can render partial text as it arrives.
abstract interface class AiChatService {
  /// Sends [prompt] in the context of [sessionId] and streams the reply.
  Stream<AiChatChunk> sendMessage({
    required String sessionId,
    required String prompt,
  });
}

/// Dio-backed [AiChatService] hitting `POST /ai/chat`.
///
/// The backend returns a JSON document `{ "reply": String, "widgets": [...] }`.
/// To keep the streaming contract uniform across implementations, the reply
/// text is emitted as a single delta followed by the widgets; richer SSE
/// streaming can be layered in later behind the same interface.
class HttpAiChatService implements AiChatService {
  /// Default constructor.
  HttpAiChatService(this._dio);

  final Dio _dio;

  @override
  Stream<AiChatChunk> sendMessage({
    required String sessionId,
    required String prompt,
  }) async* {
    final res = await _dio.post<Map<String, dynamic>>(
      '/ai/chat',
      data: <String, dynamic>{
        'session_id': sessionId,
        'prompt': prompt,
      },
    );
    final data = res.data ?? const <String, dynamic>{};
    final reply = data['reply'] as String? ?? '';
    final widgets = <WidgetSpec>[
      for (final dynamic w in (data['widgets'] as List<dynamic>? ?? const []))
        if (WidgetSpec.fromJson(w as Map<String, dynamic>) case final spec?)
          spec,
    ];
    if (reply.isNotEmpty) {
      yield AiChatChunk(textDelta: reply);
    }
    if (widgets.isNotEmpty) {
      yield AiChatChunk(widgets: widgets);
    }
  }
}

/// In-memory [AiChatService] used in previews, tests, and offline demos.
///
/// Streams a canned reply word-by-word (with a small delay) so the bubble
/// animates as if a real model were responding. Prompts mentioning charts /
/// budgets / investments get matching inline widgets attached.
class FakeAiChatService implements AiChatService {
  /// Default constructor.
  const FakeAiChatService({
    this.chunkDelay = const Duration(milliseconds: 20),
  });

  /// Delay between streamed word chunks.
  final Duration chunkDelay;

  @override
  Stream<AiChatChunk> sendMessage({
    required String sessionId,
    required String prompt,
  }) async* {
    final lower = prompt.toLowerCase();
    final reply = _replyFor(lower);
    for (final word in reply.split(' ')) {
      if (chunkDelay > Duration.zero) {
        await Future<void>.delayed(chunkDelay);
      }
      yield AiChatChunk(textDelta: '$word ');
    }
    final widgets = _widgetsFor(lower);
    if (widgets.isNotEmpty) {
      yield AiChatChunk(widgets: widgets);
    }
  }

  String _replyFor(String lower) {
    if (lower.contains('переплач') || lower.contains('overpay')) {
      return 'Похоже, вы **переплачиваете** за доставку еды — '
          'это самая быстрорастущая статья за последние 3 месяца. '
          'Ниже разбивка по категориям.';
    }
    if (lower.contains('подписк') || lower.contains('subscription')) {
      return 'Я нашёл несколько подписок, которыми вы редко пользуетесь. '
          'Отмена двух из них сэкономит примерно 4 990 ₸ в месяц.';
    }
    if (lower.contains('кассов') ||
        lower.contains('разрыв') ||
        lower.contains('cash')) {
      return 'Прогноз остатка показывает возможный **кассовый разрыв** '
          'к 20-му числу. Вот динамика баланса на месяц вперёд.';
    }
    if (lower.contains('инвест') ||
        lower.contains('акци') ||
        lower.contains('invest')) {
      return 'Я могу показать общие данные, но помните: это не '
          'индивидуальная инвестиционная рекомендация.';
    }
    return 'Я ваш финансовый ассистент. Спросите про расходы, '
        'подписки или прогноз бюджета — и я помогу разобраться.';
  }

  List<WidgetSpec> _widgetsFor(String lower) {
    if (lower.contains('переплач') || lower.contains('overpay')) {
      return const <WidgetSpec>[
        BarChartSpec(
          title: 'Топ категорий расходов',
          bars: <BarChartBar>[
            BarChartBar(label: 'Еда', value: 84000),
            BarChartBar(label: 'Транспорт', value: 32000),
            BarChartBar(label: 'Подписки', value: 18000),
          ],
        ),
      ];
    }
    if (lower.contains('подписк') || lower.contains('subscription')) {
      return const <WidgetSpec>[
        ProgressBarSpec(
          title: 'Использование подписок',
          label: 'активны 3 из 7',
          value: 3,
          max: 7,
        ),
      ];
    }
    if (lower.contains('кассов') ||
        lower.contains('разрыв') ||
        lower.contains('cash')) {
      return const <WidgetSpec>[
        LineChartSpec(
          title: 'Прогноз баланса',
          seriesName: 'Баланс',
          points: <LineChartPoint>[
            LineChartPoint(x: 0, y: 120000, label: '1'),
            LineChartPoint(x: 10, y: 60000, label: '10'),
            LineChartPoint(x: 20, y: 5000, label: '20'),
            LineChartPoint(x: 30, y: 40000, label: '30'),
          ],
        ),
      ];
    }
    return const <WidgetSpec>[];
  }
}
