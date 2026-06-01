/// Legacy entry point retained for backwards compatibility.
///
/// New code should import `package:pf_core_tokens/tokens.dart` directly,
/// but this barrel keeps the original public surface (including the
/// `PfTokens` aggregate) working for callers wired against the
/// scaffolding revision.
library pf_core_tokens.compat;

export 'src/pf_tokens.dart';
export 'tokens.dart';
