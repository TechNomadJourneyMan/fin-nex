// Zod schemas for /v1/transactions.
import { z } from 'zod';
import { currencyCode, isoDateTime, minorAmount, ulidString } from './common.js';

export const transactionCreateBody = z.object({
  clientId: ulidString,
  accountId: ulidString,
  categoryId: ulidString.nullish(),
  type: z.enum(['expense', 'income', 'transfer', 'adjustment']),
  amountMinor: minorAmount,
  currency: currencyCode,
  occurredAt: isoDateTime,
  description: z.string().max(200).optional(),
  note: z.string().max(500).optional(),
  tags: z.array(z.string().min(1).max(20)).max(5).optional(),
  transferTargetAccountId: ulidString.nullish(),
  source: z.enum(['manual', 'widget', 'sms', 'kaspi_import', 'qr_receipt', 'api', 'recurring']).optional(),
});

export const transactionUpdateBody = transactionCreateBody.partial().omit({ clientId: true });

export const transactionListQuery = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(200).optional().default(50),
  from: isoDateTime.optional(),
  to: isoDateTime.optional(),
  accountId: ulidString.optional(),
  categoryId: ulidString.optional(),
  type: z.enum(['expense', 'income', 'transfer', 'adjustment']).optional(),
  minAmount: z.coerce.number().int().optional(),
  maxAmount: z.coerce.number().int().optional(),
  query: z.string().max(100).optional(),
  source: z.string().optional(),
  order: z.enum(['occurred_at:desc', 'occurred_at:asc', 'amount:desc', 'amount:asc']).optional(),
});

export const transactionBulkBody = z.object({
  transactions: z.array(transactionCreateBody).min(1).max(1000),
  importSessionId: ulidString.optional(),
  source: z.string().optional(),
  onConflict: z.enum(['skip', 'update', 'fail']).optional(),
});
