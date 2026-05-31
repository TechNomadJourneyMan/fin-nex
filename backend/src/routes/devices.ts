// /v1/devices — register and delete push-token registrations.
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { newId } from '../lib/ids.js';
import { prisma } from '../lib/prisma.js';

const registerBody = z.object({
  deviceId: z.string().optional(),
  platform: z.enum(['ios', 'android', 'web', 'widget_ios', 'widget_android']),
  pushProvider: z.enum(['apns', 'fcm', 'web_push']).optional(),
  pushToken: z.string().optional(),
  appVersion: z.string().optional(),
  osVersion: z.string().optional(),
  model: z.string().optional(),
  locale: z.string().optional(),
  timezone: z.string().optional(),
  installId: z.string(),
});

export default async function devicesRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/devices', { preHandler: [app.requireAuth] }, async (req) => {
    const rows = await prisma.device.findMany({
      where: { userId: req.auth!.userId, revokedAt: null },
      orderBy: { lastSeenAt: 'desc' },
    });
    return {
      data: rows.map((d) => ({
        id: d.id,
        platform: d.platform,
        deviceName: d.deviceName,
        osVersion: d.osVersion,
        appVersion: d.appVersion,
        firstSeenAt: d.firstSeenAt.toISOString(),
        lastSeenAt: d.lastSeenAt.toISOString(),
      })),
    };
  });

  app.post('/v1/devices', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = registerBody.parse(req.body);
    const device = await prisma.device.upsert({
      where: { userId_installId: { userId: req.auth!.userId, installId: body.installId } },
      update: {
        platform: body.platform,
        pushToken: body.pushToken,
        pushTokenType: body.pushProvider,
        appVersion: body.appVersion,
        osVersion: body.osVersion,
        deviceName: body.model,
        language: body.locale,
        timezone: body.timezone,
        lastSeenAt: new Date(),
      },
      create: {
        id: body.deviceId ?? newId('dev'),
        userId: req.auth!.userId,
        installId: body.installId,
        platform: body.platform,
        pushToken: body.pushToken,
        pushTokenType: body.pushProvider,
        appVersion: body.appVersion,
        osVersion: body.osVersion,
        deviceName: body.model,
        language: body.locale,
        timezone: body.timezone,
      },
    });
    reply.status(201);
    return { id: device.id };
  });

  app.delete('/v1/devices/:id', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    await prisma.device.updateMany({
      where: { id, userId: req.auth!.userId },
      data: { revokedAt: new Date() },
    });
    reply.status(204);
    return null;
  });
}
