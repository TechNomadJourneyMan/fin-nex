#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_DIR="${HOME}/flutter-sdk"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --no-analytics --no-cli-animations
flutter doctor -v || true

# Bootstrap workspace (if melos present)
if [ -f "melos.yaml" ] && command -v dart >/dev/null; then
  dart pub global activate melos 6.1.0 || true
  export PATH="$HOME/.pub-cache/bin:$PATH"
  melos bootstrap || true
fi

cd apps/finnex
flutter pub get
flutter build web --release --base-href "/" --pwa-strategy=offline-first

echo "Build complete: $(pwd)/build/web"
