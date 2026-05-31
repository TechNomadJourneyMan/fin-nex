// Abstract contract for an on-device LLM.
//
// Pocket Flow runs inference locally (Gemma via flutter_gemma) so that
// sensitive financial text — OCR'd receipts, bank push notifications,
// free-form questions — never leaves the device. Implementations:
//
//   * [GemmaLocalLlmService]   — real flutter_gemma backend (mobile/desktop).
//   * [WebNoopLocalLlmService] — Web fallback that reports "not available".
//
// The service intentionally exposes a tiny surface so feature code and the
// settings UI can depend on the contract rather than the plugin.

/// Snapshot of a model download in progress.
///
/// [progress] is a 0.0–1.0 fraction. [done] flips true once the file is fully
/// downloaded and installed; [error] is set when the download failed.
class LlmDownloadProgress {
  const LlmDownloadProgress({
    required this.progress,
    this.done = false,
    this.error,
  });

  /// 0.0 .. 1.0 download fraction. May be reported coarsely by the backend.
  final double progress;

  /// True once the model is installed and ready to initialize.
  final bool done;

  /// Non-null when the download/installation failed.
  final Object? error;

  /// Convenience: percentage 0..100 rounded for labels.
  int get percent => (progress.clamp(0.0, 1.0) * 100).round();

  @override
  String toString() =>
      'LlmDownloadProgress($percent%, done=$done, error=$error)';
}

/// Contract for a locally-runnable language model.
abstract class LocalLlmService {
  /// Human-readable identifier of the model variant this service runs
  /// (e.g. `gemma-3n-E4B-it-int4`). Shown in the settings UI.
  String get modelId;

  /// Approximate on-disk size of the model, in bytes. Used for UI estimates.
  int get approxModelSizeBytes;

  /// Whether the model file is already downloaded/installed on this device.
  Future<bool> isInstalled();

  /// Whether the model is installed AND has been initialized for inference.
  Future<bool> isReady();

  /// Downloads + installs the model. Resolves once the file is on disk.
  ///
  /// Progress is surfaced via [downloadProgress]. On platforms that cannot run
  /// the model (Web) this throws [UnsupportedError].
  Future<void> download();

  /// Stream of [LlmDownloadProgress] events for the active [download].
  ///
  /// Emits the latest known fraction; completes (with a final `done: true`
  /// event) when the download finishes.
  Stream<LlmDownloadProgress> get downloadProgress;

  /// Runs a single prompt to completion and returns the full text response.
  ///
  /// Initializes the model on first use. Throws [StateError] if the model is
  /// not installed, or [UnsupportedError] on unsupported platforms.
  Future<String> infer(String prompt);

  /// Streams the response token-by-token (or chunk-by-chunk) for [prompt].
  Stream<String> stream(String prompt);

  /// Releases native resources (sessions, model handles). Safe to call when
  /// nothing is initialized.
  Future<void> dispose();
}
