# Web Icons

This directory should contain PWA icons referenced by `web/manifest.json`.
The Flutter web build will copy everything in `web/` (including this directory)
into `build/web/` verbatim.

Required files (replace before production launch):

| File                          | Size      | Purpose                |
| ----------------------------- | --------- | ---------------------- |
| `Icon-192.png`                | 192x192   | Standard PWA icon      |
| `Icon-512.png`                | 512x512   | Standard PWA icon      |
| `Icon-maskable-192.png`       | 192x192   | Maskable (Android)     |
| `Icon-maskable-512.png`       | 512x512   | Maskable (Android)     |

Until these are added, browsers will log 404s for the icon URLs but the app
itself will still load and run. The splash screen in `index.html` uses CSS
text and does not depend on these icons.

## Generating

Use a tool like https://realfavicongenerator.net/ or
`flutter pub run flutter_launcher_icons` with a 1024x1024 source PNG that
matches the Pocket Flow brand mark (primary `#0EA5E9` on `#0B1220`).
