// Maps thrown errors (ApiError, ZodError, generic) into RFC 9457 problem+json.
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import { ZodError } from 'zod';
import { ApiError, toProblem } from '../lib/problem.js';

async function plugin(app: FastifyInstance): Promise<void> {
  app.setErrorHandler((err, req: FastifyRequest, reply: FastifyReply) => {
    const traceId = (req.headers['x-trace-id'] as string | undefined) ?? req.id;
    reply.header('content-type', 'application/problem+json; charset=utf-8');

    if (err instanceof ApiError) {
      const problem = toProblem(err, { instance: req.url, traceId });
      return reply.status(err.status).send(problem);
    }

    if (err instanceof ZodError) {
      const apiErr = new ApiError(
        422,
        'VALIDATION_FAILED',
        'Request validation failed',
        err.errors.map((e) => ({
          field: e.path.join('.'),
          code: e.code,
          message: e.message,
        })),
      );
      return reply.status(422).send(toProblem(apiErr, { instance: req.url, traceId }));
    }

    if ((err as { statusCode?: number }).statusCode === 429) {
      const apiErr = new ApiError(429, 'RATE_LIMITED', 'Too many requests');
      return reply.status(429).send(toProblem(apiErr, { instance: req.url, traceId }));
    }

    if ((err as { statusCode?: number }).statusCode === 401) {
      const apiErr = new ApiError(401, 'UNAUTHENTICATED', err.message || 'Authentication required');
      return reply.status(401).send(toProblem(apiErr, { instance: req.url, traceId }));
    }

    req.log.error({ err }, 'unhandled error');
    const apiErr = new ApiError(500, 'INTERNAL_ERROR', 'Unexpected server error');
    return reply.status(500).send(toProblem(apiErr, { instance: req.url, traceId }));
  });
}

export default fp(plugin, { name: 'finnex-error' });
