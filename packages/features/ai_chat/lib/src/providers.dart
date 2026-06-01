import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/ai_chat_service.dart';

/// The configured backend [Dio] client. The app shell overrides this with the
/// authenticated instance from `pf_data_api`; left unimplemented here so the
/// feature package never accidentally talks to a real backend in previews.
final aiChatDioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
    'aiChatDioProvider must be overridden at the app level with the '
    'authenticated Dio client.',
  );
});

/// Convenience override builder for the app shell: wires
/// [aiChatServiceProvider] to an [HttpAiChatService] over [aiChatDioProvider].
///
/// Usage in `apps/finnex/lib/providers.dart`:
/// ```dart
/// aiChatServiceProvider.overrideWith(
///   (ref) => HttpAiChatService(ref.watch(authedDioProvider)),
/// )
/// ```
Provider<AiChatService> httpAiChatServiceProvider() => Provider<AiChatService>(
      (ref) => HttpAiChatService(ref.watch(aiChatDioProvider)),
    );
