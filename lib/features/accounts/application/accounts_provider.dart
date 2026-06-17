import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/account_model.dart';

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    // TODO: Replace with AccountsRepository call
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockAccounts();
  }

  Future<void> addAccount(String name, String type, String currency) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final current = state.valueOrNull ?? [];
      final newAccount = Account(
        id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        currency: currency,
        balance: 0,
      );
      return [...current, newAccount];
    });
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      final current = state.valueOrNull ?? [];
      return current.where((a) => a.id != id).toList();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockAccounts();
    });
  }

  List<Account> _mockAccounts() {
    return const [
      Account(
        id: '1',
        name: 'Banco Principal',
        type: 'bank',
        currency: 'USD',
        balance: 850000,
      ),
      Account(
        id: '2',
        name: 'Efectivo',
        type: 'cash',
        currency: 'USD',
        balance: 250000,
      ),
      Account(
        id: '3',
        name: 'Billetera Digital',
        type: 'digital_wallet',
        currency: 'USD',
        balance: 150000,
      ),
    ];
  }
}
