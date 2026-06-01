// Achievements (gamification) page — minimal OmniFi implementation.
//
// Shows 8 seeded achievements as a grid of GlassCards; locked badges are
// dimmed. Streak strip at the top. Designed for Web preview before the
// real RecomputeAchievements use-case lands as a scheduled job.

import 'package:flutter/material.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

class _Badge {
  const _Badge({
    required this.title,
    required this.icon,
    required this.color,
    required this.xp,
    required this.unlocked,
    required this.subtitle,
  });
  final String title;
  final IconData icon;
  final Color color;
  final int xp;
  final bool unlocked;
  final String subtitle;
}

// All badges start LOCKED — they unlock as the user actually uses the app.
// The "unlocked" flag will be computed by a future RecomputeAchievements
// use-case against the user's persisted transaction history.
const List<_Badge> _badges = <_Badge>[
  _Badge(
    title: 'Первая операция',
    icon: Icons.flag,
    color: Color(0xFF24A148),
    xp: 50,
    unlocked: false,
    subtitle: 'Записан первый расход',
  ),
  _Badge(
    title: '7 дней подряд',
    icon: Icons.local_fire_department,
    color: Color(0xFFFFB840),
    xp: 100,
    unlocked: false,
    subtitle: 'Неделя ведения учёта',
  ),
  _Badge(
    title: 'Под бюджетом',
    icon: Icons.savings,
    color: Color(0xFF24A148),
    xp: 200,
    unlocked: false,
    subtitle: 'Уложиться в месячный лимит',
  ),
  _Badge(
    title: '30 дней подряд',
    icon: Icons.local_fire_department_outlined,
    color: Color(0xFFFF6B35),
    xp: 300,
    unlocked: false,
    subtitle: 'Месяц без пропусков',
  ),
  _Badge(
    title: 'Минималист',
    icon: Icons.crop_square,
    color: Color(0xFFE5E5EA),
    xp: 250,
    unlocked: false,
    subtitle: 'Сократить подписки на 30%',
  ),
  _Badge(
    title: 'Финансовый инвестор',
    icon: Icons.trending_up,
    color: Color(0xFF24A148),
    xp: 500,
    unlocked: false,
    subtitle: 'Откладывать ≥10% дохода',
  ),
  _Badge(
    title: 'Босс ИП',
    icon: Icons.workspace_premium,
    color: Color(0xFFE5E5EA),
    xp: 400,
    unlocked: false,
    subtitle: 'Создать бизнес-пространство',
  ),
  _Badge(
    title: 'Чистый лист',
    icon: Icons.auto_awesome,
    color: Color(0xFF8B5CF6),
    xp: 1000,
    unlocked: false,
    subtitle: 'Закрыть все рассрочки',
  ),
];

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int unlocked = _badges.where((b) => b.unlocked).length;
    final int totalXp = _badges
        .where((b) => b.unlocked)
        .fold(0, (int acc, _Badge b) => acc + b.xp);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        title: const Text('Достижения'),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: <Widget>[
          // Streak hero
          GlassCard(
            radius: 28,
            elevation: GlassElevation.raised,
            glow: true,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFB840),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFFB840),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Стрик ещё не начат',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2F2F3),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Сегодня · Всего: $totalXp XP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: <Widget>[
                Text(
                  '$unlocked из ${_badges.length} открыто',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A8A93),
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalXp XP',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE5E5EA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Badge grid
          LayoutBuilder(
            builder: (BuildContext _, BoxConstraints cs) {
              final int cols = cs.maxWidth > 600 ? 4 : 2;
              const double gap = 12;
              final double tileW = (cs.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final _Badge b in _badges)
                    SizedBox(
                      width: tileW,
                      child: _BadgeTile(badge: b),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        badge.unlocked ? badge.color : const Color(0xFF3C3C44);
    final Color titleColor =
        badge.unlocked ? const Color(0xFFF2F2F3) : const Color(0xFF5C5C66);

    return Opacity(
      opacity: badge.unlocked ? 1.0 : 0.7,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(badge.icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8A8A93),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+${badge.xp} XP',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE5E5EA),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
