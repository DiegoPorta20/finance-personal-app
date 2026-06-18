import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/application/accounts_provider.dart';
import '../../../accounts/domain/account_model.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../categories/domain/category_model.dart';
import '../../../dashboard/application/dashboard_provider.dart';
import '../../application/transactions_provider.dart';
import '../../domain/transaction_model.dart';

class CreateTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const CreateTransactionSheet({super.key, this.transaction});

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

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _amountController.text = (t.amount / 100).toStringAsFixed(2);
      _type = t.type;
      _selectedAccountId = t.accountId;
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
      if (t.note != null) _noteController.text = t.note!;
    }
  }

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
            Text(_isEditing ? 'Editar transaccion' : 'Nueva transaccion',
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
              data: (accounts) => _buildSelector<Account>(
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
              data: (categories) => _buildSelector<Category>(
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
                disabledForegroundColor: context.cTextSecondary,
              ),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector<T>({
    required List<T> items,
    required String? value,
    required String hint,
    required IconData icon,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required ValueChanged<String?> onChanged,
  }) {
    String? selectedLabel;
    for (final item in items) {
      if (getId(item) == value) {
        selectedLabel = getLabel(item);
        break;
      }
    }
    return InkWell(
      onTap: () => _openPicker<T>(
        title: hint,
        items: items,
        value: value,
        getId: getId,
        getLabel: getLabel,
        onChanged: onChanged,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
              child: Text(
                selectedLabel ?? hint,
                style: TextStyle(
                  color: selectedLabel == null
                      ? context.cTextSecondary
                      : context.cTextPrimary,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: context.cTextSecondary),
          ],
        ),
      ),
    );
  }

  void _openPicker<T>({
    required String title,
    required List<T> items,
    required String? value,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required ValueChanged<String?> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: items.map((item) {
                    final selected = getId(item) == value;
                    return ListTile(
                      title: Text(getLabel(item),
                          style: TextStyle(
                            color: context.cTextPrimary,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                      trailing: selected
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () {
                        onChanged(getId(item));
                        Navigator.of(ctx).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.accent,
                  onPrimary: Colors.black,
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
    final notifier = ref.read(transactionsProvider.notifier);
    final note = _noteController.text.trim().isNotEmpty
        ? _noteController.text.trim()
        : null;
    final transaction = widget.transaction;

    if (transaction == null) {
      await notifier.addTransaction(
        type: _type,
        amount: (amountDouble * 100).round(),
        date: _selectedDate.toIso8601String(),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        note: note,
      );
    } else {
      await notifier.updateTransaction(
        id: transaction.id,
        type: _type,
        amount: (amountDouble * 100).round(),
        date: _selectedDate.toIso8601String(),
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId!,
        note: note,
      );
    }
    if (!mounted) return;
    // Refrescar dashboard y cuentas (el balance cambia).
    ref.invalidate(dashboardProvider);
    ref.invalidate(accountsProvider);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(transaction == null
            ? 'Transaccion registrada'
            : 'Transaccion actualizada'),
      ),
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
