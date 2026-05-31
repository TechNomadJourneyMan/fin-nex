// Goals page — minimal OmniFi implementation for the savings tracker.
//
// Uses an in-memory list seeded with three example goals so the page renders
// in Web preview before a real repository (FinancialGoalsRepository) is
// wired against the sqflite layer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:intl/intl.dart';

class _GoalVm {
  const _GoalVm({
    required this.name,
    required this.icon,
    required this.color,
    required this.targetMinor,
    required this.currentMinor,
    required this.dueDate,
  });
  final String name;
  final IconData icon;
  final Color color;
  final int targetMinor;
  final int currentMinor;
  final DateTime dueDate;

  double get progress =>
      targetMinor == 0 ? 0 : (currentMinor / targetMinor).clamp(0.0, 1.0);
}

// Goals start empty — the user creates them via the "+ Новая цель" CTA.
// Persistence to local storage will be wired in a follow-up; for now the
// list lives in this StateProvider so additions survive navigation but
// not full reloads.
final _goalsProvider = StateProvider<List<_GoalVm>>((Ref ref) => <_GoalVm>[]);

/// Financial-goals page. Wired at `/goals`.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<_GoalVm> goals = ref.watch(_goalsProvider);
    final NumberFormat money = NumberFormat.currency(
      locale: 'ru-KZ',
      symbol: '₸',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        title: const Text('Цели накоплений'),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  goals.isEmpty
                      ? 'Нет активных целей'
                      : '${goals.length} ${goals.length == 1 ? 'цель' : 'целей'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A8A93),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addStub(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Новая цель'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            GlassCard(
              radius: 24,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.flag_outlined,
                    color: Color(0xFF5C5C66),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Целей пока нет',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF2F2F3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Создайте цель — Pocket Flow рассчитает\nежемесячный взнос для её достижения.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A8A93),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          for (final _GoalVm g in goals) ...<Widget>[
            GlassCard(
              radius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: g.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(g.icon, color: g.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              g.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF2F2F3),
                              ),
                            ),
                            Text(
                              'до ${DateFormat('MMM yyyy', 'ru').format(g.dueDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A8A93),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(g.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: g.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: g.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0x14FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(g.color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        money.format(g.currentMinor / 100),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2F2F3),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '/ ${money.format(g.targetMinor / 100)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A8A93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _addStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Создание целей — следующая итерация'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
