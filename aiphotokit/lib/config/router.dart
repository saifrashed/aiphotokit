import 'package:go_router/go_router.dart';
import 'package:aiphotokit/ui/compose/view_model/compose_viewmodel.dart';
import 'package:aiphotokit/ui/compose/widgets/compose_screen.dart';
import 'package:aiphotokit/ui/home/view_model/home_viewmodel.dart';
import 'package:aiphotokit/ui/home/widgets/home_screen.dart';
import 'package:aiphotokit/ui/settings/view_models/settings_viewmodel.dart';
import 'package:aiphotokit/ui/settings/widgets/settings_screen.dart';
import 'package:provider/provider.dart';

GoRouter router() => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) => NoTransitionPage(
            child: HomeScreen(
              viewModel: HomeViewModel(imageService: context.read()),
            ),
          ),
    ),
    GoRoute(
      path: '/compose',
      pageBuilder: (context, state) {
        return NoTransitionPage(
          child: ComposeScreen(
            viewModel: ComposeViewmodel(imageService: context.read()),
          ),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder:
          (context, state) => NoTransitionPage(
            child: SettingsScreen(viewModel: SettingsViewmodel()),
          ),
    ),
  ],
);
