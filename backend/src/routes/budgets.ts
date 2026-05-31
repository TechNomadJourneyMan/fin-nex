// /v1/budgets CRUD + /progress.
import type { FastifyInstance } from 'fastify';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';
import { budgetCreateBody, budgetUpdateBody } from '../schemas/budgets.js';

function serialize(b: {
  id: string;
  name: string;
  periodCode: string;
  amountMinor: bigint;
  currency: string;
  scope: string;
  categoryIds: string[];
  accountIds: string[];
  startsOn: Date;
  endsOn: Date | null;
  rolloverUnspent: boolean;
  alertThresholds: number[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  version: bigint;
}): Record<string, unknown> {
  return {
    id: b.id,
    name: b.name,
    period: b.periodCode,
    amountMinor: Number(b.amountMinor),
    currency: b.currency,
    scope: b.scope,
    categoryIds: b.categoryIds,
    accountIds: b.accountIds,
    startsOn: b.startsOn.toISOString().slice(0, 10),
    endsOn: b.endsOn ? b.endsOn.toISOString().slice(0, 10) : null,
    rollover: b.rolloverUnspent,
    alertThresholds: b.alertThresholds,
    isActive: b.isActive,
    createdAt: b.createdAt.toISOString(),
    updatedAt: b.updatedAt.toISOString(),
    revision: Number(b.version),
  };
}

function periodRange(period: string, startsOn: Date): { start: Date; end: Date } {
  const start = new Date(startsOn);
  const end = new Date(startsOn);
  switch (period) {
    case 'weekly': end.setDate(end.getDate() + 7); break;
    case 'monthly': end.setMonth(end.getMonth() + 1); break;
    case 'quarterly': end.setMonth(end.getMonth() + 3); break;
    case 'yearly': end.setFullYear(end.getFullYear() + 1); break;
    default: end.setMonth(end.getMonth() + 1); break;
  }
  return { start, end };
}

export default async function budgetsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/budgets', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as { period?: string; status?: string };
    const rows = await prisma.budget.findMany({
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        ...(q.period ? { periodCode: q.period } : {}),
        ...(q.status === 'archived' ? { isActive: false } : q.status === 'active' ? { isActive: true } : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
    return { data: rows.map(serialize) };
  });

  app.post('/v1/budgets', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = budgetCreateBody.parse(req.body);
    const created = await prisma.budget.create({
      data: {
        id: newId('bud'),
        userId: req.auth!.userId,
        clientId: body.clientId,
        name: body.name,
        periodCode: body.period,
        amountMinor: BigInt(body.amountMinor),
        currency: body.currency,
        scope: body.scope ?? 'category',
        categoryIds: body.categoryIds ?? [],
        accountIds: body.accountIds ?? [],
        startsOn: new Date(body.startsOn),
        endsOn: body.endsOn ? new Date(body.endsOn) : null,
        rolloverUnspent: body.rollover ?? false,
        alertThresholds: body.alertThresholds ?? [80],
      },
    });
    reply.status(201);
    return serialize(created);
  });

  app.patch('/v1/budgets/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const body = budgetUpdateBody.parse(req.body);
    const existing = await prisma.budget.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!existing) throw new ApiError(404, 'BUDGET_NOT_FOUND', 'Budget not found');
    const updated = await prisma.budget.update({
      where: { id },
      data: {
        name: body.name,
        periodCode: body.period,
        amountMinor: body.amountMinor !== undefined ? BigInt(body.amountMinor) : undefined,
        currency: body.currency,
        scope: body.scope,
        categoryIds: body.categoryIds,
        accountIds: body.accountIds,
        startsOn: body.startsOn ? new Date(body.startsOn) : undefined,
        endsOn: body.endsOn ? new Date(body.endsOn) : undefined,
        rolloverUnspent: body.rollover,
        alertThresholds: body.alertThresholds,
        version: { increment: 1 },
      },
    });
    return serialize(updated);
  });

  app.delete('/v1/budgets/:id', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    const existing = await prisma.budget.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!existing) throw new ApiError(404, 'BUDGET_NOT_FOUND', 'Budget not found');
    await prisma.budget.update({ where: { id }, data: { deletedAt: new Date(), isActive: false } });
    reply.status(204);
    return null;
  });

  app.get('/v1/budgets/:id/progress', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const budget = await prisma.budget.findFirst({
      where: { id, userId: req.auth!.userId, deletedAt: null },
    });
    if (!budget) throw new ApiError(404, 'BUDGET_NOT_FOUND', 'Budget not found');
    const { start, end } = periodRange(budget.periodCode, budget.startsOn);
    const txs = await prisma.transaction.findMany({
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        typeCode: 'expense',
        occurredAt: { gte: start, lt: end },
        ...(budget.categoryIds.length > 0 ? { categoryId: { in: budget.categoryIds } } : {}),
        ...(budget.accountIds.length > 0 ? { accountId: { in: budget.accountIds } } : {}),
      },
      select: { amountMinor: true },
    });
    const spent = txs.reduce((sum, t) => sum + Number(t.amountMinor), 0);
    const amount = Number(budget.amountMinor);
    const percent = amount > 0 ? (spent / amount) * 100 : 0;
    const daysTotal = Math.max(1, Math.ceil((end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000)));
    const daysLeft = Math.max(0, Math.ceil((end.getTime() - Date.now()) / (24 * 60 * 60 * 1000)));
    const dailyAvg = spent / Math.max(1, daysTotal - daysLeft);
    return {
      budgetId: budget.id,
      periodStart: start.toISOString().slice(0, 10),
      periodEnd: end.toISOString().slice(0, 10),
      amountMinor: amount,
      spentMinor: spent,
      remainingMinor: amount - spent,
      percent: Number(percent.toFixed(2)),
      status: percent >= 100 ? 'exceeded' : percent >= 80 ? 'warning' : 'ok',
      daysLeft,
      dailyAvgMinor: Math.round(dailyAvg),
    };
  });
}
