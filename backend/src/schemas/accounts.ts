// Zod schemas for /v1/accounts.
import { z } from 'zod';
import { currencyCode, ulidString } from './common.js';

export const accountCreateBody = z.object({
  clientId: ulidString,
  name: z.string().min(1).max(40),
  type: z.enum(['cash', 'debit_card', 'credit_card', 'bank_account', 'savings', 'wallet', 'crypto', 'investment', 'other', 'card', 'credit']),
  currency: currencyCode,
  initialBalanceMinor: z.number().int().nonnegative().optional(),
  creditLimitMinor: z.number().int().nonnegative().optional(),
  bankCode: z.string().max(40).optional(),
  lastFour: z.string().length(4).optional(),
  icon: z.string().optional(),
  color: z.string().regex(/^#[0-9a-fA-F]{6}$/).optional(),
  isPrimary: z.boolean().optional(),
  sortOrder: z.number().int().optional(),
});

export const accountUpdateBody = accountCreateBody.partial().omit({ clientId: true });
