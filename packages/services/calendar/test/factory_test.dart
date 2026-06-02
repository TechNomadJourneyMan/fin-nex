import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';

void main() {
  group('createCalendarService', () {
    test('web -> GoogleCalendarService', () {
      final svc = createCalendarService(isWeb: true);
      expect(svc, isA<GoogleCalendarService>());
    });

    test('non-web -> DeviceCalendarService', () {
      final svc = createCalendarService(isWeb: false);
      expect(svc, isA<DeviceCalendarService>());
    });
  });

  group('GoogleCalendarService without OAuth client id', () {
    test('requestPermission returns false when client id is empty', () async {
      // No GOOGLE_OAUTH_CLIENT_ID dart-define is set under `flutter test`,
      // so the empty-id branch must short-circuit to false (no sign-in).
      final svc = GoogleCalendarService(clientId: '');
      expect(await svc.requestPermission(), isFalse);
    });
  });
}
