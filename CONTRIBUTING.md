# Contributing

## Setup

```bash
# 1. Install Flutter 3.24+ (stable channel)
flutter --version

# 2. Activate Melos and bootstrap the workspace
dart pub global activate melos
melos bootstrap

# 3. Generate code (freezed / drift / json_serializable)
melos run build_runner_build
```

## Day-to-day

```bash
melos run format        # dart format with --line-length=90
melos run analyze       # flutter analyze across every package
melos run test          # run all unit + widget tests
```

## Conventions

- 90-character line length.
- Single quotes.
- Trailing commas in multi-line constructors and lists.
- Public APIs must have a one-line dartdoc.
- No `print` calls — use `debugPrint` and only in dev paths.
- No hardcoded colors / sizes — pull from `fnx_core_tokens`.
- No hardcoded user-facing strings — use `AppLocalizations`.

## Path ownership

Each feature package is owned by exactly one specialist agent. Do not edit
files outside your assigned paths without coordinating with the owner.

## Commits

Conventional Commits, e.g. `feat(transactions): add quick-add sheet`.
