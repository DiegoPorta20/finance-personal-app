import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/account_model.dart';
import '../data/accounts_repository.dart';

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    final repo = ref.read(accountsRepositoryProvider);
    final data = await repo.getAll();
    return data.map(Account.fromJson).toList();
  }

  Future<void> addAccount(String name, String type, String currency) async {
    final repo = ref.read(accountsRepositoryProvider);
    await repo.create({'name': name, 'type': type, 'currency': currency});
    ref.invalidateSelf();
  }

  Future<void> deleteAccount(String id) async {
    final repo = ref.read(accountsRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
