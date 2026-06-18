import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/application/auth_provider.dart';
import '../../application/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final currency = profileAsync.valueOrNull?['currency'] as String? ?? 'USD';
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final name = profileAsync.valueOrNull?['name'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Perfil',
                subtitle: name.isNotEmpty ? name : null,
                onTap: () => context.push('/settings/profile'),
              ),
              _SettingsTile(
                icon: Icons.attach_money,
                title: 'Moneda predeterminada',
                subtitle: currency,
                onTap: () => context.push('/settings/profile'),
              ),
              _SettingsTile(
                icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                title: 'Tema',
                subtitle: isDark ? 'Oscuro' : 'Claro',
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: 'Finanzas',
            children: [
              _SettingsTile(
                icon: Icons.category_outlined,
                title: 'Categorias',
                onTap: () => context.push('/settings/categories'),
              ),
              _SettingsTile(
                icon: Icons.repeat,
                title: 'Ingresos recurrentes',
                onTap: () => context.push('/income-sources'),
              ),
              _SettingsTile(
                icon: Icons.pie_chart_outline,
                title: 'Regla de presupuesto',
                subtitle: '50/30/20',
                onTap: () => context.push('/budget'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: 'Notificaciones',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Ver notificaciones',
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.cCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: context.cTextPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary))
          : null,
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
