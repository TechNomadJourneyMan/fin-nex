// go_router route table for the workspaces feature (F-06 client).

import 'package:go_router/go_router.dart';

import 'pages/create_workspace_page.dart';

/// Route path: create a new workspace.
const String kCreateWorkspacePath = '/workspaces/new';

/// Returns the go_router routes for the workspaces feature.
List<RouteBase> workspacesRoutes() {
  return <RouteBase>[
    GoRoute(
      path: kCreateWorkspacePath,
      name: 'createWorkspace',
      builder: (context, state) => const CreateWorkspacePage(),
    ),
  ];
}
