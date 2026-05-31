// /v1/transactions — list, get, create (idempotent), update, delete, bulk.
import type { FastifyInstance } from 'fastify';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';
import {
  transactionBulkBody,
  transactionCreateBody,
  transactionListQuery,
  transactionUpdateBody,
} from '../schemas/transactions.js';
import * as idem from '../services/idempotency.service.js';

interface TxRow {
  id: string;
  clientId: string;
  accountId: string;
  categoryId: string | null;
  typeCode: string;
  amountMinor: bigint;
  currency: string;
  occurredAt: Date;
  description: string | null;
  note: string | null;
  source: string;
  transferAccountId: string | null;
  transferGroupId: string | null;
  createdAt: Date;
  updatedAt: Date;
  version: bigint;
}

function serialize(t: TxRow): Record<string, unknown> {
  return {
    id: t.id,
    clientId: t.clientId,
    accountId: t.accountId,
    categoryId: t.categoryId,
    type: t.typeCode,
    amountMinor: Number(t.amountMinor),
    currency: t.currency,
    occurredAt: t.occurredAt.toISOString(),
    description: t.description,
    note: t.note,
    source: t.source,
    transferAccountId: t.transferAccountId,
    transferGroupId: t.transferGroupId,
    createdAt: t.createdAt.toISOString(),
    updatedAt: t.updatedAt.toISOString(),
    revision: Number(t.version),
  };
}

function encodeCursor(updatedAt: Date, id: string): string {
  return Buffer.from(JSON.stringify({ t: updatedAt.toISOString(), id })).toString('base64url');
}

function decodeCursor(cursor: string): { t: string; id: string } | null {
  try {
    return JSON.parse(Buffer.from(cursor, 'base64url').toString('utf-8')) as { t: string; id: string };
  } catch {
    return null;
  }
}

