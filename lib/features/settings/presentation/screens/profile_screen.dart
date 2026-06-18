import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  String _currency = 'USD';
  bool _initialized = false;

  static const _currencies = ['USD', 'PEN', 'EUR', 'MXN', 'COP', 'ARS', 'CLP'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(userProfileProvider.notifier).updateProfile({
      'name': name,
      'currency': _currency,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar el perfil')),
        data: (profile) {
          if (!_initialized) {
            _nameController.text = profile['name'] as String? ?? '';
            final c = profile['currency'] as String? ?? 'USD';
            _currency = _currencies.contains(c) ? c : 'USD';
            _initialized = true;
          }
          final email = profile['email'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (email.isNotEmpty) ...[
                Text('Correo', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(email, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
              ],
              Text('Nombre', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Tu nombre'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text('Moneda predeterminada',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currency,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardTheme.color,
                    items: _currencies
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _currency = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
