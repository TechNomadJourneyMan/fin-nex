// /v1/export — request, status, download.
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';

const requestBody = z.object({
  format: z.enum(['csv', 'xlsx', 'json', 'pdf']),
  from: z.string(),
  to: z.string(),
  entities: z.array(z.string()).optional(),
  language: z.string().optional(),
});

export default async function exportRoutes(app: FastifyInstance): Promise<void> {
  app.post('/v1/export/request', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = requestBody.parse(req.body);
    const job = await prisma.exportJob.create({
      data: {
        id: newId('job'),
        userId: req.auth!.userId,
        format: body.format,
        fromDate: new Date(body.from),
        toDate: new Date(body.to),
        entities: body.entities ?? ['transactions', 'accounts', 'budgets', 'categories'],
        status: 'queued',
      },
    });
    reply.status(202);
    return {
      jobId: job.id,
      status: job.status,
      createdAt: job.createdAt.toISOString(),
      estimatedSeconds: 30,
    };
  });

  app.get('/v1/export/:jobId/status', { preHandler: [app.requireAuth] }, async (req) => {
    const { jobId } = req.params as { jobId: string };
    const job = await prisma.exportJob.findFirst({
      where: { id: jobId, userId: req.auth!.userId },
    });
    if (!job) throw new ApiError(404, 'JOB_NOT_FOUND', 'Job not found');
    return {
      jobId: job.id,
      status: job.status,
      progress: job.progress,
      completedAt: job.completedAt?.toISOString() ?? null,
      downloadUrl: job.downloadUrl,
      expiresAt: job.expiresAt?.toISOString() ?? null,
      error: job.errorMessage,
    };
  });

  app.get('/v1/export/:jobId/download', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { jobId } = req.params as { jobId: string };
    const job = await prisma.exportJob.findFirst({
      where: { id: jobId, userId: req.auth!.userId },
    });
    if (!job) throw new ApiError(404, 'JOB_NOT_FOUND', 'Job not found');
    if (job.status !== 'completed') {
      throw new ApiError(409, 'EXPORT_NOT_READY', `Status: ${job.status}`);
    }
    if (!job.downloadUrl) throw new ApiError(410, 'EXPORT_EXPIRED', 'Download URL expired');
    reply.redirect(302, job.downloadUrl);
    return null;
  });
}
