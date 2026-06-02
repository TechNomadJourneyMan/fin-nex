// Native / VM implementation: the Flutter test harness sets FLUTTER_TEST=true.
import 'dart:io' show Platform;

bool isFlutterTestImpl() =>
    Platform.environment.containsKey('FLUTTER_TEST') &&
    Platform.environment['FLUTTER_TEST'] != 'false';
