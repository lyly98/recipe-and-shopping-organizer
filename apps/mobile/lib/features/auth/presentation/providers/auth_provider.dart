import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/providers/auth_providers.dart';

// Auth state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier
// Auth notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // Check auth status: restore token from storage and validate with API.
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final authRepo = ref.read(authRepositoryProvider);
    final isAuthResult = await authRepo.isAuthenticated();
    isAuthResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          errorMessage: failure.message,
        );
      },
      (isAuthenticated) async {
        if (!isAuthenticated) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
            user: null,
          );
          return;
        }
        // Restore token on ApiClient so subsequent API calls are authenticated
        final secureStorage = ref.read(secureStorageServiceProvider);
        final token = await secureStorage.read(key: AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          ref.read(apiClientProvider).setToken(token);
        }
        final userResult = await authRepo.getCurrentUser();
        userResult.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: false,
              user: null,
              errorMessage: failure.message,
            );
          },
          (user) {
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              user: user,
              errorMessage: null,
            );
          },
        );
      },
    );
  }

  /// Returns [null] on success, or the error message on failure.
  /// Caller can use this after await without reading [ref] (safe when widget is unmounted).
  Future<String?> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase.execute(email: email, password: password);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          errorMessage: null,
        );
        return null;
      },
    );
  }

  /// Returns [null] on success, or the error message on failure.
  /// Caller can use this after await without reading [ref] (safe when widget is unmounted).
  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase.execute(
      email: email,
      username: username,
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: failure.message,
        );
        return failure.message;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          errorMessage: null,
        );
        return null;
      },
    );
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final logoutUseCase = ref.read(logoutUseCaseProvider);
    final result = await logoutUseCase.execute();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) {
        ref.read(apiClientProvider).removeToken();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          errorMessage: null,
        );
      },
    );
  }
}

// Auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
