// Shared Zod primitives.
import { z } from 'zod';

export const ulidString = z.string().min(8).max(64);
export const isoDateTime = z.string().datetime({ offset: true });
export const isoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/);
export const currencyCode = z.string().length(3);
export const minorAmount = z.number().int().nonnegative();

export const cursorPaginationQuery = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(200).optional().default(50),
});

export type CursorPaginationQuery = z.infer<typeof cursorPaginationQuery>;
