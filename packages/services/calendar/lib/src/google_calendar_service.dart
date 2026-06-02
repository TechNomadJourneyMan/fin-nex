import 'dart:developer' as developer;

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

import 'calendar_service.dart';
import 'models.dart';

/// [CalendarService] backed by the Google Calendar API over OAuth.
///
/// Used as the default on web, and optionally on mobile. The OAuth client id
/// is environment-specific and is read from the `GOOGLE_OAUTH_CLIENT_ID`
/// dart-define (see WEB_DEPLOY.md). When that define is empty,
/// [requestPermission] returns `false` with a logged hint instead of
/// attempting (and failing) a sign-in.
class GoogleCalendarService implements CalendarService {
  /// Creates the service. [clientId] defaults to the compile-time define.
  GoogleCalendarService({String? clientId})
      : _clientId = clientId ?? _kClientId;

  static const String _kClientId =
      String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID');

  final String _clientId;

  late final GoogleSignIn _signIn = GoogleSignIn(
    clientId: _clientId.isEmpty ? null : _clientId,
    scopes: const <String>[gcal.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _account;

  @override
  Future<bool> requestPermission() async {
    if (_clientId.isEmpty) {
      developer.log(
        'GOOGLE_OAUTH_CLIENT_ID is not set. Pass it via '
        '--dart-define=GOOGLE_OAUTH_CLIENT_ID=<id> (see WEB_DEPLOY.md). '
        'Google Calendar connect is disabled.',
        name: 'pf_calendar',
      );
      return false;
    }
    try {
      _account = await _signIn.signIn();
      return _account != null;
    } catch (e) {
      developer.log('Google sign-in failed: $e', name: 'pf_calendar');
      return false;
    }
  }

  Future<gcal.CalendarApi?> _api() async {
    final account = _account ?? await _signIn.signInSilently();
    if (account == null) return null;
    _account = account;
    final headers = await account.authHeaders;
    return gcal.CalendarApi(_AuthClient(headers));
  }

  @override
  Future<List<PfCalendar>> calendars() async {
    final api = await _api();
    if (api == null) return const <PfCalendar>[];
    final list = await api.calendarList.list();
    return <PfCalendar>[
      for (final c in list.items ?? const <gcal.CalendarListEntry>[])
        PfCalendar(
          id: c.id ?? '',
          name: c.summary ?? c.id ?? 'Calendar',
          accountName: _account?.email,
          isWritable: c.accessRole == 'owner' || c.accessRole == 'writer',
        ),
    ];
  }

  @override
  Future<String?> createEvent(String calendarId, PfCalendarEvent e) async {
    final api = await _api();
    if (api == null) return null;
    final event = gcal.Event(
      summary: e.title,
      description: e.description,
      extendedProperties: e.sourceId == null
          ? null
          : gcal.EventExtendedProperties(
              private: <String, String>{'pfSourceId': e.sourceId!},
            ),
      reminders: gcal.EventReminders(
        useDefault: e.reminders.isEmpty,
        overrides: e.reminders.isEmpty
            ? null
            : <gcal.EventReminder>[
                for (final r in e.reminders)
                  gcal.EventReminder(
                    method: 'popup',
                    minutes: r.inMinutes,
                  ),
              ],
      ),
      start: _endpoint(e.start, e.allDay),
      end: _endpoint(e.end, e.allDay),
    );
    final created = await api.events.insert(event, calendarId);
    return created.id;
  }

  @override
  Future<void> deleteEvent(String calendarId, String eventId) async {
    final api = await _api();
    if (api == null) return;
    await api.events.delete(calendarId, eventId);
  }

  @override
  Future<List<PfCalendarEvent>> eventsInRange(
    String calId,
    DateTimeRange r,
  ) async {
    final api = await _api();
    if (api == null) return const <PfCalendarEvent>[];
    final res = await api.events.list(
      calId,
      timeMin: r.start.toUtc(),
      timeMax: r.end.toUtc(),
      singleEvents: true,
    );
    return <PfCalendarEvent>[
      for (final ev in res.items ?? const <gcal.Event>[]) _fromGoogle(ev),
    ];
  }

  static gcal.EventDateTime _endpoint(DateTime dt, bool allDay) {
    if (allDay) {
      return gcal.EventDateTime(date: DateTime(dt.year, dt.month, dt.day));
    }
    return gcal.EventDateTime(dateTime: dt.toUtc());
  }

  static PfCalendarEvent _fromGoogle(gcal.Event ev) {
    final start = ev.start?.dateTime ?? ev.start?.date ?? DateTime.now();
    final end = ev.end?.dateTime ?? ev.end?.date ?? start;
    return PfCalendarEvent(
      id: ev.id,
      title: ev.summary ?? '',
      description: ev.description,
      start: start,
      end: end,
      allDay: ev.start?.date != null,
      sourceId: ev.extendedProperties?.private?['pfSourceId'],
    );
  }
}

/// Minimal [http.Client] that injects Google auth headers on each request.
class _AuthClient extends http.BaseClient {
  _AuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
