// Seeds system categories and reference data.
import { PrismaClient } from '@prisma/client';
import { ulid } from 'ulid';

const prisma = new PrismaClient();

interface SeedCategory {
  key: string;
  name: string;
  icon: string;
  color: string;
  type: 'expense' | 'income';
}

const SYSTEM_CATEGORIES: SeedCategory[] = [
  { key: 'food', name: 'Еда', icon: 'fork-knife', color: '#FF7A45', type: 'expense' },
  { key: 'transport', name: 'Транспорт', icon: 'car', color: '#1F8FFF', type: 'expense' },
  { key: 'shopping', name: 'Покупки', icon: 'shopping-bag', color: '#A855F7', type: 'expense' },
  { key: 'cafe', name: 'Кафе', icon: 'coffee', color: '#8B5E3C', type: 'expense' },
  { key: 'entertainment', name: 'Развлечения', icon: 'film', color: '#F472B6', type: 'expense' },
  { key: 'health', name: 'Здоровье', icon: 'heart', color: '#22C55E', type: 'expense' },
  { key: 'home', name: 'Дом', icon: 'home', color: '#FBBF24', type: 'expense' },
  { key: 'utilities', name: 'Коммунальные', icon: 'bolt', color: '#06B6D4', type: 'expense' },
  { key: 'education', name: 'Образование', icon: 'book', color: '#6366F1', type: 'expense' },
  { key: 'subscriptions', name: 'Подписки', icon: 'play-circle', color: '#EC4899', type: 'expense' },
  { key: 'travel', name: 'Путешествия', icon: 'plane', color: '#14B8A6', type: 'expense' },
  { key: 'gifts', name: 'Подарки', icon: 'gift', color: '#F43F5E', type: 'expense' },
  { key: 'other_expense', name: 'Прочее', icon: 'dots', color: '#888888', type: 'expense' },
  { key: 'salary', name: 'Зарплата', icon: 'wallet', color: '#22C55E', type: 'income' },
  { key: 'freelance', name: 'Фриланс', icon: 'briefcase', color: '#10B981', type: 'income' },
  { key: 'investment', name: 'Инвестиции', icon: 'trending-up', color: '#0EA5E9', type: 'income' },
  { key: 'gift_income', name: 'Подарок', icon: 'gift', color: '#84CC16', type: 'income' },
  { key: 'refund', name: 'Возврат', icon: 'rotate-ccw', color: '#A3E635', type: 'income' },
  { key: 'other_income', name: 'Прочее', icon: 'dots', color: '#888888', type: 'income' },
];

async function main(): Promise<void> {
  for (const cat of SYSTEM_CATEGORIES) {
    const id = `cat_sys_${cat.key}`;
    const clientId = `cli_sys_${cat.key.padEnd(20, '0').slice(0, 20)}xx`;
    await prisma.category.upsert({
      where: { id },
      update: {
        name: cat.name,
        icon: cat.icon,
        color: cat.color,
        typeCode: cat.type,
        isSystem: true,
      },
      create: {
        id,
        clientId: clientId.length === 26 ? clientId : ulid(),
        typeCode: cat.type,
        name: cat.name,
        nameI18nKey: `category.${cat.key}`,
        icon: cat.icon,
        color: cat.color,
        isSystem: true,
      },
    });
  }
  // eslint-disable-next-line no-console
  console.log(`Seeded ${SYSTEM_CATEGORIES.length} system categories`);
}

main()
  .catch((e) => {
    // eslint-disable-next-line no-console
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
