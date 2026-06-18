import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category_model.dart';
import '../data/categories_repository.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.read(categoriesRepositoryProvider);
  final data = await repo.getAll();
  return data.map(Category.fromJson).toList();
});

final expenseCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoriesProvider).whenData(
        (cats) => cats.where((c) => c.type == 'expense').toList(),
      );
});

final incomeCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoriesProvider).whenData(
        (cats) => cats.where((c) => c.type == 'income').toList(),
      );
});
