// Web fallback for [LocalLlmService].
//
// flutter_gemma's MediaPipe LLM inference is not available in the browser at
// the sizes Pocket Flow needs, so on Web we surface a clear "not supported"
// state instead of attempting a multi-GB download that cannot run.

import 'dart:async';

import 'local_llm_service.dart';

const String _unsupportedMessage =
    'On-device Gemma is not available on Web. Open Pocket Flow on Android, '
    'iOS or desktop to download and run the local model.';

class WebNoopLocalLlmService implements LocalLlmService {
  WebNoopLocalLlmService();

  @override
  String get modelId => 'gemma-3n-E4B-it-int4 (unavailable on Web)';

  @override
  int get approxModelSizeBytes => 0;

  @override
  Future<bool> isInstalled() async => false;

  @override
  Future<bool> isReady() async => false;

  @override
  Stream<LlmDownloadProgress> get downloadProgress =>
      const Stream<LlmDownloadProgress>.empty();

  @override
  Future<void> download() async {
    throw UnsupportedError(_unsupportedMessage);
  }

  @override
  Future<String> infer(String prompt) async {
    throw UnsupportedError(_unsupportedMessage);
  }

  @override
  Stream<String> stream(String prompt) {
    throw UnsupportedError(_unsupportedMessage);
  }

  @override
  Future<void> dispose() async {}
}
