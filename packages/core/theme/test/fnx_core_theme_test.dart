import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_theme/fnx_core_theme.dart';

void main() {
  test('FnxTheme.light builds Material 3 light theme', () {
    final theme = FnxTheme.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
  });

  test('FnxTheme.dark builds Material 3 dark theme', () {
    final theme = FnxTheme.dark();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
  });
}
