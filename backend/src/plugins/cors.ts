// CORS configuration — open in dev, restricted in prod.
import type { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import fp from 'fastify-plugin';
import { env } from '../lib/env.js';

async function plugin(app: FastifyInstance): Promise<void> {
  await app.register(cors, {
    origin: env.NODE_ENV === 'production'
      ? ['https://finnex.kz', 'https://app.finnex.kz']
      : true,
    credentials: true,
    exposedHeaders: ['ETag', 'X-Trace-Id', 'X-RateLimit-Limit', 'X-RateLimit-Remaining', 'Retry-After'],
    allowedHeaders: [
      'Authorization',
      'Content-Type',
      'X-Device-Id',
      'X-Client-Version',
      'X-Idempotency-Key',
      'X-Trace-Id',
      'X-Timezone',
      'If-Match',
      'If-None-Match',
      'Accept-Language',
    ],
  });
}

export default fp(plugin, { name: 'pocketflow-cors' });
