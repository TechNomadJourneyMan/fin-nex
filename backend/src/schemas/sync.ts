// Zod schemas for /v1/sync.
import { z } from 'zod';
import { isoDateTime, ulidString } from './common.js';

export const syncPushBody = z.object({
  deviceId: ulidString,
  lastKnownServerRevision: z.number().int().nonnegative().optional(),
  changes: z.array(
    z.object({
      entity: z.enum(['transaction', 'account', 'category', 'budget', 'tag']),
      op: z.enum(['create', 'update', 'delete']),
      clientId: ulidString,
      id: ulidString.optional(),
      clientUpdatedAt: isoDateTime,
      clientRevision: z.number().int().optional(),
      payload: z.record(z.string(), z.unknown()).optional(),
    }),
  ).min(1).max(1000),
});

export const syncPullQuery = z.object({
  since: z.coerce.number().int().optional(),
  sinceCursor: z.string().optional(),
  entities: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(1000).optional().default(500),
});
