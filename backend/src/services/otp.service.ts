// OTP service stub. Stores codes in memory; accepts dev-bypass code "000000".
// TODO(F-AUTH-OTP): replace in-memory store with Redis, integrate SMS provider.
import { env } from '../lib/env.js';
import { newId } from '../lib/ids.js';

interface OtpRecord {
  requestId: string;
  phone: string;
  code: string;
  expiresAt: number;
  attempts: number;
}

const STORE = new Map<string, OtpRecord>();
const TTL_MS = 5 * 60 * 1000;
const MAX_ATTEMPTS = 3;

/** Creates an OTP record and returns its request id. */
export function requestOtp(phone: string): { requestId: string; expiresIn: number; resendAfter: number } {
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const requestId = newId('otp');
  const record: OtpRecord = {
    requestId,
    phone,
    code,
    expiresAt: Date.now() + TTL_MS,
    attempts: 0,
  };
  STORE.set(requestId, record);
  if (env.NODE_ENV !== 'production') {
    // eslint-disable-next-line no-console
    console.log(`[otp] phone=${phone} code=${code} requestId=${requestId}`);
  }
  return { requestId, expiresIn: 300, resendAfter: 60 };
}

export type OtpResult =
  | { ok: true; phone: string }
  | { ok: false; reason: 'NOT_FOUND' | 'EXPIRED' | 'INVALID' | 'TOO_MANY_ATTEMPTS' };

/** Validates the OTP code; accepts dev-bypass in non-prod. */
export function verifyOtp(requestId: string, code: string): OtpResult {
  const record = STORE.get(requestId);
  if (!record) return { ok: false, reason: 'NOT_FOUND' };
  if (Date.now() > record.expiresAt) {
    STORE.delete(requestId);
    return { ok: false, reason: 'EXPIRED' };
  }
  record.attempts += 1;
  if (record.attempts > MAX_ATTEMPTS) {
    STORE.delete(requestId);
    return { ok: false, reason: 'TOO_MANY_ATTEMPTS' };
  }
  const accepted =
    record.code === code ||
    (env.NODE_ENV !== 'production' && code === env.OTP_DEV_BYPASS_CODE);
  if (!accepted) return { ok: false, reason: 'INVALID' };
  STORE.delete(requestId);
  return { ok: true, phone: record.phone };
}
