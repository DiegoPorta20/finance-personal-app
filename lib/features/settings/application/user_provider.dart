import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, Map<String, dynamic>>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final repo = ref.read(userRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.updateProfile(data);
    ref.invalidateSelf();
  }
}
