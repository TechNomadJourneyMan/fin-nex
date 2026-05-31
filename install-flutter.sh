#!/usr/bin/env bash
set -euo pipefail

# Pinned to a recent stable Flutter release that allows intl ^0.20.0.
# (Flutter 3.24/3.27 pin intl to 0.19, which conflicts with our pubspec.)
FLUTTER_VERSION="${FLUTTER_VERSION:-3.32.5}"
FLUTTER_DIR="${HOME}/flutter-sdk"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --no-analytics --no-cli-animations
flutter doctor -v || true

# Bootstrap the Melos workspace so every path-dep gets `pub get`.
if [ -f "melos.yaml" ] && command -v dart >/dev/null; then
  dart pub global activate melos 6.1.0 || true
  export PATH="$HOME/.pub-cache/bin:$PATH"
  melos bootstrap || true
fi

# Generate l10n bundle (the l10n package has `flutter: generate: true`).
( cd packages/core/l10n && flutter pub get && flutter gen-l10n ) || true

cd apps/finnex
flutter pub get
# Web sqflite worker (downloaded at runtime; safe to skip on Vercel because
# the app falls back to in-memory if missing).
dart run sqflite_common_ffi_web:setup || true

flutter build web --release --no-tree-shake-icons --base-href "/" --pwa-strategy=offline-first

echo "Build complete: $(pwd)/build/web"
