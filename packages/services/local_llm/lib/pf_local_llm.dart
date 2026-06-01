// Public API for pf_local_llm — Pocket Flow's on-device LLM service.
//
// On-device (Gemma via flutter_gemma) inference so financial text never leaves
// the device. See src/MODEL_CHOICE.md for the model variant + license.

library pf_local_llm;

export 'src/factory.dart';
export 'src/gemma_local_llm_service.dart'
    show
        GemmaLocalLlmService,
        kDefaultGemmaModelId,
        kDefaultGemmaModelUrl,
        kDefaultGemmaModelSizeBytes;
export 'src/llm_use_cases.dart';
export 'src/local_llm_service.dart';
export 'src/web_noop_local_llm_service.dart' show WebNoopLocalLlmService;
