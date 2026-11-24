import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/models/enums.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/l10n.dart';
import '../features/accounts/account_editor_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/backup/backup_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/recurring/recurring_editor_screen.dart';
import '../features/recurring/recurring_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/spaces/spaces_screen.dart';
import '../features/transactions/transaction_editor_screen.dart';
import '../features/transactions/transactions_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!settings.onboardingComplete) {
        return atOnboarding ? null : '/onboarding';
      }
      if (atOnboarding) {
        return '/dashboard';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/transaction/new',
        builder: (context, state) {
          final type = switch (state.uri.queryParameters['type']) {
            'income' => TxnType.income,
            'transfer' => TxnType.transfer,
            _ => TxnType.expense,
          };
          return TransactionEditorScreen(initialType: type);
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) => TransactionEditorScreen(
          txnId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/account/new',
        builder: (context, state) => const AccountEditorScreen(),
      ),
      GoRoute(
        path: '/account/:id',
        builder: (context, state) => AccountEditorScreen(
          accountId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/spaces',
        builder: (context, state) => const SpacesScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/recurring/new',
        builder: (context, state) => const RecurringEditorScreen(),
      ),
      GoRoute(
        path: '/recurring/:id',
        builder: (context, state) => RecurringEditorScreen(
          ruleId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/backup',
        builder: (context, state) => const BackupScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.explore_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.pageNotFound,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(l10n.backToDashboard),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  ref.onDispose(router.dispose);
  return router;
});
