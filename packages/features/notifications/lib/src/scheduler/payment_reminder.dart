// Pure scheduling model for local payment / subscription push reminders.
//
// The scheduler is deliberately platform-free: it consumes a list of upcoming
// payments ([PaymentReminderInput]) and produces a deterministic list of
// [ScheduledNotification]s honouring quiet-hours and a per-day cap. The app
// layer hands these to a [NotificationsService] (the native plugin wrapper) to
// actually schedule them; everything here is exercised in headless tests with
// no platform calls.

import 'package:flutter/foundation.dart';

/// A single upcoming payment the scheduler can build a reminder for.
///
/// This mirrors the relevant fields of a detected subscription / recurring
/// payment without depending on those feature packages, so the notifications
/// package stays leaf-level and unit-testable. The app composition layer maps
/// its domain objects onto this shape.
@immutable
class PaymentReminderInput {
  /// Creates a payment reminder input.
  const PaymentReminderInput({
    required this.sourceId,
    required this.title,
    required this.amountLabel,
    required this.dueDate,
  });

  /// Stable id of the originating entity (e.g. `subscription:<ulid>`).
  ///
  /// Used to derive a stable notification id so re-scheduling never
  /// duplicates and a cancelled payment can be removed precisely.
  final String sourceId;

  /// Human-readable payee / merchant (e.g. "Netflix").
  final String title;

  /// Pre-formatted amount string (e.g. "₸ 4 990"). Built by the caller in the
  /// active locale so this package needs no formatting deps.
  final String amountLabel;

  /// Local calendar day the charge is expected. Time component is ignored.
  final DateTime dueDate;
}

/// A notification the scheduler decided to schedule.
@immutable
class ScheduledNotification {
  /// Creates a scheduled notification.
  const ScheduledNotification({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.body,
    required this.when,
  });

  /// Deterministic channel id derived from [sourceId] and the fire offset.
  final int id;

  /// Originating entity id (for cancellation by source).
  final String sourceId;

  /// Notification headline.
  final String title;

  /// Notification body.
  final String body;

  /// Local time the notification should fire.
  final DateTime when;

  @override
  bool operator ==(Object other) =>
      other is ScheduledNotification &&
      other.id == id &&
      other.sourceId == sourceId &&
      other.title == title &&
      other.body == body &&
      other.when == when;

  @override
  int get hashCode => Object.hash(id, sourceId, title, body, when);

  @override
  String toString() =>
      'ScheduledNotification(id: $id, when: $when, title: $title)';
}

/// Localised copy for the reminder body. The app passes the active strings so
/// this package carries no l10n dependency.
@immutable
class PaymentReminderCopy {
  /// Creates a copy bundle.
  const PaymentReminderCopy({
    required this.dayBeforeTitle,
    required this.dayBeforeBody,
    required this.dueTodayTitle,
    required this.dueTodayBody,
  });

  /// Sensible English fallback used in tests / before l10n is wired.
  factory PaymentReminderCopy.fallback() => const PaymentReminderCopy(
        dayBeforeTitle: 'Payment tomorrow',
        dayBeforeBody: '{title} — {amount} is due tomorrow',
        dueTodayTitle: 'Payment due today',
        dueTodayBody: '{title} — {amount} is due today',
      );

  /// Title for the day-before nudge.
  final String dayBeforeTitle;

  /// Body template for the day-before nudge. Supports `{title}` / `{amount}`.
  final String dayBeforeBody;

  /// Title for the due-today nudge.
  final String dueTodayTitle;

  /// Body template for the due-today nudge. Supports `{title}` / `{amount}`.
  final String dueTodayBody;

  String _fill(String template, String title, String amount) =>
      template.replaceAll('{title}', title).replaceAll('{amount}', amount);

  /// Renders the day-before body.
  String dayBefore(String title, String amount) =>
      _fill(dayBeforeBody, title, amount);

  /// Renders the due-today body.
  String dueToday(String title, String amount) =>
      _fill(dueTodayBody, title, amount);
}

/// Quiet-hours window (local clock). When a reminder would fire inside the
/// window it is shifted to [end].
///
/// Defaults to 22:00–08:00 to match the project's "quiet-hours spirit".
@immutable
class QuietHours {
  /// Creates a quiet-hours window. Hours are 0–23 on the local clock.
  const QuietHours({this.startHour = 22, this.endHour = 8});

  /// Disabled window (never shifts).
  const QuietHours.disabled()
      : startHour = -1,
        endHour = -1;

  /// Inclusive start hour (e.g. 22 == 10pm).
  final int startHour;

  /// Exclusive end hour (e.g. 8 == 8am).
  final int endHour;

  /// Whether this window is active.
  bool get enabled => startHour >= 0 && endHour >= 0;

