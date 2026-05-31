// /v1/sync — push, pull, status.
import type { FastifyInstance } from 'fastify';
import { prisma } from '../lib/prisma.js';
import { syncPullQuery, syncPushBody } from '../schemas/sync.js';
import { pullChanges, pushChanges, type ChangePush } from '../services/sync.service.js';

export default async function syncRoutes(app: FastifyInstance): Promise<void> {
  app.post('/v1/sync/push', { preHandler: [app.requireAuth] }, async (req) => {
    const body = syncPushBody.parse(req.body);
    const changes: ChangePush[] = body.changes.map((c) => ({
      entity: c.entity as ChangePush['entity'],
      op: c.op,
      clientId: c.clientId,
      id: c.id,
      clientUpdatedAt: c.clientUpdatedAt,
      clientRevision: c.clientRevision,
      payload: c.payload,
    }));
    return pushChanges(req.auth!.userId, changes);
  });

  app.get('/v1/sync/pull', { preHandler: [app.requireAuth] }, async (req) => {
    const q = syncPullQuery.parse(req.query);
    return pullChanges(req.auth!.userId, q.since ?? 0);
  });

  app.get('/v1/sync/status', { preHandler: [app.requireAuth] }, async (req) => {
    const latest = await prisma.transaction.findFirst({
      where: { userId: req.auth!.userId },
      orderBy: { updatedAt: 'desc' },
      select: { updatedAt: true },
    });
    return {
      serverRevision: latest?.updatedAt.getTime() ?? 0,
      lastPushAt: null,
      lastPullAt: null,
      pendingConflicts: 0,
    };
  });
}
