// Widget test for [CategoryFormPage] create-mode save.
//
// Fills the name field and taps Save, then asserts the category was persisted
// to the repository with the entered name. The form pops via go_router on
// success, so it is mounted inside a minimal GoRouter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:pf_domain/domain.dart';

import 'package:pf_feat_categories/pf_feat_categories.dart';
import 'package:pf_feat_categories/src/data/in_memory_categories_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create-mode save persists a new category',
      (WidgetTester tester) async {
    // Tall surface so the Save button (bottom of a lazy ListView) is built.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final InMemoryCategoriesRepository repo = InMemoryCategoriesRepository();

    // The form is mounted under a /list parent so its post-save context.pop()
    // has a route to return to.
    final GoRouter router = GoRouter(
      initialLocation: '/list/add',
      routes: <RouteBase>[
        GoRoute(
          path: '/list',
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('list-root'))),
          routes: <RouteBase>[
            GoRoute(
              path: 'add',
              builder: (_, __) => const CategoryFormPage(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          categoriesRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          theme: PfTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: PfLocales.all,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CategoryFormPage), findsOneWidget);

    // Enter a name.
    await tester.enterText(find.byType(TextField).first, 'Subscriptions');
    await tester.pumpAndSettle();

    // Scroll the Save button (bottom of the ListView) into view, then tap it.
    // PfButton renders its label as plain Text.
    final Finder saveBtn = find.text('Save');
    await tester.scrollUntilVisible(
      saveBtn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // currentUserIdProvider defaults to a fixed ULID; the in-memory repo
    // ignores the userId filter anyway.
    final List<Category> rows =
        await repo.watchAll(Ulid('00000000000000000000000000')).first;
    final Iterable<Category> created =
        rows.where((Category c) => c.name == 'Subscriptions' && !c.isSystem);
    expect(
      created,
      isNotEmpty,
      reason: 'the new custom category should be persisted',
    );
  });
}
