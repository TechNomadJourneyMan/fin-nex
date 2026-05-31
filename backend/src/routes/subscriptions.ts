// /v1/subscriptions — me, validate-receipt (stub).
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';

const validateBody = z.object({
  store: z.enum(['appstore', 'playstore', 'promo']),
  receipt: z.string(),
  transactionId: z.string().optional(),
  productId: z.string(),
});

export default async function subscriptionsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/subscriptions/me', { preHandler: [app.requireAuth] }, async (req) => {
    const sub = await prisma.subscription.findUnique({ where: { userId: req.auth!.userId } });
    if (!sub) {
      return {
        plan: 'free',
        status: 'inactive',
        store: null,
        productId: null,
        autoRenew: false,
      };
    }
    return {
      plan: sub.plan,
      status: sub.status,
      store: sub.store,
      productId: sub.productId,
      startedAt: sub.startedAt?.toISOString() ?? null,
      currentPeriodEnd: sub.currentPeriodEnd?.toISOString() ?? null,
      autoRenew: sub.autoRenew,
      cancelledAt: sub.cancelledAt?.toISOString() ?? null,
      inGracePeriod: sub.inGracePeriod,
    };
  });

  app.post('/v1/subscriptions/validate-receipt', { preHandler: [app.requireAuth] }, async (req) => {
    const body = validateBody.parse(req.body);
    // TODO(F-SUBS): integrate App Store Server API + Google Play Developer API.
    if (!body.receipt) throw new ApiError(400, 'INVALID_RECEIPT', 'Receipt is empty');

    const sub = await prisma.subscription.upsert({
      where: { userId: req.auth!.userId },
      update: {
        plan: 'pro',
        status: 'active',
        store: body.store,
        productId: body.productId,
        startedAt: new Date(),
        currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        autoRenew: true,
      },
      create: {
        id: newId('sub'),
        userId: req.auth!.userId,
        plan: 'pro',
        status: 'active',
        store: body.store,
        productId: body.productId,
        startedAt: new Date(),
        currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        autoRenew: true,
      },
    });
    return { plan: sub.plan, status: sub.status, currentPeriodEnd: sub.currentPeriodEnd?.toISOString() };
  });

  app.post('/v1/subscriptions/restore', { preHandler: [app.requireAuth] }, async (req) => {
    const sub = await prisma.subscription.findUnique({ where: { userId: req.auth!.userId } });
    return { restored: !!sub, plan: sub?.plan ?? 'free' };
  });
}
