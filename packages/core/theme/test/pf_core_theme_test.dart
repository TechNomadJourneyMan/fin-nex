import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_theme/pf_core_theme.dart';

void main() {
  test('PfTheme.light builds Material 3 light theme', () {
    final theme = PfTheme.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
  });

  test('PfTheme.dark builds Material 3 dark theme', () {
    final theme = PfTheme.dark();
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
  });
}
