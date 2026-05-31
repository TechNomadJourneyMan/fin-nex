// JWT verification plugin. Adds `request.auth` with the decoded principal.
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import jwt from 'jsonwebtoken';
import { env } from '../lib/env.js';
import { ApiError } from '../lib/problem.js';

export interface AuthPrincipal {
  userId: string;
  deviceId?: string;
  sessionId?: string;
  plan: string;
  scope: string[];
}

declare module 'fastify' {
  interface FastifyRequest {
    auth?: AuthPrincipal;
  }
  interface FastifyInstance {
    requireAuth: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

async function plugin(app: FastifyInstance): Promise<void> {
  app.decorate('requireAuth', async (req: FastifyRequest, _reply: FastifyReply) => {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw new ApiError(401, 'UNAUTHENTICATED', 'Missing or invalid Authorization');
    }
    const token = header.slice('Bearer '.length).trim();
    try {
      const payload = jwt.verify(token, env.JWT_SECRET) as jwt.JwtPayload;
      req.auth = {
        userId: String(payload.sub),
        deviceId: payload.device_id as string | undefined,
        sessionId: payload.jti as string | undefined,
        plan: (payload.plan as string | undefined) ?? 'free',
        scope: typeof payload.scope === 'string' ? payload.scope.split(' ') : [],
      };
    } catch (err) {
      if (err instanceof jwt.TokenExpiredError) {
        throw new ApiError(401, 'TOKEN_EXPIRED', 'Access token expired');
      }
      throw new ApiError(401, 'UNAUTHENTICATED', 'Invalid access token');
    }
  });
}

export default fp(plugin, { name: 'finnex-auth' });
