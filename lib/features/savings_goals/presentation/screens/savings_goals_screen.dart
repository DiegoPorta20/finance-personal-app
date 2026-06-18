import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/savings_goals_provider.dart';
import '../../domain/savings_goal_model.dart';
import '../../../accounts/application/accounts_provider.dart';
import '../../../accounts/domain/account_model.dart';
import '../../../dashboard/application/dashboard_provider.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Ahorro')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showGoalSheet(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: goalsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) => const Center(child: Text('Error al cargar metas')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_outlined,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text('Sin metas aun',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Crea tu primera meta de ahorro',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () =>
                ref.read(savingsGoalsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GestureDetector(
                  onTap: () => _showGoalSheet(context, ref, goal: goal),
                  child: _GoalCard(goal: goal),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showGoalSheet(BuildContext context, WidgetRef ref,
      {SavingsGoal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalSheet(ref: ref, goal: goal),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final SavingsGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressPercent = (goal.progress * 100).toInt();
    final dateFormat = DateFormat('dd MMM yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(goal.name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$progressPercent%',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress ring
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _GoalRingPainter(progress: goal.progress),
                  child: Center(
                    child: Icon(
                      Icons.flag,
                      color: AppColors.accent
                          .withValues(alpha: 0.5 + goal.progress * 0.5),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ahorrado',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      CurrencyFormatter.formatDefault(goal.currentAmount),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Meta',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      CurrencyFormatter.formatDefault(goal.targetAmount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (goal.deadline != null) ...[
              const SizedBox(height: 8),
              Text(
                'Fecha limite: ${dateFormat.format(goal.deadline!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (goal.progress < 1.0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFundsDialog(context, ref, goal),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Abonar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(
      BuildContext context, WidgetRef ref, SavingsGoal goal) {
    final controller = TextEditingController();
    final accounts = ref.read(accountsProvider).valueOrNull ?? <Account>[];
    String? accountId = accounts.isNotEmpty ? accounts.first.id : null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: context.cCard,
          title: const Text('Abonar a meta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Monto (ej: 100.00)'),
                style: TextStyle(color: context.cTextPrimary),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              if (accounts.isEmpty)
                Text('No tienes cuentas para descontar',
                    style: TextStyle(color: context.cTextSecondary))
              else
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: accountId,
                    isExpanded: true,
                    dropdownColor: context.cCard,
                    items: accounts
                        .map((Account a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('Desde ${a.name}',
                                  style:
                                      TextStyle(color: context.cTextPrimary)),
                            ))
                        .toList(),
                    onChanged: (v) => setLocal(() => accountId = v),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancelar',
                  style: TextStyle(color: context.cTextSecondary)),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                if (amount == null || amount <= 0) return;
                ref
                    .read(savingsGoalsProvider.notifier)
                    .addFunds(goal.id, (amount * 100).round(), accountId);
                ref.invalidate(dashboardProvider);
                ref.invalidate(accountsProvider);
                Navigator.of(ctx).pop();
              },
              child: const Text('Abonar',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  final double progress;

  _GoalRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GoalRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GoalSheet extends StatefulWidget {
  final WidgetRef ref;
  final SavingsGoal? goal;

  const _GoalSheet({required this.ref, this.goal});

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    if (goal != null) {
      _nameController.text = goal.name;
      _amountController.text = (goal.targetAmount / 100).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
          Text(_isEditing ? 'Editar meta' : 'Nueva meta de ahorro',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Nombre de la meta'),
            style: TextStyle(color: context.cTextPrimary),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              hintText: 'Monto objetivo (ej: 5000.00)',
              prefixIcon:
                  Icon(Icons.attach_money, color: AppColors.textSecondary),
            ),
            style: TextStyle(color: context.cTextPrimary),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final amountText = _amountController.text.trim();
              if (name.isEmpty || amountText.isEmpty) return;
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) return;
              final notifier =
                  widget.ref.read(savingsGoalsProvider.notifier);
              final goal = widget.goal;
              if (goal == null) {
                notifier.addGoal(name, (amount * 100).round(), null);
              } else {
                notifier.updateGoal(goal.id, name, (amount * 100).round());
              }
              Navigator.of(context).pop();
            },
            child: Text(_isEditing ? 'Guardar cambios' : 'Crear meta'),
          ),
        ],
      ),
    );
  }
}
