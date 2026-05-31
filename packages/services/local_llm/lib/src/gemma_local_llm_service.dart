// flutter_gemma-backed [LocalLlmService] for mobile/desktop.
//
// Downloads a quantised Gemma-3 instruction-tuned model from the network,
// installs it via flutter_gemma's [ModelFileManager], then creates an
// [InferenceModel] + session for prompt/stream inference.
//
// See MODEL_CHOICE.md for the variant, size, URL and license.

import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';

import 'local_llm_service.dart';

/// Default model variant. See MODEL_CHOICE.md for rationale.
///
/// `gemma-3n-E4B-it-int4` — Gemma 3n E4B, instruction-tuned, int4 quantised.
/// Effective ~4B params with ~3.1 GB `.task` weights, the largest stable
/// Gemma-3 family variant that fits comfortably under the 4 GB budget.
const String kDefaultGemmaModelId = 'gemma-3n-E4B-it-int4';

/// Public download URL (Hugging Face MediaPipe `.task` build). Gemma is
/// governed by Google's Gemma Terms of Use; some hosts gate the file behind a
/// HF token — pass one via [GemmaLocalLlmService.hfToken] if required.
const String kDefaultGemmaModelUrl =
    'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task';

/// ~3.1 GB on disk (int4 `.task`).
const int kDefaultGemmaModelSizeBytes = 3145728000; // ~3.0 GiB

class GemmaLocalLlmService implements LocalLlmService {
  GemmaLocalLlmService({
    String modelUrl = kDefaultGemmaModelUrl,
    String modelId = kDefaultGemmaModelId,
    int approxSizeBytes = kDefaultGemmaModelSizeBytes,
    this.hfToken,
    this.maxTokens = 2048,
    FlutterGemmaPlugin? plugin,
  })  : _modelUrl = modelUrl,
        _modelId = modelId,
        _approxSizeBytes = approxSizeBytes,
        _plugin = plugin ?? FlutterGemmaPlugin.instance;

  final FlutterGemmaPlugin _plugin;
  final String _modelUrl;
  final String _modelId;
  final int _approxSizeBytes;

  /// Optional Hugging Face access token for gated model downloads.
  final String? hfToken;

  /// Context window used when creating the inference model.
  final int maxTokens;

  InferenceModel? _model;
  InferenceModelSession? _session;
  bool _initializing = false;

  final StreamController<LlmDownloadProgress> _progress =
      StreamController<LlmDownloadProgress>.broadcast();

  @override
  String get modelId => _modelId;

  @override
  int get approxModelSizeBytes => _approxSizeBytes;

  @override
  Stream<LlmDownloadProgress> get downloadProgress => _progress.stream;

  @override
  Future<bool> isInstalled() => _plugin.modelManager.isModelInstalled;

  @override
  Future<bool> isReady() async {
    if (_session != null) return true;
    return isInstalled();
  }

  @override
  Future<void> download() async {
    _progress.add(const LlmDownloadProgress(progress: 0));
    try {
      final Stream<int> raw = _plugin.modelManager
          .downloadModelFromNetworkWithProgress(_modelUrl, token: hfToken);
      await for (final int pct in raw) {
        _progress.add(LlmDownloadProgress(progress: pct.clamp(0, 100) / 100.0));
      }
      _progress.add(const LlmDownloadProgress(progress: 1.0, done: true));
    } catch (e) {
      _progress.add(LlmDownloadProgress(progress: 0, error: e));
      rethrow;
    }
  }

  /// Lazily creates the inference model + session. No-op if already ready.
  Future<InferenceModelSession> _ensureSession() async {
    final InferenceModelSession? existing = _session;
    if (existing != null) return existing;

    if (!await isInstalled()) {
      throw StateError(
        'Local model "$_modelId" is not installed. Call download() first.',
      );
    }

    // Guard against concurrent initialization races.
    while (_initializing) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final InferenceModelSession? s = _session;
      if (s != null) return s;
    }
    _initializing = true;
    try {
      final InferenceModel model = _model ??
          await _plugin.createModel(
            modelType: ModelType.gemmaIt,
            maxTokens: maxTokens,
            supportImage: false,
          );
      _model = model;
      final InferenceModelSession session = await model.createSession(
        temperature: 0.2, // low temp — we want deterministic JSON extraction
        topK: 40,
      );
      _session = session;
      return session;
    } finally {
      _initializing = false;
    }
  }

  @override
  Future<String> infer(String prompt) async {
    final InferenceModelSession session = await _ensureSession();
    await session.addQueryChunk(Message(text: prompt, isUser: true));
    return session.getResponse();
  }

  @override
  Stream<String> stream(String prompt) async* {
    final InferenceModelSession session = await _ensureSession();
    await session.addQueryChunk(Message(text: prompt, isUser: true));
    yield* session.getResponseAsync();
  }

  @override
  Future<void> dispose() async {
    await _session?.close();
    _session = null;
    await _model?.close();
    _model = null;
    await _progress.close();
  }
}
