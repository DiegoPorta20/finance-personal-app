import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/auth/domain/auth_state.dart';

void main() {
  group('AuthState', () {
    test('default state is not authenticated', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.token, isNull);
      expect(state.userId, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates fields correctly', () {
      const state = AuthState();
      final updated = state.copyWith(
        isAuthenticated: true,
        token: 'test-token',
        userId: 'user-1',
      );

      expect(updated.isAuthenticated, true);
      expect(updated.token, 'test-token');
      expect(updated.userId, 'user-1');
      expect(updated.isLoading, false);
    });

    test('copyWith preserves unchanged fields', () {
      const state = AuthState(
        isAuthenticated: true,
        token: 'token',
        userId: 'user-1',
      );
      final updated = state.copyWith(isLoading: true);

      expect(updated.isAuthenticated, true);
      expect(updated.token, 'token');
      expect(updated.userId, 'user-1');
      expect(updated.isLoading, true);
    });

    test('copyWith clears error when set to null', () {
      const state = AuthState(error: 'some error');
      final updated = state.copyWith(error: null);

      expect(updated.error, isNull);
    });

    test('loading state', () {
      const state = AuthState();
      final loading = state.copyWith(isLoading: true, error: null);

      expect(loading.isLoading, true);
      expect(loading.error, isNull);
      expect(loading.isAuthenticated, false);
    });

    test('error state', () {
      const state = AuthState();
      final errored = state.copyWith(
        isLoading: false,
        error: 'Invalid credentials',
      );

      expect(errored.isLoading, false);
      expect(errored.error, 'Invalid credentials');
      expect(errored.isAuthenticated, false);
    });
  });
}
