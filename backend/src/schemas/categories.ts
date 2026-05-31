// Zod schemas for /v1/categories.
import { z } from 'zod';
import { ulidString } from './common.js';

export const categoryCreateBody = z.object({
  clientId: ulidString,
  kind: z.enum(['expense', 'income', 'transfer', 'adjustment']),
  parentId: ulidString.nullish(),
  name: z.string().min(1).max(30),
  icon: z.string(),
  color: z.string().regex(/^#[0-9a-fA-F]{6}$/),
  sortOrder: z.number().int().optional(),
  monthlyLimitMinor: z.number().int().nonnegative().optional(),
});

export const categoryUpdateBody = categoryCreateBody.partial().omit({ clientId: true });

export const categoryDeleteQuery = z.object({
  reassignTo: ulidString.optional(),
});
