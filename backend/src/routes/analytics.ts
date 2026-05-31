// /v1/analytics — summary, by-category, cashflow.
import type { FastifyInstance } from 'fastify';
import { prisma } from '../lib/prisma.js';

interface RangeQuery { from?: string; to?: string; groupBy?: string; currency?: string; kind?: string; top?: string }

function defaultRange(): { from: Date; to: Date } {
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - 30);
  return { from, to };
}

export default async function analyticsRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/analytics/summary', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as RangeQuery;
    const def = defaultRange();
    const from = q.from ? new Date(q.from) : def.from;
    const to = q.to ? new Date(q.to) : def.to;

    const txs = await prisma.transaction.findMany({
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        occurredAt: { gte: from, lte: to },
      },
      select: { amountMinor: true, typeCode: true, occurredAt: true },
    });

    let income = 0;
    let expense = 0;
    for (const t of txs) {
      const amt = Number(t.amountMinor);
      if (t.typeCode === 'income') income += amt;
      else if (t.typeCode === 'expense') expense += amt;
    }
    const net = income - expense;
    const savingsRate = income > 0 ? net / income : 0;

    return {
      from: from.toISOString().slice(0, 10),
      to: to.toISOString().slice(0, 10),
      currency: q.currency ?? 'KZT',
      totals: {
        incomeMinor: income,
        expenseMinor: expense,
        netMinor: net,
        savingsRate: Number(savingsRate.toFixed(3)),
      },
      buckets: [],
    };
  });

  app.get('/v1/analytics/by-category', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as RangeQuery;
    const def = defaultRange();
    const from = q.from ? new Date(q.from) : def.from;
    const to = q.to ? new Date(q.to) : def.to;
    const kind = q.kind ?? 'expense';

    const grouped = await prisma.transaction.groupBy({
      by: ['categoryId'],
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        typeCode: kind,
        occurredAt: { gte: from, lte: to },
        categoryId: { not: null },
      },
      _sum: { amountMinor: true },
      _count: { _all: true },
    });

    const total = grouped.reduce((s, g) => s + Number(g._sum.amountMinor ?? 0), 0);
    const categoryIds = grouped.map((g) => g.categoryId).filter((x): x is string => !!x);
    const cats = await prisma.category.findMany({ where: { id: { in: categoryIds } } });
    const catMap = new Map(cats.map((c) => [c.id, c]));

    const categories = grouped
      .map((g) => {
        const amount = Number(g._sum.amountMinor ?? 0);
        const cat = g.categoryId ? catMap.get(g.categoryId) : null;
        return {
          categoryId: g.categoryId,
          name: cat?.name ?? 'Unknown',
          amountMinor: amount,
          share: total > 0 ? Number((amount / total).toFixed(3)) : 0,
          transactionCount: g._count._all,
        };
      })
      .sort((a, b) => b.amountMinor - a.amountMinor);

    return {
      currency: q.currency ?? 'KZT',
      totalMinor: total,
      categories: categories.slice(0, Number(q.top ?? 10)),
    };
  });

  app.get('/v1/analytics/cashflow', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as RangeQuery;
    const def = defaultRange();
    const from = q.from ? new Date(q.from) : def.from;
    const to = q.to ? new Date(q.to) : def.to;
    const txs = await prisma.transaction.findMany({
      where: {
        userId: req.auth!.userId,
        deletedAt: null,
        occurredAt: { gte: from, lte: to },
      },
      orderBy: { occurredAt: 'asc' },
    });
    const map = new Map<string, { income: number; expense: number }>();
    for (const t of txs) {
      const key = t.occurredAt.toISOString().slice(0, 10);
      const entry = map.get(key) ?? { income: 0, expense: 0 };
      const amt = Number(t.amountMinor);
      if (t.typeCode === 'income') entry.income += amt;
      else if (t.typeCode === 'expense') entry.expense += amt;
      map.set(key, entry);
    }
    return {
      from: from.toISOString().slice(0, 10),
      to: to.toISOString().slice(0, 10),
      currency: q.currency ?? 'KZT',
      series: [...map.entries()].map(([date, v]) => ({ date, incomeMinor: v.income, expenseMinor: v.expense })),
    };
  });
}
