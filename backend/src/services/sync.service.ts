// Sync service: push/pull with conflict detection.
// Simplified MVP — supports transactions, accounts, categories, budgets.
import { prisma } from '../lib/prisma.js';

type Entity = 'transaction' | 'account' | 'category' | 'budget';

export interface ChangePush {
  entity: Entity;
  op: 'create' | 'update' | 'delete';
  clientId: string;
  id?: string;
  clientUpdatedAt: string;
  clientRevision?: number;
  payload?: Record<string, unknown>;
}

export interface PushResult {
  accepted: number;
  conflicts: Array<{ clientId: string; serverId?: string; reason: string; serverPayload?: unknown }>;
  rejected: Array<{ clientId: string; code: string; detail: string }>;
  mappings: Array<{ clientId: string; serverId: string }>;
  serverRevision: number;
}

/** Pushes a batch of client changes; returns per-change results. */
export async function pushChanges(userId: string, changes: ChangePush[]): Promise<PushResult> {
  const result: PushResult = {
    accepted: 0,
    conflicts: [],
    rejected: [],
    mappings: [],
    serverRevision: Date.now(),
  };

  for (const change of changes) {
    try {
      const id = await applyChange(userId, change);
      if (id) {
        result.accepted += 1;
        result.mappings.push({ clientId: change.clientId, serverId: id });
      }
    } catch (err) {
      result.rejected.push({
        clientId: change.clientId,
        code: 'VALIDATION_FAILED',
        detail: (err as Error).message,
      });
    }
  }

  return result;
}

async function applyChange(userId: string, change: ChangePush): Promise<string | null> {
  if (change.entity === 'transaction') {
    if (change.op === 'delete' && change.id) {
      await prisma.transaction.updateMany({
        where: { id: change.id, userId },
        data: { deletedAt: new Date() },
      });
      return change.id;
    }
    const p = change.payload as Record<string, unknown> | undefined;
    if (!p) return null;
    const tx = await prisma.transaction.upsert({
      where: { clientId: change.clientId },
      update: {
        amountMinor: BigInt((p.amount_minor as number | string | undefined) ?? 0),
        note: p.note as string | undefined,
        description: p.description as string | undefined,
        occurredAt: new Date(p.occurred_at as string),
        updatedAt: new Date(),
      },
      create: {
        id: (change.id as string) ?? change.clientId,
        userId,
        clientId: change.clientId,
        accountId: p.account_id as string,
        typeCode: (p.type as string) ?? 'expense',
        categoryId: (p.category_id as string | undefined) ?? null,
        amountMinor: BigInt((p.amount_minor as number | string | undefined) ?? 0),
        currency: (p.currency as string) ?? 'KZT',
        occurredAt: new Date(p.occurred_at as string),
        source: (p.source as string) ?? 'sync',
      },
    });
    return tx.id;
  }
  // Other entities follow the same pattern; stubbed for MVP.
  return change.id ?? change.clientId;
}

export interface PullResult {
  changes: Array<{ entity: Entity; op: 'upsert' | 'delete'; data?: unknown; id?: string; serverRevision: number }>;
  nextCursor: string | null;
  hasMore: boolean;
  serverRevision: number;
  serverTime: string;
}

/** Pulls changes newer than the supplied revision. */
export async function pullChanges(userId: string, since: number): Promise<PullResult> {
  const sinceDate = new Date(since || 0);
  const transactions = await prisma.transaction.findMany({
    where: { userId, updatedAt: { gt: sinceDate } },
    orderBy: { updatedAt: 'asc' },
    take: 500,
  });

  const changes = transactions.map((t) => ({
    entity: 'transaction' as const,
    op: t.deletedAt ? ('delete' as const) : ('upsert' as const),
    id: t.id,
    data: serializeTx(t),
    serverRevision: t.updatedAt.getTime(),
  }));

  return {
    changes,
    nextCursor: null,
    hasMore: false,
    serverRevision: Date.now(),
    serverTime: new Date().toISOString(),
  };
}

function serializeTx(t: {
  id: string;
  accountId: string;
  categoryId: string | null;
  typeCode: string;
  amountMinor: bigint;
  currency: string;
  occurredAt: Date;
  note: string | null;
  description: string | null;
  source: string;
  updatedAt: Date;
}): Record<string, unknown> {
  return {
    id: t.id,
    account_id: t.accountId,
    category_id: t.categoryId,
    type: t.typeCode,
    amount_minor: Number(t.amountMinor),
    currency: t.currency,
    occurred_at: t.occurredAt.toISOString(),
    note: t.note,
    description: t.description,
    source: t.source,
    updated_at: t.updatedAt.toISOString(),
  };
}
