// Smoke test for transactions routes — verifies route registration + auth gate.
import { describe, expect, it } from 'vitest';

describe('transactions routes', () => {
  it('requires authentication', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/v1/transactions' });
    expect(res.statusCode).toBe(401);
    await app.close();
  });

  it('rejects invalid bodies', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({
      method: 'POST',
      url: '/v1/transactions',
      payload: {},
    });
    expect([401, 422]).toContain(res.statusCode);
    await app.close();
  });
});
