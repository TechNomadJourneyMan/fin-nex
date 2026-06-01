# Pocket Flow Backend (local dev)

## Prerequisites
- Node.js 20+
- Docker + docker compose (for Postgres and Redis)

## Quick start

```bash
cp .env.example .env

# Start Postgres + Redis
docker compose up -d

# Install deps + generate Prisma client
npm install
npm run db:generate

# Apply migrations
npm run db:migrate

# Seed system categories
npm run db:seed

# Run the dev server
npm run dev
```

The API listens on `http://localhost:3000`. OpenAPI docs at `http://localhost:3000/docs`.

## Useful scripts

| Command | Description |
| --- | --- |
| `npm run dev` | tsx watch on `src/index.ts` |
| `npm run build` | tsc compile to `dist/` |
| `npm run start` | run compiled output |
| `npm run test` | vitest |
| `npm run db:generate` | regenerate Prisma client |
| `npm run db:migrate` | create + apply a migration |
| `npm run db:seed` | seed reference data |

## OTP in development
SMS OTP is stubbed. Either:
- read the code from server logs (`[otp] phone=... code=...`), or
- use the bypass code `000000` (configurable via `OTP_DEV_BYPASS_CODE`).
