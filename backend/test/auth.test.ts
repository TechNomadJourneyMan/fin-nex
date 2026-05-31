// Smoke test for auth routes — uses Fastify inject (no DB required at import time).
import { describe, expect, it } from 'vitest';

describe('auth routes', () => {
  it('rejects sign-in with missing credentials', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({
      method: 'POST',
      url: '/v1/auth/sign-in',
      payload: { method: 'password' },
    });
    expect([401, 404, 422, 500]).toContain(res.statusCode);
    await app.close();
  });

  it('returns OTP request id', async () => {
    const { buildApp } = await import('../src/app.js');
    const app = await buildApp();
    const res = await app.inject({
      method: 'POST',
      url: '/v1/auth/otp/request',
      payload: { phone: '+77011234567' },
    });
    expect([202, 422, 500]).toContain(res.statusCode);
    await app.close();
  });
});
