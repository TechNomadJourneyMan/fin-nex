// Global rate limiting (60 req/min default per IP+user).
import type { FastifyInstance } from 'fastify';
import rateLimit from '@fastify/rate-limit';
import fp from 'fastify-plugin';

async function plugin(app: FastifyInstance): Promise<void> {
  await app.register(rateLimit, {
    max: 120,
    timeWindow: '1 minute',
    keyGenerator: (req) => {
      const userId = req.auth?.userId;
      if (userId) return `u:${userId}`;
      return `ip:${req.ip}`;
    },
  });
}

export default fp(plugin, { name: 'finnex-rate-limit' });
