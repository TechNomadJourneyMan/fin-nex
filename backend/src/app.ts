// Fastify app builder — exported so tests can spin up an in-memory server.
import Fastify, { type FastifyInstance } from 'fastify';
import { env } from './lib/env.js';
import authPlugin from './plugins/auth.js';
import corsPlugin from './plugins/cors.js';
import errorPlugin from './plugins/error.js';
import rateLimitPlugin from './plugins/rate-limit.js';
import swaggerPlugin from './plugins/swagger.js';
import authRoutes from './routes/auth.js';
import meRoutes from './routes/me.js';
import accountsRoutes from './routes/accounts.js';
import categoriesRoutes from './routes/categories.js';
import transactionsRoutes from './routes/transactions.js';
import budgetsRoutes from './routes/budgets.js';
import analyticsRoutes from './routes/analytics.js';
import insightsRoutes from './routes/insights.js';
import notificationsRoutes from './routes/notifications.js';
import syncRoutes from './routes/sync.js';
import devicesRoutes from './routes/devices.js';
import subscriptionsRoutes from './routes/subscriptions.js';
import exportRoutes from './routes/export.js';

/** Builds a configured Fastify instance with all plugins and routes registered. */
export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
      transport:
        env.NODE_ENV === 'development'
          ? { target: 'pino-pretty', options: { colorize: true, translateTime: 'SYS:HH:MM:ss' } }
          : undefined,
    },
    genReqId: () => cryptoRandomId(),
    bodyLimit: 5 * 1024 * 1024,
  });

  await app.register(errorPlugin);
  await app.register(corsPlugin);
  await app.register(authPlugin);
  await app.register(rateLimitPlugin);
  await app.register(swaggerPlugin);

  app.get('/health', async () => ({ status: 'ok', time: new Date().toISOString() }));

  await app.register(authRoutes);
  await app.register(meRoutes);
  await app.register(accountsRoutes);
  await app.register(categoriesRoutes);
  await app.register(transactionsRoutes);
  await app.register(budgetsRoutes);
  await app.register(analyticsRoutes);
  await app.register(insightsRoutes);
  await app.register(notificationsRoutes);
  await app.register(syncRoutes);
  await app.register(devicesRoutes);
  await app.register(subscriptionsRoutes);
  await app.register(exportRoutes);

  return app;
}

function cryptoRandomId(): string {
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
