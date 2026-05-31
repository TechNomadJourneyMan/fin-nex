# FinNex

Personal finance tracking app built with Flutter. Web-first deployment to Vercel,
with mobile builds for iOS and Android coming later.

## Quick start

```bash
# Get Flutter SDK (3.24+)
flutter --version

# Install workspace dependencies
flutter pub get

# Run the app in Chrome
cd apps/finnex
flutter run -d chrome
```

## Repo layout

```
apps/finnex/                 # Main Flutter app entrypoint
packages/core/theme          # MaterialTheme + FnxTheme
packages/core/tokens         # Design tokens (colors, spacing, type)
packages/core/widgets        # Shared widget library
packages/core/charts         # Chart primitives (wraps fl_chart)
packages/core/l10n           # Localization
packages/domain              # Pure-Dart domain models
packages/data/local          # Drift database
packages/data/api            # REST client (Dio)
packages/data/sync           # Offline sync engine
packages/features/*          # Feature modules
backend/                     # Node + Fastify API server
```

## Useful scripts

```bash
melos bootstrap        # Link all workspace packages
melos run analyze      # flutter analyze across the workspace
melos run format       # dart format
melos run test         # Run all tests
melos run build_runner # codegen for freezed/drift/json_serializable
```

## Deploying

The Flutter web build is deployed to Vercel via `install-flutter.sh`. See
`vercel.json` for the configured `buildCommand` and `outputDirectory`.

## Documentation

The product spec, UX spec, UI spec, architecture and DB schema live in the
sibling `FinNex_Product_Package/` folder.
