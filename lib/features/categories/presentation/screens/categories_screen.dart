import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/categories_provider.dart';
import '../../data/categories_repository.dart';
import '../../domain/category_model.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddCategory(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar categorias')),
        data: (cats) {
          final expense = cats.where((c) => c.type == 'expense').toList();
          final income = cats.where((c) => c.type == 'income').toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _section(context, 'Gastos', expense),
              const SizedBox(height: 20),
              _section(context, 'Ingresos', income),
            ],
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Category> cats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (cats.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Sin categorias',
                style: Theme.of(context).textTheme.bodyMedium),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: cats
                  .map((c) => ListTile(
                        leading:
                            Icon(_iconFor(c.icon), color: AppColors.accent),
                        title: Text(c.name,
                            style: Theme.of(context).textTheme.titleMedium),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showAddCategory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddCategorySheet(),
    );
  }

  IconData _iconFor(String icon) {
    return switch (icon) {
      'home' => Icons.home,
      'restaurant' => Icons.restaurant,
      'directions_car' => Icons.directions_car,
      'movie' => Icons.movie,
      'local_hospital' => Icons.local_hospital,
      'credit_card' => Icons.credit_card,
      'autorenew' => Icons.autorenew,
      'school' => Icons.school,
      'payments' => Icons.payments,
      'work' => Icons.work,
      'home_work' => Icons.home_work,
      'trending_up' => Icons.trending_up,
      _ => Icons.more_horiz,
    };
  }
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _type = 'expense';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    await ref.read(categoriesRepositoryProvider).create({
      'slug': slug,
      'name': name,
      'type': _type,
      'icon': 'more_horiz',
    });
    ref.invalidate(categoriesProvider);
    if (mounted) Navigator.of(context).pop();
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
          Text('Nueva categoria',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Nombre'),
            style: Theme.of(context).textTheme.bodyLarge,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _typeButton('Gasto', 'expense'),
              const SizedBox(width: 12),
              _typeButton('Ingreso', 'income'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Crear categoria'),
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String label, String value) {
    final selected = _type == value;
    final color = value == 'income' ? AppColors.accent : AppColors.error;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ),
    );
  }
}
