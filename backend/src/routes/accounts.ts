// /v1/accounts CRUD.
import type { FastifyInstance } from 'fastify';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';
import { accountCreateBody, accountUpdateBody } from '../schemas/accounts.js';

function serialize(a: {
  id: string;
  name: string;
  typeCode: string;
  currency: string;
  balanceMinor: bigint;
  initialBalanceMinor: bigint;
  creditLimitMinor: bigint | null;
  icon: string | null;
  color: string;
  isArchived: boolean;
  isPrimary: boolean;
  bankCode: string | null;
  lastFour: string | null;
  sortOrder: number;
  createdAt: Date;
  updatedAt: Date;
  version: bigint;
}): Record<string, unknown> {
  return {
    id: a.id,
    name: a.name,
    type: a.typeCode,
    currency: a.currency,
    balanceMinor: Number(a.balanceMinor),
    initialBalanceMinor: Number(a.initialBalanceMinor),
    creditLimitMinor: a.creditLimitMinor ? Number(a.creditLimitMinor) : null,
    icon: a.icon,
    color: a.color,
    isArchived: a.isArchived,
    isPrimary: a.isPrimary,
    bankCode: a.bankCode,
    lastFour: a.lastFour,
    sortOrder: a.sortOrder,
    createdAt: a.createdAt.toISOString(),
    updatedAt: a.updatedAt.toISOString(),
    revision: Number(a.version),
  };
}

export default async function accountsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/accounts', { preHandler: [app.requireAuth] }, async (req) => {
    const includeArchived = (req.query as { includeArchived?: string }).includeArchived === 'true';
    const accounts = await prisma.account.findMany({
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        ...(includeArchived ? {} : { isArchived: false }),
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return { data: accounts.map(serialize) };
  });

  app.post('/v1/accounts', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = accountCreateBody.parse(req.body);
    const dup = await prisma.account.findFirst({
      where: { userId: req.auth!.userId, name: body.name, deletedAt: null },
    });
    if (dup) throw new ApiError(409, 'ACCOUNT_NAME_DUPLICATE', 'Duplicate account name');

    const account = await prisma.account.create({
      data: {
        id: newId('acc'),
        userId: req.auth!.userId,
        clientId: body.clientId,
        typeCode: body.type,
        name: body.name,
        currency: body.currency,
        initialBalanceMinor: BigInt(body.initialBalanceMinor ?? 0),
        balanceMinor: BigInt(body.initialBalanceMinor ?? 0),
        creditLimitMinor: body.creditLimitMinor ? BigInt(body.creditLimitMinor) : null,
        bankCode: body.bankCode,
        lastFour: body.lastFour,
        icon: body.icon,
        color: body.color ?? '#1F8FFF',
        isPrimary: body.isPrimary ?? false,
        sortOrder: body.sortOrder ?? 0,
      },
    });
    reply.status(201);
    return serialize(account);
  });

  app.get('/v1/accounts/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const account = await prisma.account.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!account) throw new ApiError(404, 'ACCOUNT_NOT_FOUND', 'Account not found');
    return serialize(account);
  });

  app.patch('/v1/accounts/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const body = accountUpdateBody.parse(req.body);
    const existing = await prisma.account.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!existing) throw new ApiError(404, 'ACCOUNT_NOT_FOUND', 'Account not found');

    const updated = await prisma.account.update({
      where: { id },
      data: {
        name: body.name,
        typeCode: body.type,
        currency: body.currency,
        creditLimitMinor: body.creditLimitMinor ? BigInt(body.creditLimitMinor) : undefined,
        icon: body.icon,
        color: body.color,
        isPrimary: body.isPrimary,
        bankCode: body.bankCode,
        lastFour: body.lastFour,
        sortOrder: body.sortOrder,
        version: { increment: 1 },
      },
    });
    return serialize(updated);
  });

  app.delete('/v1/accounts/:id', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    const force = (req.query as { force?: string }).force === 'true';
    const account = await prisma.account.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!account) throw new ApiError(404, 'ACCOUNT_NOT_FOUND', 'Account not found');
    if (account.isPrimary) {
      throw new ApiError(403, 'PRIMARY_ACCOUNT_CANNOT_DELETE', 'Primary account cannot be deleted');
    }
    const txCount = await prisma.transaction.count({
      where: { accountId: id, deletedAt: null },
    });
    if (txCount > 0 && !force) {
      throw new ApiError(409, 'ACCOUNT_HAS_TRANSACTIONS', 'Account has transactions; pass ?force=true');
    }
    if (txCount > 0) {
      await prisma.account.update({
        where: { id },
        data: { isArchived: true, deletedAt: new Date() },
      });
    } else {
      await prisma.account.delete({ where: { id } });
    }
    reply.status(204);
    return null;
  });
}
