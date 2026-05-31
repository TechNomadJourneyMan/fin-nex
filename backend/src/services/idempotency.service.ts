// Stores idempotency keys for 24h to deduplicate retried POSTs.
import { createHash } from 'node:crypto';
import { prisma } from '../lib/prisma.js';

const TTL_MS = 24 * 60 * 60 * 1000;

/** Hashes a request body for fingerprint comparison. */
export function hashRequest(body: unknown): string {
  return createHash('sha256').update(JSON.stringify(body ?? null)).digest('hex');
}

export interface StoredResponse {
  status: number;
  body: unknown;
}

/** Returns a previously stored response if the key+hash match, else null. */
export async function lookup(
  key: string,
  userId: string,
  endpoint: string,
  requestHash: string,
): Promise<{ replay: StoredResponse } | { conflict: true } | null> {
  const row = await prisma.idempotencyKey.findUnique({ where: { key } });
  if (!row) return null;
  if (row.userId !== userId || row.endpoint !== endpoint) return { conflict: true };
  if (row.requestHash !== requestHash) return { conflict: true };
  if (row.expiresAt < new Date()) return null;
  return { replay: { status: row.responseStatus, body: row.responseBody } };
}

/** Persists an idempotent response. */
export async function store(opts: {
  key: string;
  userId: string;
  endpoint: string;
  requestHash: string;
  response: StoredResponse;
}): Promise<void> {
  const expiresAt = new Date(Date.now() + TTL_MS);
  await prisma.idempotencyKey.upsert({
    where: { key: opts.key },
    update: {
      requestHash: opts.requestHash,
      responseBody: opts.response.body as object,
      responseStatus: opts.response.status,
      expiresAt,
    },
    create: {
      key: opts.key,
      userId: opts.userId,
      endpoint: opts.endpoint,
      requestHash: opts.requestHash,
      responseBody: opts.response.body as object,
      responseStatus: opts.response.status,
      expiresAt,
    },
  });
}
