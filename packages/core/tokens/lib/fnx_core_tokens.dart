/// Legacy entry point retained for backwards compatibility.
///
/// New code should import `package:fnx_core_tokens/tokens.dart` directly,
/// but this barrel keeps the original public surface (including the
/// `FnxTokens` aggregate) working for callers wired against the
/// scaffolding revision.
library fnx_core_tokens.compat;

export 'src/fnx_tokens.dart';
export 'tokens.dart';
