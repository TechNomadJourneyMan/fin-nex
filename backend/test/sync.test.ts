// Smoke test for sync endpoints.
import { describe, expect, it } from 'vitest';

describe('sync routes', () => {
  it('requires auth on push', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({
      method: 'POST',
      url: '/v1/sync/push',
      payload: { deviceId: 'dev_01', changes: [] },
    });
    expect(res.statusCode).toBe(401);
    await app.close();
  });

  it('requires auth on pull', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/v1/sync/pull' });
    expect(res.statusCode).toBe(401);
    await app.close();
  });
});
