import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/list_skeleton.dart';
import '../../application/accounts_provider.dart';
import '../../domain/account_model.dart';
import '../../../dashboard/application/dashboard_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAccountSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: accountsAsync.when(
        loading: () => const ListSkeleton(),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Error al cargar cuentas',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(accountsProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text('Sin cuentas aun',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Agrega tu primera cuenta',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAccountSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear cuenta'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return GestureDetector(
                  onTap: () =>
                      _showAccountSheet(context, ref, account: account),
                  child: _AccountTile(account: account),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAccountSheet(BuildContext context, WidgetRef ref,
      {Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AccountSheet(ref: ref, account: account),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;

  const _AccountTile({required this.account});

  IconData get _icon => switch (account.type) {
        'bank' => Icons.account_balance,
        'cash' => Icons.money,
        'digital_wallet' => Icons.account_balance_wallet,
        _ => Icons.account_balance,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.cBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: context.cTextPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(account.typeLabel,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(account.balance, symbol: '\$'),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _AccountSheet extends StatefulWidget {
  final WidgetRef ref;
  final Account? account;

  const _AccountSheet({required this.ref, this.account});

  @override
  State<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<_AccountSheet> {
  final _nameController = TextEditingController();
  String _selectedType = 'bank';

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    if (account != null) {
      _nameController.text = account.name;
      _selectedType = account.type;
    }
  }

  static const _accountTypes = [
    ('bank', 'Banco', Icons.account_balance),
    ('cash', 'Efectivo', Icons.money),
    ('digital_wallet', 'Billetera Digital', Icons.account_balance_wallet),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_isEditing ? 'Editar cuenta' : 'Nueva cuenta',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Nombre de la cuenta'),
            style: TextStyle(color: context.cTextPrimary),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Text('Tipo de cuenta',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: _accountTypes.map((t) {
              final (type, label, icon) = t;
              final isSelected = type == _selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : context.cBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            size: 24),
                        const SizedBox(height: 4),
                        Text(label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              final notifier = widget.ref.read(accountsProvider.notifier);
              final account = widget.account;
              if (account == null) {
                notifier.addAccount(name, _selectedType, 'USD');
              } else {
                notifier.updateAccount(account.id, name, _selectedType);
              }
              Navigator.of(context).pop();
            },
            child: Text(_isEditing ? 'Guardar cambios' : 'Crear cuenta'),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text('Eliminar cuenta',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final account = widget.account;
    if (account == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar cuenta',
      message:
          'Se eliminara "${account.name}" y TODAS sus transacciones. '
          'Esta accion no se puede deshacer.',
    );
    if (!confirmed) return;
    await widget.ref.read(accountsProvider.notifier).deleteAccount(account.id);
    widget.ref.invalidate(dashboardProvider);
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Cuenta eliminada')),
    );
  }
}
