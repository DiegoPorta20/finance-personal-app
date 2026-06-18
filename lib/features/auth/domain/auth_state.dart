class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userId,
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}
