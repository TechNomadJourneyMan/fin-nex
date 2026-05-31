// Platform-aware factory for [LocalLlmService].
//
// Returns the flutter_gemma-backed implementation on platforms that can run
// the model, and the no-op stub on Web. Callers (e.g. the app's Provider)
// should use this rather than constructing implementations directly.

import 'package:flutter/foundation.dart' show kIsWeb;

import 'gemma_local_llm_service.dart';
import 'local_llm_service.dart';
import 'web_noop_local_llm_service.dart';

/// Builds the appropriate [LocalLlmService] for the current platform.
LocalLlmService defaultLocalLlmService() {
  if (kIsWeb) {
    return WebNoopLocalLlmService();
  }
  return GemmaLocalLlmService();
}
