// Server bootstrap — binds the Fastify app to a port.
import { buildApp } from './app.js';
import { env } from './lib/env.js';

async function main(): Promise<void> {
  const app = await buildApp();
  try {
    await app.listen({ host: env.HOST, port: env.PORT });
    app.log.info(`FinNex API listening on http://${env.HOST}:${env.PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

void main();
