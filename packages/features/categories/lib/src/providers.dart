// Riverpod providers for the categories feature.
//
// The repository is wired to an in-memory stub by default so the feature
// works end-to-end on Web before the data layer is connected. Override
// [categoriesRepositoryProvider] in app composition with a real
// `CategoriesRepository` to swap in persistence.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import 'data/in_memory_categories_repository.dart';

/// Provides the active [CategoriesRepository].
///
/// Apps must override this with a real implementation in their composition
/// root (e.g. one backed by `pf_data_local`).
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  // TODO(F-cat): replace with real repository wired in app composition.
  return InMemoryCategoriesRepository.seeded();
});

/// Provides the current user's ULID for category scoping.
///
/// Overridden by the auth feature once a session is established.
final currentUserIdProvider = Provider<Ulid>((ref) {
  // TODO(F-auth): provide real user id from auth controller.
  return Ulid('00000000000000000000000000');
});
