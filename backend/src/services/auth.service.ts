// Auth service: JWT signing, refresh rotation, password hashing.
import argon2 from 'argon2';
import { createHash } from 'node:crypto';
import jwt from 'jsonwebtoken';
import { env } from '../lib/env.js';
import { newId } from '../lib/ids.js';
import { prisma } from '../lib/prisma.js';

export interface IssuedTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  refreshExpiresAt: Date;
  sessionId: string;
  jti: string;
}

/** Hashes a password using argon2id. */
export async function hashPassword(plain: string): Promise<string> {
  return argon2.hash(plain, { type: argon2.argon2id });
}

/** Verifies a password hash. */
export async function verifyPassword(hash: string, plain: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, plain);
  } catch {
    return false;
  }
}

/** SHA-256 of a token, for storage in the sessions table. */
export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

/**
 * Issues a new access+refresh token pair and persists the session row.
 */
export async function issueTokens(opts: {
  userId: string;
  deviceId?: string;
  plan?: string;
  locale?: string;
}): Promise<IssuedTokens> {
  const jti = newId('ses');
  const refreshToken = newId('rft');
  const now = Math.floor(Date.now() / 1000);
  const accessToken = jwt.sign(
    {
      sub: opts.userId,
      jti,
      device_id: opts.deviceId,
      plan: opts.plan ?? 'free',
      locale: opts.locale ?? 'ru-RU',
      scope: 'user accounts transactions budgets analytics insights sync notifications subscriptions export',
    },
    env.JWT_SECRET,
    {
      issuer: 'https://api.finnex.kz',
      audience: 'finnex-mobile',
      expiresIn: env.JWT_ACCESS_TTL_SECONDS,
      jwtid: jti,
    },
  );

  const refreshExpiresAt = new Date((now + env.JWT_REFRESH_TTL_SECONDS) * 1000);

  await prisma.session.create({
    data: {
      id: jti,
      userId: opts.userId,
      deviceId: opts.deviceId,
      accessTokenHash: hashToken(accessToken),
      refreshTokenHash: hashToken(refreshToken),
      expiresAt: refreshExpiresAt,
    },
  });

  return {
    accessToken,
    refreshToken,
    expiresIn: env.JWT_ACCESS_TTL_SECONDS,
    refreshExpiresAt,
    sessionId: jti,
    jti,
  };
}

/** Rotates the refresh token: revokes the previous session and issues new tokens. */
export async function rotateRefresh(refreshToken: string): Promise<IssuedTokens> {
  const tokenHash = hashToken(refreshToken);
  const session = await prisma.session.findUnique({ where: { refreshTokenHash: tokenHash } });
  if (!session) {
    throw new Error('INVALID_REFRESH_TOKEN');
  }
  if (session.revokedAt) {
    // Reuse detection: revoke all sessions for this user.
    await prisma.session.updateMany({
      where: { userId: session.userId, revokedAt: null },
      data: { revokedAt: new Date(), revokeReason: 'reuse_detected' },
    });
    throw new Error('REFRESH_TOKEN_REUSED');
  }
  if (session.expiresAt < new Date()) {
    throw new Error('INVALID_REFRESH_TOKEN');
  }
  await prisma.session.update({
    where: { id: session.id },
    data: { revokedAt: new Date(), revokeReason: 'rotated' },
  });
  return issueTokens({ userId: session.userId, deviceId: session.deviceId ?? undefined });
}

/** Revokes a single session by id. */
export async function revokeSession(sessionId: string): Promise<void> {
  await prisma.session.update({
    where: { id: sessionId },
    data: { revokedAt: new Date(), revokeReason: 'sign_out' },
  });
}
