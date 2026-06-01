// Environment loader with safe defaults.
import 'dotenv/config';

export interface Env {
  NODE_ENV: 'development' | 'staging' | 'production' | 'test';
  PORT: number;
  HOST: string;
  LOG_LEVEL: string;
  DATABASE_URL: string;
  REDIS_URL: string;
  JWT_SECRET: string;
  JWT_ACCESS_TTL_SECONDS: number;
  JWT_REFRESH_TTL_SECONDS: number;
  OTP_DEV_BYPASS_CODE: string;
}

function int(value: string | undefined, fallback: number): number {
  if (!value) return fallback;
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

export const env: Env = {
  NODE_ENV: (process.env.NODE_ENV ?? 'development') as Env['NODE_ENV'],
  PORT: int(process.env.PORT, 3000),
  HOST: process.env.HOST ?? '0.0.0.0',
  LOG_LEVEL: process.env.LOG_LEVEL ?? 'info',
  DATABASE_URL:
    process.env.DATABASE_URL ??
    'postgresql://pocketflow:pocketflow@localhost:5432/pocketflow?schema=public',
  REDIS_URL: process.env.REDIS_URL ?? 'redis://localhost:6379',
  JWT_SECRET: process.env.JWT_SECRET ?? 'dev-jwt-secret-change-me',
  JWT_ACCESS_TTL_SECONDS: int(process.env.JWT_ACCESS_TTL_SECONDS, 900),
  JWT_REFRESH_TTL_SECONDS: int(process.env.JWT_REFRESH_TTL_SECONDS, 60 * 60 * 24 * 30),
  OTP_DEV_BYPASS_CODE: process.env.OTP_DEV_BYPASS_CODE ?? '000000',
};
