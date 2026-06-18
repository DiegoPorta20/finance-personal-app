import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/application/accounts_provider.dart';
import '../../../accounts/domain/account_model.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../categories/domain/category_model.dart';
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
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
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
                  color: AppColors.card,
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
                          const TextStyle(color: AppColors.textPrimary),
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
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(hint,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          dropdownColor: AppColors.card,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: getId(item),
              child: Text(getLabel(item),
                  style: const TextStyle(color: AppColors.textPrimary)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
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
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty ||
        _selectedAccountId == null ||
        _selectedCategoryId == null) {
      return;
    }

    final amountDouble = double.tryParse(amountText);
    if (amountDouble == null || amountDouble <= 0) {
      return;
    }

    ref.read(transactionsProvider.notifier).addTransaction(
          type: _type,
          amount: (amountDouble * 100).round(),
          date: _selectedDate.toIso8601String(),
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );
    Navigator.of(context).pop();
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
                : AppColors.background,
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
