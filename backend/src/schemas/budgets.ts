// Zod schemas for /v1/budgets.
import { z } from 'zod';
import { currencyCode, isoDate, minorAmount, ulidString } from './common.js';

export const budgetCreateBody = z.object({
  clientId: ulidString,
  name: z.string().min(1).max(40),
  period: z.enum(['weekly', 'monthly', 'quarterly', 'yearly', 'custom']),
  amountMinor: minorAmount,
  currency: currencyCode,
  startsOn: isoDate,
  endsOn: isoDate.optional(),
  scope: z.enum(['category', 'account', 'total']).optional(),
  categoryIds: z.array(ulidString).optional(),
  accountIds: z.array(ulidString).optional(),
  rollover: z.boolean().optional(),
  alertThresholds: z.array(z.number().int().min(1).max(200)).optional(),
});

export const budgetUpdateBody = budgetCreateBody.partial().omit({ clientId: true });