  /// True when [t]'s local hour falls inside the quiet window.
  ///
  /// Handles windows that wrap past midnight (start > end).
  bool contains(DateTime t) {
    if (!enabled) return false;
    final h = t.hour;
    if (startHour <= endHour) {
      return h >= startHour && h < endHour;
    }
    // Wraps midnight: e.g. 22..8 → [22,23] ∪ [0,8).
    return h >= startHour || h < endHour;
  }

  /// Returns [t] shifted out of the quiet window to [endHour] (same or next
  /// day), or [t] unchanged when not inside the window.
  DateTime shift(DateTime t) {
    if (!contains(t)) return t;
    // Land at endHour:00. If the window wraps and t is in the late-evening
    // segment (h >= startHour), the safe exit is endHour the *next* day.
    final wraps = startHour > endHour;
    final nextDay = wraps && t.hour >= startHour;
    final base = nextDay ? t.add(const Duration(days: 1)) : t;
    return DateTime(base.year, base.month, base.day, endHour);
  }
}

/// Builds the local-notification schedule for upcoming payments.
///
/// Pure: no platform access. Given the list of upcoming payments, the local
/// "now", the reminder hour, the per-day cap and a quiet-hours window, it emits
/// the notifications to schedule, sorted by fire time.
class PaymentReminderScheduler {
  /// Creates a scheduler.
  const PaymentReminderScheduler({
    this.reminderHour = 9,
    this.maxPerDay = 2,
    this.quietHours = const QuietHours(),
    this.dayBefore = true,
  });

  /// Local hour-of-day the reminders aim to fire at (default 9am).
  final int reminderHour;

  /// Hard cap on notifications scheduled to fire on any single local day.
  /// Defaults to 2 to respect the existing "≤ 2/day" cadence spirit.
  final int maxPerDay;

  /// Quiet-hours window applied to every candidate before capping.
  final QuietHours quietHours;

  /// Whether to also emit a "due tomorrow" nudge the day before.
  final bool dayBefore;

  /// Builds the schedule for [inputs] relative to [now].
  ///
  /// Rules:
  ///  * For each payment, emit a due-day reminder at [reminderHour], and (when
  ///    [dayBefore]) a day-before reminder at [reminderHour] the prior day.
  ///  * Drop any candidate whose fire time is in the past (< [now]).
  ///  * Apply [quietHours] (shifting late/early candidates out of the window).
  ///  * Sort by fire time, then enforce [maxPerDay] per local calendar day,
  ///    keeping the earliest candidates and dropping the overflow.
  List<ScheduledNotification> schedule(
    List<PaymentReminderInput> inputs, {
    required DateTime now,
    PaymentReminderCopy? copy,
  }) {
    final c = copy ?? PaymentReminderCopy.fallback();
    final candidates = <ScheduledNotification>[];

    for (final input in inputs) {
      final due = input.dueDate;
      final dueAt = DateTime(due.year, due.month, due.day, reminderHour);

      if (dayBefore) {
        final prior = dueAt.subtract(const Duration(days: 1));
        final when = quietHours.shift(prior);
        if (!when.isBefore(now)) {
          candidates.add(
            ScheduledNotification(
              id: _idFor(input.sourceId, offset: 1),
              sourceId: input.sourceId,
              title: c.dayBeforeTitle,
              body: c.dayBefore(input.title, input.amountLabel),
              when: when,
            ),
          );
        }
      }

      final dueWhen = quietHours.shift(dueAt);
      if (!dueWhen.isBefore(now)) {
        candidates.add(
          ScheduledNotification(
            id: _idFor(input.sourceId, offset: 0),
            sourceId: input.sourceId,
            title: c.dueTodayTitle,
            body: c.dueToday(input.title, input.amountLabel),
            when: dueWhen,
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final cmp = a.when.compareTo(b.when);
      return cmp != 0 ? cmp : a.id.compareTo(b.id);
    });

    if (maxPerDay <= 0) {
      return List<ScheduledNotification>.unmodifiable(candidates);
    }

    final perDay = <String, int>{};
    final kept = <ScheduledNotification>[];
    for (final n in candidates) {
      final key = '${n.when.year}-${n.when.month}-${n.when.day}';
      final count = perDay[key] ?? 0;
      if (count >= maxPerDay) continue;
      perDay[key] = count + 1;
      kept.add(n);
    }
    return List<ScheduledNotification>.unmodifiable(kept);
  }

  /// Stable, collision-resistant 31-bit notification id derived from the
  /// source id and the day offset (0 = due day, 1 = day before).
  static int _idFor(String sourceId, {required int offset}) {
    // FNV-1a 32-bit over the source id, then fold to a positive 31-bit int and
    // mix in the offset so the two reminders for one source never collide.
    var hash = 0x811c9dc5;
    for (final unit in sourceId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    hash = (hash ^ (offset * 0x9e3779b1)) & 0xffffffff;
    return hash & 0x7fffffff;
  }

  /// Exposed for the app layer / tests to derive cancellation ids.
  static int notificationId(String sourceId, {required int offset}) =>
      _idFor(sourceId, offset: offset);
}
