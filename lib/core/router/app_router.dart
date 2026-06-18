import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/savings_goals/presentation/screens/savings_goals_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/income_sources/presentation/screens/income_sources_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/recommendations/presentation/screens/recommendations_screen.dart';
import '../../features/transactions/presentation/widgets/create_transaction_sheet.dart';
import '../../features/auth/application/auth_provider.dart';
import '../theme/app_theme.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Mientras se restaura la sesión desde el almacenamiento seguro.
      if (!authState.isInitialized) {
        return loc == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authState.isAuthenticated;

      if (!isLoggedIn) {
        return loc == '/login' ? null : '/login';
      }

      // Autenticado: salir del splash/login hacia el dashboard.
      if (loc == '/splash' || loc == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell with persistent bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            _ShellScaffold(state: state, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Screens without bottom nav (pushed on top)
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/savings-goals',
        builder: (context, state) => const SavingsGoalsScreen(),
      ),
      GoRoute(
        path: '/income-sources',
        builder: (context, state) => const IncomeSourcesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _ShellScaffold({required this.state, required this.child});

  static const _slots = [
    ('/dashboard', Icons.home_rounded),
    ('/transactions', Icons.swap_horiz_rounded),
    ('/reports', Icons.show_chart_rounded),
    ('__more__', Icons.grid_view_rounded),
  ];

  int get _currentIndex {
    final location = state.matchedLocation;
    if (location == '/dashboard') return 0;
    if (location == '/transactions') return 1;
    if (location == '/reports') return 2;
    return 3;
  }

  void _onSlotTap(BuildContext context, int index) {
    final route = _slots[index].$1;
    if (route == '__more__') {
      _showMoreMenu(context);
    } else {
      context.go(route);
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        const items = [
          ('/budget', Icons.pie_chart_rounded, 'Presupuesto'),
          ('/settings', Icons.settings_rounded, 'Ajustes'),
          ('/accounts', Icons.account_balance_wallet_rounded, 'Cuentas'),
          ('/savings-goals', Icons.savings_rounded, 'Metas de ahorro'),
          ('/income-sources', Icons.payments_rounded, 'Fuentes de ingreso'),
          ('/recommendations', Icons.lightbulb_outline, 'Recomendaciones'),
          ('/notifications', Icons.notifications_rounded, 'Notificaciones'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.cDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                for (final item in items)
                  ListTile(
                    leading: Icon(item.$2, color: AppColors.accent),
                    title: Text(item.$3,
                        style: TextStyle(color: context.cTextPrimary)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      final route = item.$1;
                      // Presupuesto/Ajustes viven en el shell (conservan la
                      // barra); las demás son independientes (con back).
                      if (route == '/budget' || route == '/settings') {
                        context.go(route);
                      } else {
                        context.push(route);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // El botón central (+) abre el formulario de nueva transacción
  // desde cualquier pantalla.
  void _showCreateTransaction(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTransactionSheet(),
    );
  }

  Widget _navIcon(BuildContext context, int index) {
    final active = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onSlotTap(context, index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            _slots[index].$2,
            size: 26,
            color: active ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTransaction(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: context.cCard,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _navIcon(context, 0),
            _navIcon(context, 1),
            const SizedBox(width: 56), // hueco para el FAB
            _navIcon(context, 2),
            _navIcon(context, 3),
          ],
        ),
      ),
    );
  }
}
