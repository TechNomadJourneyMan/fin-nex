import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_calendar/pf_calendar.dart';

import '../preferences_store.dart';

/// SharedPreferences key for the chosen calendar id.
const String kCalendarIdKey = 'pf_calendar_id';

/// UI state for the calendar connect flow.
class CalendarConnectState {
  /// Creates a state snapshot.
  const CalendarConnectState({
    this.connected = false,
    this.permissionDenied = false,
    this.calendars = const <PfCalendar>[],
    this.selectedId,
    this.busy = false,
  });

  /// Whether a calendar has been chosen and persisted.
  final bool connected;

  /// Whether the last permission request was refused.
  final bool permissionDenied;

  /// Calendars available after a successful permission grant.
  final List<PfCalendar> calendars;

  /// The persisted, chosen calendar id (if any).
  final String? selectedId;

  /// Whether an async op is in flight (disables the connect button).
  final bool busy;

  /// The selected calendar object, if it is in [calendars].
  PfCalendar? get selected {
    for (final c in calendars) {
      if (c.id == selectedId) return c;
    }
    return null;
  }

  /// Returns a copy with the given fields replaced.
  CalendarConnectState copyWith({
    bool? connected,
    bool? permissionDenied,
    List<PfCalendar>? calendars,
    String? selectedId,
    bool? busy,
  }) {
    return CalendarConnectState(
      connected: connected ?? this.connected,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      calendars: calendars ?? this.calendars,
      selectedId: selectedId ?? this.selectedId,
      busy: busy ?? this.busy,
    );
  }
}

/// Drives the "Connect calendar" flow: requests permission, lists calendars,
/// and persists the chosen calendar id under [kCalendarIdKey].
class CalendarController extends StateNotifier<CalendarConnectState> {
  /// Creates the controller and loads any previously chosen calendar id.
  CalendarController(this._service, this._store)
      : super(const CalendarConnectState()) {
    // ignore: discarded_futures
    _load();
  }

  final CalendarService _service;
  final PreferencesStore _store;

  Future<void> _load() async {
    final id = await _store.getString(kCalendarIdKey);
    if (id != null) {
      state = state.copyWith(selectedId: id, connected: true);
    }
  }

  /// Requests permission and loads the calendar list. On denial, flips
  /// [CalendarConnectState.permissionDenied].
  Future<void> connect() async {
    state = state.copyWith(busy: true, permissionDenied: false);
    final granted = await _service.requestPermission();
    if (!granted) {
      state = state.copyWith(busy: false, permissionDenied: true);
      return;
    }
    final cals = await _service.calendars();
    state = state.copyWith(busy: false, calendars: cals);
  }

  /// Persists [id] as the chosen calendar.
  Future<void> select(String id) async {
    await _store.setString(kCalendarIdKey, id);
    state = state.copyWith(selectedId: id, connected: true);
  }
}
