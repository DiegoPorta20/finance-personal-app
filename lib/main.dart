import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/utils/currency_formatter.dart';
import 'core/network/api_provider.dart';
import 'features/auth/application/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: FinanceApp()));
}

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Mantener el símbolo de moneda sincronizado con la config del usuario.
    CurrencyFormatter.symbol = ref.watch(currencySymbolProvider);
    // Auto-logout: si una request da 401 (token expirado), cerrar sesión.
    ref.read(apiClientProvider).onUnauthorized =
        () => ref.read(authProvider.notifier).logout();

    return MaterialApp.router(
      title: 'Finanzas Personales',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
