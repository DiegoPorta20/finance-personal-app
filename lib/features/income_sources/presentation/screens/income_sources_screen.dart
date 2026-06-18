import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/application/accounts_provider.dart';
import '../../../accounts/domain/account_model.dart';
import '../../application/income_sources_provider.dart';
import '../../domain/income_source_model.dart';

class IncomeSourcesScreen extends ConsumerWidget {
  const IncomeSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(incomeSourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos Recurrentes')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showSourceSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: sourcesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar ingresos')),
        data: (sources) {
          if (sources.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text('Sin ingresos configurados',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              return GestureDetector(
                onTap: () => _showSourceSheet(context, ref, source: source),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up,
                            color: AppColors.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(source.name,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            Text(
                              '${source.typeLabel} · ${source.periodicityLabel}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatDefault(source.amount),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          );
        },
      ),
    );
  }

  void _showSourceSheet(BuildContext context, WidgetRef ref,
      {IncomeSource? source}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _IncomeSourceSheet(source: source),
    );
  }
}

class _IncomeSourceSheet extends ConsumerStatefulWidget {
  final IncomeSource? source;

  const _IncomeSourceSheet({this.source});

  @override
  ConsumerState<_IncomeSourceSheet> createState() =>
      _IncomeSourceSheetState();
}

class _IncomeSourceSheetState extends ConsumerState<_IncomeSourceSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'salary';
  String _periodicity = 'monthly';
  String? _accountId;

  bool get _isEditing => widget.source != null;

  @override
  void initState() {
    super.initState();
    final source = widget.source;
    if (source != null) {
      _nameController.text = source.name;
      _amountController.text = (source.amount / 100).toStringAsFixed(2);
      _type = source.type;
      _periodicity = source.periodicity;
      _accountId = source.accountId;
    }
  }

  static const _types = [
    ('salary', 'Sueldo fijo'),
    ('freelance', 'Freelance'),
    ('rent_income', 'Renta'),
    ('investment', 'Inversiones'),
    ('other_income', 'Otros'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(_isEditing ? 'Editar ingreso' : 'Nuevo ingreso recurrente',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Nombre'),
              style: TextStyle(color: context.cTextPrimary),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(hintText: 'Monto (ej: 3000.00)'),
              style: TextStyle(color: context.cTextPrimary),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            // Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.cCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _type,
                  dropdownColor: context.cCard,
                  isExpanded: true,
                  items: _types.map((t) {
                    return DropdownMenuItem(
                      value: t.$1,
                      child: Text(t.$2,
                          style:
                              TextStyle(color: context.cTextPrimary)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Periodicity
            Row(
              children: [
                for (final p in [
                  ('weekly', 'Semanal'),
                  ('biweekly', 'Quincenal'),
                  ('monthly', 'Mensual'),
                ])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _periodicity = p.$1),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _periodicity == p.$1
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : context.cBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _periodicity == p.$1
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(p.$2,
                              style: TextStyle(
                                color: _periodicity == p.$1
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Account
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Error'),
              data: (accounts) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.cCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _accountId,
                    hint: const Text('Cuenta destino',
                        style: TextStyle(color: AppColors.textSecondary)),
                    dropdownColor: context.cCard,
                    isExpanded: true,
                    items: accounts.map((Account a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name,
                            style: const TextStyle(
                                color: context.cTextPrimary)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _accountId = v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Guardar cambios' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    if (name.isEmpty || amountText.isEmpty || _accountId == null) return;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final data = {
      'name': name,
      'type': _type,
      'amount': (amount * 100).round(),
      'periodicity': _periodicity,
      'accountId': _accountId,
    };
    final notifier = ref.read(incomeSourcesProvider.notifier);
    final source = widget.source;
    if (source == null) {
      notifier.add({...data, 'nextDate': DateTime.now().toIso8601String()});
    } else {
      notifier.updateSource(source.id, data);
    }
    Navigator.of(context).pop();
  }
}
