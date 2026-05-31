// /v1/me — profile read/update/delete.
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';

const updateBody = z.object({
  displayName: z.string().min(1).max(40).optional(),
  timezone: z.string().optional(),
  primaryCurrency: z.string().length(3).optional(),
  locale: z.string().optional(),
});

const deleteBody = z.object({
  reason: z.string().max(200).optional(),
  confirmPhrase: z.literal('DELETE'),
});

export default async function meRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/me', { preHandler: [app.requireAuth] }, async (req) => {
    const user = await prisma.user.findUnique({ where: { id: req.auth!.userId } });
    if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'User not found');
    return {
      id: user.id,
      email: user.email,
      phone: user.phoneE164,
      displayName: user.displayName,
      locale: user.locale,
      timezone: user.timezone,
      currencyPrimary: user.primaryCurrency,
      plan: user.plan,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
      flags: {
        emailVerified: !!user.emailVerifiedAt,
        phoneVerified: !!user.phoneVerifiedAt,
      },
    };
  });

  app.patch('/v1/me', { preHandler: [app.requireAuth] }, async (req) => {
    const body = updateBody.parse(req.body);
    const updated = await prisma.user.update({
      where: { id: req.auth!.userId },
      data: {
        displayName: body.displayName,
        timezone: body.timezone,
        primaryCurrency: body.primaryCurrency,
        locale: body.locale,
      },
    });
    return { id: updated.id, displayName: updated.displayName, updatedAt: updated.updatedAt.toISOString() };
  });

  app.delete('/v1/me', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = deleteBody.parse(req.body);
    const scheduledAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    await prisma.user.update({
      where: { id: req.auth!.userId },
      data: {
        deletionRequestedAt: new Date(),
        status: 'deletion_requested',
      },
    });
    reply.status(202);
    return { erasureScheduledAt: scheduledAt.toISOString(), reason: body.reason ?? null };
  });
}