export default async function transactionsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/transactions', { preHandler: [app.requireAuth] }, async (req) => {
    const q = transactionListQuery.parse(req.query);
    const where: Record<string, unknown> = {
      userId: req.auth!.userId,
      deletedAt: null,
    };
    if (q.from || q.to) {
      where.occurredAt = {
        ...(q.from ? { gte: new Date(q.from) } : {}),
        ...(q.to ? { lte: new Date(q.to) } : {}),
      };
    }
    if (q.accountId) where.accountId = q.accountId;
    if (q.categoryId) where.categoryId = q.categoryId;
    if (q.type) where.typeCode = q.type;
    if (q.source) where.source = q.source;
    if (q.minAmount !== undefined || q.maxAmount !== undefined) {
      where.amountMinor = {
        ...(q.minAmount !== undefined ? { gte: BigInt(q.minAmount) } : {}),
        ...(q.maxAmount !== undefined ? { lte: BigInt(q.maxAmount) } : {}),
      };
    }
    if (q.query) {
      where.OR = [
        { description: { contains: q.query, mode: 'insensitive' } },
        { note: { contains: q.query, mode: 'insensitive' } },
      ];
    }
    if (q.cursor) {
      const decoded = decodeCursor(q.cursor);
      if (decoded) {
        where.OR = [
          { occurredAt: { lt: new Date(decoded.t) } },
          { occurredAt: new Date(decoded.t), id: { lt: decoded.id } },
        ];
      }
    }

    const order = q.order ?? 'occurred_at:desc';
    const [field, dir] = order.split(':');
    const orderBy =
      field === 'amount'
        ? { amountMinor: dir as 'asc' | 'desc' }
        : { occurredAt: dir as 'asc' | 'desc' };

    const rows = await prisma.transaction.findMany({
      where,
      orderBy: [orderBy, { id: 'desc' }],
      take: q.limit + 1,
    });
    const hasMore = rows.length > q.limit;
    const page = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeCursor(page[page.length - 1]!.occurredAt, page[page.length - 1]!.id) : null;

    return {
      data: page.map(serialize),
      pagination: { nextCursor, hasMore, limit: q.limit },
    };
  });

  app.get('/v1/transactions/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const tx = await prisma.transaction.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!tx) throw new ApiError(404, 'TRANSACTION_NOT_FOUND', 'Transaction not found');
    return serialize(tx);
  });

  app.post('/v1/transactions', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = transactionCreateBody.parse(req.body);
    const idemKey = req.headers['x-idempotency-key'] as string | undefined;
    const userId = req.auth!.userId;
    const endpoint = 'POST /v1/transactions';
    const requestHash = idem.hashRequest(body);

    if (idemKey) {
      const cached = await idem.lookup(idemKey, userId, endpoint, requestHash);
      if (cached && 'conflict' in cached) {
        throw new ApiError(409, 'IDEMPOTENCY_KEY_CONFLICT', 'Same key, different payload');
      }
      if (cached && 'replay' in cached) {
        reply.header('idempotent-replay', 'true');
        reply.status(cached.replay.status);
        return cached.replay.body;
      }
    }

    const account = await prisma.account.findFirst({
      where: { id: body.accountId, userId, deletedAt: null },
    });
    if (!account) throw new ApiError(404, 'ACCOUNT_NOT_FOUND', 'Account not found');
    if (account.currency !== body.currency) {
      throw new ApiError(409, 'CURRENCY_MISMATCH', 'Transaction currency must match account');
    }

    const existing = await prisma.transaction.findUnique({ where: { clientId: body.clientId } });
    if (existing) {
      throw new ApiError(409, 'DUPLICATE_CLIENT_ID', 'client_id already used');
    }

    const tx = await prisma.transaction.create({
      data: {
        id: newId('tx'),
        userId,
        clientId: body.clientId,
        accountId: body.accountId,
        categoryId: body.categoryId ?? null,
        typeCode: body.type,
        amountMinor: BigInt(body.amountMinor),
        currency: body.currency,
        occurredAt: new Date(body.occurredAt),
        description: body.description,
        note: body.note,
        transferAccountId: body.transferTargetAccountId ?? null,
        transferGroupId: body.transferTargetAccountId ? newId('tx') : null,
        source: body.source ?? 'manual',
      },
    });

    const body200 = serialize(tx);
    if (idemKey) {
      await idem.store({
        key: idemKey,
        userId,
        endpoint,
        requestHash,
        response: { status: 201, body: body200 },
      });
    }
    reply.status(201);
    return body200;
  });

  app.patch('/v1/transactions/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const body = transactionUpdateBody.parse(req.body);
    const existing = await prisma.transaction.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!existing) throw new ApiError(404, 'TRANSACTION_NOT_FOUND', 'Transaction not found');
    const updated = await prisma.transaction.update({
      where: { id },
      data: {
        amountMinor: body.amountMinor !== undefined ? BigInt(body.amountMinor) : undefined,
        currency: body.currency,
        accountId: body.accountId,
        categoryId: body.categoryId,
        typeCode: body.type,
        occurredAt: body.occurredAt ? new Date(body.occurredAt) : undefined,
        description: body.description,
        note: body.note,
        version: { increment: 1 },
      },
    });
    return serialize(updated);
  });

  app.delete('/v1/transactions/:id', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    const existing = await prisma.transaction.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!existing) throw new ApiError(404, 'TRANSACTION_NOT_FOUND', 'Transaction not found');
    await prisma.transaction.update({ where: { id }, data: { deletedAt: new Date() } });
    reply.status(204);
    return null;
  });

  app.post('/v1/transactions/bulk', { preHandler: [app.requireAuth] }, async (req) => {
    const body = transactionBulkBody.parse(req.body);
    const userId = req.auth!.userId;
    const results = { created: 0, skipped: 0, updated: 0, failed: 0, failures: [] as Array<{ index: number; code: string; detail: string }> };

    for (let i = 0; i < body.transactions.length; i += 1) {
      const tx = body.transactions[i]!;
      try {
        const dup = await prisma.transaction.findUnique({ where: { clientId: tx.clientId } });
        if (dup) {
          if (body.onConflict === 'skip') { results.skipped += 1; continue; }
          if (body.onConflict === 'fail') {
            results.failures.push({ index: i, code: 'DUPLICATE_CLIENT_ID', detail: 'client_id already used' });
            results.failed += 1;
            continue;
          }
          await prisma.transaction.update({
            where: { clientId: tx.clientId },
            data: { amountMinor: BigInt(tx.amountMinor), description: tx.description, note: tx.note },
          });
          results.updated += 1;
          continue;
        }
        await prisma.transaction.create({
          data: {
            id: newId('tx'),
            userId,
            clientId: tx.clientId,
            accountId: tx.accountId,
            categoryId: tx.categoryId ?? null,
            typeCode: tx.type,
            amountMinor: BigInt(tx.amountMinor),
            currency: tx.currency,
            occurredAt: new Date(tx.occurredAt),
            description: tx.description,
            note: tx.note,
            source: body.source ?? tx.source ?? 'manual',
          },
        });
        results.created += 1;
      } catch (err) {
        results.failed += 1;
        results.failures.push({ index: i, code: 'VALIDATION_FAILED', detail: (err as Error).message });
      }
    }
    return results;
  });
}
