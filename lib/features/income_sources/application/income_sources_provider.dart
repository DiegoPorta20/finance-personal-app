import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/income_source_model.dart';
import '../data/income_sources_repository.dart';

final incomeSourcesProvider =
    AsyncNotifierProvider<IncomeSourcesNotifier, List<IncomeSource>>(
  IncomeSourcesNotifier.new,
);

class IncomeSourcesNotifier extends AsyncNotifier<List<IncomeSource>> {
  @override
  Future<List<IncomeSource>> build() async {
    final repo = ref.read(incomeSourcesRepositoryProvider);
    final data = await repo.getAll();
    return data.map(IncomeSource.fromJson).toList();
  }

  Future<void> add(Map<String, dynamic> data) async {
    final repo = ref.read(incomeSourcesRepositoryProvider);
    await repo.create(data);
    ref.invalidateSelf();
  }

  Future<void> updateSource(String id, Map<String, dynamic> data) async {
    final repo = ref.read(incomeSourcesRepositoryProvider);
    await repo.update(id, data);
    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(incomeSourcesRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
