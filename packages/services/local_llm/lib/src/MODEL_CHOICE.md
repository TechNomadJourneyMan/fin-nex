# On-device model choice

## Selected variant: `gemma-3n-E4B-it-int4`

Pocket Flow runs a quantised **Gemma 3n E4B, instruction-tuned, int4** model
fully on-device via [`flutter_gemma`](https://pub.dev/packages/flutter_gemma).

| Property        | Value |
| --------------- | ----- |
| Model id        | `gemma-3n-E4B-it-int4` |
| Family          | Gemma 3n (Gemma 3 generation) |
| Tuning          | Instruction-tuned (`-it`) |
| Quantisation    | int4 (MediaPipe `.task`) |
| Effective params| ~4B (E4B "effective" config) |
| On-disk size    | ~3.0–3.1 GB (under the 4 GB budget) |
| Context window  | 2048 tokens (configured in `GemmaLocalLlmService.maxTokens`) |

### Why this variant

The task budget is **≤ 4 GB on disk**. The candidates flutter_gemma exposes:

- `gemma-3-4b-it-int8` — ~4.4 GB, exceeds the budget.
- `gemma-3-4b-it-int4` — ~2.5 GB, fits but smaller activations.
- **`gemma-3n-E4B-it-int4` — ~3.0 GB**, the *largest* stable Gemma-3 family
  instruction-tuned variant that still fits comfortably under 4 GB, and the
  one MediaPipe/flutter_gemma ship a maintained LiteRT `.task` build for.

We therefore pick `gemma-3n-E4B-it-int4` to maximise quality within the budget.
For very storage-constrained devices, swap `kDefaultGemmaModelUrl` /
`kDefaultGemmaModelId` for the 1B/2B int4 builds — the service contract is
unchanged.

### Download URL

```
https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task
```

Some Hugging Face hosts gate Gemma weights behind an access token. Pass one via
`GemmaLocalLlmService(hfToken: '...')` if the download returns 401/403. The
download URL can be overridden at construction time without code changes
elsewhere.

### License

Gemma models are **not** open-source in the OSI sense. They are distributed
under **Google's Gemma Terms of Use** and the **Gemma Prohibited Use Policy**:

- Gemma Terms of Use: https://ai.google.dev/gemma/terms
- Prohibited Use Policy: https://ai.google.dev/gemma/prohibited_use_policy

By downloading and running the model the end user accepts these terms. Pocket
Flow surfaces the model id and a privacy note in the Local LLM settings page;
shipping or redistributing the weights inside the app bundle is **not**
permitted — they are fetched at runtime by the user.

## flutter_gemma pin

Resolved version: **`flutter_gemma: ^0.10.0`** (locked to `0.10.6` at write
time), which resolves cleanly on Dart 3.8 / Flutter 3.32.5. No fallback pin was
required.
