// /v1/notifications — list, mark-read, preferences.
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../lib/prisma.js';

const prefsBody = z.object({
  channels: z.record(z.boolean()).optional(),
  categories: z.record(z.record(z.boolean())).optional(),
  quietHours: z
    .object({
      enabled: z.boolean(),
      from: z.string(),
      to: z.string(),
      timezone: z.string(),
    })
    .optional(),
});

export default async function notificationsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/notifications', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as { unreadOnly?: string };
    const rows = await prisma.notification.findMany({
      where: {
        userId: req.auth!.userId,
        ...(q.unreadOnly === 'true' ? { readAt: null } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    return {
      data: rows.map((n) => ({
        id: n.id,
        kind: n.kind,
        title: n.title,
        body: n.body,
        payload: n.payload,
        createdAt: n.createdAt.toISOString(),
        readAt: n.readAt?.toISOString() ?? null,
      })),
    };
  });

  app.patch('/v1/notifications/:id/read', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    await prisma.notification.updateMany({
      where: { id, userId: req.auth!.userId },
      data: { readAt: new Date() },
    });
    reply.status(204);
    return null;
  });

  app.post('/v1/notifications/mark-all-read', { preHandler: [app.requireAuth] }, async (req) => {
    const result = await prisma.notification.updateMany({
      where: { userId: req.auth!.userId, readAt: null },
      data: { readAt: new Date() },
    });
    return { marked: result.count };
  });

  app.get('/v1/notifications/preferences', { preHandler: [app.requireAuth] }, async (req) => {
    const settings = await prisma.userSetting.findUnique({ where: { userId: req.auth!.userId } });
    return settings?.notificationPreferences ?? {
      channels: { push: true, email: false, inApp: true },
      categories: {
        budgetAlerts: { push: true, inApp: true },
        reminders: { push: true },
        insights: { push: false, inApp: true },
        security: { push: true, email: true },
        marketing: { push: false, email: false },
      },
      quietHours: { enabled: false, from: '23:00', to: '08:00', timezone: 'Asia/Almaty' },
    };
  });

  app.patch('/v1/notifications/preferences', { preHandler: [app.requireAuth] }, async (req) => {
    const body = prefsBody.parse(req.body);
    await prisma.userSetting.upsert({
      where: { userId: req.auth!.userId },
      update: { notificationPreferences: body as object },
      create: { userId: req.auth!.userId, notificationPreferences: body as object },
    });
    return body;
  });
}
