import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/transactions_provider.dart';

class CreateTransactionSheet extends StatefulWidget {
  final WidgetRef ref;

  const CreateTransactionSheet({super.key, required this.ref});

  @override
  State<CreateTransactionSheet> createState() => _CreateTransactionSheetState();
}

class _CreateTransactionSheetState extends State<CreateTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
          Text('Nueva transaccion',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          // Type toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _type = 'expense'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _type == 'expense'
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _type == 'expense'
                            ? AppColors.error
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text('Gasto',
                          style: TextStyle(
                            color: _type == 'expense'
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _type = 'income'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _type == 'income'
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _type == 'income'
                            ? AppColors.accent
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text('Ingreso',
                          style: TextStyle(
                            color: _type == 'income'
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              hintText: 'Monto (ej: 150.00)',
              prefixIcon:
                  Icon(Icons.attach_money, color: AppColors.textSecondary),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          const SizedBox(height: 12),

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
    );
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    final amountDouble = double.tryParse(amountText);
    if (amountDouble == null || amountDouble <= 0) return;

    final amountCents = (amountDouble * 100).round();
    widget.ref.read(transactionsProvider.notifier).addTransaction(
          type: _type,
          amount: amountCents,
          date: DateTime.now().toIso8601String(),
          accountId: '1', // TODO: Let user pick account
          categoryId: _type == 'income' ? 'salary' : 'other_expense',
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );
    Navigator.of(context).pop();
  }
}
