// Zod schemas for /v1/auth endpoints.
import { z } from 'zod';

export const phoneE164 = z.string().regex(/^\+[1-9]\d{6,14}$/);

export const signUpBody = z.object({
  method: z.enum(['phone', 'apple', 'google', 'password']),
  phone: phoneE164.optional(),
  email: z.string().email().optional(),
  password: z.string().min(8).optional(),
  idToken: z.string().optional(),
  locale: z.enum(['ru-RU', 'ru-KZ', 'kk-KZ', 'en-US']).optional(),
  timezone: z.string().optional(),
  marketingConsent: z.boolean().optional(),
  referralCode: z.string().regex(/^[A-Z0-9]{4,16}$/).optional(),
});

export const signInBody = z.object({
  method: z.enum(['phone', 'apple', 'google', 'password']),
  phone: phoneE164.optional(),
  email: z.string().email().optional(),
  password: z.string().min(1).optional(),
  idToken: z.string().optional(),
});

export const otpRequestBody = z.object({
  phone: phoneE164,
  purpose: z.enum(['sign_in', 'sign_up', 'change_phone']).optional(),
});

export const otpVerifyBody = z.object({
  requestId: z.string(),
  code: z.string().length(6),
});

export const refreshBody = z.object({
  refreshToken: z.string(),
});

export type SignUpBody = z.infer<typeof signUpBody>;
export type SignInBody = z.infer<typeof signInBody>;
