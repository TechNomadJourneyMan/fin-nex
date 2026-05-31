# Web Deployment

FinNex's primary deployment target is **Flutter Web on Vercel**.

## Local dev

```bash
# One-time
cd apps/finnex
flutter pub get

# Run in Chrome with hot reload
flutter run -d chrome
```

If you need a fixed port (e.g. for OAuth callbacks):

```bash
flutter run -d chrome --web-port 5173
```

## Local production build

```bash
cd apps/finnex
flutter build web --release --base-href "/"

# Serve the built output with any static file server
npx http-server build/web -p 8080
# or
python3 -m http.server -d build/web 8080
```

Output: `apps/finnex/build/web/`

## Vercel deployment

### Via dashboard (recommended)

1. Import the GitHub repo `TechNomadJourneyMan/fin-nex` in the Vercel
   dashboard.
2. Framework preset: **Other** (Vercel will read `vercel.json`).
3. Leave Build Command, Install Command, and Output Directory blank —
   `vercel.json` overrides them:
   - Build:  `bash install-flutter.sh`
   - Output: `apps/finnex/build/web`
4. Deploy.

`install-flutter.sh` clones the pinned Flutter SDK
(`FLUTTER_VERSION=3.24.5`), runs `flutter pub get` and
`flutter build web --release`.

### Via CLI

```bash
npm i -g vercel
vercel login
vercel link        # link to TechNomadJourneyMan/fin-nex
vercel --prod
```

## Environment variables

Set these in **Vercel Project Settings -> Environment Variables**, or
locally via `--dart-define=KEY=value`:

| Var                  | Example                          | Purpose                          |
| -------------------- | -------------------------------- | -------------------------------- |
| `FNX_API_BASE_URL`   | `https://api.finnex.app`         | Backend REST base URL            |
| `FNX_API_TIMEOUT_MS` | `15000`                          | Per-request timeout (ms)         |
| `FNX_ENV`            | `dev` \| `staging` \| `prod`     | Tags telemetry, gates dev panels |

Reading at runtime:

```dart
const apiBase = String.fromEnvironment(
  'FNX_API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
```

Pass at build time:

```bash
flutter build web --release \
  --dart-define=FNX_API_BASE_URL=https://api.finnex.app \
  --dart-define=FNX_ENV=prod
```

## SPA rewrites

`vercel.json` rewrites all paths to `/index.html` so go_router deep
links (e.g. `/budgets/abc`) work on hard refresh.

## Troubleshooting

- **CanvasKit fails to load behind a proxy** — set `--web-renderer html`
  in `install-flutter.sh` (slower text rendering but proxy-friendly).
- **Build OOM on Vercel** — bump the Vercel project's build memory to
  8 GB or split heavy generators (`build_runner`) out of the build path.
- **`flutter_local_notifications` errors at compile time on web** —
  ensure callers guard with `if (kIsWeb) return;` (see
  `WEB_COMPATIBILITY.md`).
