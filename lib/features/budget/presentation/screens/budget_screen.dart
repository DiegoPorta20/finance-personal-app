import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/budget_provider.dart';
import '../../data/budget_repository.dart';
import '../../domain/budget_model.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../categories/domain/category_model.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuesto')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        onPressed: () => _showBudgetSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Presupuesto'),
      ),
      body: budgetAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar presupuesto')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('Regla 50/30/20',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Ingreso: ${CurrencyFormatter.formatDefault(summary.totalIncome)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RulePill(
                          label: 'Esenciales', percent: '50%',
                          color: AppColors.accent),
                      _RulePill(
                          label: 'Estilo de vida', percent: '30%',
                          color: const Color(0xFF5AC8FA)),
                      _RulePill(
                          label: 'Ahorro', percent: '20%',
                          color: const Color(0xFFFF9500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(title: 'Esenciales (50%)'),
            ...summary.categories
                .where((c) => c.group == 'essentials')
                .map((c) => GestureDetector(
                      onTap: () => _showBudgetSheet(context, category: c),
                      child: _BudgetTile(category: c),
                    )),

            const SizedBox(height: 16),
            _SectionHeader(title: 'Estilo de vida (30%)'),
            ...summary.categories
                .where((c) => c.group == 'lifestyle')
                .map((c) => GestureDetector(
                      onTap: () => _showBudgetSheet(context, category: c),
                      child: _BudgetTile(category: c),
                    )),

            const SizedBox(height: 16),
            _SectionHeader(title: 'Ahorro (20%)'),
            ...summary.categories
                .where((c) => c.group == 'savings')
                .map((c) => GestureDetector(
                      onTap: () => _showBudgetSheet(context, category: c),
                      child: _BudgetTile(category: c),
                    )),
          ],
        ),
      ),
    );
  }
}

class _RulePill extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const _RulePill({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(percent,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final BudgetCategory category;

  const _BudgetTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final progressColor =
        category.isOverBudget ? AppColors.error : AppColors.accent;
    final clampedProgress = category.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category.categoryName,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${CurrencyFormatter.formatDefault(category.spentAmount)}'
                  ' / ${CurrencyFormatter.formatDefault(category.budgetAmount)}',
                  style: TextStyle(
                    color: category.isOverBudget
                        ? AppColors.error
                        : context.cTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: context.cDivider,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showBudgetSheet(BuildContext context, {BudgetCategory? category}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.cCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _BudgetSheet(category: category),
  );
}

class _BudgetSheet extends ConsumerStatefulWidget {
  final BudgetCategory? category;

  const _BudgetSheet({this.category});

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    if (c != null) {
      _amountController.text = (c.budgetAmount / 100).toStringAsFixed(2);
      _selectedCategoryId = c.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    final category = widget.category;
    if (category == null && _selectedCategoryId == null) return;
    final repo = ref.read(budgetRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final now = DateTime.now();
    try {
      if (category == null) {
        await repo.create({
          'amount': (amount * 100).round(),
          'month': now.month,
          'year': now.year,
          'categoryId': _selectedCategoryId,
        });
      } else {
        await repo.update(category.budgetId, (amount * 100).round());
      }
      ref.invalidate(budgetProvider);
      if (mounted) navigator.pop();
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Ya existe un presupuesto para esa categoria')));
      }
    }
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;
    final repo = ref.read(budgetRepositoryProvider);
    final navigator = Navigator.of(context);
    await repo.delete(category.budgetId);
    ref.invalidate(budgetProvider);
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
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
          Text(_isEditing ? 'Editar presupuesto' : 'Definir presupuesto',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          if (_isEditing)
            Text(widget.category!.categoryName,
                style: Theme.of(context).textTheme.titleMedium)
          else
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Error cargando categorias'),
              data: (cats) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.cCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.cDivider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: Text('Selecciona una categoria',
                        style: TextStyle(color: context.cTextSecondary)),
                    dropdownColor: context.cCard,
                    items: cats
                        .map((Category c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name,
                                  style:
                                      TextStyle(color: context.cTextPrimary)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              hintText: 'Limite mensual (ej: 500.00)',
              prefixIcon:
                  Icon(Icons.attach_money, color: AppColors.textSecondary),
            ),
            style: TextStyle(color: context.cTextPrimary),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isEditing ? 'Guardar' : 'Crear presupuesto'),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text('Eliminar',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ],
      ),
    );
  }
}
