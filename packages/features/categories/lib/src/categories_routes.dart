// go_router route table for the categories feature.

import 'package:go_router/go_router.dart';

import 'pages/categories_list_page.dart';
import 'pages/category_form_page.dart';

/// Route path: categories list.
const String kCategoriesListPath = '/categories';

/// Route path: new category.
const String kCategoryNewPath = '/categories/new';

/// Route path: edit category (`:id`).
const String kCategoryEditPath = '/categories/:id/edit';

/// Returns the go_router routes for the categories feature.
List<RouteBase> categoriesRoutes() {
  return <RouteBase>[
    GoRoute(
      path: kCategoriesListPath,
      name: 'categoriesList',
      builder: (context, state) => const CategoriesListPage(),
    ),
    GoRoute(
      path: kCategoryNewPath,
      name: 'categoryNew',
      builder: (context, state) => const CategoryFormPage(),
    ),
    GoRoute(
      path: kCategoryEditPath,
      name: 'categoryEdit',
      builder: (context, state) =>
          CategoryFormPage(categoryId: state.pathParameters['id']),
    ),
  ];
}
