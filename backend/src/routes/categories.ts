// /v1/categories — system + user-defined CRUD.
import type { FastifyInstance } from 'fastify';
import { newId } from '../lib/ids.js';
import { ApiError } from '../lib/problem.js';
import { prisma } from '../lib/prisma.js';
import { categoryCreateBody, categoryDeleteQuery, categoryUpdateBody } from '../schemas/categories.js';

function serialize(c: {
  id: string;
  userId: string | null;
  typeCode: string;
  parentId: string | null;
  name: string;
  icon: string;
  color: string;
  isSystem: boolean;
  sortOrder: number;
  monthlyLimitMinor: bigint | null;
  version: bigint;
}): Record<string, unknown> {
  return {
    id: c.id,
    kind: c.typeCode,
    name: c.name,
    icon: c.icon,
    color: c.color,
    isSystem: c.isSystem,
    parentId: c.parentId,
    sortOrder: c.sortOrder,
    monthlyLimitMinor: c.monthlyLimitMinor ? Number(c.monthlyLimitMinor) : null,
    revision: Number(c.version),
  };
}

export default async function categoriesRoutes(app: FastifyInstance): Promise<void> {
  app.get('/v1/categories', { preHandler: [app.requireAuth] }, async (req) => {
    const q = req.query as { kind?: string; includeSystem?: string; includeUser?: string };
    const includeSystem = q.includeSystem !== 'false';
    const includeUser = q.includeUser !== 'false';
    const rows = await prisma.category.findMany({
      where: {
        deletedAt: null,
        ...(q.kind && q.kind !== 'all' ? { typeCode: q.kind } : {}),
        OR: [
          ...(includeUser ? [{ userId: req.auth!.userId }] : []),
          ...(includeSystem ? [{ isSystem: true }] : []),
        ],
      },
      orderBy: [{ isSystem: 'desc' }, { sortOrder: 'asc' }, { name: 'asc' }],
    });
    return { data: rows.map(serialize) };
  });

  app.post('/v1/categories', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const body = categoryCreateBody.parse(req.body);
    const dup = await prisma.category.findFirst({
      where: {
        userId: req.auth!.userId,
        typeCode: body.kind,
        name: body.name,
        deletedAt: null,
      },
    });
    if (dup) throw new ApiError(409, 'CATEGORY_NAME_DUPLICATE', 'Duplicate category name');

    const created = await prisma.category.create({
      data: {
        id: newId('cat'),
        userId: req.auth!.userId,
        clientId: body.clientId,
        typeCode: body.kind,
        parentId: body.parentId ?? null,
        name: body.name,
        icon: body.icon,
        color: body.color,
        sortOrder: body.sortOrder ?? 0,
        monthlyLimitMinor: body.monthlyLimitMinor ? BigInt(body.monthlyLimitMinor) : null,
      },
    });
    reply.status(201);
    return serialize(created);
  });

  app.patch('/v1/categories/:id', { preHandler: [app.requireAuth] }, async (req) => {
    const { id } = req.params as { id: string };
    const body = categoryUpdateBody.parse(req.body);
    const existing = await prisma.category.findUnique({ where: { id } });
    if (!existing) throw new ApiError(404, 'CATEGORY_NOT_FOUND', 'Category not found');
    if (existing.isSystem) {
      throw new ApiError(403, 'SYSTEM_CATEGORY_READONLY', 'System category is read-only');
    }
    if (existing.userId !== req.auth!.userId) {
      throw new ApiError(404, 'CATEGORY_NOT_FOUND', 'Category not found');
    }
    const updated = await prisma.category.update({
      where: { id },
      data: {
        name: body.name,
        icon: body.icon,
        color: body.color,
        parentId: body.parentId,
        sortOrder: body.sortOrder,
        monthlyLimitMinor: body.monthlyLimitMinor ? BigInt(body.monthlyLimitMinor) : undefined,
        version: { increment: 1 },
      },
    });
    return serialize(updated);
  });

  app.delete('/v1/categories/:id', { preHandler: [app.requireAuth] }, async (req, reply) => {
    const { id } = req.params as { id: string };
    const query = categoryDeleteQuery.parse(req.query);
    const existing = await prisma.category.findUnique({ where: { id } });
    if (!existing || existing.userId !== req.auth!.userId) {
      throw new ApiError(404, 'CATEGORY_NOT_FOUND', 'Category not found');
    }
    if (existing.isSystem) {
      throw new ApiError(403, 'SYSTEM_CATEGORY_READONLY', 'System category is read-only');
    }
    const txCount = await prisma.transaction.count({ where: { categoryId: id, deletedAt: null } });
    if (txCount > 0) {
      if (!query.reassignTo) {
        throw new ApiError(422, 'REASSIGN_TARGET_REQUIRED', 'reassign_to is required');
      }
      await prisma.transaction.updateMany({
        where: { categoryId: id },
        data: { categoryId: query.reassignTo },
      });
    }
    await prisma.category.update({ where: { id }, data: { deletedAt: new Date() } });
    reply.status(204);
    return null;
  });
}
