// /v1/insights — list + dismiss.
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';

const dismissBody = z.object({
  reason: z.enum(['not_relevant', 'already_aware', 'incorrect', 'other']).optional(),
  comment: z.string().max(500).optional(),
});

export default async function insightsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/insights', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as { status?: string; severity?: string };
    const rows = await prisma.insight.findMany({
      where: {
        userId: req.auth!.userId,
        ...(q.status === 'dismissed' ? { dismissedAt: { not: null } } : q.status === 'new' ? { dismissedAt: null } : {}),
        ...(q.severity ? { severity: q.severity } : {}),
      },
      orderBy: { generatedAt: 'desc' },
      take: 100,
    });
    return {
      data: rows.map((r) => ({
        id: r.id,
        kind: r.kind,
        severity: r.severity,
        title: r.title,
        body: r.body,
        generatedAt: r.generatedAt.toISOString(),
        expiresAt: r.expiresAt?.toISOString() ?? null,
        status: r.dismissedAt ? 'dismissed' : 'new',
      })),
    };
  });

  app.post('/v1/insights/:id/dismiss', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    dismissBody.parse(req.body ?? {});
    const existing = await prisma.insight.findFirst({ where: { id, userId: req.auth!.userId } });
    if (!existing) throw new ApiError(404, 'NOT_FOUND', 'Insight not found');
    await prisma.insight.update({ where: { id }, data: { dismissedAt: new Date() } });
    reply.status(204);
    return null;
  });
}
