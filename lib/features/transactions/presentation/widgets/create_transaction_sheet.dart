import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/application/accounts_provider.dart';
import '../../../accounts/domain/account_model.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../categories/domain/category_model.dart';
import '../../../dashboard/application/dashboard_provider.dart';
import '../../application/transactions_provider.dart';

class CreateTransactionSheet extends ConsumerStatefulWidget {
  const CreateTransactionSheet({super.key});

  @override
  ConsumerState<CreateTransactionSheet> createState() =>
      _CreateTransactionSheetState();
}

class _CreateTransactionSheetState
    extends ConsumerState<CreateTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = _type == 'expense'
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
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
            Text('Nueva transaccion',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),

            // Type toggle
            Row(
              children: [
                _TypeButton(
                  label: 'Gasto',
                  isSelected: _type == 'expense',
                  color: AppColors.error,
                  onTap: () => setState(() {
                    _type = 'expense';
                    _selectedCategoryId = null;
                  }),
                ),
                const SizedBox(width: 12),
                _TypeButton(
                  label: 'Ingreso',
                  isSelected: _type == 'income',
                  color: AppColors.accent,
                  onTap: () => setState(() {
                    _type = 'income';
                    _selectedCategoryId = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: 'Monto (ej: 150.00)',
                prefixIcon:
                    Icon(Icons.attach_money, color: AppColors.textSecondary),
              ),
              style: TextStyle(color: context.cTextPrimary),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Account selector
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) =>
                  const Text('Error cargando cuentas'),
              data: (accounts) => _buildDropdown<Account>(
                items: accounts,
                value: _selectedAccountId,
                hint: 'Seleccionar cuenta',
                icon: Icons.account_balance_wallet_outlined,
                getId: (a) => a.id,
                getLabel: (a) => a.name,
                onChanged: (id) => setState(() => _selectedAccountId = id),
              ),
            ),
            const SizedBox(height: 12),

            // Category selector
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) =>
                  const Text('Error cargando categorias'),
              data: (categories) => _buildDropdown<Category>(
                items: categories,
                value: _selectedCategoryId,
                hint: 'Seleccionar categoria',
                icon: Icons.category_outlined,
                getId: (c) => c.id,
                getLabel: (c) => c.name,
                onChanged: (id) =>
                    setState(() => _selectedCategoryId = id),
              ),
            ),
            const SizedBox(height: 12),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.cCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style:
                          TextStyle(color: context.cTextPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Nota (opcional)',
                prefixIcon: Icon(Icons.note_outlined,
                    color: AppColors.textSecondary),
              ),
              style: TextStyle(color: context.cTextPrimary),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isValid ? _submit : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: context.cDivider,
                disabledForegroundColor: AppColors.textSecondary,
              ),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required List<T> items,
    required String? value,
    required String hint,
    required IconData icon,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cDivider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(hint,
                    style: const TextStyle(color: AppColors.textSecondary)),
                dropdownColor: context.cCard,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: getId(item),
                    child: Text(getLabel(item),
                        style: TextStyle(color: context.cTextPrimary)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              surface: context.cCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text.trim());
    return amount != null &&
        amount > 0 &&
        _selectedAccountId != null &&
        _selectedCategoryId != null;
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    final amountDouble = double.parse(_amountController.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await ref.read(transactionsProvider.notifier).addTransaction(
          type: _type,
          amount: (amountDouble * 100).round(),
          date: _selectedDate.toIso8601String(),
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );
    if (!mounted) return;
    // Refrescar dashboard y cuentas (el balance cambia).
    ref.invalidate(dashboardProvider);
    ref.invalidate(accountsProvider);
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Transaccion registrada')),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : context.cBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ),
    );
  }
}
