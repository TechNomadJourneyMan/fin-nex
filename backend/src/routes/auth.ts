// /v1/auth/* routes: sign-up, sign-in, OTP, refresh, sign-out.
import type { FastifyInstance } from 'fastify';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';
import {
  otpRequestBody,
  otpVerifyBody,
  refreshBody,
  signInBody,
  signUpBody,
} from '../schemas/auth.js';
import {
  hashPassword,
  issueTokens,
  revokeSession,
  rotateRefresh,
  verifyPassword,
} from '../services/auth.service.js';
import { requestOtp, verifyOtp } from '../services/otp.service.js';

export default async function authRoutes(app: FastifyInstance): Promise<void> {
  app.post('/v1/auth/sign-up', async (req, reply) => {
    const body = signUpBody.parse(req.body);
    if (body.method === 'phone' && !body.phone) {
      throw new ApiError(422, 'VALIDATION_FAILED', 'phone required for method=phone');
    }
    if (body.method === 'password' && (!body.email || !body.password)) {
      throw new ApiError(422, 'VALIDATION_FAILED', 'email and password required');
    }

    const existing = await prisma.user.findFirst({
      where: {
        OR: [
          body.email ? { email: body.email } : { id: '__none__' },
          body.phone ? { phoneE164: body.phone } : { id: '__none__' },
        ],
      },
    });
    if (existing) throw new ApiError(409, 'USER_ALREADY_EXISTS', 'User already exists');

    const passwordHash = body.password ? await hashPassword(body.password) : null;
    const user = await prisma.user.create({
      data: {
        id: newId('usr'),
        email: body.email,
        phoneE164: body.phone,
        passwordHash,
        displayName: body.email?.split('@')[0],
        locale: body.locale ?? 'ru-KZ',
        timezone: body.timezone ?? 'Asia/Almaty',
        marketingConsent: body.marketingConsent ?? false,
      },
    });

    const tokens = await issueTokens({ userId: user.id, plan: user.plan, locale: user.locale });
    reply.status(201);
    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phoneE164,
        createdAt: user.createdAt.toISOString(),
      },
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
      tokenType: 'Bearer',
    };
  });

  app.post('/v1/auth/sign-in', async (req) => {
    const body = signInBody.parse(req.body);
    const user = await prisma.user.findFirst({
      where: {
        OR: [
          body.email ? { email: body.email } : { id: '__none__' },
          body.phone ? { phoneE164: body.phone } : { id: '__none__' },
        ],
      },
    });
    if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'User not found');

    if (body.method === 'password') {
      if (!body.password || !user.passwordHash) {
        throw new ApiError(401, 'UNAUTHENTICATED', 'Invalid credentials');
      }
      const ok = await verifyPassword(user.passwordHash, body.password);
      if (!ok) throw new ApiError(401, 'UNAUTHENTICATED', 'Invalid credentials');
    }

    const tokens = await issueTokens({ userId: user.id, plan: user.plan, locale: user.locale });
    return {
      user: { id: user.id, email: user.email, phone: user.phoneE164 },
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
      tokenType: 'Bearer',
    };
  });

  app.post('/v1/auth/otp/request', async (req, reply) => {
    const body = otpRequestBody.parse(req.body);
    const result = requestOtp(body.phone);
    reply.status(202);
    return result;
  });

  app.post('/v1/auth/otp/verify', async (req) => {
    const body = otpVerifyBody.parse(req.body);
    const result = verifyOtp(body.requestId, body.code);
    if (!result.ok) {
      if (result.reason === 'EXPIRED') throw new ApiError(410, 'OTP_EXPIRED', 'OTP expired');
      if (result.reason === 'TOO_MANY_ATTEMPTS') {
        throw new ApiError(429, 'OTP_ATTEMPTS_EXCEEDED', 'Too many OTP attempts');
      }
      throw new ApiError(401, 'INVALID_OTP', 'Invalid OTP code');
    }

    let user = await prisma.user.findUnique({ where: { phoneE164: result.phone } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          id: newId('usr'),
          phoneE164: result.phone,
          phoneVerifiedAt: new Date(),
        },
      });
    }
    const tokens = await issueTokens({ userId: user.id, plan: user.plan });
    return {
      user: { id: user.id, phone: user.phoneE164 },
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
      tokenType: 'Bearer',
    };
  });

  app.post('/v1/auth/refresh', async (req) => {
    const body = refreshBody.parse(req.body);
    try {
      const tokens = await rotateRefresh(body.refreshToken);
      return {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
        tokenType: 'Bearer',
      };
    } catch (err) {
      const code = (err as Error).message;
      if (code === 'REFRESH_TOKEN_REUSED') {
        throw new ApiError(401, 'REFRESH_TOKEN_REUSED', 'Refresh token reuse detected');
      }
      throw new ApiError(401, 'INVALID_REFRESH_TOKEN', 'Invalid refresh token');
    }
  });

  app.post(
    '/v1/auth/sign-out',
    { preHandler: [app.requireAuth] },
    async (req, reply) => {
      if (req.auth?.sessionId) await revokeSession(req.auth.sessionId);
      reply.status(204);
      return null;
    },
  );

  app.post(
    '/v1/auth/sign-out-all',
    { preHandler: [app.requireAuth] },
    async (req, reply) => {
      if (req.auth?.userId) {
        await prisma.session.updateMany({
          where: { userId: req.auth.userId, revokedAt: null },
          data: { revokedAt: new Date(), revokeReason: 'sign_out_all' },
        });
      }
      reply.status(204);
      return null;
    },
  );

  app.get(
    '/v1/auth/sessions',
    { preHandler: [app.requireAuth] },
    async (req) => {
      const sessions = await prisma.session.findMany({
        where: { userId: req.auth!.userId, revokedAt: null },
        orderBy: { issuedAt: 'desc' },
      });
      return {
        data: sessions.map((s) => ({
          id: s.id,
          deviceId: s.deviceId,
          issuedAt: s.issuedAt.toISOString(),
          expiresAt: s.expiresAt.toISOString(),
          ipAddress: s.ipAddress,
          userAgent: s.userAgent,
        })),
      };
    },
  );

  app.delete(
    '/v1/auth/sessions/:id',
    { preHandler: [app.requireAuth] },
    async (req, reply) => {
      const { id } = req.params as { id: string };
      await prisma.session.updateMany({
        where: { id, userId: req.auth!.userId },
        data: { revokedAt: new Date(), revokeReason: 'manual' },
      });
      reply.status(204);
      return null;
    },
  );
}
